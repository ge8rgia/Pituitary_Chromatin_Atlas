#!/bin/bash

PredBW() {
	local biasDir="$1"
        local modelDir="$2"
        local genome="$3"
	local BEDfile="$4"
	local outDir="$5"

	# Check all inputs have been provided
        if [[ -z "$biasDir" || -z "$modelDir" || -z "$genome" || -z "$BEDfile" || -z "$outDir" ]]; then
                echo "Beginning PredBW pipeline: $(date)"
                return 1
        fi

	# Define paths
	inputDir="/scratch/prj/stem_cells_pituitary/Georgia"
	genome_fasta="$inputDir/genome/$genome/${genome}.fa"
	genome_chrom_sizes="$inputDir/genome/$genome/${genome}.chrom.sizes"

	for model_folder in "$modelDir"/*_model
	do
		folder_name=$(basename "$model_folder")
		cell_type="${folder_name%_model}"
		cellDir="$outDir/$cell_type/pred_bw"

		# Check to see if model has already run
		final_file="$cellDir/${cell_type}_predicted_bias.bw"
		if [[ -f "$final_file" ]]; then
			echo "Skipping $cell_type: $final_file exists."
			continue
		else
			echo "$final_file does not exist. New run starting."
			rm -rf "$cellDir"
			mkdir -p "$cellDir"
		fi

		echo "Beginning pred_bw command for $cell_type : $(date)"

		# Run deepLIFT contribution score pipeline
		chrombpnet pred_bw \
		        -bm "$biasDir/models/bias.h5" \
        		-cm "$model_folder/models/chrombpnet.h5" \
        		-cmb "$model_folder/models/chrombpnet_nobias.h5" \
        		-r "$BEDfile" \
        		-g "$genome_fasta" \
        		-c "$genome_chrom_sizes" \
        		-op "$cellDir/${cell_type}_predicted"

		echo "Complete pred_bw command for $cell_type : $(date)"

	done
}

## Call Function

#PredBW \
#	 $biasDir
#        $modelDir
#        $genome
#        $BEDfile
#        $outDir

