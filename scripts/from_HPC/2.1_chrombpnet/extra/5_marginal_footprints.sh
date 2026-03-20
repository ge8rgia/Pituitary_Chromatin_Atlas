#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/5_marginal_footprints.out
#SBATCH --job-name=footprints
#SBATCH --gres=gpu
#SBATCH --exclude=erc-hpc-comp038,erc-hpc-comp039
#SBATCH --cpus-per-task=4
#SBATCH --mem=50G
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
python -c "import torch; print('Using Torch from:', torch.__file__)"
python -c "import torch; print('Torch CUDA version:', torch.version.cuda)"
python -c "import torch; print('Can Torch see GPU?:', torch.cuda.is_available())"
nvidia-smi
echo "------------------------"

echo "Begin marginal footprinting: $(date)"

# Run marginal footprint command
chrombpnet footprints \
	-m ChromBPnet/test_lactotrophs/chrombpnet_model/models/chrombpnet_nobias.h5 \
	-r ChromBPnet/test_lactotrophs/output_f0_negatives.bed \
	-g genome/mm10.fa \
	-fl ChromBPnet/splits/fold_0.json \
	--output-prefix ChromBPnet/test_lactotrophs/data/test_footprints \
	--motifs-to-pwm ChromBPnet/test_lactotrophs/lactotroph_motifs.tsv

echo "Complete marginal footprinting: $(date). Success."
