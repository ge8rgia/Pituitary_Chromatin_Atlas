#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/5_MarginalFootprints_clusters_adult_gonado.out
#SBATCH --job-name=MF_gonado
#SBATCH --gres=gpu
#SBATCH --exclude=erc-hpc-comp038,erc-hpc-comp039,erc-hpc-comp040,erc-hpc-comp031,erc-hpc-comp035
#SBATCH --cpus-per-task=2
#SBATCH --mem=75G
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
source /scratch/prj/stem_cells_pituitary/Georgia/scripts/functions/MarginalFootprints.sh

# Run pipeline on adult mice
#cell_types_list=("Corticotrophs" "Gonadotrophs" "Lactotrophs" "Melanotrophs" "Somatotrophs" "Stem_cells" "Thyrotrophs")
cell_types_list=("Gonadotrophs")

echo "Beginning List 1: $(date)"

for cell in "${cell_types_list[@]}"
do
     MarginalFootprints_clusters \
           "mm10" \
           "fold_0" \
           /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/data/motif_seqs/PCA_motif_sequences_1.tsv \
           /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs/mouse \
           "$cell" \
	   "PCAmotifs1"
done

echo "Done List 1: $(date)"
echo "Beginning List 2: $(date)"

for cell in "${cell_types_list[@]}"
do
     MarginalFootprints_clusters \
           "mm10" \
           "fold_0" \
           /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/data/motif_seqs/PCA_motif_sequences_2.tsv \
           /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs/mouse \
           "$cell" \
           "PCAmotifs2"
done

echo "Done List 2: $(date)"
echo "Beginning List 3: $(date)"

for cell in "${cell_types_list[@]}"
do
     MarginalFootprints_clusters \
           "mm10" \
           "fold_0" \
           /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/data/motif_seqs/PCA_motif_sequences_3.tsv \
           /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs/mouse \
           "$cell" \
           "PCAmotifs3"
done

echo "Done List 3: $(date)"
