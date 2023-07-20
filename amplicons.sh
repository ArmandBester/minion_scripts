
mkdir nanofilt_qc amplicon_sorter

for bc in {01..24}
do
	echo Processing barcode $bc
	echo Running NanoFilt
	cat pass/barcode$bc/*.fastq | NanoFilt -q 12 -l 500 --maxlength 800 > nanofilt_qc/barcode$bc.fastq
	echo Running amplicon_sorter
	python3 ~/software/amplicon_sorter/amplicon_sorter.py -np 8 -i nanofilt_qc/barcode$bc.fastq -o amplicon_sorter


done

