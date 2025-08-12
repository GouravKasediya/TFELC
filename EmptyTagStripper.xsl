<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:m="urn:messages.service.ti.apps.tiplus2.misys.com"
                exclude-result-prefixes="xsl xsi">
  
  <xsl:output indent="yes" />
  <!-- specify elements to strip here if the value is all white spaces -->
  <xsl:strip-space elements="m:EventNotificationss"/>
  
  <!-- Identity template -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- For empty nodes without any attributes, remove it -->
  <xsl:template match="*[.=''][not(@*[.!=''])]"/>
  
  <!-- For elements with require-nil="true", retain the xsi:nil -->
  <xsl:template match="*[@xsi:nil = 'true' and @require-nil='true']">
    <xsl:copy>
      <xsl:apply-templates select="@xsi:nil | node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- For non-empty nodes with require-nil="true" attribute or
       elements without require-nil="true" or
       require-nil="false" but with xsi:nil attribute,
       only copy the node -->
  <xsl:template match="*[(.!='' and @require-nil='true') or (@xsi:nil = 'true' and (not(@require-nil) or @require-nil != 'true'))]">
    <xsl:copy>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
