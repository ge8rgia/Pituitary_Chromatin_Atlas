#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/1_split_tsv.out
#SBATCH --job-name=split
#SBATCH --cpus-per-task=8
#SBATCH --mem=80G
#SBATCH --time=20:00:00

# 0. Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# 1. Paths
rootdir=/scratch/prj/stem_cells_pituitary/georgia_atac
atacDir=$rootdir/mouse
barcodes=$rootdir/cell_metadata.csv

OUT=$rootdir/mouse_split
mkdir "$OUT"

# 2. List ATAC-seq data available
cd $atacDir
find . -mindepth 1 -maxdepth 1 -type d | sed 's|^\./||' | sort > "$OUT/sample_sheet.txt"
samples=($(cat "$OUT/sample_sheet.txt"))

echo ${samples[@]}
echo "==> Number of samples: ${#samples[@]} <==="

# 3. Iterate through each fragment.tsv.gz file

echo "Begin split by cell type iteration: $(date)"

for sample in "${samples[@]}"
do
	IN=$atacDir/$sample

	cd $OUT
	if [ ! -d "$OUT/$sample" ]; then
		mkdir -p "$OUT/$sample"
	fi
	cd $OUT/$sample

	# Get the .tsv.gz file
	FRAG_FILES=($IN/*fragments*.tsv.gz)
    	FRAGMENTS="${FRAG_FILES[0]}"

	echo "Processing $sample using the $FRAGMENTS file"

	# Filter barcode file for barcodes only associated to the ATAC-seq run
	barcodes_filtered="temp_${sample}_metadata.csv"
	head -n 1 "$barcodes" > "$barcodes_filtered"
	grep ",${sample}," "$barcodes" >> "$barcodes_filtered"

	# Extract barcodes and map to cell_type name
	zcat "$FRAGMENTS" | awk -v barcodefile="$barcodes_filtered" -v s="$sample" '
		BEGIN {
            	   while ((getline < barcodefile) > 0) {
                	if ($0 !~ /sample|Sex/) {
			split($0, csv, ",")
			split(csv[1], bc_parts, ":")
                    	barcode = bc_parts[2]
                    	map[barcode] = csv[7]
               		 }
		   }
            	close(barcodefile)
            	FS = "\t"
		OFS = "\t"
	        }
		{
            	   $1=$1
            	   ctype = map[$4]
            	   if (ctype != "") {
                	gsub(/ /, "_", ctype)
                	outfile = s "_" ctype ".tsv"
                	print $0 >> outfile
            	   }
        	}'

	echo "Begin the sort, zip, and index for $sample"
	# Sort, zip, and index output files
	for file in "${sample}"_*.tsv; do
		[ -e "$file" ] || continue
		echo "Sorting and indexing $file..."
		sort -k1,1 -k2,2n "$file" | bgzip > "${file}.gz"
		tabix -p bed "${file}.gz"
		rm "$file"
	done

	echo "===> Done processing $sample : $(date) <===="
done

echo "Cell type separation complete : $(date)"


