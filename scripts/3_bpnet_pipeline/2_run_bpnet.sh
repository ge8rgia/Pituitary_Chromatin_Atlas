#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/2_run_bpnet.out
#SBATCH --job-name=run_bpnet
#SBATCH --gres=gpu
#SBATCH --exclude=erc-hpc-comp040,erc-hpc-comp034,erc-hpc-comp039
#SBATCH --cpus-per-task=5
#SBATCH --mem=100G
#SBATCH --time=04:00:00

cd /scratch/prj/stem_cells_pituitary/Georgia/bpnet/exp20_CUTandRUN_PIT1_chr13

# Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate bpnet_lite

# Load dependencies for GPU to work
module load cuda/11.8.0-gcc-13.2.0
module load cudnn

export CUDA_HOME=/software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/cuda-11.8.0-k4tnio54miofdxttjlj6iilwqj7djrlz
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
export PATH="/scratch/users/k25055720/conda_envs/bpnet_lite/bin:$PATH"

echo "--- Diagnostic Check ---"
echo "Hostname: $(hostname)"
echo "Sbatch GPU request: $CUDA_VISIBLE_DEVICES"
python -c "import tensorflow as tf; print('Num GPUs:', len(tf.config.list_physical_devices('GPU'))); print('Details:', tf.config.list_physical_devices('GPU'))"
nvidia-smi
echo "------------------------"

# Command for running bpnet on experiment 20 - CUTandRUN TaT1 mouse (POU1F1 validation)

echo "Generating bpnet model: $(date)"

bpnet pipeline -p /scratch/prj/stem_cells_pituitary/Georgia/bpnet/exp20_CUTandRUN_PIT1_chr13/exp20_PIT1_pipeline_nomodiscoreport.json

echo "bpnet model done: $(date)"


