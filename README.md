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
```text
chip_seq_H3K27ac/
│
├── raw_data/        # Raw FASTQ files
├── fastqc/          # FastQC reports
├── index/           # hg38 HISAT2 index
├── bam/             # BAM and BigWig files
├── peaks/           # MACS2 peak files
└── IGV_Linux_2.17.4/
```
## Software Requirements
**Ubuntu Packages**
```bash
sudo apt update
sudo apt install -y \
wget \
unzip \
curl \
default-jre \
sra-toolkit \
python3-pip \
firefox
```
**Install Miniconda**
```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
```
**Reload Terminal**
```bash
source ~/.bashrc
```
**Create Conda Environment**
```bash
conda create -n chipseq_Breast_cancer python=3.10 -y
conda activate chipseq_Breast_cancer
```
**Install Bioinformatics Tools**
```bash
conda install -c bioconda -c conda-forge -y \
fastqc \
samtools \
bedtools \
deeptools \
hisat2
```
**Install MACS2**
```bash
pip3 install MACS2
```
## Running the pipeline
**Clone Repository**
```bash
git clone https://github.com/mahealamuq/Breast_Cancer-RNA-seq_ChIP-seq_Analysis.git
cd Breast_Cancer-RNA-seq_ChIP-seq_Analysis
```
**Make Pipeline Executable**
```bash
chmod +x ChIp-seq_breast_cancer.sh
```
**Run Pipeline**
```bash
./ChIp-seq_breast_cancer.sh
```
## Pipeline Explanation

**Step 1 — Create Project Folders**

The script automatically creates directories for:
- raw sequencing files
- FastQC reports
- genome index
- BAM files
- peak files
  
```bash
mkdir -p $PROJECT/{raw_data,fastqc,index,bam,peaks}
```

**Step 2 — Install Required Software**

The pipeline installs:

| Tool      | Purpose                  |
| --------- | ------------------------ |
| FastQC    | Sequencing quality check |
| HISAT2    | Read alignment           |
| SAMtools  | BAM processing           |
| deepTools | BigWig generation        |
| MACS2     | Peak calling             |
| IGV       | Genome visualization     |


**Step 3 — Download Human Genome Index**

- Downloads the pre-built h38 genome index
- HISAT2 needs this to align reads

Aligners cannot work directly on FASTA - they need a indexed genome

```bash
wget https://genome-idx.s3.amazonaws.com/hisat/hg38_genome.tar.gz
```

**Step 4 — Download ChIP-seq Data**
Download raw sequencing reads from NCBI SRA, need raw fastQ files to align them to the genome

| File       | Description       |
| ---------- | ----------------- |
| GSM9022859 | H3K27ac ChIP-seq (10 nM E2 treatwd MCF7)|
| GSM9022841 | Input DNA control (background)|

```bash
# Get raw FASTQ for H3K27ac 10nM E2 (GSM9022859)
fasterq-dump $CHIP --split-files -e 8 -p
gzip GSM9022859.fastq
# Get Input control for 10nM E2 (GSM9022841)
fasterq-dump $CONTROL --split-files -e 8 -p
gzip GSM9022841.fastq
```

**Step 5 — Quality Control with FastQC**

FastQC evaluates sequencing quality including:

- per base quality
- GC content
- adapter contamination
- sequence duplication

Command:

```bash
fastqc raw_data/*.fastq.gz -o fastqc
```
Output:

```bash
fastqc/*.html
```

Open reports in Firefox:
```bash
firefox fastqc/*.html
```
**Step 6 — Align Reads to hg38 Genome**

Reads are aligned using HISAT2.
- Maps each read to the human genome(hg38)
- Produces SAM files(alignment format)
- Need aligned reads to identify enriched regions(peaks)
  
Chip sample

```bash
hisat2 -p 8 \
-x index/hg38/genome \
-U raw_data/GSM9022859.fastq.gz \
-S bam/H3K27ac_E2.sam
```

Input control

```bash
hisat2 -p 8 \
-x index/hg38/genome \
-U raw_data/GSM9022841.fastq.gz \
-S bam/Input_E2.sam
```

**Step 7 — Convert SAM to BAM**

- SAM files are converted into sorted BAM files.
- BAM files are compressed, sorted, indexed
- IGV and MACS2 require sorted BAM
- Sorted BAM allows faster genomic lookup and peak calling

