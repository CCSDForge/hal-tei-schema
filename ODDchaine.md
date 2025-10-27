# Procédure ODD chainé pour SPM

# Obsolete...

* Transformer HALSpecification.xml avec odd2odd.xsl pour obtenir un fichier ODD compiled. Renommé ce fichier HALSpecification.compiled.xml
* Contrôler le fichier HALSpecification.compiled.xml car quelques erreurs peuvent apparaitre au moment de la transformation
* Créer un fichier ODD dans Oxygen 
* Modifier l'élément schemaSpec pour inclure l'appel à HALSpecification.compiled.xml. Exemple : 
```xml
 <schemaSpec ident="SPM"
    source="HALSpecification.compiled.xml" start="TEI">
    <moduleRef key="tei"/>
    <moduleRef key="header" except="funder"/>
    <moduleRef key="core"/>
    <moduleRef key="textstructure"/>
  </schemaSpec>
```
