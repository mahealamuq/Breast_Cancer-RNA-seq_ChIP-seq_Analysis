# Breast Cancer RNA-seq and ChIP-seq Analysis

![Platform](https://img.shields.io/badge/Platform-Ubuntu-orange)
![RNA-seq](https://img.shields.io/badge/Analysis-RNA--seq-red)
![ChIP-seq](https://img.shields.io/badge/Analysis-ChIP--seq-purple)
![Bash](https://img.shields.io/badge/Bash-Scripting-blue)
![R](https://img.shields.io/badge/R-DESeq2-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

Integrated RNA-seq and ChIP-seq bioinformatics workflow for analysing breast cancer gene expression and epigenetic regulation in **MCF7 breast cancer cells** compared with **normal breast tissue**.

---

## Project Aim

The aim of this project is to compare gene expression between MCF7 breast cancer cells and normal breast tissue, identify significantly overexpressed and underexpressed genes, and relate these expression changes to regulatory histone modification patterns from ChIP-seq data.

RNA-seq is used to detect differential gene expression.

ChIP-seq is used to identify H3K27ac-enriched regulatory regions, including active promoters and enhancers.

Together, the analysis helps identify candidate genes and regulatory regions that may be associated with breast cancer progression.

---



---

## Workflow Overview

### RNA-seq Pipeline

```text
RNA-seq FASTQ files
        ↓
FastQC quality control
        ↓
fastp trimming
        ↓
HISAT2 alignment to hg38
        ↓
SAMtools BAM sorting and indexing
        ↓
featureCounts gene quantification
        ↓
DESeq2 differential expression analysis
        ↓
BioMart annotation
        ↓
Enrichr disease enrichment
```

### ChIP-seq Pipeline

```text
ChIP-seq FASTQ files
        ↓
FastQC quality control
        ↓
HISAT2 alignment to hg38
        ↓
SAMtools BAM sorting and indexing
        ↓
MACS2 broad peak calling
        ↓
deepTools BigWig generation
        ↓
IGV visualisation
```

---

## Dataset Information

### RNA-seq Samples

| Sample Type | Replicate | Accession |
|-------------|------------|------------|
| Normal Breast Tissue | 1 | ERR358485 |
| Normal Breast Tissue | 2 | ERR358486 |
| MCF7 Breast Cancer Cells | 1 | ERR358488 |
| MCF7 Breast Cancer Cells | 2 | ERR358487 |

### ChIP-seq Samples

| Sample Type | Histone Mark | GEO Accession |
|-------------|-------------|---------------|
| ChIP Sample | H3K27ac (10 nM E2) | GSM9022859 |
| Input Control | Input DNA | GSM9022841 |

---
## Important Limitation about Dataset

The RNA-seq and ChIP-seq datasets used in this study were obtained from different public experiments and were not generated from the same biological samples or under the same experimental conditions.

The RNA-seq dataset consisted of normal breast tissue and MCF7 breast cancer cell samples, whereas the ChIP-seq dataset examined H3K27ac enrichment in MCF7 cells treated with 10 nM estradiol (E2). Consequently, direct sample-to-sample comparisons between gene expression and histone modification signals should be interpreted with caution.

The ChIP-seq analysis was therefore used as supportive evidence to investigate whether differentially expressed genes identified by RNA-seq were associated with active chromatin features. The presence of H3K27ac enrichment near a gene promoter or enhancer may suggest a transcriptionally active regulatory region; however, it does not conclusively demonstrate that the observed RNA expression changes were caused by the detected histone modification.

Future studies using matched RNA-seq and ChIP-seq datasets generated from the same biological samples would provide stronger evidence for linking gene expression changes to epigenetic regulation.

## Software Requirements

| Software | Purpose |
|-----------|----------|
| FastQC | Quality Control |
| MultiQC | Aggregate QC Reports |
| fastp | Read Trimming |
| HISAT2 | Alignment |
| SAMtools | BAM Processing |
| BEDTools | Genomic Analysis |
| featureCounts | Gene Quantification |
| MACS2 | Peak Calling |
| deepTools | BigWig Generation |
| DESeq2 | Differential Expression |
| BioMart | Gene Annotation |
| Enrichr | Disease Enrichment |
| IGV | Genome Visualization |

---

## Installation

### Clone Repository

```bash
git clone https://github.com/mahealamuq/Breast-Cancer-RNAseq-ChIPseq-Analysis.git

cd Breast-Cancer-RNAseq-ChIPseq-Analysis
```

### Make Scripts Executable

```bash
chmod +x RNA-seq_Breast_cancer.sh

chmod +x ChIp-seq_breast_cancer.sh
```

---

## Running RNA-seq Analysis

```bash
./RNA-seq_Breast_cancer.sh
```

Pipeline performs:

1. Software installation
2. Miniconda setup
3. Genome download
4. FASTQ download
5. FastQC
6. fastp trimming
7. HISAT2 alignment
8. BAM generation
9. featureCounts
10. DESeq2 analysis
11. BioMart annotation
12. Enrichr disease enrichment

---

## Running ChIP-seq Analysis

```bash
./ChIp-seq_breast_cancer.sh
```

Pipeline performs:

1. Tool installation
2. Genome download
3. FASTQ download
4. FastQC
5. HISAT2 alignment
6. BAM processing
7. MACS2 peak calling
8. BigWig generation
9. IGV preparation

---

## RNA-seq Output Files

| File | Description |
|--------|------------|
| DESeq2_results.csv | Differential expression results |
| Significant_genes.csv | Significant genes |
| Top100_overexpressed.csv | Top overexpressed genes |
| Top100_underexpressed.csv | Top underexpressed genes |
| Top100_overexpressed_annotated.csv | Annotated genes |
| Top100_underexpressed_annotated.csv | Annotated genes |
| Overexpressed_DisGeNET_Significant_Diseases.csv | upregulated genes and Associate Disease|
| Overexpressed_Jensen_Significant_Diseases.csv | upregulated genes and Associate Disease |
| Underexpressed_DisGeNET_Significant_Diseases.csv | downregulated genes and Associate Disease |
|  Underexpressed_Jensen_Significant_Diseases.csv | downregulated genes and Associate Disease |

---

## ChIP-seq Output Files

| File | Description |
|--------|------------|
| H3K27ac_sorted.bam | Sorted alignment |
| H3K27ac.bw | BigWig track |
| H3K27a_vs_input_peaks.broadPeak | Peak file |
| H3K27a_vs_input_peaks.xls | Peak statistics |

---

## IGV Visualisation
The upregulated genes identified from RNA-seq analysis were further examined in IGV using RNA-seq bigWig and ChIP-seq tracks. Genes showing strong RNA-seq signal across the gene body together with enrichment of active histone marks on H3K27ac near the promoter region were considered transcriptionally active.

For example, if an upregulated gene shows high RNA-seq coverage and a clear H3K27ac peak near its transcription start site, this supports that the gene is actively transcribed in the breast cancer sample.

If Downregulated Genes showing reduced RNA-seq signal across the gene body in MCF7 compared with normal samples, together with weak or absent active histone marks on H3K27ac near the promoter, were interpreted as transcriptionally inactive or reduced in activity in breast cancer cells.

Launch IGV:

```bash
cd IGV_Linux_2.17.4

./igv.sh
```

Load:

```text
H3k27ac.bw
input.bw
H3K27a_vs_input_peaks.broadPeak
MCF7_rep1.bw
MCF7_rep2.bw
normal_rep1.bw
normal_rep2.bw
```

Select:

```text
Human hg38
```

---

## Biological Interpretation

### RNA-seq

Positive Log2FoldChange:

```text
Higher expression in MCF7 cells
```

Negative Log2FoldChange:

```text
Higher expression in normal tissue
```

### ChIP-seq

Strong H3K27ac peaks indicate:

- Active promoters
- Active enhancers
- Regulatory chromatin regions

---

## References

Love MI et al. (2014). DESeq2. Genome Biology.

Kim D et al. (2019). HISAT2. Nature Biotechnology.

Liao Y et al. (2014). featureCounts. Bioinformatics.

Zhang Y et al. (2008). MACS2. Genome Biology.

Ramírez F et al. (2016). deepTools2. Nucleic Acids Research.

---

## Author

Mahe Alam

Melbourne, Australia

---

## License

MIT License
