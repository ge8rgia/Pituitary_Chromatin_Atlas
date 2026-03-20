#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/4_TFModisco_groupings.out
#SBATCH --job-name=TFModisco
#SBATCH --cpus-per-task=8
#SBATCH --mem=50G
#SBATCH --time=48:00:00

cd /scratch/prj/stem_cells_pituitary/Georgia

# Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# Function
source /scratch/prj/stem_cells_pituitary/Georgia/scripts/functions/TFModisco.sh

# Run TFModisco pipeline
groupings=("grouping_1_up" "grouping_2_up" "grouping_4_up" "grouping_4_down" "grouping_6_up" "grouping_7_up" "grouping_8_up")

for group in ${groupings[@]}
do
TFModisco \
	/scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs \
	/scratch/prj/stem_cells_pituitary/Georgia/genome/JASPAR_CORE_2026_non-redundant.meme \
	"$group"
done

