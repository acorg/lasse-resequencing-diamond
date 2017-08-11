# Lasse requencing initial pipeline spec

This repo contains a
[slurm-pipeline](https://github.com/acorg/slurm-pipeline) specification
file (`specification.json`) and associated scripts for processing Lasse's
resequencing data.

## Pipeline steps

* `00-start`: Logging. Find input FASTQ files for a sample, check they
  exist, issue a task for each.
* `01-stats`: Collect statistics on the original (trimmed) FASTQ files.
* `02-map`: Map reads to the human genome using bwa. Find unmapped reads
  for the next stage of processing.
* `03-diamond`: Map the non-human reads to a viral protein database.
* `04-panel`: Make a [dark matter](https://github.com/acorg/dark-matter/) panel of blue plots.
* `05-sample-count`: Count the number of reads per sample (summing the
  sequencing read counts from `01-stats`).
* `06-stop`: Logging. Create `slurm-pipeline.done` in top-level dir.

## Output

The scripts in `00-start`, etc. are all submitted by `sbatch` for execution
under [SLURM](http://slurm.schedmd.com/). The final step, `04-panel` leaves
its output in `04-panel/out`.

## Cleaning up

There are 3 `Makefile` targets for cleaning up, `clean-1`, `clean-2`, and
`clean-3`. These increase in severity. See the `Makefile` to see what
exactly is removed by each target. You can run these by, e.g.,

```sh
$ make clean-1
```

`clean-1` throws away the large intermediate files created by the pipeline.
E.g., information about how many reads mapped to the human genome can be
found in the `03-find-unmapped/slurm-*.out`. Make sure you know what you're
doing if you clean up, else you may need to recreate these files at some
point.
