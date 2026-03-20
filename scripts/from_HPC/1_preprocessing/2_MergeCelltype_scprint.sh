#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/2_MergeCelltype_scprint.out
#SBATCH --job-name=scprint_MergeCelltype
#SBATCH --cpus-per-task=4
#SBATCH --mem=80G
#SBATCH --time=48:00:00

# 0. Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# 0. Load functions
source /scratch/prj/stem_cells_pituitary/Georgia/scripts/1_preprocessing/functions/MergeCelltype.sh

# 1. Define paths
sampleDir="/scratch/prj/stem_cells_pituitary/georgia_atac/mouse_split_scprint"
outDir="/scratch/prj/stem_cells_pituitary/georgia_atac/mouse_merged_scprint"
sample_sheet="/scratch/prj/stem_cells_pituitary/georgia_atac/metadata/sample_sheet.txt"

# 2. Run Functions

# Merge all celltypes excluding Gonadotrophs
cell_type_list=("Corticotrophs" "Endothelial_cells" "Erythrocytes" "Immune_cells" "Lactotrophs" "Melanotrophs" "Mesenchymal_cells" "Pituicytes" "Somatotrophs" "Stem_cells" "Thyrotrophs")
excluded_samples=()

MergeCelltype \
       cell_type_list \
       "$sample_sheet" \
       "$sampleDir" \
       "$outDir" \
       excluded_samples \
       ""

# Merge Gonadotrophs excluding KO samples
cell_type_list=("Gonadotrophs")
excluded_samples=("GSM5712761" "GSM5712762" "GSM5712763" "GSM5959924")

MergeCelltype \
       cell_type_list \
       "$sample_sheet" \
       "$sampleDir" \
       "$outDir" \
       excluded_samples \
       ""

# Merge Gonadotroph Gata2 KO samples
cell_type_list=("Gonadotrophs")
excluded_samples=()

gata2_samples=("GSM5712761" "GSM5712762" "GSM5712763")
printf "%s\n" "${gata2_samples[@]}" > /scratch/prj/stem_cells_pituitary/georgia_atac/gata2_temp.txt

MergeCelltype \
       cell_type_list \
       /scratch/prj/stem_cells_pituitary/georgia_atac/gata2_temp.txt \
       "$sampleDir" \
       "$outDir" \
       excluded_samples \
       "Gata2_KO"

rm /scratch/prj/stem_cells_pituitary/georgia_atac/gata2_temp.txt

# Merge Gonadotroph SF1 KO samples
cell_type_list=("Gonadotrophs")
excluded_samples=()

sf1_samples=("GSM5959924")
printf "%s\n" "${sf1_samples[@]}" > /scratch/prj/stem_cells_pituitary/georgia_atac/sf1_temp.txt

MergeCelltype \
       cell_type_list \
       /scratch/prj/stem_cells_pituitary/georgia_atac/sf1_temp.txt \
       "$sampleDir" \
       "$outDir" \
       excluded_samples \
       "SF1_KO"

rm /scratch/prj/stem_cells_pituitary/georgia_atac/sf1_temp.txt
