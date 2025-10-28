# Définir les variables

# principe de RelaxNG : on importe deja l'ensemble de ce qui est utilise (voir plus) (version "compiled")
#   On peut ensuite allege le schema (version "lite")

# A partir de la version "lite", on peut generer la documentation.
# A partir de la version "conpilde", on genere les schema xsd ou relaxNg

SHELL=/bin/bash
DOCKERIMAGE=atomgraph/saxon

XML_CATALOG=catalog.xml

XSL_ODD2ODD = Stylesheets/odds/odd2odd.xsl
XSL_ODDLITE= Stylesheets/odds/odd2lite.xsl
# XSL_TOHTML= Stylesheets/html/html.xsl
XSL_TOHTML= Stylesheets/odds/odd2html.xsl
XSL_ODD_TO_RELAXNG= Stylesheets/profiles/default/rng/to.xsl
XSL_ODD_TO_XSD= Stylesheets/profiles/default/xsd/to.xsl
STYLESHEETS_VERSION=7.59.0

# Docker mount point
MP = /workdir
TESTDIR=test
STATIC_TEST_DIR = $(TESTDIR)/static
DYN_TEST_DIR = $(TESTDIR)/dyn

MODULO=1000

DOCKER_RUN=docker run --rm -v "$(PWD)":"$(MP)" \
	$(DOCKERIMAGE) 

HAL_SPEC = HALSpecification.xml
SPM_SPEC = SPMSpecification.xml

#Variable Intermédiaire
HAL_COMPILED_SPEC = build/HALSpecification.compiled.xml
SPM_COMPILED_SPEC = build/SPMSpecification_compiled.xml

SPM_ODD_LITE = build/SPMSpecification_lite.xml
HAL_ODD_LITE = build/HALSpecification_lite.xml

HAL_HTML_OUT = out/HALSpecification.html
SPM_HTML_OUT = out/SPMSpecification.html

SPM_RNG = out/SPMSpecification.rng
HAL_RNG = out/HALSpecification.rng

SPM_XSD = out/SPMSpecification.xsd
HAL_XSD = out/HALSpecification.xsd


# Cible par défaut
all: docker Stylesheets $(HAL_RNG) $(HAL_HTML_OUT) $(HAL_COMPILED_SPEC) $(SPM_HTML_OUT) $(SPM_RNG) clean_intermediates

# Règle pour transformer le fichier XML en utilisant XSLT
$(HAL_COMPILED_SPEC): build $(HAL_SPEC) $(XSL_ODD2ODD)
	@echo Make $(HAL_COMPILED_SPEC)
	@$(DOCKER_RUN) -s:$(MP)/$(HAL_SPEC) -xsl:$(MP)/$(XSL_ODD2ODD) > $(HAL_COMPILED_SPEC)

$(HAL_RNG): build $(HAL_COMPILED_SPEC) $(XSL_ODD_TO_RELAXNG)
	@echo Make $(HAL_RNG)
	@$(DOCKER_RUN) -s:"$(MP)/$(HAL_COMPILED_SPEC)" -xsl:$(MP)/$(XSL_ODD_TO_RELAXNG) > $(HAL_RNG)

$(HAL_XSD): $(HAL_COMPILED_SPEC) $(XSL_ODD_TO_XSD)
	@echo Make $(HAL_RNG)
	@$(DOCKER_RUN) -s:"$(MP)/$(HAL_COMPILED_SPEC)" -xsl:$(MP)/$(XSL_ODD_TO_XSD) > $(HAL_XSD)

$(HAL_ODD_LITE): build $(HAL_COMPILED_SPEC) $(XSL_ODDLITE)
	@echo make $(HAL_ODD_LITE)
	@$(DOCKER_RUN) -s:"$(MP)/$(HAL_COMPILED_SPEC)" -xsl:$(MP)/$(XSL_ODDLITE) > $(HAL_ODD_LITE)

$(HAL_HTML_OUT): $(HAL_SPEC) $(XSL_TOHTML) $(HAL_ODD_LITE)
	@echo Make $(HAL_HTML_OUT)
	@$(DOCKER_RUN) -s:"$(MP)/$(HAL_ODD_LITE)" -xsl:$(MP)/$(XSL_TOHTML)  showTitleAuthor=false authorWord='' includeAuthor=false includeAffiliation=false > $(HAL_HTML_OUT)


# SPM
$(SPM_COMPILED_SPEC): $(HAL_COMPILED_SPEC) $(SPM_SPEC) $(XSL_ODD2ODD)
	@echo Make $(HAL_HTML_OUT)
	@$(DOCKER_RUN) -s:"$(MP)/$(SPM_SPEC)"          -xsl:$(MP)/$(XSL_ODD2ODD)  > $(SPM_COMPILED_SPEC)

$(SPM_ODD_LITE): $(SPM_COMPILED_SPEC) $(XSL_ODDLITE)
	@echo Make $(SPM_ODD_LITE)
	@$(DOCKER_RUN) -s:"$(MP)/$(SPM_COMPILED_SPEC)" -xsl:$(MP)/$(XSL_ODDLITE) > $(SPM_ODD_LITE)

