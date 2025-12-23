#!/usr/bin/bash

# Set base URLs
BASE_URL="https://ftp.ensembl.org/pub/release-115/fasta/rattus_norvegicus/dna"
GTF_URL="https://ftp.ensembl.org/pub/release-115/gtf/rattus_norvegicus/Rattus_norvegicus.GRCr8.115.chr.gtf.gz"

# Chromosome names (1-20, X, Y, MT)
CHRS=({1..20} X Y MT)

# Download all chromosome fasta files
for chr in "${CHRS[@]}"; do
    fname="Rattus_norvegicus.GRCr8.dna.primary_assembly.${chr}.fa.gz"
    wget "${BASE_URL}/${fname}"
done

# Concatenate all fasta files into one (after decompressing)
for chr in "${CHRS[@]}"; do
    gunzip -c "Rattus_norvegicus.GRCr8.dna.primary_assembly.${chr}.fa.gz"
done > Rattus_norvegicus.GRCr8.dna.primary_assembly.fa

# Remove individual chromosome fasta files
rm Rattus_norvegicus.GRCr8.dna.primary_assembly.*.fa.gz

# Download the GTF file
wget "${GTF_URL}"

# Unzip the GTF files

gunzip Rattus_norvegicus.GRCr8.115.chr.gtf.gz

echo "Download, concatenation, and decompression complete."

# Download the fastq files

curl -L ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR848/000/SRR8487230/SRR8487230_1.fastq.gz -o SRR8487230.fastq.gz
curl -L ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR848/006/SRR8487226/SRR8487226_1.fastq.gz -o SRR8487226.fastq.gz

echo "Downloaded fastq files."
