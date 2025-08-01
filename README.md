## Background

This is a place for me to keep some scripts I use for minion data analysis.


## Example of guppy bascalling

```bash
guppy_basecaller -i [input_folder] -r -s [output_folder] -x "cuda:all" \
                 -c dna_r9.4.1_450bps_hac.cfg --min_qscore 10 --num_callers 4 \
                 --gpu_runners_per_device 8 --enable_trim_barcodes --trim_adapters \
                 --require_barcodes_both_ends --barcode_kits "EXP-NBD104 EXP-NBD114"
```

## Example of using dorado

```bash
dorado basecaller dna_r10.4.1_e8.2_400bps_sup@v4.3.0 pod5/  --min-qscore 10 --kit-name SQK-NBD114-24 > calls.bam

# to trim all barcodes and adapters and require barcode to be at both ends
dorado basecaller dna_r10.4.1_e8.2_400bps_sup@v4.3.0 pod5 --min-qscore 10 --kit-name SQK-NBD114-24 --barcode-both-ends --trim all > calls.bam

dorado basecaller dna_r10.4.1_e8.2_400bps_sup@v5.0.0 -r no_sample_id/ --min-qscore 10 --kit-name SQK-NBD114-96 --barcode-both-ends --trim all > calls.bam


dorado demux --output-dir demux/ --emit-fastq --no-classify calls.bam
```

## Example of fastq and fasta conversion

```bash
for bc in {17..24}; do bamToFastq -i SQK-NBD114-24_barcode$bc.bam -fq SQK-NBD114-24_barcode$bc.fastq; done

for bc in {17..24}; do seqkit fq2fa fastq_files/SQK-NBD114-24_barcode$bc.fastq  > fasta_files/SQK-NBD114-24_barcode$bc.fasta; done
```

## Simple statistics

```bash
for bc in {17..24}
do
seqkit stats -a fastq_files/SQK-NBD114-24_barcode$bc.fastq 
done
```

## Kraken2 on the UFS HPC
[UFS HPC](https://docs.ern.ufs.ac.za)

This is an example of how to run kraken2 on the UFS HPC utilizing a for loop

```bash
module load ern
ern_shell
```
```bash
module load cluster/hpc
```


```bash
for i in {01..96}  # change this range
do
   echo "Running kraken2 on bc$i"
   ern jobs submit --quiet --name=kraken04.kraken2.barcode$i \
   --threads=16 --memory=128gb --hours=100 \
   --input="fastq_pass_v5/*barcode$i.fastq" \
   --input="kraken_out/" \
   --module='kraken/1.2_754d9b0 python=3.10' \
   --command=kraken2 -- --db Standard --threads 16 \
   --report kraken_out/barcode$i.k2report \
   --output kraken_out/barcode$i.kraken2 \
   --report-minimizer-data \
   fastq_pass_v5/*barcode$i.fastq
done
```
```bash
for i in {15..36}
do
   echo "Running kraken2 on bc$i"
   ern jobs submit --quiet --name=kraken10.kraken2.barcode$i \
   --threads=16 --memory=300gb --hours=100 \
   --input="fastq_pass/*barcode$i.fastq" \
   --input="kraken_core_nt/" \
   --module='kraken/1.2_754d9b0 python=3.10' \
   --command=kraken2 -- --db core_nt --threads 16 \
   --report kraken_core_nt/barcode$i.k2report \
   --output kraken_core_nt/barcode$i.kraken2 \
   --report-minimizer-data \
   fastq_pass/*barcode$i.fastq
done
```



To check the queue (remember to load cluster/hpc)
```bash
qstat -a
```

**generate text files for krona**

```bash
for i in {01..96} # change this range
do
  kreport2krona.py -r k2report_files/barcode$i.k2report --no-intermediate-ranks -o krona_text_files/barcode$i-krona.txt
done

```
**now run krona on all the above files**

```bash
 ktImportText krona_text_files/*
```
## TB profiler
```bash
for r in {03..08}
do
  echo "TB profiling $r"
  tb-profiler profile --read1 ../fastq_pass_supv5/d11d1c3891aef84b30857ebf795a74e93095769e_SQK-NBD114-96_barcode$r.fastq \
  --platform nanopore --call_whole_genome --prefix run03_bc$r --threads 6 --csv --snp_dist 5
done
```

## Giovannie amplicon sorter script

[https://github.com/wdecoster/nanoQC](https://github.com/wdecoster/nanoQC)

```bash
nanoq -i "$dir/$new_name" -o "$dir/nanoq_output.fastq" -r "$dir/report.txt" -m 1000 -q 12
 
```

```bash
for i in {47..69}
do
  echo "running nanoq on $i"
  nanoq -i ../fastq_pass/*barcode$i.fastq -o nanoq/nanoq_barcode$i.fastq -q 12 -r nanoq/nanoq_barcode$i_report.txt -m 2000
done

```



```bash
#!/bin/bash
 
# Set the path to the directory containing the folders with fastq.gz files

base_dir="/home/gghielmetti/16_20240321_rachielcattlefeces/50"
 
# Iterate through each directory in the base directory

for dir in "$base_dir"/*; do

  if [[ -d "$dir" ]]; then

    echo "Processing directory: $dir"
 
    # Get the directory name

    dir_name=$(basename "$dir")
 
    # Rename the concatenated.fastq.gz file with the name of the directory

    mv "$dir/nanoq_output.fastq" "$dir/${dir_name}_nanoq_output.fastq"
 
 
    # Run Amplicon Sorter on the renamed concatenated.fastq file

    python amplicon_sorter_2023-06-19.py -i "$dir/${dir_name}_nanoq_output.fastq" -o "$dir/amplicon_output_q12_max200000" -min 50 -max 2000 -np 16 -maxr 200000
 
    echo "Amplicon Sorter completed for directory: $dir"

    echo

  fi

done

```


