#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/2_MergeCelltype_young.out
#SBATCH --job-name=MergeCelltype
#SBATCH --cpus-per-task=4
#SBATCH --mem=80G
#SBATCH --time=48:00:00

# 0. Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# 0. Load functions
source /scratch/prj/stem_cells_pituitary/Georgia/scripts/functions/MergeCelltype.sh

# 1. Define paths
sampleDir="/scratch/prj/stem_cells_pituitary/georgia_atac/mouse_young_split"
outDir="/scratch/prj/stem_cells_pituitary/georgia_atac/mouse_young_merged"
sample_sheet="/scratch/prj/stem_cells_pituitary/georgia_atac/mouse_young_split/sample_sheet.txt"

# 2. Run Functions

# Merge all celltypes
cell_type_list=("Corticotrophs" "Endothelial_cells" "Erythrocytes" "Gonadotrophs" "Immune_cells" "Lactotrophs" "Melanotrophs" "Mesenchymal_cells" "Pituicytes" "Somatotrophs" "Stem_cells" "Thyrotrophs")
excluded_samples=()

MergeCelltype \
       cell_type_list \
       "$sample_sheet" \
       "$sampleDir" \
       "$outDir" \
       excluded_samples \
       ""

