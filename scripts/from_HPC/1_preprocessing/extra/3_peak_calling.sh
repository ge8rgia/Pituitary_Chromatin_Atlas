#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/3_peak_calling.out
#SBATCH --job-name=peaks
#SBATCH --cpus-per-task=8
#SBATCH --mem=100G
#SBATCH --time=20:00:00

#cd /scratch/prj/stem_cells_pituitary/georgia_atac/mouse_merged
#cd /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/data

# 0. Activate conda environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# 1. Peak-calling
#echo "Starting peak calling: $(date)"

#/scratch/users/k25055720/conda_envs/scprint/bin/macs2 callpeak \
#	-t /scratch/prj/stem_cells_pituitary/georgia_atac/mouse_merged/all_cells_merged_sorted.tsv.gz \
#	-f BED \
#	-g mm \
#	-p 0.01 \
#	--nomodel --shift -75 --extsize 150 \
#	--name all_cells \
#	--outdir /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/peak_validation/

#echo "Done. $(date)"

#cd /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/data/

#if [ -f all_fragments_peaks.narrowPeak ]; then
#    mv all_fragments_peaks.narrowPeak all_fragments_peaks.bed
#    gzip -f all_fragments_peaks.bed
#else
#    echo "MACS2 failed to make output file."
#    exit 1
#fi

# 2. Generate peaks_no_blacklist file
#bedtools slop -i mm10_blacklist.bed.gz -g mm10.chrom.sizes -b 1057 > temp.bed
#bedtools intersect -v -a all_fragments_peaks.bed.gz -b /scratch/prj/stem_cells_pituitary/Georgia/genome/temp.bed > peaks_no_blacklist_macs2.bed

# 3. Generate non-peaks

cd /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/peak_validation

echo "Starting peak calling: $(date)"

chrombpnet prep nonpeaks \
	-g /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10/mm10.fa \
	-p peaks_no_blacklist.bed \
	-c /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10/mm10.chrom.subset.sizes \
	-fl /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/splits/mm10/fold_0.json \
	-br /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10/mm10_blacklist.bed.gz \
	-o output

echo "Done. $(date)"

