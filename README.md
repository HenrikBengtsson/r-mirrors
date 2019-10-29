# R Package Repositories - Local Mirrors

by Henrik Bengtsson


## Usage

```
make ## same as 'make sync-all'
make debug
make summary
make sync-all
make sync-cran
make sync-bioconductor
```

## CRAN

Calling
```sh
$ make sync-cran
```
will create/update a local CRAN package repository under `cran/` (in the current directory) with the following structure:
```
$ tree -d cran/
cran/
└── src
    └── contrib
        ├── PACKAGES
        ├── PACKAGES.gz
        ├── PACKAGES.in
        ├── PACKAGES.rds
        ├── A3_1.0.0.tar.gz
        ├── abbyyR_0.5.1.tar.gz
		:
        └── zyp_0.10-1.tar.gz
```

## Bioconductor

Calling
```sh
$ make sync-bioconductor
```
will create/update three local Bioconductor package repositories under `bioconductor/$BIOC_VERSION/` (in the current directory), where `$BIOC_VERSION` is the Bioconductor version (as automatically queried from Bioconductor):

* BioCsoft: Bioconductor Software packages (`bioconductor/$BIOC_VERSION/bioc`)
* BioCann:  Bioconductor Annotation Data packages (`bioconductor/$BIOC_VERSION/data/annotation`)
* BioCexp:  Bioconductor Experimental Data packages (`bioconductor/$BIOC_VERSION/data/experiment`)

Example of tree structure:
```sh
$ tree -d bioconductor/$BIOC_VERSION/bioc
cran/
└── src
    └── contrib
        ├── PACKAGES
        ├── PACKAGES.gz
        ├── PACKAGES.in
        ├── PACKAGES.rds
        ├── a4_1.26.0.tar.gz
        ├── a4Base_1.26.0.tar.gz
		:
        └── zlibbioc_1.24.0.tar.gz
```


## Statistics

As of 2017-11-09, the above package repositories contains:

* CRAN: 11,795 packages, 5.8 GiB disk space
* BioCsoft: 1,476 packages, 4.2 GiB disk space
* BioCann: 910 packages, 61 GiB disk space
* BioCexp: 324 packages, 31 GiB disk space
