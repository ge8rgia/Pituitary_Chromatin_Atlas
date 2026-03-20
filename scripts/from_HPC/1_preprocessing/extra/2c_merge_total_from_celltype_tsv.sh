#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/2c_merge_total_from_celltype_tsv.out
#SBATCH --job-name=merge_cells
#SBATCH --cpus-per-task=6
#SBATCH --mem=150G
#SBATCH --time=15:00:00

cd /scratch/prj/stem_cells_pituitary/

# 0. Activate conda environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# 0. Set Paths
rootdir=/scratch/prj/stem_cells_pituitary
atacdir=$rootdir/georgia_atac
atacdata=$atacdir/mouse_merged

OUT="$atacdata"

cd $atacdata

ALL_FRAGMENTS=($(ls *_merged_sorted.tsv.gz | grep -v "all_merged"))

echo "Files identified for merging:"
printf '%s\n' "${ALL_FRAGMENTS[@]}"
echo "Number of samples: ${#ALL_FRAGMENTS[@]}"
echo "Total size of files: $(du -ch "${ALL_FRAGMENTS[@]}" | grep total$ | cut -f1)"

# Merge and sort files
echo "Merging and sorting the merged fragment files: $(date)"

LC_ALL=C
zcat "${ALL_FRAGMENTS[@]}" | \
sort -k1,1 -k2,2n --parallel=6 -S 28G -T "$OUT" | \
bgzip -@ 6 -c > "$OUT/all_cells_merged_sorted.tsv.gz"

echo "Done merging and sorting the fragment files: $(date)"

echo "Starting to compress and zip the sorted fragment file: $(date)"
tabix -p bed "$OUT/all_cells_merged_sorted.tsv.gz"

echo "===> DONE SORTING AND INDEXING FILES $(date) <==="
