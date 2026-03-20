#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/1_SplitTSV_scprint.out
#SBATCH --job-name=scprint_split
#SBATCH --cpus-per-task=4
#SBATCH --mem=80G
#SBATCH --time=20:00:00

# 0. Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# 0. Load functions
source /scratch/prj/stem_cells_pituitary/Georgia/scripts/functions/Split_tmp.sh

# 1. Define paths
sample_directory="/scratch/prj/stem_cells_pituitary/georgia_atac/mouse"
output_directory="/scratch/prj/stem_cells_pituitary/georgia_atac/mouse_split_scprint"
barcodes="/scratch/prj/stem_cells_pituitary/georgia_atac/metadata/cell_metadata.csv"

# 2. Run split function
SplitTSV_scprint \
	"$sample_directory" \
	"$output_directory" \
	"$barcodes"
