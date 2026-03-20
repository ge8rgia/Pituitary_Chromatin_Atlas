#!/bin/bash

ChromBPnet() {
        local Tn5_bias_model="$1"
        local genome="$2"
	local cell_type="$3"
	local fileDir="$4"
	local modelDir="$5"

	# Check all inputs have been provided
        if [[ -z "$Tn5_bias_model" || -z "$genome" || -z "$cell_type" || -z "$fileDir" || -z "$modelDir" ]]; then
                echo "Beginning chrombpnet pipeline: $(date)"
                return 1
        fi

	# Define paths
	inputDir="/scratch/prj/stem_cells_pituitary/Georgia"
	genome_fasta="$inputDir/genome/$genome/${genome}.fa"
	genome_chrom_subset="$inputDir/genome/$genome/${genome}.chrom.subset.sizes"
	fold_name=$(basename "$Tn5_bias_model")
	fold_id="fold_${fold_name##*_}"

	# Check to see if model has already run
	final_file="$modelDir/${cell_type}_model/evaluation/overall_report.html"
	if [[ -f "$final_file" ]]; then
		echo "Skipping $cell_type: model already exists in $modelDir"
		return 0
	else
		echo "Report not found for $cell_type. New run starting."
		for sub in "auxiliary" "evaluation" "logs" "models"; do
			if [[ -d "$modelDir/${cell_type}_model/$sub" ]]; then
			   echo "Removing existing directory: $modelDir/${cell_type}_model/$sub"
			   rm -rf "$modelDir/${cell_type}_model/$sub"
			fi
		done
	fi

	echo "Beginning chrombpnet command for $cell_type : $(date)"

	# Run bias model training pipeline
	chrombpnet pipeline \
        	-ifrag "$fileDir/${cell_type}_merged_sorted.tsv.gz" \
        	-d "ATAC" \
        	-g "$genome_fasta" \
        	-c "$genome_chrom_subset" \
        	-p "$inputDir/ChromBPnet/data/$genome/peaks_no_blacklist.bed" \
        	-n "$inputDir/ChromBPnet/data/$genome/output_${fold_id}_negatives.bed" \
        	-fl "$inputDir/ChromBPnet/splits/$genome/${fold_id}.json" \
        	-b "$Tn5_bias_model/models/bias.h5" \
        	-o "$modelDir/${cell_type}_model"

	echo "Complete chrombpnet command for $cell_type : $(date)"

}

## Call Function

#fragment_list=("Corticotrophs" "Gonadotrophs")

#for cell in "${fragment_list[@]}"
#do
#     ChromBPnet \
#      	    /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/Bias_Models/Tn5_bias_model_fold_0 \
#	    "mm10" \
#	    "$cell" \
#	    /scratch/prj/stem_cells_pituitary/georgia_atac/mouse_merged \
#	    /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/Models
#done
