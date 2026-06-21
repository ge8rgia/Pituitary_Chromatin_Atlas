#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/2_ChromBPnet_young2.out
#SBATCH --job-name=ChromBPnet
#SBATCH --gres=gpu
#SBATCH --exclude=erc-hpc-comp040,erc-hpc-comp034,erc-hpc-comp039
#SBATCH --cpus-per-task=5
#SBATCH --mem=100G
#SBATCH --time=48:00:00

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

# Function
source /scratch/prj/stem_cells_pituitary/Georgia/scripts/functions/ChromBPnet.sh

# Run bias model training pipeline

fragment_list=("Corticotrophs" "Gonadotrophs" "Lactotrophs" "Melanotrophs" "Somatotrophs" "Stem_cells" "Thyrotrophs")

echo "Begin ChromBPnet models: $(date)"

for cell in "${fragment_list[@]}"
do
	ChromBPnet \
		/scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/Bias_Models/Tn5_bias_model_fold_0_young_celltype_bias0.9 \
		"mm10" \
		"$cell" \
		/scratch/prj/stem_cells_pituitary/georgia_atac/mouse_young_merged \
		/scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/Models/mouse_young
done

echo "Done all ChromBPnet models: $(date)"
