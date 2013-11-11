bitcurator-md
=============

BitCurator Metadata Handling

## Extracting Schema Metadata into a CSV

The `xslt/schema2csv.xsl` script can be used to produce a CSV file with 
a row of information for each element extracted from the XML Schema definition file.
See the `csv dfxml.csv` file in this repository for an example.

```
$ xsltproc xslt/schema2csv.xsl dfxml.xsd
```
