#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/2a_merge_total_tsv.out
#SBATCH --job-name=merge_all
#SBATCH --cpus-per-task=8
#SBATCH --mem=130G
#SBATCH --time=20:00:00

cd /scratch/prj/stem_cells_pituitary/

# 0. Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# 0. Set Paths
rootdir=/scratch/prj/stem_cells_pituitary
atacdir=$rootdir/georgia_atac
atacdata=$atacdir/mouse

samples=($(cat "$atacdir/sample_sheet.txt"))

OUT=$atacdir/mouse_merged

# 1. List ATAC-seq samples to merge
echo ${samples[@]}
echo "==> Number of samples: ${#samples[@]} <==="

ALL_FRAGMENTS=()

for sample in "${samples[@]}"
do
	IN=$atacdata/$sample
	FRAG_FILES=($IN/*fragments*.tsv.gz)
	FRAGMENTS="${FRAG_FILES[0]}"

	if [ -f "$FRAGMENTS" ]; then
		echo "Fragment file selected for $sample : $FRAGMENTS"
		ALL_FRAGMENTS+=("$FRAGMENTS")
	else
		echo "No fragment file found for $sample"

	fi
done

echo "====> Total files selected to merge: ${#ALL_FRAGMENTS[@]} <===="
echo "====> Total size of files: $(du -ch "${ALL_FRAGMENTS[@]}" | grep total$ | cut -f1) <===="

# 2. Merge files
echo "Starting to merge all samples"
zcat "${ALL_FRAGMENTS[@]}" | bgzip -c > "$OUT/all_merged_fragments.tsv.gz"

# 3. Sort and index the file
echo "Starting to sort the merged fragment file: $(date)"

LC_ALL=C
zcat "$OUT/all_merged_fragments.tsv.gz" | \
sort -k1,1 -k2,2n --parallel=6 -S 28G -T "$OUT" | \
bgzip -@ 6 > "$OUT/all_merged_sorted.tsv.gz"

echo "Done sorting the merged fragment file: $(date)"

echo "Starting to compress and zip the sorted fragment file: $(date)"
tabix -p bed "$OUT/all_merged_sorted.tsv.gz"

echo "===> DONE SORTING AND INDEXING FILES $(date) <==="
