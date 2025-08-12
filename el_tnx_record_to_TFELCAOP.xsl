<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:core="xalan://com.misys.tiplus2.ticc.GlobalFunctions"
  xmlns:params="xalan://com.misys.tiplus2.ticc.MappingParameters"
  exclude-result-prefixes="core params">

  <xsl:template match="el_tnx_record">
    <xsl:variable name="FTIVersion"><xsl:value-of select="params:getFTIVersion()" /></xsl:variable>
    <ServiceRequest xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
                    xmlns:m='urn:messages.service.ti.apps.tiplus2.misys.com'
                    xmlns:c="urn:common.service.ti.apps.tiplus2.misys.com"
                    xmlns:x="urn:custom.service.ti.apps.tiplus2.misys.com"
                    xmlns="urn:control.services.tiplus2.misys.com">
      <xsl:call-template name="RequestHeader">
        <xsl:with-param name="operation">TFELCAOP</xsl:with-param>
        <xsl:with-param name="sourceSystem" select="if ($FTIVersion >= 28) then params:getFCCSourceSystem() else ''"/>
      </xsl:call-template>
      <m:TFELCAOP>
        <m:Context>
          <c:Customer><xsl:value-of select="core:getCustomerFromReference(beneficiary_reference)" /></c:Customer>
          <c:OurReference><xsl:value-of select="bo_ref_id" /></c:OurReference>
          <c:TheirReference><xsl:value-of select="cust_ref_id" /></c:TheirReference>
          <c:BehalfOfBranch><xsl:value-of select="core:getBOBFromReference(beneficiary_reference)" /></c:BehalfOfBranch>
        </m:Context>
        <!-- DocumentsReceived -->
        <xsl:call-template name="documents-received" />
        <!-- Additional Data/EventNotifications -->
        <m:EventNotificationss>
          <xsl:if test="params:getSetInstructionsToGAP() = 'Y'">
            <xsl:for-each select="AdditionalData/DataItems">
              <m:EventNotifications>
                <m:MessageData>"This transaction contains attachments. You should connect to Trade Portal."</m:MessageData>
                <m:MessageDescription>Instructions</m:MessageDescription>
                <m:MessageInfo>Instructions</m:MessageInfo>
                <m:Actioned>Y</m:Actioned>
              </m:EventNotifications>
            </xsl:for-each>
          </xsl:if>
          <!-- NoDataStream -->
          <xsl:call-template name="attachment-notification" />
          <!--  <xsl:call-template name="customisation-eventnotifications" /> -->
        </m:EventNotificationss>
        <!-- EmbeddedItems -->
        <xsl:call-template name="embedded-items" />
        <m:Amount>
          <c:Amount><xsl:value-of select="tnx_amt" /></c:Amount>
          <c:Currency><xsl:value-of select="tnx_cur_code" /></c:Currency>
        </m:Amount>
        <xsl:variable name="secondBeneNameAddress">
          <xsl:value-of select="if(sec_beneficiary_name != '') then concat(sec_beneficiary_name, '&#10;') else ''" />
          <xsl:value-of select="if(sec_beneficiary_address_line_1 != '') then concat(sec_beneficiary_address_line_1, '&#10;') else ''" />
          <xsl:value-of select="if(sec_beneficiary_address_line_2 != '') then concat(sec_beneficiary_address_line_2, '&#10;') else ''" />
          <xsl:value-of select="if(sec_beneficiary_dom != '') then sec_beneficiary_dom else ''" />
        </xsl:variable>
        <m:SecondBeneficiary>
          <c:NameAddress><xsl:value-of select="$secondBeneNameAddress" /></c:NameAddress>
          <c:Country><xsl:value-of select="sec_beneficiary_country" /></c:Country>
        </m:SecondBeneficiary>
        <m:Sender>
          <c:Customer><xsl:value-of select="core:getCustomerFromReference(beneficiary_reference)" /></c:Customer>
          <c:Reference><xsl:value-of select="cust_ref_id" /></c:Reference>
        </m:Sender>
        <m:Instructions><xsl:value-of select="free_format_text" /></m:Instructions>
        <m:eBankMasterRef><xsl:value-of select="ref_id" /></m:eBankMasterRef>
        <m:eBankEventRef><xsl:value-of select="tnx_id" /></m:eBankEventRef>
        <!-- <xsl:call-template name="extra-data" />  -->
        <!-- <xsl:call-template name="customisation-fields" /> -->
        <xsl:variable name="assigneeNameAddress">
          <xsl:value-of select="if(assignee_name != '') then concat(assignee_name, '&#10;') else ''" />
          <xsl:value-of select="if(assignee_address_line_1 != '') then concat(assignee_address_line_1, '&#10;') else ''" />
          <xsl:value-of select="if(assignee_address_line_2 != '') then concat(assignee_address_line_2, '&#10;') else ''" />
          <xsl:value-of select="if(assignee_dom != '') then concat(assignee_dom, '&#10;') else ''" />
          <xsl:value-of select="if(assignee_address_line_4 != '') then concat(assignee_address_line_4, '&#10;') else ''" />
        </xsl:variable>
        <m:Assignee>
          <c:LegalEntityIdentifier><xsl:value-of select="assignee_lei" /></c:LegalEntityIdentifier>
          <c:NameAddress><xsl:value-of select="$assigneeNameAddress" /></c:NameAddress>
          <c:AssigneeCountry><xsl:value-of select="assignee_country" /> </c:AssigneeCountry>
          <xsl:call-template name="mt-mx-address">
            <xsl:with-param name="party" select="assignee_address" />
          </xsl:call-template>
        </m:Assignee>
      </m:TFELCAOP>
    </ServiceRequest>
  </xsl:template>

  <!--  <xsl:include href="../custom/incoming/el_tnx_record_to_TFELCAOP_custom.xsl" />  -->
  <xsl:include href="../commons/CChannelsCommons.xsl" />
</xsl:stylesheet>
