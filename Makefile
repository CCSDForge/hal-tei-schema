# Définir les variables

# principe de RelaxNG : on importe deja l'ensemble de ce qui est utilise (voir plus) (version "compiled")
#   On peut ensuite allege le schema (version "lite")

# A partir de la version "lite", on peut generer la documentation.
# A partir de la version "conpilde", on genere les schema xsd ou relaxNg


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
all: Stylesheets $(HAL_RNG) $(HAL_HTML_OUT) $(HAL_COMPILED_SPEC) $(SPM_HTML_OUT) $(SPM_RNG) clean_intermediates

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

# Nettoyer les fichiers intermédiaires
clean_intermediates:
	rm -f $(SPM_COMPILED_SPEC) $(SPM_ODD_LITE)

# Nettoyer les fichiers générés
clean:
	rm -f $(HAL_COMPILED_SPEC) $(HAL_HTML_OUT) $(HAL_RNG)  \
	      $(SPM_COMPILED_SPEC) $(SPM_HTML_OUT) $(SPM_RNG) 

# Forcer la re-génération même si les fichiers n'ont pas changé
.PHONY: all clean test

/usr/bin/jing:
	echo "You need to install 'jing' (apt install jng) to make tests"
	exit 1

Stylesheets:
	git clone https://github.com/TEIC/Stylesheets.git
	cd Stylesheets;git checkout release-$(STYLESHEETS_VERSION)

STATIC_TESTFILES=$(wildcard $$STATIC_TEST_DIR/*.xml)
DYN_TESTFILES=$(wildcard $$DYN_TEST_DIR/*.xml)

test:	/usr/bin/jing staticTests dynTests


staticTests:
	@for f in $(TESTFILES) ; do echo -n  "\rTest: $$f      "; jing out/HALSpecification.rng $$f || echo ; done


dynTests:
	@for f in $(TESTFILES) ; do echo -n  "\rTest: $$f      "; jing out/HALSpecification.rng $$f || echo ; done


build:
	@mkdir build

build/sitemap:
	wget -O build/sitemap https://hal.science/public/sitemap/

getTests: build/sitemap
	@for t in `zcat build/sitemap | grep '<loc>' | grep -v /document | sed -e 's/xxx/yyy' -e 's/xxxx/yyy/'` ; do \
		f=`echo $t | sed -e 's+/tei$++' -e 's+.*/++'`; \
		wget -O $$DYN_TEST_DIR/$f.xml $t;\
	done

DYN_TEST_DIR:
	@mkdir $(DYN_TEST_DIR)
