#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/4_process_peak_file.out
#SBATCH --job-name=peaks
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=20:00:00

cd /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/data

# 0. Activate conda environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# 1. Process peak file provided
# Peak file already provided - consensus_chromatin_landscape.bed
#This is in a 3 column format: chr - start - end
#Input files from the chrombpnet tutorial is in 10 column format:
#chr - start - end - name - score - strand - signal - pvalue - qvalue - summit
#Summit can be assumed to be the number of base pairs to the middle of the sequence
#So modification of our input peak file needs to be made.

awk -v OFS='\t' '{
    summit_offset = int(($3 - $2) / 2);
    print $1, $2, $3, "peak_"NR, ".", ".", ".", ".", ".", summit_offset
}' consensus_chromatin_landscape.bed > consensus_chromatin_landscape_modified.bed

# 2. Generate peaks_no_blacklist.bed as normal

gzip consensus_chromatin_landscape_modified.bed
bedtools slop -i mm10_blacklist.bed.gz -g mm10.chrom.sizes -b 1057 > temp.bed
bedtools intersect -v -a consensus_chromatin_landscape_modified.bed.gz -b ../temp.bed  > peaks_no_blacklist.bed
