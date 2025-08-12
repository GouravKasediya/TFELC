<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:core="xalan://com.misys.tiplus2.ticc.GlobalFunctions"
  xmlns:params="xalan://com.misys.tiplus2.ticc.MappingParameters"
  exclude-result-prefixes="core params">

  <xsl:template match="el_tnx_record">
    <xsl:variable name="FTIVersion"><xsl:value-of select="params:getFTIVersion()" /></xsl:variable>
    <xsl:variable name="SWIFT2018" select="params:getSWIFT2018()" />
    <ServiceRequest xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
                    xmlns:m='urn:messages.service.ti.apps.tiplus2.misys.com'
                    xmlns:c="urn:common.service.ti.apps.tiplus2.misys.com"
                    xmlns:x="urn:custom.service.ti.apps.tiplus2.misys.com"
                    xmlns="urn:control.services.tiplus2.misys.com">
      <xsl:call-template name="RequestHeader">
        <xsl:with-param name="operation">TFELCAMD</xsl:with-param>
        <xsl:with-param name="sourceSystem" select="if ($FTIVersion >= 28) then params:getFCCSourceSystem() else ''"/>
      </xsl:call-template>
      <m:TFELCAMD>
        <m:Context>
          <c:Customer><xsl:value-of select="core:getCustomerFromReference(beneficiary_reference)" /></c:Customer>
          <c:OurReference><xsl:value-of select="bo_ref_id" /></c:OurReference>
          <c:TheirReference><xsl:value-of select="cust_ref_id" /></c:TheirReference>
          <c:BehalfOfBranch><xsl:value-of select="core:getBOBFromReference(beneficiary_reference)" /></c:BehalfOfBranch>
        </m:Context>
        <!-- DocumentsReceived -->
        <xsl:call-template name="documents-received" />
        <m:EventNotificationss>
          <!-- ContactDetails -->
          <xsl:call-template name="corporate-contact" />
          <xsl:if test="(tnx_type_code = '13') and (sub_tnx_type_code = '03')">
            <m:EventNotifications>
              <m:MessageData>Customer reference has been set by Beneficiary.</m:MessageData>
              <m:MessageDescription>Special amendment type</m:MessageDescription>
              <m:MessageInfo>Additional information</m:MessageInfo>
              <m:Actioned>Y</m:Actioned>
            </m:EventNotifications>
          </xsl:if>
          <!-- NoDataStream -->
          <xsl:call-template name="attachment-notification" />
          <!--  <xsl:call-template name="customisation-eventnotifications" /> -->
        </m:EventNotificationss>
        <!-- EmbeddedItems -->
        <xsl:call-template name="embedded-items" />
        <m:Beneficiary>
          <c:Reference><xsl:value-of select="cust_ref_id" /></c:Reference>
        </m:Beneficiary>
        <m:EBankEventRef><xsl:value-of select="tnx_id" /></m:EBankEventRef>
        <m:EBankMasterRef><xsl:value-of select="ref_id" /></m:EBankMasterRef>
        <m:Sender>
          <c:Customer><xsl:value-of select="core:getCustomer(beneficiary_reference)" /></c:Customer>
        </m:Sender>
        <xsl:if test="$FTIVersion and $FTIVersion &gt;= 28">
          <m:AmendmentDetails>
            <c:AmendmentNumber><xsl:value-of select="amd_no" /></c:AmendmentNumber>
            <xsl:if test="$SWIFT2018 = 'Y'">
              <c:AmendmentChargesBy>
                <c:Code><xsl:value-of select="if (amd_chrg_brn_by_code = '01') then 'A'
                                              else if (amd_chrg_brn_by_code = '02') then 'B'
                                              else if (amd_chrg_brn_by_code = '07') then 'O'
                                              else ''" /></c:Code>
                <c:OtherText><xsl:value-of select="narrative_amend_charges_other" /></c:OtherText>
              </c:AmendmentChargesBy>
            </xsl:if>
          </m:AmendmentDetails>
        </xsl:if>
        <m:AmendmentNarrative><xsl:value-of select="if (tnx_type_code='13' and sub_tnx_type_code='03') then concat('New customer reference added: ', cust_ref_id)
                                                    else amd_details" /></m:AmendmentNarrative>
        <!-- <xsl:call-template name="extra-data" />  -->
        <!-- <xsl:call-template name="customisation-fields" /> -->
      </m:TFELCAMD>
    </ServiceRequest>
  </xsl:template>

  <!--  <xsl:include href="../custom/incoming/el_tnx_record_to_TFELCAMD_custom.xsl" />  -->
  <xsl:include href="../commons/CChannelsCommons.xsl" />
</xsl:stylesheet>