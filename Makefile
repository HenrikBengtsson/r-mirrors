SHELL=bash

## make CRAN_MIRROR=137.208.57.37
CRAN_MIRROR ?= cran.r-project.org
BIOC_MIRROR ?= master.bioconductor.org
BIOC_WWW ?= www.bioconductor.org

## Query Bioconductor for the current release version
BIOC_VERSION_RELEASE := $(shell curl --silent "https://${BIOC_WWW}/config.yaml" | grep -F "release_version:" | sed -E 's/.*release_version:[ ]*"([0-9.]+)".*/\1/g')
BIOC_VERSION_DEVEL := $(shell curl --silent "https://${BIOC_WWW}/config.yaml" | grep -F "devel_version:" | sed -E 's/.*devel_version:[ ]*"([0-9.]+)".*/\1/g')
BIOC_VERSION := $(BIOC_VERSION_RELEASE)
BIOC_VERSION_X := $(shell echo "$(BIOC_VERSION)" | sed -E 's/[.].*//')
BIOC_VERSION_Y := $(shell echo "$(BIOC_VERSION)" | sed -E 's/[^.]+[.]//')
BIOC_VERSION_Y_OLD := $(shell bc <<< "$(BIOC_VERSION_Y)-1")
BIOC_VERSION_OLD := $(BIOC_VERSION_X).$(BIOC_VERSION_Y_OLD)

OPTS = --dry-run
OPTS =

all: debug misc sync-all tsv-cran summary

debug:
	@echo "ftp_proxy=${ftp_proxy}"
	@echo "http_proxy=${http_proxy}"
	@echo "https_proxy=${https_proxy}"
	@echo "RSYNC_PROXY=${RSYNC_PROXY}"
	@echo "CRAN_MIRROR=${CRAN_MIRROR}"
	@echo "BIOC_MIRROR=${BIOC_MIRROR}"
	@echo "BIOC_WWW=${BIOC_WWW}"
	@echo "BIOC_VERSION_RELEASE=$(BIOC_VERSION_RELEASE)"
	@echo "BIOC_VERSION_DEVEL=$(BIOC_VERSION_DEVEL)"
	@echo "BIOC_VERSION=$(BIOC_VERSION)"
	@echo "BIOC_VERSION_X=$(BIOC_VERSION_X)"
	@echo "BIOC_VERSION_Y=$(BIOC_VERSION_Y)"
	@echo "BIOC_VERSION_OLD=$(BIOC_VERSION_OLD)"
	du -c -h misc cran bioconductor
#	curl --silent https://${BIOC_WWW}/config.yaml

summary:
	@echo "CRAN: $(shell find cran/ -type f -name *.tar.gz | wc -l) packages ($(shell du -s -h cran/ | cut -f 1))"
	@echo "BioCsoft $(BIOC_VERSION): $(shell find bioconductor/$(BIOC_VERSION)/bioc -type f -name *.tar.gz | wc -l) packages ($(shell du -s -h bioconductor/$(BIOC_VERSION)/bioc | cut -f 1))"
	@echo "BioCann $(BIOC_VERSION): $(shell find bioconductor/$(BIOC_VERSION)/data/annotation -type f -name *.tar.gz | wc -l) packages ($(shell du -s -h bioconductor/$(BIOC_VERSION)/data/annotation | cut -f 1))"
	@echo "BioCexp $(BIOC_VERSION): $(shell find bioconductor/$(BIOC_VERSION)/data/experiment -type f -name *.tar.gz | wc -l) packages ($(shell du -s -h bioconductor/$(BIOC_VERSION)/data/experiment | cut -f 1))"
	@echo "BioCworkflows $(BIOC_VERSION): $(shell find bioconductor/$(BIOC_VERSION)/workflows -type f -name *.tar.gz | wc -l) packages ($(shell du -s -h bioconductor/$(BIOC_VERSION)/workflows | cut -f 1))"

	@echo "BioCsoft $(BIOC_VERSION_OLD): $(shell find bioconductor/$(BIOC_VERSION_OLD)/bioc -type f -name *.tar.gz | wc -l) packages ($(shell du -s -h bioconductor/$(BIOC_VERSION_OLD)/bioc | cut -f 1))"
	@echo "BioCann $(BIOC_VERSION_OLD): $(shell find bioconductor/$(BIOC_VERSION_OLD)/data/annotation -type f -name *.tar.gz | wc -l) packages ($(shell du -s -h bioconductor/$(BIOC_VERSION_OLD)/data/annotation | cut -f 1))"
	@echo "BioCexp $(BIOC_VERSION_OLD): $(shell find bioconductor/$(BIOC_VERSION_OLD)/data/experiment -type f -name *.tar.gz | wc -l) packages ($(shell du -s -h bioconductor/$(BIOC_VERSION_OLD)/data/experiment | cut -f 1))"
#	@echo "BioCworkflows $(BIOC_VERSION_OLD): $(shell find bioconductor/$(BIOC_VERSION_OLD)/workflows -type f -name *.tar.gz | wc -l) packages ($(shell du -s -h bioconductor/$(BIOC_VERSION_OLD)/workflows | cut -f 1))"

misc: misc/icu55/data/icudt61l.zip

