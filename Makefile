# Définir les variables

DOCKERIMAGE=atomgraph/saxon

XML_CATALOG=catalog.xml

XSL_ODD2ODD = Stylesheets/odds/odd2odd.xsl
XSL_ODDLITE= Stylesheets/odds/odd2lite.xsl
# XSL_TOHTML= Stylesheets/html/html.xsl
XSL_TOHTML= Stylesheets/odds/odd2html.xsl
XSL_ODD_TO_RELAXNG= Stylesheets/profiles/default/rng/to.xsl

# Docker mount point
MP = /workdir

DOCKER_RUN=docker run --rm -v "$(PWD)":"$(MP)" \
	$(DOCKERIMAGE) 

HAL_SPEC= HALSpecification.xml
SPM_SPEC = SPMSpecification.xml

#Variable Intermédiaire
SPM_COMPILED_SPEC=SPMSpecification_compiled.xml
SPM_ODD_LITE=SPMSpecification_lite.xml

HAL_ODD_LITE=HALSpecification_lite.xml
#
HAL_COMPILED_SPEC = HALSpecification.compiled.xml
HAL_HTML_OUT = HALSpecification.html
SPM_HTML_OUT = SPMSpecification.html
SPM_RNG = out/SPMSpecification.rng

HAL_RNG = out/HALSpecification.rng

# Cible par défaut
all: $(HAL_RNG) $(HAL_HTML_OUT) $(HAL_COMPILED_SPEC) $(SPM_HTML_OUT) $(SPM_RNG) clean_intermediates

# Règle pour transformer le fichier XML en utilisant XSLT
$(HAL_COMPILED_SPEC): $(HAL_SPEC) $(XSL_ODD2ODD)
	@echo Make $(HAL_COMPILED_SPEC)
	@$(DOCKER_RUN) -s:$(MP)/$(HAL_SPEC) -xsl:$(MP)/$(XSL_ODD2ODD) > $(HAL_COMPILED_SPEC)

$(HAL_RNG): $(HAL_COMPILED_SPEC) $(XSL_ODD_TO_RELAXNG)
	@echo Make $(HAL_RNG)
	@$(DOCKER_RUN) -s:"$(MP)/$(HAL_COMPILED_SPEC)" -xsl:$(MP)/$(XSL_ODD_TO_RELAXNG) > $(HAL_RNG)

$(HAL_ODD_LITE): $(HAL_COMPILED_SPEC) $(XSL_ODDLITE)
	@echo make $(HAL_ODD_LITE)
	@$(DOCKER_RUN) -s:"$(MP)/$(HAL_COMPILED_SPEC)" -xsl:$(MP)/$(XSL_ODDLITE) > $(HAL_ODD_LITE)

$(HAL_HTML_OUT): $(HAL_SPEC) $(XSL_TOHTML) $(HAL_ODD_LITE)
	@echo Make $(HAL_HTML_OUT)
	@$(DOCKER_RUN) -s:"$(MP)/$(HAL_ODD_LITE)" -xsl:$(MP)/$(XSL_TOHTML)  showTitleAuthor=false authorWord='' includeAuthor=false includeAffiliation=false > $(HAL_HTML_OUT)


# SPM
$(SPM_COMPILED_SPEC): $(HAL_COMPILED_SPEC) $(SPM_SPEC) $(XSL_ODD2ODD)
	@echo Make $(HAL_HTML_OUT)
	@$(DOCKER_RUN) -s:"$(MP)/$(SPM_SPEC)" -xsl:$(MP)/$(XSL_ODD2ODD)  > $(SPM_COMPILED_SPEC)

$(SPM_ODD_LITE): $(SPM_COMPILED_SPEC) $(XSL_ODDLITE)
	@echo Make $(SPM_ODD_LITE)
	@$(DOCKER_RUN) -s:"$(MP)/$(SPM_COMPILED_SPEC)" -xsl:$(MP)/$(XSL_ODDLITE) > $(SPM_ODD_LITE)

$(SPM_HTML_OUT): $(SPM_ODD_LITE) $(XSL_TOHTML)
	@echo Make $(SPM_HTML_OUT)
	@$(DOCKER_RUN) -s:"$(MP)/$(SPM_ODD_LITE)" -xsl:$(MP)/$(XSL_TOHTML) > $(SPM_HTML_OUT)

$(SPM_RNG): $(SPM_COMPILED_SPEC) $(XSL_ODD_TO_RELAXNG)
	@echo Make $(SPM_RNG)
	@$(DOCKER_RUN) -s:"$(MP)/$(SPM_COMPILED_SPEC)" -xsl:$(MP)/$(XSL_ODD_TO_RELAXNG) > $(SPM_RNG)

# Nettoyer les fichiers intermédiaires
clean_intermediates:
	rm -f $(SPM_COMPILED_SPEC) $(SPM_ODD_LITE)

# Nettoyer les fichiers générés
clean:
	rm -f $(HAL_COMPILED_SPEC) $(FINAL_OUTPUT) $(HAL_HTML_OUT) $(SPM_HTML_OUT) $(SPM_RNG) $(HAL_RNG) 

# Forcer la re-génération même si les fichiers n'ont pas changé
.PHONY: all clean


TESTFILES=$(wildcard listFichierTEIControleRNG/*)
test:	
	for f in $(TESTFILES) ; do echo "Test: $$f"; java -jar jing/bin/jing.jar out/HALSpecification.rng $$f; done
