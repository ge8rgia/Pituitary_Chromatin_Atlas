#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/4_tf_modisco_report.out
#SBATCH --job-name=tf_modisc
#SBATCH --cpus-per-task=8
#SBATCH --mem=50G
#SBATCH --time=30:00:00

cd /scratch/prj/stem_cells_pituitary/Georgia

# Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

#which modisco
MODISCO_EXE=$(which modisco | sed "s|/users/k25055720/.local/bin/modisco|/scratch/users/k25055720/conda_envs/chrombpnet_new/bin/modisco|")

echo "Beginning tf_motif analysis"

# Run TF-modisco contribution score pipeline
$MODISCO_EXE motifs \
    -i ChromBPnet/outputs/Lactotrophs/contribs_bw/lactotrophs_contribs.profile_scores.h5 \
    -n 50000 \
    -o ChromBPnet/outputs/Lactotrophs/tf_modisco/modisco_results.h5

echo "Complete tf_motif analysis. Success."

echo "Begin generating tf_modisco report"

# Run TF-modisco report
$MODISCO_EXE report \
	-i ChromBPnet/outputs/Lactotrophs/tf_modisco/modisco_results.h5 \
	-o ChromBPnet/outputs/Lactotrophs/tf_modisco/modisco_report/ \
	-s ChromBPnet/outputs/Lactotrophs/tf_modisco/modisco_report/ \
	-m genome/JASPAR_CORE_2026_non-redundant.meme

echo "Complete tf_modisco report. Success."
