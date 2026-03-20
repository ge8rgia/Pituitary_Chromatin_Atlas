#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/trial_function_tsv.out
#SBATCH --job-name=SplitTSV
#SBATCH --cpus-per-task=4
#SBATCH --mem=80G
#SBATCH --time=20:00:00

# 0. Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# 0. Load functions
source /scratch/prj/stem_cells_pituitary/Georgia/scripts/1_preprocessing/functions/SplitTSV.sh

# 1. Define paths
sample_directory="/scratch/prj/stem_cells_pituitary/Georgia/practice"
output_directory="/scratch/prj/stem_cells_pituitary/Georgia/practice"
barcodes="/scratch/prj/stem_cells_pituitary/georgia_atac/metadata/cell_metadata.csv"

# 2. Run split function
SplitTSV "$sample_directory" "$output_directory" "$barcodes"



