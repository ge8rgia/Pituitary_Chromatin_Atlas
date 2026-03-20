#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/1_general_model_training.out
#SBATCH --job-name=scprint_bulk
#SBATCH --gres=gpu
#SBATCH --exclude=erc-hpc-comp038,erc-hpc-comp039
#SBATCH --cpus-per-task=4
#SBATCH --mem=100G
#SBATCH --time=48:00:00

cd /scratch/prj/stem_cells_pituitary/Georgia

# Activate scprint environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate scprint

# Load dependencies for GPU to work
module load cuda/11.8.0-gcc-13.2.0
module load cudnn

export CUDA_HOME=/software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/cuda-11.8.0-k4tnio54miofdxttjlj6iilwqj7djrlz
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
export PATH="/scratch/users/k25055720/conda_envs/scprint/bin:$PATH"

echo "--- Diagnostic Check ---"
python -c "import torch; print('Using Torch from:', torch.__file__)"
python -c "import torch; print('Torch CUDA version:', torch.version.cuda)"
python -c "import torch; print('Can Torch see GPU?:', torch.cuda.is_available())"
nvidia-smi
echo "------------------------"

python -c "import torch; torch.amp = torch.cuda.amp"

# Run pseudobulk training pipeline for fold0
seq2print_train \
	--config /scratch/prj/stem_cells_pituitary/Georgia/scPRINT/GSM4594389/configs/GSM4594389_fold0.JSON \
	--temp_dir /scratch/prj/stem_cells_pituitary/Georgia/scPRINT/GSM4594389/temp \
	--model_dir /scratch/prj/stem_cells_pituitary/Georgia/scPRINT/GSM4594389/model \
	--data_dir /scratch/prj/stem_cells_pituitary/Georgia/scPRINT/GSM4594389 \
	--project scprint_GSM4594389 \
	--enable_wandb
