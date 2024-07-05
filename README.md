## Background

This is a place for me to keep some scripts I use for minion data analysis.

## Software used

[NanoFilt](https://github.com/wdecoster/nanofilt)

[amplicon_sorter](https://github.com/avierstr/amplicon_sorter)

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

dorado demux --output-dir demux/ --no-classify calls.bam
```

## Example of fastq and fasta conversion

```bash
for bc in {17..24}; do bamToFastq -i SQK-NBD114-24_barcode$bc.bam -fq SQK-NBD114-24_barcode$bc.fastq; done

for bc in {17..24}; do seqkit fq2fa fastq_files/SQK-NBD114-24_barcode$bc.fastq  > fasta_files/SQK-NBD114-24_barcode$bc.fasta; done
```


