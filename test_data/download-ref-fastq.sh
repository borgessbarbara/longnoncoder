#!/usr/bin/bash

# Set base URLs
FASTA_URL="https://ftp.ensembl.org/pub/release-114/fasta/rattus_norvegicus/dna/Rattus_norvegicus.GRCr8.dna.primary_assembly.1.fa.gz"
GTF_URL="https://ftp.ensembl.org/pub/release-114/gtf/rattus_norvegicus/Rattus_norvegicus.GRCr8.114.chr.gtf.gz"

mkdir -p references

# Download the FASTA chr1 file
curl -L "${FASTA_URL}" -o references/Rattus_norvegicus.GRCr8.dna.primary_assembly.1.fa.gz

# Download the GTF file
curl -L "${GTF_URL}" -o references/Rattus_norvegicus.GRCr8.114.chr.gtf.gz

# Unzip the files

gunzip references/Rattus_norvegicus.GRCr8.dna.primary_assembly.1.fa.gz
gunzip references/Rattus_norvegicus.GRCr8.114.chr.gtf.gz

# separate only chr1 annotations from the GTF file
awk '$1 == "1"' references/Rattus_norvegicus.GRCr8.114.chr.gtf > references/Rattus_norvegicus.GRCr8.114.chr1.gtf

# remove complete gtf file
rm references/Rattus_norvegicus.GRCr8.114.chr.gtf

echo -e "\nRat reference chromosome 1 - genome and annotation files downloaded.\n"

# Download the fastq files

mkdir -p samples

FASTQ_URL="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR848/"

curl -L "${FASTQ_URL}"000/SRR8487230/SRR8487230_1.fastq.gz -o samples/SRR8487230.fastq.gz
curl -L "${FASTQ_URL}"006/SRR8487226/SRR8487226_1.fastq.gz -o samples/SRR8487226.fastq.gz


echo -e "\nBioProject PRJNA517125 - Downloaded 2 fastq files.\n"