$(SPM_HTML_OUT): $(SPM_ODD_LITE) $(XSL_TOHTML)
	@echo Make $(SPM_HTML_OUT)
	@$(DOCKER_RUN) -s:"$(MP)/$(SPM_ODD_LITE)"      -xsl:$(MP)/$(XSL_TOHTML) > $(SPM_HTML_OUT)

$(SPM_RNG): $(SPM_COMPILED_SPEC) $(XSL_ODD_TO_RELAXNG)
	@echo Make $(SPM_RNG)
	@$(DOCKER_RUN) -s:"$(MP)/$(SPM_COMPILED_SPEC)" -xsl:$(MP)/$(XSL_ODD_TO_RELAXNG) > $(SPM_RNG)

$(SPM_XSD): $(SPM_COMPILED_SPEC) $(XSL_ODD_TO_XSD)
	@echo Make $(SPM_RNG)
	@$(DOCKER_RUN) -s:"$(MP)/$(SPM_COMPILED_SPEC)" -xsl:$(MP)/$(XSL_ODD_TO_XSD) > $(SPM_XSD)

hal: $(HAL_HTML_OUT) $(HAL_RNG)

spm: $(SPM_HTML_OUT) $(SPM_RNG)

test:	/usr/bin/jing staticTests dynTests

# We use sitemaps to get all documents and retreive on one on MODULO tei
.ONESHELL:
getTests: build/sitemap.xml
	@for t in `zcat build/sitemap*.gz | grep '<loc>' | grep -v /document | sed -e 's/.*<loc>//' -e 's+</loc>++'` ; do 
		f=`echo $$t | sed -e 's+.*/++'`;
		rand="$$((RANDOM % $(MODULO) ))"
		total=$$((total + 1))
		if expr "$$rand" = 8 >/dev/null; then docDone=$$((docDone + 1)); echo -n -e "Rand=$$rand     $$docDone/$$total   $$f\r"; wget -q -O $(DYN_TEST_DIR)/$$f.xml $$t/tei; else echo -e -n "Rand=$$rand  \r";fi
	done

# internal tools
# Nettoyer les fichiers intermédiaires
clean_intermediates:
	rm -f $(SPM_COMPILED_SPEC) $(SPM_ODD_LITE)

# Nettoyer les fichiers générés
clean:
	rm -f $(HAL_COMPILED_SPEC) $(HAL_HTML_OUT) $(HAL_RNG)  \
	      $(SPM_COMPILED_SPEC) $(SPM_HTML_OUT) $(SPM_RNG) 


diff:
	git diff | grep '^[-+] ' | grep -v "on 2025-"

# Forcer la re-génération même si les fichiers n'ont pas changé
.PHONY: all clean test

docker:
	@docker ps 2>/dev/null >/dev/null ||  { echo "You need to install 'docker'";exit 1; }


/usr/bin/jing:
	echo "You need to install 'jing' (apt install jng) to make tests"
	exit 1

Stylesheets:
	git clone https://github.com/TEIC/Stylesheets.git
	cd Stylesheets;git checkout release-$(STYLESHEETS_VERSION)

STATIC_TESTFILES=$(wildcard $(STATIC_TEST_DIR)/*.xml)
staticTests:
	@echo "Do static tests..."
	@for f in $(STATIC_TESTFILES) ; do echo -n -e "\r$$f           "; jing out/HALSpecification.rng $$f; done
	@echo
	@echo Done.

$(DYN_TEST_DIR):
	@mkdir $(DYN_TEST_DIR)

.ONESHELL:
dynTests:
	@echo "Do dynamic tests..."
	find $(DYN_TEST_DIR) -name '*.xml' -print | {
	   tested=0
	   nbErrors=0
	   while read -r file; do
	     tested=$$((tested + 1))
	     if ! output=$$(jing out/HALSpecification.rng "$$file" 2>&1); then
	        echo "$$file:   $$output"
	     else
	        printf " %s %s\r" "$$file" "tested=$$tested"
	     fi
	  done
	  echo
	  echo Done "($$tested tested files - $$nbErrors errors)".
	}

build:
	@mkdir build

# Retreve all sitemaps of hal.science
build/sitemap.xml:
	wget -O build/sitemap.xml https://hal.science/public/sitemap/sitemap.xml
	for url in `cat build/sitemap.xml | grep '<loc>' |  sed -e 's/.*<loc>//' -e 's+</loc>++'` ; do \
		cd build; \
		wget $$url; \
		cd ..; \
	done; 

help:   docker
	@echo "Make file to construct relaxNG and documentation"
	@echo "   make           : will make relaxNg schemas and documentation html files"
	@echo "   make getTests  : will download some TEI files from Hal"
	@echo "   make test      : will run test on static and previously downloaded tests"
	@echo "       make staticTests : to just run static tests"
	@echo "       make dynTests    : to just run dynamic tests"
