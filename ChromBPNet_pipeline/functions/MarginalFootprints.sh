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

        # Assign genome_name based on genome input
        local genome_name=""
        case "$genome" in
                rn6)  genome_name="rat" ;;
                mm10) genome_name="mouse" ;;
                hg38) genome_name="human" ;;
                *)
                        echo "Error: Unknown genome '$genome'. Expected rn6, mm10, or hg38."
                        return 1
                        ;;
        esac

        # Define paths
        inputDir="/scratch/prj/stem_cells_pituitary/Georgia"
        genome_fasta="$inputDir/genome/$genome/${genome}.fa"
        genome_chrom_subset="$inputDir/genome/$genome/${genome}.chrom.subset.sizes"
        fold_json="$inputDir/ChromBPnet/splits/$genome/${fold_id}.json"
        background_regions="$inputDir/ChromBPnet/data/$genome/peaks/output_${fold_id}_negatives.bed"

        # Make marginal_footprints folder if it doesn't already exist
        footprintDir="$outDir/$cell_type/marginal_footprints"
        if [ ! -d "$footprintDir" ]; then
                mkdir -p "$footprintDir"
        fi

        echo "Beginning marginal footprinting command for $cell_type : $(date)"

        # Run chrombpnet footprints pipeline
        chrombpnet footprints \
                -m "$inputDir/ChromBPnet/Models/${genome_name}/${cell_type}_model/models/chrombpnet_nobias.h5" \
                -r "$background_regions" \
                -g "$genome_fasta" \
                -fl "$fold_json" \
                --output-prefix "$outDir/$cell_type/marginal_footprints/${cell_type}_${batch_id}" \
                --motifs-to-pwm "$motif_sequences"

        echo "Complete marginal footprinting command for $cell_type : $(date)"

}

MarginalFootprints_young() {
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
        background_regions="$inputDir/ChromBPnet/data/$genome/young_peaks/output_${fold_id}_negatives.bed"

        # Make marginal_footprints folder if it doesn't already exist
        footprintDir="$outDir/$cell_type/marginal_footprints"
        if [ ! -d "$footprintDir" ]; then
                mkdir -p "$footprintDir"
        fi

        echo "Beginning marginal footprinting command for $cell_type : $(date)"

        # Run chrombpnet footprints pipeline
        chrombpnet footprints \
                -m "$inputDir/ChromBPnet/Models/mouse_young/${cell_type}_model/models/chrombpnet_nobias.h5" \
                -r "$background_regions" \
                -g "$genome_fasta" \
                -fl "$fold_json" \
                --output-prefix "$outDir/$cell_type/marginal_footprints/${cell_type}_${batch_id}" \
                --motifs-to-pwm "$motif_sequences"

        echo "Complete marginal footprinting command for $cell_type : $(date)"

}

MarginalFootprints_experiment() {
        local genome="$1"
        local fold_id="$2"
        local motif_sequences="$3"
        local outDir="$4"
        local experiment="$5"
        local batch_id="$6"

        # Check all inputs have been provided
        if [[ -z "$genome" || -z "$fold_id" || -z "$motif_sequences" || -z "$outDir" || -z "$experiment" ]]; then
                echo "Beginning MarginalFootprint pipeline: $(date)"
                return 1
        fi

        # Define paths
        inputDir="/scratch/prj/stem_cells_pituitary/Georgia"
        genome_fasta="$inputDir/genome/$genome/${genome}.fa"
        genome_chrom_subset="$inputDir/genome/$genome/${genome}.chrom.subset.sizes"
        fold_json="$inputDir/ChromBPnet/splits/$genome/${fold_id}.json"

        exp_number=$(echo "$experiment" | cut -d'_' -f2)
        exp_condition=$(echo "$experiment" | cut -d'_' -f3)

        background_regions="/scratch/prj/stem_cells_pituitary/Bence/atacseq_results/${exp_number}/bwa/merged_replicate/macs2/broad_peak/${exp_condition}_output_negatives.bed"

        # Make marginal_footprints folder if it doesn't already exist
        footprintDir="$outDir/$experiment/marginal_footprints"
        if [ ! -d "$footprintDir" ]; then
                mkdir -p "$footprintDir"
        fi

        echo "Beginning marginal footprinting command for $experiment : $(date)"

        # Run chrombpnet footprints pipeline
        chrombpnet footprints \
                -m "$inputDir/ChromBPnet/Models/experiments/${experiment}_model/models/chrombpnet_nobias.h5" \
                -r "$background_regions" \
                -g "$genome_fasta" \
                -fl "$fold_json" \
                --output-prefix "$outDir/$experiment/marginal_footprints/${experiment}_${batch_id}" \
                --motifs-to-pwm "$motif_sequences"

        echo "Complete marginal footprinting command for $experiment : $(date)"

}

MarginalFootprints_clusters() {
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

	# Assign genome_name based on genome input
        local genome_name=""
        case "$genome" in
                rn6)  genome_name="rat" ;;
                mm10) genome_name="mouse" ;;
                hg38) genome_name="human" ;;
                *)
			echo "Error: Unknown genome '$genome'. Expected rn6, mm10, or hg38."
                        return 1
                        ;;
        esac

        # Define paths
        inputDir="/scratch/prj/stem_cells_pituitary/Georgia"
        genome_fasta="$inputDir/genome/$genome/${genome}.fa"
        genome_chrom_subset="$inputDir/genome/$genome/${genome}.chrom.subset.sizes"
        fold_json="$inputDir/ChromBPnet/splits/$genome/${fold_id}.json"
        background_regions="$inputDir/ChromBPnet/data/$genome/peaks/output_${fold_id}_negatives.bed"

        # Make marginal_footprints folder if it doesn't already exist
        footprintDir="$outDir/$cell_type/marginal_footprints_clusters"
        if [ ! -d "$footprintDir" ]; then
                mkdir -p "$footprintDir"
        fi

        echo "Beginning marginal footprinting command for $cell_type : $(date)"

        # Run chrombpnet footprints pipeline
        chrombpnet footprints \
                -m "$inputDir/ChromBPnet/Models/${genome_name}/${cell_type}_model/models/chrombpnet_nobias.h5" \
                -r "$background_regions" \
                -g "$genome_fasta" \
                -fl "$fold_json" \
                --output-prefix "$outDir/$cell_type/marginal_footprints_clusters/${cell_type}_${batch_id}" \
                --motifs-to-pwm "$motif_sequences"

        echo "Complete marginal footprinting command for $cell_type : $(date)"

}

MarginalFootprints_young_clusters() {
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
        background_regions="$inputDir/ChromBPnet/data/$genome/young_peaks/output_${fold_id}_negatives.bed"

        # Make marginal_footprints folder if it doesn't already exist
        footprintDir="$outDir/$cell_type/marginal_footprints_clusters"
        if [ ! -d "$footprintDir" ]; then
                mkdir -p "$footprintDir"
        fi

        echo "Beginning marginal footprinting command for $cell_type : $(date)"

        # Run chrombpnet footprints pipeline
        chrombpnet footprints \
                -m "$inputDir/ChromBPnet/Models/mouse_young/${cell_type}_model/models/chrombpnet_nobias.h5" \
                -r "$background_regions" \
                -g "$genome_fasta" \
                -fl "$fold_json" \
                --output-prefix "$outDir/$cell_type/marginal_footprints_clusters/${cell_type}_${batch_id}" \
                --motifs-to-pwm "$motif_sequences"

        echo "Complete marginal footprinting command for $cell_type : $(date)"

}
