bitcurator-environment-metadata
===============================

DFXML metadata transform scripts for use in the BitCurator Environment.

## Extracting Schema Metadata into a CSV

The `xslt/schema2csv.xsl` script can be used to produce a CSV file with
a row of information for each element extracted from the XML Schema definition file.
See the `csv/dfxml.csv` file in this repository for an example.

```
$ xsltproc xslt/schema2csv.xsl dfxml.xsd
```

The script produces values for the following columns:

* Tag name
* Element name
* Description
* May contain
* May occur in
* Attributes
* Allowable values
* Repeatable?
* Mandatory?

The "Example" column is present, but the script will not place any content
there due to the lack of examples in the source XML Schema.
