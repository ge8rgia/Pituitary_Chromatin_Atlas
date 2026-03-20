#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/PreprocessPeaks.out
#SBATCH --job-name=PreprocessPeaks
#SBATCH --cpus-per-task=6
#SBATCH --mem=80G
#SBATCH --time=48:00:00

# 0. Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# 0. Load functions
source /scratch/prj/stem_cells_pituitary/Georgia/scripts/1_preprocessing/functions/PreprocessPeaks.sh

# 1. Run preprocess peaks function
PreprocessPeaks \
	/scratch/prj/stem_cells_pituitary/georgia_atac/metadata/consensus_chromatin_landscape.bed \
	/scratch/prj/stem_cells_pituitary/Georgia \
	"mm10"

