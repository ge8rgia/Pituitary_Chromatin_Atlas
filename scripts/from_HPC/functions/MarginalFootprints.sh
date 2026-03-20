#!/bin/bash

MarginalFootprints() {
        local genome="$1"
        local fold_id="$2"
        local motif_sequences="$3"
        local outDir="$4"
        local cell_type="$5"
	local batch_id="$6"

        # Check all inputs have been provided
        if [[ -z "$genome" || -z "$fold_id" || -z "$motif_sequences" || -z "$outDir" || -z "$cell_type" ]]; then
                echo "Beginning MarginalFootprint pipeline: $(date)"
                return 1
        fi

        # Define paths
        inputDir="/scratch/prj/stem_cells_pituitary/Georgia"
        genome_fasta="$inputDir/genome/$genome/${genome}.fa"
        genome_chrom_subset="$inputDir/genome/$genome/${genome}.chrom.subset.sizes"
        fold_json="$inputDir/ChromBPnet/splits/$genome/${fold_id}.json"
        background_regions="$inputDir/ChromBPnet/data/$genome/output_${fold_id}_negatives.bed"

        # Make marginal_footprints folder if it doesn't already exist
        footprintDir="$outDir/$cell_type/marginal_footprints"
        if [ ! -d "$footprintDir" ]; then
                mkdir -p "$footprintDir"
        fi

        echo "Beginning marginal footprinting command for $cell_type : $(date)"

        # Run chrombpnet footprints pipeline
        chrombpnet footprints \
                -m "$inputDir/ChromBPnet/Models/${cell_type}_model/models/chrombpnet_nobias.h5" \
                -r "$background_regions" \
                -g "$genome_fasta" \
                -fl "$fold_json" \
                --output-prefix "$outDir/$cell_type/marginal_footprints/${cell_type}_${batch_id}" \
                --motifs-to-pwm "$motif_sequences"

        echo "Complete marginal footprinting command for $cell_type : $(date)"

}

## Call Function

#cell_types_list=("Corticotrophs" "Gonadotrophs")

#for cell in "${cell_types_list[@]}"
#do
#     MarginalFootprints \
#           "mm10" \
#           "fold_0" \
#           /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/data/motif_sequences_subset.tsv \
#           /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs \
#           "$cell"
#	    "$batch_id"
#done

