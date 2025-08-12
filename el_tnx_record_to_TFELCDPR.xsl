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
        <xsl:with-param name="operation">TFELCDPR</xsl:with-param>
        <xsl:with-param name="sourceSystem" select="if ($FTIVersion >= 28) then params:getFCCSourceSystem() else ''"/>
      </xsl:call-template>
      <m:TFELCDPR>
        <xsl:variable name="hasAttachedDocumentMessage" select="core:hasAttachedDocumentMessage(free_format_text)" />
        <m:Context>
          <c:Customer><xsl:value-of select="core:getCustomerFromReference(beneficiary_reference)" /></c:Customer>
          <c:OurReference><xsl:value-of select="bo_ref_id" /></c:OurReference>
          <c:TheirReference><xsl:value-of select="cust_ref_id" /></c:TheirReference>
          <c:BehalfOfBranch><xsl:value-of select="core:getBOBFromReference(beneficiary_reference)" /></c:BehalfOfBranch>
        </m:Context>
        <!-- DocumentsReceived -->
        <xsl:call-template name="documents-received" />
        <m:EventNotificationss>
          <!--  EventNotifications: Contact details -->
          <xsl:call-template name="corporate-contact" />
          <m:EventNotifications>
            <xsl:if test="string($hasAttachedDocumentMessage) = 'true'">
              <m:MessageData>This transaction contains attachments. You should connect to Misys Portal.</m:MessageData>
              <m:MessageDescription>Message Text</m:MessageDescription>
              <m:MessageInfo>Additional information</m:MessageInfo>
              <m:Actioned>N</m:Actioned>
            </xsl:if>
          </m:EventNotifications>
            <!-- NoDataStream -->
          <xsl:call-template name="attachment-notification" />
          <!--  <xsl:call-template name="customisation-eventnotifications" /> -->
        </m:EventNotificationss>
        <!-- EmbeddedItems -->
        <xsl:call-template name="embedded-items" />
        <m:MasterRef><xsl:value-of select="bo_ref_id" /></m:MasterRef>
        <m:ClaimId><xsl:value-of select="bo_tnx_id" /></m:ClaimId>
        <m:eBankEventRef><xsl:value-of select="tnx_id" /></m:eBankEventRef>
        <m:eBankMasterRef><xsl:value-of select="ref_id" /></m:eBankMasterRef>
        <m:Sender>
          <c:Customer><xsl:value-of select="core:getCustomer(beneficiary_reference)" /></c:Customer>
        </m:Sender>
        <m:PresentationDetails>
          <c:PresentationAmount>
            <c:Amount><xsl:value-of select="tnx_amt" /></c:Amount>
            <c:Currency><xsl:value-of select="tnx_cur_code" /></c:Currency>
          </c:PresentationAmount>
          <c:PresentationDate><xsl:value-of select="core:dateFormatCCToTIPlus(iss_date)"/></c:PresentationDate>
          <c:PresentersReference><xsl:value-of select="presenter_reference"/></c:PresentersReference>
          <c:NotesFromPresenter><xsl:value-of select="narrative_doc_additional_instructions"/></c:NotesFromPresenter>
        </m:PresentationDetails>
        <m:GWRDocumentAs>
          <xsl:for-each select="documents/document">
            <xsl:if test="mapped_attachment_id = '' ">
              <m:GWRDocumentA>
                <m:Document><xsl:value-of select="params:getCCColDOTCodeMaps(code)" /></m:Document>
                <m:DocumentFaceReference><xsl:value-of select="doc_no"/></m:DocumentFaceReference>
                <m:DocumentDate><xsl:value-of select="if (doc_date != '') then core:dateFormatCCToTIPlus(doc_date) else ''"/></m:DocumentDate>
                <m:DocumentDesc><xsl:value-of select="name" /></m:DocumentDesc>
                <m:DocumentMailing1><xsl:value-of select="first_mail" /></m:DocumentMailing1>
                <m:DocumentMailing2><xsl:value-of select="second_mail" /></m:DocumentMailing2>
                <m:DocumentMailingTotal><xsl:value-of select="total" /></m:DocumentMailingTotal>
                <m:IsCustomerAttachedDocument>Y</m:IsCustomerAttachedDocument>
              </m:GWRDocumentA>
            </xsl:if>
          </xsl:for-each>
        </m:GWRDocumentAs>
        <!-- <xsl:call-template name="extra-data" />  -->
        <!-- <xsl:call-template name="customisation-fields" /> -->
      </m:TFELCDPR>
    </ServiceRequest>
  </xsl:template>
  <!--  <xsl:include href="../custom/incoming/el_tnx_record_to_TFELCDPR_custom.xsl" />  -->
  <xsl:include href="../commons/CChannelsCommons.xsl" />
</xsl:stylesheet>