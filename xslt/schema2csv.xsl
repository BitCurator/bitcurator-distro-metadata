<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
>
  <xsl:output method="text"/>

  <xsl:variable name="prefix" select="'dfxml'" />

  <!-- xsl:strip-space elements="*" / -->

  <!--
     - Rules that match various columns in the CSV
    -->

  <xsl:template match="xs:element" mode="tagname">
    <xsl:text>"&lt;</xsl:text>
    <xsl:value-of select="normalize-space(./@name)" />
    <xsl:text>&gt;"</xsl:text>
  </xsl:template>

  <xsl:template match="xs:element" mode="element-name">
    <xsl:text>"</xsl:text>
    <xsl:value-of select="normalize-space(./@name)" />
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="xs:element" mode="description">
    <xsl:choose>
      <xsl:when test="count(./xs:annotation/xs:documentation) > 0">
        <xsl:text>"</xsl:text>
        <xsl:if test="./xs:annotation/xs:documentation">
          <xsl:call-template name="escapeQuote">
            <xsl:with-param name="pText" select="normalize-space(./xs:annotation/xs:documentation)" />
          </xsl:call-template>
        </xsl:if>
        <xsl:text>"</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="./@type != ''">
            <xsl:choose>
              <xsl:when test="substring-before(./@type, ':') = $prefix">
                <xsl:variable name="type" select="substring-after(./@type, ':')" />
                <xsl:choose>
                  <xsl:when test="count(//xs:complexType[./@name=$type]) != 0">
                    <xsl:apply-templates select="//xs:complexType[./@name = $type]" mode="documentation" />
                  </xsl:when>
                  <xsl:when test="count(//xs:simpleType[./@name=$type]) != 0">
                    <xsl:apply-templates select="//xs:simpleType[./@name=$type]" mode="documentation" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>""</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>""</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>""</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xs:element" mode="may-contain">
    <xsl:choose>
      <xsl:when test="./@type != ''">
        <xsl:choose>
          <xsl:when test="substring-before(./@type, ':') = $prefix">
            <xsl:variable name="type" select="substring-after(./@type, ':')" />
            <xsl:choose>
              <xsl:when test="count(//xs:complexType[./@name=$type]) != 0">
                <xsl:apply-templates select="//xs:complexType[./@name = $type]" mode="may-contain" />
              </xsl:when>
              <xsl:when test="count(//xs:simpleType[./@name=$type]) != 0">
                <xsl:text>""</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>"(mirrors type </xsl:text>
                <xsl:value-of select="./@type" />
                <xsl:text>)"</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>"(mirrors type </xsl:text>
            <xsl:value-of select="./@type" />
            <xsl:text>)"</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="./xs:complexType" mode="may-contain" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xs:element" mode="may-occur-in">
    <xsl:variable name="name" select="./@name" />
    <xsl:text>"</xsl:text>
    <xsl:for-each select="//xs:element[
                            .//xs:element[./@ref=concat($prefix, ':', $name)]
                          ]
                        | //xs:element[
                            ./@type = concat($prefix, ':', //xs:complexType[
                               .//xs:element[./@ref=concat($prefix, ':', $name)]
                              |.//xs:element[./@name=$name                 ]
                            ]/@name)
                          ]">
      <xsl:sort select="./@name" />
      <xsl:text>""</xsl:text>
      <xsl:apply-templates select="." mode="occurs-in" />
      <xsl:text>""</xsl:text>
      <xsl:if test="not(position() = last())">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="xs:element" mode="attributes">
    <xsl:choose>
      <xsl:when test="./@type != ''">
        <xsl:choose>
          <xsl:when test="substring-before(./@type, ':') = $prefix">
            <xsl:variable name="type" select="substring-after(./@type, ':')" />
            <xsl:choose>
              <xsl:when test="count(//xs:complexType[./@name=$type]) != 0">
                <xsl:apply-templates select="//xs:complexType[./@name = $type]" mode="attributes" />
              </xsl:when>
              <xsl:when test="count(//xs:simpleType[./@name=$type]) != 0">
                <xsl:text>""</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>""</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>""</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="./xs:complexType" mode="attributes" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xs:element" mode="allowable-values">
    <xsl:variable name="type" value="./@type" />
    <xsl:choose>
      <xsl:when test="./xs:simpleType//xs:enumeration">
        <xsl:text>"</xsl:text>
        <xsl:for-each select="./xs:simpleType//xs:enumeration">
          <xsl:sort select="./@value" />
          <xsl:apply-templates select="." mode="allowable-values" />
          <xsl:if test="not(position() = last())">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>"</xsl:text>
      </xsl:when>
      <xsl:when test="//xs:simpleType[concat($prefix, ':', ./@name) = $type]//xs:enumeration">
        <xsl:text>"</xsl:text>
        <xsl:for-each select="//xs:simpleType[concat($prefix, ':', @name) = $type]//xs:enumeration">
          <xsl:sort select="./@value" />
          <xsl:apply-templates select="." mode="allowable-values" />
          <xsl:if test="not(position() = last())">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>"</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xs:element" mode="repeatable">
    <xsl:variable name="name" select="./@name" />
    <xsl:choose>
      <xsl:when test="//xs:element[./@ref=concat($prefix, ':',$name)][./@maxOccurs = 'unbounded']">
        <xsl:text>"yes"</xsl:text>
      </xsl:when>
      <xsl:when test="count(//xs:element[./@ref=concat($prefix, ':',$name)][2 > ./@maxOccurs]) > 0">
        <xsl:text>"no"</xsl:text>
      </xsl:when>
      <xsl:when test="count(//xs:element[./@name=$name][2 > ./@maxOccurs]) > 0">
        <xsl:text>"no"</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>"yes"</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xs:element" mode="mandatory">
    <xsl:variable name="name" select="./@name" />
    <xsl:choose>
      <xsl:when test="count(//xs:element[./@ref=concat($prefix, ':',$name)][./@minOccurs > 0]) > 0">
        <xsl:text>"yes"</xsl:text>
      </xsl:when>
      <xsl:when test="count(//xs:element[./@name=$name][./@minOccurs > 0]) > 0">
        <xsl:text>"yes"</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>"no"</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
     - No examples in the .xsd at present
   -->
  <xsl:template match="xs:element" mode="example"><xsl:text>""</xsl:text></xsl:template>

  <!--
     - Rules called by the colume templates
   -->

  <xsl:template match="xs:element" mode="contained-in">
    <xsl:choose>
      <xsl:when test="substring-before(./@ref, ':') = $prefix">
        <xsl:call-template name="escapeQuote"><xsl:with-param name="pText" select="substring-after(./@ref, ':')" /></xsl:call-template>
      </xsl:when>
      <xsl:when test="./@name != ''">
        <xsl:call-template name="escapeQuote"><xsl:with-param name="pText" select="./@name" /></xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="escapeQuote"><xsl:with-param name="pText" select="./@ref" /></xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xs:element" mode="occurs-in">
    <xsl:choose>
      <xsl:when test="substring-before(./@ref, ':') = $prefix">
        <xsl:call-template name="escapeQuote"><xsl:with-param name="pText" select="substring-after(./@ref, ':')" /></xsl:call-template>
      </xsl:when>
      <xsl:when test="./@name != ''">
        <xsl:call-template name="escapeQuote"><xsl:with-param name="pText" select="./@name" /></xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="escapeQuote"><xsl:with-param name="pText" select="./@ref" /></xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

   <xsl:template match="xs:complexType" mode="may-contain">
    <xsl:text>"</xsl:text>
    <xsl:for-each select=".//xs:element">
      <xsl:sort select="./@ref | ./@name" />
      <xsl:text>""</xsl:text>
      <xsl:apply-templates select="." mode="contained-in" />
      <xsl:text>""</xsl:text>
      <xsl:if test="not(position() = last())">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="xs:enumeration" mode="allowable-values">
    <xsl:text>""</xsl:text>
    <xsl:call-template name="escapeQuote"><xsl:with-param name="pText" select="./@value" /></xsl:call-template>
    <xsl:text>""</xsl:text>
  </xsl:template>

  <xsl:template match="xs:complexType" mode="documentation">
    <xsl:text>"</xsl:text>
      <xsl:if test="./xs:annotation/xs:documentation">
        <xsl:call-template name="escapeQuote">
          <xsl:with-param name="pText" select="normalize-space(./xs:annotation/xs:documentation)" />
        </xsl:call-template>
      </xsl:if>
      <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="xs:simpleType" mode="documentation">
    <xsl:text>"</xsl:text>
      <xsl:if test="./xs:annotation/xs:documentation">
        <xsl:call-template name="escapeQuote">
          <xsl:with-param name="pText" select="normalize-space(./xs:annotation/xs:documentation)" />
        </xsl:call-template>
      </xsl:if>
      <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="xs:complexType" mode="attributes">
    <xsl:text>"</xsl:text>
    <xsl:for-each select=".//xs:attribute">
      <xsl:sort select="./@ref | ./@name" />
      <xsl:text>""</xsl:text>
      <xsl:call-template name="escapeQuote"><xsl:with-param name="pText" select="./@ref | ./@name" /></xsl:call-template>
      <xsl:text>""</xsl:text>
      <xsl:if test="not(position() = last())">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <!--
     - Rule for generating the CSV rows
    -->
  <xsl:template match="/">
    <xsl:text>"Tag name","Element name","Description","May contain","May occur in","Attributes","Allowable values","Repeatable?","Mandatory?","Example"&#xA;</xsl:text>
    <xsl:for-each select=".//xs:element[./@name != '']">
      <xsl:sort select="./@name" />
      <xsl:apply-templates select="." mode="tagname" />
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="." mode="element-name" />
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="." mode="description" />
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="." mode="may-contain" />
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="." mode="may-occur-in" />
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="." mode="attributes" />
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="." mode="allowable-values" />
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="." mode="repeatable" />
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="." mode="mandatory" />
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="." mode="example" />
      <xsl:text>&#xD;&#xA;</xsl:text><!-- CRLF per RFC 4180 -->
    </xsl:for-each>
  </xsl:template>


  <!--
     - Utility templates
   -->
  <xsl:template name="escapeQuote">
    <xsl:param name="pText" select="."/>
    <xsl:if test="string-length($pText) > 0">
      <xsl:value-of select="substring-before(concat($pText, '&quot;'), '&quot;')"/>
      <xsl:if test="contains($pText, '&quot;')">
        <xsl:text>""</xsl:text>
        <xsl:call-template name="escapeQuote">
          <xsl:with-param name="pText" select="substring-after($pText, '&quot;')"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>