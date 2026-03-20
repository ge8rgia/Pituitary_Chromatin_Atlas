#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/7_observed_bw.out
#SBATCH --job-name=observed_bw
#SBATCH --cpus-per-task=6
#SBATCH --mem=100G
#SBATCH --time=48:00:00

cd /scratch/prj/stem_cells_pituitary/Georgia

# Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

cell_types=("Corticotrophs" "Gonadotrophs" "Gonadotrophs_Gata2_KO" "Gonadotrophs_SF1_KO" "Lactotrophs" "Melanotrophs" "Somatotrophs" "Stem_cells" "Thyrotrophs")
IN="/scratch/prj/stem_cells_pituitary/georgia_atac/mouse_merged"
OUT="/scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs"

echo "Begin observed_bw: $(date)"

# Run observed bigwig files command
for cell_type in "${cell_types[@]}"
do
        echo "Beginning cell type: $cell_type"

	cell_file=$IN/"${cell_type}_merged_sorted.tsv.gz"

	echo "Make filtered .tsv file from ${cell_file}"
	zcat "${cell_file}" | grep -E "^chr[0-9XYM]+\b" > $OUT/${cell_type}/${cell_type}_temp.tsv

	echo "Beginning filtering of ${cell_type}"
	grep -v "^#" $OUT/${cell_type}/${cell_type}_temp.tsv | cut -f1,2,3 > $OUT/${cell_type}/${cell_type}_temp.bed

	echo "Generate bedgraph file for ${cell_type}"
	bedtools genomecov -i $OUT/${cell_type}/${cell_type}_temp.bed -bg -g genome/mm10/mm10.chrom.sizes > $OUT/${cell_type}/${cell_type}_observed.bdg

	echo "Convert bedgraph to bigwig for ${cell_type}"
	bedGraphToBigWig $OUT/${cell_type}/${cell_type}_observed.bdg genome/mm10/mm10.chrom.sizes $OUT/${cell_type}/${cell_type}_observed.bw

	echo "Done ${cell_type}."

	rm $OUT/${cell_type}/${cell_type}_temp.tsv $OUT/${cell_type}/${cell_type}_temp.bed $OUT/${cell_type}/${cell_type}_observed.bdg

done

echo "Complete observed_bw: $(date). Success."