H3K27ac:
  
```bash  
samtools view -bS bam/H3K27ac_E2.sam | samtools sort -o bam/H3K27ac_sorted.bam
# Index BAM Files
samtools index bam/H3K27ac_sorted.bam
```
Input:

```bah
samtools view -bS bam/Input_E2.sam | samtools sort-o bam/Input_sorted.bam
# Index BAM Files
samtools index bam/Input_sorted.bam
```
Remove sam file 

```bash
rm bam/*.sam
```

**Step 8 — Peak Calling with MACS2**

MACS2 identifies genomic regions enriched with H3K27ac signals.

Commands:
```bash
macs2 callpeak \
-t bam/H3K27ac_sorted.bam \
-c bam/Input_sorted.bam \
-f BAM \
-g hs \
--broad \
-n H3K27a_vs_input \
-q 0.01 \
--outdir peaks
```

Important parameters:

| Parameter | Meaning             |
| --------- | ------------------- |
| -t        | ChIP BAM            |
| -c        | Input control BAM   |
| --broad   | Broad histone peaks |
| -q 0.01   | FDR threshold       |


Peak output files:

| File       | Description      |
| ---------- | ---------------- |
| .broadPeak | Peak regions     |
| .xls       | Peak statistics  |
| .bed       | Peak coordinates |


**Step 9 — Count Number of Peaks**

```bash
wc -l peaks/H3K27a_vs_input_peaks.broadPeak
```
This shows how many enriched regions were detected.

**Step 10 — Generate BigWig Files**

BigWig files store genome-wide signal intensity.

```bash
bamCoverage \
-b bam/H3K27ac_sorted.bam \
-o bam/H3k27ac.bw \
--binSize 10 \
--normalizeUsing RPKM
```
These files are used for IGV visualization.

# Visualization Using IGV
**Download IGV**

```bash
wget https://data.broadinstitute.org/igv/projects/downloads/2.17/IGV_Linux_2.17.4_WithJava.zip

unzip IGV_Linux_2.17.4_WithJava.zip
```

**Launch IGV**
```bash
cd IGV_Linux_2.17.4

./igv.sh
```

**Load Files in IGV**

Load:

- bam/H3k27ac.bw
- bam/input.bw
- peaks/H3K27a_vs_input_peaks.broadPeak
- Select genome hg38



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
## Explanation of Each Step

### 1. System Update

```bash
sudo apt update -y
sudo apt upgrade -y
```

This updates Ubuntu package information and upgrades installed packages.

---

### 2. Software Installation

The script installs required tools such as:

| Tool | Purpose |
|---|---|
| FastQC | Checks sequencing read quality |
| fastp | Trims low-quality reads |
| HISAT2 | Aligns RNA-seq reads to the genome |
| SAMtools | Processes SAM/BAM files |
| BEDTools | Genomic interval processing |
| Subread/featureCounts | Counts reads per gene |
| deepTools | Creates BigWig files |
| DESeq2 | Differential expression analysis |
| BioMart | Converts Ensembl IDs to gene symbols |

---

### 3. Miniconda and Conda Environment

The script installs Miniconda if it is not already installed.

Then it creates a Conda environment:

```bash
rnaseq_env
```

This environment contains bioinformatics packages used in the RNA-seq workflow.

---

### 4. Project Folder Structure

The script creates this project structure:

```text
breast_cancer_project/
│
├── index/
├── raw_data/
├── fastqc/
├── trimmed/
├── bam/
├── results/
├── FeatureCounts/
├── R_scripts/
└── IGV/
```

---

### 5. Reference Genome Download

The script downloads the **hg38 HISAT2 genome index**.

This index is required for mapping RNA-seq reads to the human genome.

---

### 6. RNA-seq Data Download

The pipeline downloads paired-end RNA-seq data:

| Sample Type | Replicate | Accession |
|---|---|---|
| Normal breast tissue | Replicate 1 | ERR358485 |
| Normal breast tissue | Replicate 2 | ERR358486 |
| MCF7 breast cancer | Replicate 1 | ERR358488 |
| MCF7 breast cancer | Replicate 2 | ERR358487 |

---

### 7. Quality Control

FastQC checks raw sequencing quality.

It produces HTML reports showing:

- Per-base quality
- GC content
- Adapter contamination
- Sequence duplication
- Overrepresented sequences

