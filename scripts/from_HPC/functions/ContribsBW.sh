#!/bin/bash

ContribsBW() {
        local modelDir="$1"
	local cell="$2"
        local genome="$3"
	local BEDfile="$4"
	local outDir="$5"

	# Check all inputs have been provided
        if [[ -z "$modelDir" || -z "$cell" || -z "$genome" || -z "$BEDfile" || -z "$outDir" ]]; then
                echo "Beginning ContribsBW pipeline: $(date)"
                return 1
        fi

	# Define paths
	inputDir="/scratch/prj/stem_cells_pituitary/Georgia"
	genome_fasta="$inputDir/genome/$genome/${genome}.fa"
	genome_chrom_subset="$inputDir/genome/$genome/${genome}.chrom.subset.sizes"

	cell_type="$cell"
	cellDir="$outDir/$cell_type/contribs_bw"
	output_name=$(basename "$BEDfile" .bed.gz)

	# Check to see if model has already run
	final_file="$cellDir/${cell_type}_${output_name}_contribs.profile_scores.bw"
	if [[ -f "$final_file" ]]; then
		echo "Skipping $cell_type: $final_file exists."
		return 0
	else
		echo "$final_file does not exist. New run starting."
	fi

	echo "Beginning contribs_bw command for $cell_type : $(date)"

	# Run deepLIFT contribution score pipeline
	chrombpnet contribs_bw \
       		-m "$modelDir/${cell_type}_model/models/chrombpnet_nobias.h5" \
       		--regions "$BEDfile" \
       		-g "$genome_fasta" \
       		-c "$genome_chrom_subset" \
		-op "$cellDir/${cell_type}_${output_name}_contribs"

	echo "Complete contribs_bw command for $cell_type : $(date)"

}

## Call Function

#cell_type_list=c("______")

#for cell in ${cell_type_list[@]}
#do
#	ContribsBW \
#		$modelDir \
#		$cell \
#		$genome \
#		$BEDfile \
#		$outDir
#done
