#!/bin/bash

TFModisco() {
	local outputsDir="$1"
        local jaspar_file="$2"
	local condition="$3"

	# Check all inputs have been provided
        if [[ -z "$outputsDir" || -z "$jaspar_file" || -z "$condition" ]]; then
                echo "Beginning TFModisco pipeline: $(date)"
                return 1
        fi

	# Define paths
	MODISCO_EXE=$(which modisco | sed "s|/users/k25055720/.local/bin/modisco|/scratch/users/k25055720/conda_envs/chrombpnet_new/bin/modisco|")
	inputDir="/scratch/prj/stem_cells_pituitary/Georgia"

	for cell_folder in "$outputsDir"/*
	do
		cell_type=$(basename "$cell_folder")
		cellDir="$outputsDir/$cell_type"
		contribsDir="$cellDir/contribs_bw"
		modiscoDir="$cellDir/tf_modisco"

		# Make sure cell type aligns with condition
		test_combination="$contribsDir/${cell_type}_${condition}_contribs.profile_scores.h5"
		if [[ ! -f "$test_combination" ]]; then
			continue
		fi

		echo "Processing $cell_type with $condition"

		# Run first motifs command
		final_file="$modiscoDir/${condition}_modisco_results.h5"
		if [[ -f "$final_file" ]]; then
			echo "modisco_results.h5 exists for $cell_type. Moving to report generation"
		else
			echo "modisco_results.h5 does not exist. New run starting."
			echo "Beginning tf_modisco motifs command for $cell_type : $(date)"

			$MODISCO_EXE motifs \
    				-i "$contribsDir/${cell_type}_${condition}_contribs.profile_scores.h5" \
    				-n 50000 \
    				-o "$final_file"
		fi

		# Run TFmodisco report command
		final_file="$modiscoDir/${condition}_modisco_report/motifs.html"
		if [[ -f "$final_file" ]]; then
                        echo "Skipping report for $cell_type: $final_file exists."
                        continue
                else
                        echo "Report for $cell_type does not exist. New run starting."
			rm -rf "$modiscoDir/${condition}_modisco_report"
			echo "Beginning TFmodisco report command"

			$MODISCO_EXE report \
			        -i "$modiscoDir/${condition}_modisco_results.h5" \
			        -o "$modiscoDir/${condition}_modisco_report/" \
			        -s "$modiscoDir/${condition}_modisco_report/" \
			        -m "$jaspar_file"
		fi

		echo "Complete TFModisco for $cell_type : $(date)"

	done
}

## Call Function

#TFModisco \
#	 $outputsDir \
#        $jaspar_file \
#	 $condition