---

### 8. Read Trimming

fastp removes poor-quality bases and sequencing artifacts.

Output files are stored in:

```text
trimmed/
```

---

### 9. RNA-seq Alignment

HISAT2 aligns trimmed reads to the human reference genome.

Output SAM files are created first, then converted into BAM files.

---

### 10. BAM Processing

SAMtools converts SAM files into sorted BAM files.

Sorted BAM files are required for:

- gene counting
- visualization
- statistics
- BigWig generation

---

### 11. Alignment Statistics

SAMtools flagstat reports mapping statistics for each sample.

Output files:

```text
results/normal_rep1_stats.txt
results/normal_rep2_stats.txt
results/MCF7_rep1_stats.txt
results/MCF7_rep2_stats.txt
```

---

### 12. BigWig File Generation

BigWig files are generated using deepTools.

These files can be loaded into IGV to visualize gene expression patterns across the genome.

---

### 13. Gene Annotation File

The script downloads:

```text
GENCODE v43 hg38 annotation
```

This GTF file tells featureCounts where genes are located in the genome.

---

### 14. Gene Quantification

featureCounts counts how many reads map to each gene.

Output:

```text
FeatureCounts/gene_counts.txt
```

This count matrix is used by DESeq2.

---

### 15. Differential Expression Analysis

DESeq2 compares:

```text
MCF7 vs normal
```

The output includes:

| Column | Meaning |
|---|---|
| baseMean | Average normalized expression |
| log2FoldChange | Expression difference |
| lfcSE | Standard error |
| stat | Test statistic |
| pvalue | Raw p-value |
| padj | Adjusted p-value |

Main output:

```text
results/DESeq2_results.csv
```

---

### 16. Top 20 Genes

The script creates:

```text
results/Top20_overexpressed.csv
results/Top20_underexpressed.csv
```

These files contain the most strongly upregulated and downregulated genes.

---

### 17. BioMart Gene Annotation

BioMart converts Ensembl gene IDs into readable gene names.

Example:

```text
ENSG00000141510 → TP53
```

Final annotated output:

```text
results/top20_overexpressed_genes_annotated.csv
results/top20_underexpressed_genes_annotated.csv
```

---

## Final Output Files

| Output File | Description |
|---|---|
| `fastqc/` | FastQC and MultiQC reports |
| `trimmed/` | Trimmed FASTQ files |
| `bam/*.bam` | Sorted alignment files |
| `bam/*.bai` | BAM index files |
| `bam/*.bw` | BigWig visualization files |
| `FeatureCounts/gene_counts.txt` | Gene count matrix |
| `results/DESeq2_results.csv` | Full differential expression results |
| `results/Top20_overexpressed.csv` | Top 20 upregulated genes in MCF7 |
| `results/Top20_underexpressed.csv` | Top 20 downregulated genes in MCF7 |
| `results/top20_overexpressed_genes_annotated.csv` | Annotated overexpressed genes |
| `results/top20_underexpressed_genes_annotated.csv` | Annotated underexpressed genes |

---

## Biological Interpretation

Positive `log2FoldChange` means the gene is more highly expressed in MCF7 breast cancer cells.

Negative `log2FoldChange` means the gene is more highly expressed in normal breast tissue.

For example:

```text
log2FoldChange = 2
```

means the gene is approximately 4 times higher in MCF7.

```text
log2FoldChange = -2
```

means the gene is approximately 4 times lower in MCF7.

---

## Next Analysis Steps

After this pipeline finishes, the next steps are:

1. Open `Top20_overexpressed.csv`
2. Check gene symbols in the annotated file
3. Search important genes in GeneCards
4. Run disease enrichment analysis using Enrichr
5. Create plots such as:
   - volcano plot
   - heatmap
   - bar plot of top genes
6. Discuss cancer-related genes in the report

---

## Repository Structure

```text
breast-cancer-rnaseq-analysis/
│
├── RNA-seq_Breast_cancer.sh
├── README.md
│
└── breast_cancer_project/
    ├── index/
    ├── raw_data/
    ├── fastqc/
    ├── trimmed/
    ├── bam/
    ├── results/
    ├── FeatureCounts/
    ├── R_scripts/
    └── IGV/
```

---

## Author

Mahe Alam

---

## License

MIT License
