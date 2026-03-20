#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/5_prep_nonpeaks.out
#SBATCH --job-name=peaks
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=20:00:00

cd /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/data

# 0. Activate conda environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# 1. Generate non-peaks for individual folds
echo "Starting non-peaks for f0"
chrombpnet prep nonpeaks \
	-g /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10.fa \
	-p peaks_no_blacklist.bed \
	-c /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10.chrom.subset.sizes \
	-fl /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/splits/fold_0.json \
	-br /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10_blacklist.bed.gz \
	-o output_f0
echo "Done."

echo "Starting non-peaks for f1"
chrombpnet prep nonpeaks \
        -g /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10.fa \
        -p peaks_no_blacklist.bed \
        -c /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10.chrom.subset.sizes \
        -fl /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/splits/fold_1.json \
        -br /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10_blacklist.bed.gz \
        -o output_f1
echo "Done."

echo "Starting non-peaks for f2"
chrombpnet prep nonpeaks \
        -g /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10.fa \
        -p peaks_no_blacklist.bed \
        -c /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10.chrom.subset.sizes \
        -fl /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/splits/fold_2.json \
        -br /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10_blacklist.bed.gz \
        -o output_f2
echo "Done."

echo "Starting non-peaks for f3"
chrombpnet prep nonpeaks \
        -g /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10.fa \
        -p peaks_no_blacklist.bed \
        -c /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10.chrom.subset.sizes \
        -fl /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/splits/fold_3.json \
        -br /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10_blacklist.bed.gz \
        -o output_f3
echo "Done."

echo "Starting non-peaks for f4"
chrombpnet prep nonpeaks \
        -g /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10.fa \
        -p peaks_no_blacklist.bed \
        -c /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10.chrom.subset.sizes \
        -fl /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/splits/fold_4.json \
        -br /scratch/prj/stem_cells_pituitary/Georgia/genome/mm10_blacklist.bed.gz \
        -o output_f4
echo "Done."
