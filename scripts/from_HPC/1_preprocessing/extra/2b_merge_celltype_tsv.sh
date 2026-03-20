#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/2b_merge_celltype_tsv.out
#SBATCH --job-name=cell_merge
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=20:00:00

cd /scratch/prj/stem_cells_pituitary/

# 0. Activate conda environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# 0. Set Paths
rootdir=/scratch/prj/stem_cells_pituitary
atacdir=$rootdir/georgia_atac
atacdata=$atacdir/mouse_split

# Paths for merging cell types except Gonadotrophs
samples=($(cat "$atacdir/sample_sheet.txt"))
cell_types=("Corticotrophs" "Endothelial_cells" "Erythrocytes" "Immune_cells" "Lactotrophs" "Melanotrophs" "Mesenchymal_cells" "Pituicytes" "Somatotrophs" "Stem_cells" "Thyrotrophs")
# Paths for merging Gonadotrophs (separate to exclude KO samples)
#samples=($(cat "$atacdir/sample_sheet_noKO.txt"))
#cell_types=("Gonadotrophs")

OUT=$atacdir/mouse_merged

# 1. Iterate merge, sort, and index pipeline through samples and cell_types
echo ${samples[@]}
echo "==> Number of samples: ${#samples[@]} <==="

for cell_type in "${cell_types[@]}"
do
	echo "Beginning cell type: $cell_type"

	CELL_FRAGMENTS=()

	for sample in "${samples[@]}"
	do
		IN=$atacdata/$sample
		FILE=$(ls $IN/*${cell_type}.tsv.gz 2>/dev/null | head -n 1)
		if [ -f "$FILE" ]; then
		   echo "Fragment file selected for $sample : $FILE"
		   CELL_FRAGMENTS+=("$FILE")
		fi
	done

	echo "====> Total files selected for $cell_type : ${#CELL_FRAGMENTS[@]} <===="

	if [ ${#CELL_FRAGMENTS[@]} -eq 0 ]; then
	   echo "No files found for $cell_type — skipping"
	   continue
	fi

	MERGED_FILENAME="$OUT/${cell_type}_merged"

	echo "Merging $cell_type fragments"
	zcat "${CELL_FRAGMENTS[@]}" | bgzip -c > "${MERGED_FILENAME}.tsv.gz"

	echo "Sorting $cell_type"
	zcat "${MERGED_FILENAME}.tsv.gz" \
	   | sort -k1,1 -k2,2n -T "$OUT" \
	   > "${MERGED_FILENAME}_sorted.tsv"

	echo "Compress and index $cell_type"
	bgzip "${MERGED_FILENAME}_sorted.tsv"
	tabix -p bed "${MERGED_FILENAME}_sorted.tsv.gz"

	echo "===> Completed merging of $cell_type <==="
done

echo "===> ALL CELL TYPES MERGED <==="
