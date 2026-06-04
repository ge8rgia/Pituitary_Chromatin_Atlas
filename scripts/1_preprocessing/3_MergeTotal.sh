#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/MergeTotal_young_traj.out
#SBATCH --job-name=MergeTotal
#SBATCH --cpus-per-task=6
#SBATCH --mem=80G
#SBATCH --time=20:00:00

# 0. Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# 0. Load functions
source /scratch/prj/stem_cells_pituitary/Georgia/scripts/functions/MergeTotal.sh

# 1. Define paths
sample_directory="/scratch/prj/stem_cells_pituitary/georgia_atac/mouse_young_merged"
output_directory="/scratch/prj/stem_cells_pituitary/georgia_atac/mouse_young_merged"

# 2. Run merge function
MergeTotal "$sample_directory" "$output_directory"
