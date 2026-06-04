#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/2_ChromBPnet_exp10_NEO.out
#SBATCH --job-name=ChromBPnet_neo
#SBATCH --gres=gpu
#SBATCH --exclude=erc-hpc-comp040,erc-hpc-comp034,erc-hpc-comp039,erc-hpc-comp035
#SBATCH --cpus-per-task=5
#SBATCH --mem=100G
#SBATCH --time=30:00:00

cd /scratch/prj/stem_cells_pituitary/Georgia

# Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# Load dependencies for GPU to work
module load cuda/11.8.0-gcc-13.2.0
module load cudnn

export CUDA_HOME=/software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/cuda-11.8.0-k4tnio54miofdxttjlj6iilwqj7djrlz
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
export PATH="/scratch/users/k25055720/conda_envs/chrombpnet_new/bin:$PATH"

echo "--- Diagnostic Check ---"
echo "Hostname: $(hostname)"
echo "Sbatch GPU request: $CUDA_VISIBLE_DEVICES"
python -c "import tensorflow as tf; print('Num GPUs:', len(tf.config.list_physical_devices('GPU'))); print('Details:', tf.config.list_physical_devices('GPU'))"
nvidia-smi
echo "------------------------"

# General Paths
genome="mm10"
inputDir="/scratch/prj/stem_cells_pituitary/Georgia"
genome_fasta="$inputDir/genome/$genome/${genome}.fa"
genome_chrom_subset="$inputDir/genome/$genome/${genome}.chrom.subset.sizes"

# Specific Paths
experimentDir="/scratch/prj/stem_cells_pituitary/Bence/atacseq_results/10"
experiment_name="experiment_10"
Tn5_bias_model="/scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/Bias_Models/Tn5_bias_model_experiment_10_bias1.5"
modelDir="/scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/Models/experiments"

# Run bias model training pipeline
echo "Beginning chrombpnet command for $experiment_name : $(date)"

chrombpnet pipeline \
	-ibam "$experimentDir/bwa/merged_replicate/AtT20_NEO.mRp.clN.sorted.bam" \
        -d "ATAC" \
        -g "$genome_fasta" \
        -c "$genome_chrom_subset" \
        -p "$experimentDir/bwa/merged_replicate/macs2/broad_peak/consensus/att20_peaks_no_blacklist_2.bed" \
        -n "$experimentDir/bwa/merged_replicate/macs2/broad_peak/consensus/att20_output_negatives.bed" \
        -fl "$inputDir/ChromBPnet/splits/$genome/fold_0.json" \
        -b "$Tn5_bias_model/models/bias.h5" \
        -o "$modelDir/${experiment_name}_model_AtT20_NEO"

echo "Complete chrombpnet command for $experiment_name : $(date)"

