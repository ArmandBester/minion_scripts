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

