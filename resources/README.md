# Resources for variant integration


Per-read group contamination estimates estimated from sequencing data using
[VerifyBamID](http://genome.sph.umich.edu/wiki/VerifyBamID).  The "free"
estimates (non-chip) were used.  Per-read group estimates allow for the use of
contamination estimates when mixing exome and low-coverage data.

    p3.exome_lowcov.per_RG.het_and_contam.contaminations


A copy-number variation map, accounting for the PAR on the X, single-copy of
non-PAR in males, and single-copy and 0-copy of Y.  This is used by default,
but only has effect in the X and Y.

    sample_cnv_map.X_PAR1_PAR2_Y.bed


20 random exome and low-coverage samples were selected, and coverage was
calculated using bamtools coverage.  This coverage information was used to
determine a set of regions containing approximately equivalent amounts of
sequencing data.  This is done to normalize runtime for the jobs, as even
genomic regions can have extremely wide variance in runtime.  There are 54453
regions.

    regions
    regions/20files.chr1.even_coverage.regions
    ..
    regions/20files.chrY.even_coverage.regions
