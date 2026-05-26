#!/bin/bash
set -e

# ==================================================
# Full ChIP-seq Analysis Pipeline
# FASTQ → FastQC → HASAT2 → BAM → MACS2 → IGV 
# ==================================================

PROJECT="chip_seq_H3K27ac"
ENV_NAME="chipseq_Breast_cancer"

#----------------------------------------------------
#   H3K27ac (10 nM E2): GSM9022859 (Histon Mark)
#   Input  (10 nM E2): GSM9022841  (control)
#-------------------------------------------------------


CHIP="GSM9022859"
CONTROL="GSM9022841"
THREADS=8

echo "Creating project folders..."
mkdir -p $PROJECT/{raw_data,fastqc,index,bam,peaks}
cd $PROJECT

echo "Installing basic Ubuntu packages..."
sudo apt update
sudo apt install -y wget unzip curl default-jre sra-toolkit python3-pip firefox

echo "Installing Miniconda if missing..."
if [ ! -d "$HOME/miniconda3" ]; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
fi

echo "Loading Conda..."
source $HOME/miniconda3/etc/profile.d/conda.sh

echo "Creating Conda environment..."
if ! conda env list | grep -q "$ENV_NAME"; then
    conda create -n $ENV_NAME python=3.10 -y
fi

conda activate $ENV_NAME

echo "Installing bioinformatics tools..."
conda install -c bioconda -c conda-forge -y \
fastqc \
samtools \
bedtools \
deeptools \
hisat2 

echo "Installing MACS2 with pip..."
pip3 install MACS2

echo "Checking software versions..."
python --version
fastqc --version
hisat2 --version
samtools --version
bedtools --version
bamCoverage --version
macs2 --version

echo "Downloading hg38 index"
cd index
wget https://genome-idx.s3.amazonaws.com/hisat/hg38_genome.tar.gz
tar -xzf hg38_genome.tar.gz

cd ..


echo "Downloading ChIP-seq-breast cancer and control raw  fastq file..."
cd raw_data

# Get raw FASTQ for H3K27ac 10nM E2 (GSM9022859 = set 1)

fasterq-dump $CHIP --split-files -e 8 -p
gzip GSM9022859.fastq


# Get Input control for 10nM E2 (GSM9022841 = set 1)

fasterq-dump $CONTROL --split-files -e 8 -p
gzip GSM9022841.fastq

cd ..

echo "Running FastQC..."
fastqc raw_data/*.fastq.gz -o fastqc

echo "Aligning ChIP sample..."

# Align H3K27ac ChIP-seq
hisat2 -p $THREADS -x index/hg38/genome -U raw_data/GSM9022859.fastq.gz -S bam/H3K27ac_E2.sam

#Align Input control
hisat2 -p $THREADS -x index/hg38/genome -U raw_data/GSM9022841.fastq.gz -S bam/Input_E2.sam

echo "Indexing BAM files..."
## H3K27ac
samtools sort bam/H3K27ac_E2.sam -o bam/H3K27ac_sorted.bam
samtools index bam/H3K27ac_sorted.bam
# Input 
samtools sort bam/Input_E2.sam -o bam/Input_sorted.bam
samtools index bam/Input_sorted.bam

# Free up disk space 
rm bam/*.sam

echo "Running MACS2 peak calling..."
macs2 callpeak \
-t bam/H3K27ac_sorted.bam \
-c bam/Input_sorted.bam \
-f BAM \
-g hs \
--broad \
-n H3K27a_vs_input \
-q 0.01 \
--outdir peaks

echo "Checking peak output..."
echo "Check broadpeak Head"

head peaks/H3K27a_vs_input_peaks.broadPeak

echo "Count How many picks it got"

wc -l peaks/H3K27a_vs_input_peaks.broadPeak

echo "Creating BigWig files for IGV..."
bamCoverage \
-b bam/H3K27ac_sorted.bam \
-o bam/H3k27ac.bw \
--binSize 10 \
--normalizeUsing RPKM

bamCoverage \
-b bam/Input_sorted.bam  \
-o bam/input.bw \
--binSize 10 \
--normalizeUsing RPKM

echo "Downloading IGV..."
if [ ! -d IGV_Linux_2.17.4 ]; then
    wget https://data.broadinstitute.org/igv/projects/downloads/2.17/IGV_Linux_2.17.4_WithJava.zip
    unzip IGV_Linux_2.17.4_WithJava.zip
fi

echo "Opening FastQC and MEME reports..."
firefox fastqc/*.html &

echo "======================================"
echo "Pipeline completed successfully!"
echo "======================================"
echo ""
echo "Main output files:"
echo "FastQC reports: fastqc/*.html"
echo "ChIP BAM: bam/chip.sorted.bam"
echo "Control BAM: bam/control.sorted.bam"
echo "ChIP BigWig: bam/chip.bw"
echo "Control BigWig: bam/control.bw"
echo "Peak file: peaks/chip_vs_control_peaks.narrowPeak"
echo ""
echo "To open IGV:"
echo "cd IGV_Linux_2.17.4"
echo "./igv.sh"
echo ""
echo "Load these files in IGV:"
echo "bam/chip.bw"
echo "bam/control.bw"
echo "peaks/chip_vs_control_peaks.narrowPeak"
