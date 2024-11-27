# Définir les variables
SAXON_JAR = SaxonHE11-6J/saxon-he-11.6.jar  # Changez selon votre version de Saxon
XSL_ODD2ODD = Stylesheets/odds/odd2odd.xsl
XSL_FILE2_INTERMEDIAIRE1= Stylesheets/odds/odd2lite.xsl
XSL_FILE2_INTERMEDIAIRE2= Stylesheets/html/html.xsl
XSL_FILE3_INTERMEDIAIRE= Stylesheets/profiles/default/rng/to.xsl
XML_INPUT1= HALSpecification.xml
XML_INPUT2 = SPMSpecification.xml

#Variable Intermédiaire
OUTPUT_FILE2_INTERMEDIAIRE1=SPMSpecificationIntermediaire1.xml
OUTPUT_FILE2_INTERMEDIAIRE2=SPMSpecificationIntermediaire2.xml
#
OUTPUT_FILE1 = HALSpecification.compiled.xml
OUTPUT_FILE2_FINAL = SPMSpecification.html
OUTPUT_FILE3 = out/SPMSpecification.rng

# Cible par défaut
all: $(OUTPUT_FILE1) $(OUTPUT_FILE2_FINAL) $(OUTPUT_FILE3) clean_intermediates

# Règle pour transformer le fichier XML en utilisant XSLT
$(OUTPUT_FILE1): $(XML_INPUT1) $(XSL_ODD2ODD)
	java -jar $(SAXON_JAR) -s:$(XML_INPUT1) -xsl:$(XSL_ODD2ODD) -o:$(OUTPUT_FILE1)

$(OUTPUT_FILE2_INTERMEDIAIRE1): $(XML_INPUT2) $(XSL_ODD2ODD)
	java -jar $(SAXON_JAR) -s:$(XML_INPUT2) -xsl:$(XSL_ODD2ODD) -o:$(OUTPUT_FILE2_INTERMEDIAIRE1)

$(OUTPUT_FILE2_INTERMEDIAIRE2): $(OUTPUT_FILE2_INTERMEDIAIRE1) $(XSL_FILE2_INTERMEDIAIRE1)
	java -jar $(SAXON_JAR) -s:$(OUTPUT_FILE2_INTERMEDIAIRE1) -xsl:$(XSL_FILE2_INTERMEDIAIRE1) -o:$(OUTPUT_FILE2_INTERMEDIAIRE2)
	
$(OUTPUT_FILE2_FINAL): $(OUTPUT_FILE2_INTERMEDIAIRE2) $(XSL_FILE2_INTERMEDIAIRE2)
	java -jar $(SAXON_JAR) -s:$(OUTPUT_FILE2_INTERMEDIAIRE2) -xsl:$(XSL_FILE2_INTERMEDIAIRE2) -o:$(OUTPUT_FILE2_FINAL)

$(OUTPUT_FILE3): $(OUTPUT_FILE2_INTERMEDIAIRE1) $(XSL_FILE3_INTERMEDIAIRE)
	java -jar $(SAXON_JAR) -s:$(OUTPUT_FILE2_INTERMEDIAIRE1) -xsl:$(XSL_FILE3_INTERMEDIAIRE) -o:$(OUTPUT_FILE3)

# Nettoyer les fichiers intermédiaires
clean_intermediates:
	rm -f $(OUTPUT_FILE2_INTERMEDIAIRE1) $(OUTPUT_FILE2_INTERMEDIAIRE2)

# Nettoyer les fichiers générés
clean:
	rm -f $(OUTPUT_FILE1) $(FINAL_OUTPUT)

# Forcer la re-génération même si les fichiers n'ont pas changé
.PHONY: all clean
