![Logo](https://github.com/BitCurator/bitcurator.github.io/blob/master/logos/BitCurator-Basic-400px.png)

# bitcurator-distro-metadata

[![GitHub issues](https://img.shields.io/github/issues/bitcurator/bitcurator-distro-metadata.svg)](https://github.com/bitcurator/bitcurator-distro-metadata/issues)
[![GitHub forks](https://img.shields.io/github/forks/bitcurator/bitcurator-distro-metadata.svg)](https://github.com/bitcurator/bitcurator-distro-metadata/network)
[![Build Status](https://travis-ci.org/BitCurator/bitcurator-distro-metadata.svg?branch=master)](https://travis-ci.org/BitCurator/bitcurator-distro-metadata)
[![Twitter Follow](https://img.shields.io/twitter/follow/bitcurator.svg?style=social&label=Follow)](https://twitter.com/bitcurator)

DFXML metadata transform scripts for use in the BitCurator Environment. These scripts are optional; they are not required to build, run, respin, or distribute the BitCurator distro.

## Legacy Warning

This is a legacy repository retained for informational purposes. It is not currently maintained.

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

## License(s)

The BitCurator logo, BitCurator project documentation, and other non-software products of the BitCurator team are subject to the the Creative Commons Attribution 4.0 Generic license (CC By 4.0).

Unless otherwise indicated, software items in this repository are distributed under the terms of the GNU General Public License, Version 3. See the text file "COPYING" for further details about the terms of this license.

In addition to software produced by the BitCurator team, BitCurator packages and modifies open source software produced by other developers. Licenses and attributions are retained here where applicable.