misc/icu55/data/icudt61l.zip:
	mkdir -p "$(@D)";
	cd "$(@D)"; \
	curl -O https://www.ibspan.waw.pl/~gagolews/stringi/"$(@F)"

sync-all: sync-cran sync-bioconductor sync-bioconductor-devel

sync-cran:
	mkdir -p cran/; \
	rsync \
	  --verbose --human-readable \
	  $(OPTS) \
	  --times \
	  --recursive \
	  --delete \
	  --include 'src/'\
          --include 'src/contrib/' \
          --include 'src/contrib/*.tar.gz' \
          --include 'src/contrib/PACKAGES*' \
          --include 'src/contrib/Meta/' \
          --include 'src/contrib/Meta/*.rds' \
	  --exclude '*' \
	  ${CRAN_MIRROR}::CRAN \
	  cran/

##	  -e "ssh" cran-rsync@${CRAN_MIRROR}: \

sync-bioconductor-packages:
	mkdir -p bioconductor/$(BIOC_VERSION_RELEASE)
	rm -f bioconductor/packages
	ln -fs $(BIOC_VERSION_RELEASE) bioconductor/packages

sync-bioconductor: sync-bioconductor-packages
	mkdir -p bioconductor/$(BIOC_VERSION)
	rsync --verbose --human-readable \
	  $(OPTS) \
	  --times \
	  --recursive \
	  --delete \
	  --include 'src/' \
	  --include 'src/contrib/' \
          --include 'src/contrib/*.tar.gz' \
          --include 'src/contrib/PACKAGES*' \
	  --include 'bioc/' \
	  --include 'data/' \
	  --include 'data/annotation/' \
	  --include 'data/experiment/' \
	  --include 'workflows/' \
	  --exclude '*' \
	  ${BIOC_MIRROR}::$(BIOC_VERSION) \
	  bioconductor/$(BIOC_VERSION)/

sync-bioconductor-devel-packages:
	mkdir -p bioconductor/$(BIOC_VERSION_DEVEL)
#	rm -f bioconductor/packages
#	ln -fs $(BIOC_VERSION_DEVEL) bioconductor/packages

sync-bioconductor-devel: sync-bioconductor-devel-packages
	mkdir -p bioconductor/$(BIOC_VERSION_DEVEL)
	rsync --verbose --human-readable \
	  $(OPTS) \
	  --times \
	  --recursive \
	  --delete \
	  --include 'src/' \
	  --include 'src/contrib/' \
          --include 'src/contrib/*.tar.gz' \
          --include 'src/contrib/PACKAGES*' \
	  --include 'bioc/' \
	  --include 'data/' \
	  --include 'data/annotation/' \
	  --include 'data/experiment/' \
	  --include 'workflows/' \
	  --exclude '*' \
	  ${BIOC_MIRROR}::$(BIOC_VERSION_DEVEL) \
	  bioconductor/$(BIOC_VERSION_DEVEL)/

list-cran:
	mkdir -p cran/; \
	rsync --verbose --human-readable \
	  --list-only \
	  --times \
	  --recursive \
	  --include 'src/' \
          --include 'src/contrib/' \
          --include 'src/contrib/PACKAGES*' \
          --include 'src/contrib/*.tar.gz' \
          --include 'src/contrib/Archive/' \
          --include 'src/contrib/Archive/*/' \
          --include 'src/contrib/Archive/*/*.tar.gz' \
	  --exclude '*' \
	  ${CRAN_MIRROR}::CRAN \
	  cran/


## Produce a tab-delimited file that can be read in R as:
##  data <- readr::read_tsv("cran_20171213-015554.tsv")
##                            
##   A tibble: 75,050 x 6
##           date     time         name version archived    size
##         <date>   <time>        <chr>   <chr>    <int>   <int>
##   1 2015-08-16 14:05:54           A3   1.0.0        0   42810
##   2 2016-10-20 01:52:18      ABC.RAP   0.9.0        0 4769661
##   3 2017-03-13 06:31:39  ABCanalysis   1.2.1        0   23436
##   4 2017-11-06 00:55:47     ABCoptim  0.15.0        0   13482
##   5 2016-02-04 02:27:29        ABCp2     1.2        0    7293
##   6 2016-02-04 02:27:30 ABHgenotypeR   1.0.1        0  100729
##   7 2016-03-10 08:55:17          ACA     1.0        0    8890
##   8 2012-10-29 05:13:35       ACCLMA     1.0        0    7465
##   9 2013-10-31 12:59:05          ACD   1.5.3        0   29286
##  10 2016-07-16 03:19:06         ACDm   1.0.4        0 1688818
tsv-cran:
	d=`date +%Y%m%d-%H%M%S` \
	f=cran_$$d.tsv; \
	printf 'date\ttime\tname\tversion\tarchived\tsize\n' > $$f ; \
	make list-cran | grep -E "[.]tar[.]gz[ ]*$$" | cut -c 11- | sed -E 's|^[ ]*||g' | sed 's|src/contrib/||' | sed -E 's| Archive/.*/(.*)[.]tar[.]gz| \1 1|' | sed -E 's|[.]tar[.]gz$$| 0|' | sed -E 's|_| |g' | sed 's|/|-|g' | awk '{ print $$2 "\t" $$3 "\t" $$4 "\t" $$5 "\t" $$6 "\t" $$1 }' >> $$f

