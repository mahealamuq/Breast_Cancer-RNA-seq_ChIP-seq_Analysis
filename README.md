# Breast-Cancer-RNAseq-ChIPseq-analysis
Integrated RNA-seq and ChIP-seq analysis pipeline for MCF7 breast cancer cells to identify differential gene expression, histone modification peaks, and epigenetic regulation associated with breast cancer progression.

Complete integrated RNA-seq and ChIP-seq analysis pipeline using FastQC, HISAT2, Bowtie2, SAMtools, MACS2, featureCounts, and DESeq2 for identifying differentially expressed genes and histone modification peaks in MCF7 breast cancer cells.

This repository contains a complete bioinformatics workflow for integrating RNA-seq and ChIP-seq analysis to study epigenetic regulation in breast cancer. The pipeline identifies differentially expressed genes from RNA-seq data and histone modification peaks from ChIP-seq data, then integrates both datasets to investigate gene regulation in MCF7 breast cancer cells.

The workflow is designed for:
- RNA-seq differential expression analysis
- ChIP-seq peak calling
- Histone modification analysis
- Epigenetic regulation studies
- Breast cancer genomics research

## Table of contents

- [Introduction](#introduction)
- [Workflow Overview](#workflow-overview)
- [Software Requirements](#software-requirements)
- [Installation](#installation)
- [Data Download](#data-download)
- [Running the RNA-seq Pipeline](#running-the-rna-seq-pipeline)
- [Running the ChIP-seq Pipeline](#running-the-chip-seq-pipeline)
- [Peak Annotation](#peak-annotation)
- [Integrative Analysis](#integrative-analysis)
- [Visualization in IGV](#visualization-in-igv)
- [Results](#results)
- [References](#references)

# Breast Cancer RNA-seq & ChIP-seq Pipeline

## Introduction

This repository contains a complete integrated RNA-seq and ChIP-seq bioinformatics workflow for studying breast cancer epigenetic regulation using next-generation sequencing (NGS) data.

The project focuses on:
- MCF7 breast cancer cells
- Normal breast tissue
- Histone modifications
- Gene expression changes
- Epigenetic regulation

RNA sequencing (RNA-seq) is used to identify:
- Differentially expressed genes
- Upregulated cancer genes
- Downregulated genes
- Transcriptome-wide expression changes

ChIP sequencing (ChIP-seq) is used to identify:
- Histone modification peaks
- Active promoter regions
- Enhancer regions
- Regulatory chromatin marks

This workflow demonstrates:
- RNA-seq quality control and alignment
- ChIP-seq alignment and peak calling
- Differential expression analysis
- Histone peak annotation
- Integration of RNA-seq and ChIP-seq results
---

## Integrated Analysis

```text
RNA-seq Differential Expression
                +
ChIP-seq Histone Peaks
                ↓
Epigenetic Regulation Analysis
                ↓
Candidate Breast Cancer Genes
```

---

## Software Requirements

**Operating System**

- Ubuntu 20.04+ recommended

**Required Software**

| Software | Purpose |
|---|---|
| FastQC | Sequencing quality control |
| MultiQC | Aggregate QC reports |
| fastp | Read trimming |
| HISAT2 | RNA-seq alignment |
| Bowtie2 | ChIP-seq alignment |
| SAMtools | BAM processing |
| Picard | Duplicate removal |
| featureCounts | Gene quantification |
| MACS2 | Peak calling |
| BEDTools | Peak annotation |
| IGV | Genome visualization |
| R / DESeq2 | Differential expression analysis |

---

## Installation

### Update Ubuntu

```bash
sudo apt update
```

---

### Install Required Tools

```bash
sudo apt install -y \
fastqc \
hisat2 \
bowtie2 \
samtools \
bedtools \
subread \
default-jre \
python3-pip \
wget \
gzip
```

---

### Install MultiQC

```bash
pip3 install multiqc
```

---

### Install fastp

```bash
sudo apt install fastp
```

---

### Install MACS2

```bash
pip3 install MACS2
```

---

### Download Picard

```bash
wget https://github.com/broadinstitute/picard/releases/download/3.1.1/picard.jar
```

---

## Data Download

### Create Project Directory

```bash
mkdir -p breast_cancer_project/{raw_data,fastqc,trimmed,genome,index,bam,chipseq,counts,results,peaks,tracks,scripts}

cd breast_cancer_project
```

---

### Download Human Reference Genome

```bash
cd genome

wget https://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.fa.gz

gunzip hg19.fa.gz
```

---

### Build HISAT2 Index

```bash
cd ../index

hisat2-build ../genome/hg19.fa hg19_hisat2
```

---

### Build Bowtie2 Index

```bash
bowtie2-build ../genome/hg19.fa hg19_bowtie2
```

---

### Download RNA-seq Data

Examples:
- Normal sample = ERR358486
- MCF7 sample = ERR358487

```bash
cd ../raw_data

wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR358/ERR358486/ERR358486_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR358/ERR358486/ERR358486_2.fastq.gz

wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR358/ERR358487/ERR358487_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR358/ERR358487/ERR358487_2.fastq.gz
```

---

## Running the RNA-seq Pipeline

### Step 1: Quality Control

```bash
cd ../fastqc

fastqc ../raw_data/*.fastq.gz -o .
```

Generate combined report:

```bash
multiqc .
```

---

### Step 2: Read Trimming

```bash
cd ../trimmed

fastp \
-i ../raw_data/ERR358486_1.fastq.gz \
-I ../raw_data/ERR358486_2.fastq.gz \
-o normal_R1.trimmed.fastq.gz \
-O normal_R2.trimmed.fastq.gz
```

```bash
fastp \
-i ../raw_data/ERR358487_1.fastq.gz \
-I ../raw_data/ERR358487_2.fastq.gz \
-o mcf7_R1.trimmed.fastq.gz \
-O mcf7_R2.trimmed.fastq.gz
```

---

### Step 3: RNA-seq Alignment

```bash
cd ../bam

hisat2 \
-x ../index/hg19_hisat2 \
-1 ../trimmed/normal_R1.trimmed.fastq.gz \
-2 ../trimmed/normal_R2.trimmed.fastq.gz \
-S normal.sam
```

```bash
hisat2 \
-x ../index/hg19_hisat2 \
-1 ../trimmed/mcf7_R1.trimmed.fastq.gz \
-2 ../trimmed/mcf7_R2.trimmed.fastq.gz \
-S mcf7.sam
```

---

### Step 4: Convert SAM to BAM

```bash
samtools view -bS normal.sam | samtools sort -o normal.sorted.bam

samtools view -bS mcf7.sam | samtools sort -o mcf7.sorted.bam
```

---

### Step 5: Index BAM Files

```bash
samtools index normal.sorted.bam

samtools index mcf7.sorted.bam
```

---

### Step 6: Gene Quantification

```bash
cd ../counts

featureCounts \
-p \
-a hg19_gencode.v19.annotation.gtf \
-o gene_counts.txt \
../bam/normal.sorted.bam \
../bam/mcf7.sorted.bam
```

---

### Step 7: Differential Expression Analysis

```r
library(DESeq2)

counts <- read.delim("gene_counts.txt",
                     comment.char = "#",
                     check.names = FALSE)

countData <- counts[,7:ncol(counts)]
rownames(countData) <- counts$Geneid

sampleInfo <- data.frame(
  row.names = colnames(countData),
  condition = c("Normal","MCF7")
)

dds <- DESeqDataSetFromMatrix(
  countData = countData,
  colData = sampleInfo,
  design = ~ condition
)

dds <- DESeq(dds)

res <- results(dds)

resOrdered <- res[order(res$padj), ]

write.csv(as.data.frame(resOrdered),
          "Differential_Expression_Results.csv")
```

---

# Breast Cancer ChIP-seq Analysis Pipeline

## Overview

This project performs a complete ChIP-seq analysis workflow for breast cancer data using the histone modification **H3K27ac** under **10 nM estrogen (E2)** treatment conditions.

The pipeline processes raw FASTQ sequencing files and performs:

- Quality control with FastQC
- Genome alignment using HISAT2
- BAM sorting and indexing with SAMtools
- Peak calling using MACS2
- BigWig generation using deepTools
- Visualization in IGV

The final goal is to identify active enhancer and promoter regions associated with breast cancer gene regulation.

---

## Dataset Information

**Histone Mark Selected**

- H3K27ac (10 nM E2)

**GEO Accessions**

| Sample Type | GEO Accession |
|-------------|---------------|
| H3K27ac ChIP-seq | GSM9022859 |
| Input DNA Control | GSM9022841 |

---

## Pipeline Workflow

```text
Raw FASTQ
    ↓
FastQC Quality Check
    ↓
HISAT2 Alignment
    ↓
SAM → BAM Conversion
    ↓
BAM Sorting & Indexing
    ↓
MACS2 Peak Calling
    ↓
BigWig Generation
    ↓
Visualization in IGV
```

## Repository Structure
---
chip_seq_H3K27ac/
│
├── raw_data/        # Raw FASTQ files
├── fastqc/          # FastQC reports
├── index/           # hg38 HISAT2 index
├── bam/             # BAM and BigWig files
├── peaks/           # MACS2 peak files
└── IGV_Linux_2.17.4/

---


## References

### RNA-seq Differential Expression

Love MI et al. (2014).  
Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2.  
Genome Biology.

---

### HISAT2

Kim D et al. (2019).  
Graph-based genome alignment and genotyping with HISAT2 and HISAT-genotype.  
Nature Biotechnology.

---

### MACS2

Zhang Y et al. (2008).  
Model-based Analysis of ChIP-Seq (MACS).  
Genome Biology.

---

### Bowtie2

Langmead B et al. (2012).  
Fast gapped-read alignment with Bowtie 2.  
Nature Methods.

---

## Author

Mahe Alam

---

## License

MIT License
