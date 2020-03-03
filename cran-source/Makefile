SRC=/wynton/home/cbi/shared/mirrors/r-mirrors/cran/src/contrib

untar:
	mkdir -p src/
	cd src/; \
	for ff in "$(SRC)"/*.tar.gz; do \
	  pkg=$$(basename "$${ff/_*.tar.gz/}"); \
	  printf "$$pkg ... "; \
	  [[ ! -d "$$pkg" ]] && tar zxf "$$ff"; \
	  echo "ok"; \
	done

scan-example:
	cd src/; \
	for pkg in ma*; do \
	  printf "$$pkg, "; \
	  grep -n -F 'globalVariables(' $$pkg/R/*.R | grep -F 'multiple'; \
	done
