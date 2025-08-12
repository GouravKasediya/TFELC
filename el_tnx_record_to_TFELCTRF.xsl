<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:core="xalan://com.misys.tiplus2.ticc.GlobalFunctions"
  xmlns:params="xalan://com.misys.tiplus2.ticc.MappingParameters"
  exclude-result-prefixes="core params">

  <xsl:template match="el_tnx_record">
    <xsl:variable name="FTIVersion"><xsl:value-of select="params:getFTIVersion()" /></xsl:variable>
    <xsl:variable name="SWIFT2018"><xsl:value-of select="params:getSWIFT2018()" /></xsl:variable>
    <ServiceRequest xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
          xmlns:m='urn:messages.service.ti.apps.tiplus2.misys.com'
          xmlns:c="urn:common.service.ti.apps.tiplus2.misys.com"
          xmlns:x="urn:custom.service.ti.apps.tiplus2.misys.com"
          xmlns="urn:control.services.tiplus2.misys.com">
      <xsl:call-template name="RequestHeader">
        <xsl:with-param name="operation">TFELCTRF</xsl:with-param>
        <xsl:with-param name="sourceSystem" select="if ($FTIVersion >= 28) then params:getFCCSourceSystem() else ''"/>
      </xsl:call-template>
      <m:TFELCTRF>
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
          <m:EventNotifications>
            <xsl:if test="core:getIncotermAndPlaceGAP(inco_term, inco_place) != ''">
              <m:MessageData><xsl:value-of select="core:getIncotermAndPlaceGAP(inco_term, inco_place)" /></m:MessageData>
              <m:MessageDescription>Incoterm and Place</m:MessageDescription>
              <m:MessageInfo>Additional information</m:MessageInfo>
              <m:Actioned>N</m:Actioned>
            </xsl:if>
          </m:EventNotifications>
          <m:EventNotifications>
            <xsl:variable name="transferMethod"><xsl:value-of select="if (trns_adv_send_mode_text != '') then trns_adv_send_mode_text
                                                                      else if (adv_send_mode_text != '') then adv_send_mode_text
                                                                      else ''"/></xsl:variable>
            <xsl:if test="$transferMethod != ''">
              <m:MessageData><xsl:value-of select="$transferMethod" /></m:MessageData>
              <m:MessageDescription>Other transfer method</m:MessageDescription>
              <m:MessageInfo>Additional information</m:MessageInfo>
              <m:Actioned>N</m:Actioned>
            </xsl:if>
          </m:EventNotifications>
          <!-- TIVersionGAP -->
          <xsl:if test="$FTIVersion and $FTIVersion &lt;= 25">
            <m:EventNotifications>
              <xsl:if test="trans_exp_date != ''">
                <m:MessageData><xsl:value-of select="core:dateFormatCCToTIPlus(trans_exp_date)" /></m:MessageData>
                <m:MessageDescription>Expiry Date</m:MessageDescription>
                <m:MessageInfo>Additional information</m:MessageInfo>
                <m:Actioned>N</m:Actioned>
              </xsl:if>
            </m:EventNotifications>
            <m:EventNotifications>
              <xsl:if test="expiry_place != ''">
                <m:MessageData><xsl:value-of select="expiry_place" /></m:MessageData>
                <m:MessageDescription>Expiry Place</m:MessageDescription>
                <m:MessageInfo>Additional information</m:MessageInfo>
                <m:Actioned>N</m:Actioned>
              </xsl:if>
            </m:EventNotifications>
            <m:EventNotifications>
              <xsl:if test="advise_mode_code != ''">
                <m:MessageData><xsl:value-of select="if (advise_mode_code = '01') then 'Y' else if (advise_mode_code = '02') then 'N' else ''" /></m:MessageData>
                <m:MessageDescription>Advise Direct</m:MessageDescription>
                <m:MessageInfo>Additional information</m:MessageInfo>
                <m:Actioned>N</m:Actioned>
              </xsl:if>
            </m:EventNotifications>
            <m:EventNotifications>
              <xsl:if test="last_ship_date != ''">
                <m:MessageData><xsl:value-of select="core:dateFormatCCToTIPlus(last_ship_date)" /></m:MessageData>
                <m:MessageDescription>Last Shipment Date</m:MessageDescription>
                <m:MessageInfo>Additional information</m:MessageInfo>
                <m:Actioned>N</m:Actioned>
              </xsl:if>
            </m:EventNotifications>
            <m:EventNotifications>
              <xsl:if test="narrative_shipment_period != ''">
                <m:MessageData><xsl:value-of select="narrative_shipment_period" /></m:MessageData>
                <m:MessageDescription>Shipment Period</m:MessageDescription>
                <m:MessageInfo>Additional information</m:MessageInfo>
                <m:Actioned>N</m:Actioned>
              </xsl:if>
            </m:EventNotifications>
            <m:EventNotifications>
              <xsl:if test="notify_amendment_flag != ''">
                <m:MessageData><xsl:value-of select="notify_amendment_flag" /></m:MessageData>
                <m:MessageDescription>Notify Amendments</m:MessageDescription>
                <m:MessageInfo>Additional information</m:MessageInfo>
                <m:Actioned>N</m:Actioned>
              </xsl:if>
            </m:EventNotifications>
            <m:EventNotifications>
              <xsl:if test="substitute_invoice_flag != ''">
                <m:MessageData><xsl:value-of select="substitute_invoice_flag" /></m:MessageData>
                <m:MessageDescription>Substitute Invoice</m:MessageDescription>
                <m:MessageInfo>Additional information</m:MessageInfo>
                <m:Actioned>N</m:Actioned>
              </xsl:if>
            </m:EventNotifications>
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
        <m:SecondBeneficiary>
          <c:LegalEntityIdentifier><xsl:value-of select="sec_beneficiary_lei" /></c:LegalEntityIdentifier>
          <c:NameAddress><xsl:value-of select="core:constructNameAndAddress(sec_beneficiary_name,sec_beneficiary_address_line_1,sec_beneficiary_address_line_2,sec_beneficiary_dom)" /></c:NameAddress>
          <c:Country><xsl:value-of select="sec_beneficiary_country" /></c:Country>
          <xsl:call-template name="mt-mx-address">
            <xsl:with-param name="party" select="sec_beneficiary_address" />
          </xsl:call-template>
        </m:SecondBeneficiary>
        <m:Sender>
          <c:Customer><xsl:value-of select="core:getCustomer(beneficiary_reference)" /></c:Customer>
          <c:Reference><xsl:value-of select="cust_ref_id" /></c:Reference>
        </m:Sender>
        <m:AdviseThru>
          <c:LegalEntityIdentifier><xsl:value-of select="advise_thru_bank/lei_code" /></c:LegalEntityIdentifier>
          <c:NameAddress><xsl:value-of select="if (advise_mode_code = '02') then core:constructNameAndAddress(advise_thru_bank/name,advise_thru_bank/address_line_1,advise_thru_bank/address_line_2,advise_thru_bank/dom) else ''" /></c:NameAddress>
          <c:SwiftAddress><xsl:value-of select="if (advise_mode_code = '02') then advise_thru_bank/iso_code else ''" /></c:SwiftAddress>
          <xsl:if test="(advise_mode_code = '02')">
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="advise_thru_bank" />
            </xsl:call-template>
          </xsl:if>
        </m:AdviseThru>
        <m:Instructions><xsl:value-of select="free_format_text" /></m:Instructions>
        <m:eBankMasterRef><xsl:value-of select="ref_id" /></m:eBankMasterRef>
        <m:eBankEventRef><xsl:value-of select="tnx_id" /></m:eBankEventRef>
        <xsl:if test="$FTIVersion and $FTIVersion &gt;= 27">
          <m:AdviseBy><xsl:value-of select="if (trns_adv_send_mode != '') then params:getTIAdviceMethod(trns_adv_send_mode)
                                            else if (adv_send_mode != '') then params:getTIAdviceMethod(adv_send_mode)
                                            else '' "/></m:AdviseBy>
          <m:ExpiryDate><xsl:value-of select="if (trns_exp_date != '') then core:dateFormatCCToTIPlus(trns_exp_date) else ''" /></m:ExpiryDate>
          <m:ExpiryPlace><xsl:value-of select="trns_expiry_place" /></m:ExpiryPlace>
          <m:AdviseDirect><xsl:value-of select="if (trns_advise_mode_code = '01') then 'Y'
                                                else if (trns_advise_mode_code = '02') then 'N'
                                                else ''" /></m:AdviseDirect>
          <m:ShipmentDate><xsl:value-of select="if (trns_last_ship_date != '') then core:dateFormatCCToTIPlus(trns_last_ship_date) else ''" /></m:ShipmentDate>
          <m:ShipmentPeriod><xsl:value-of select="trns_narrative_shipment_period"/></m:ShipmentPeriod>
            <m:IncoTerm><xsl:value-of select="inco_term" /></m:IncoTerm>
            <m:IncoPlace><xsl:value-of select="inco_place" /></m:IncoPlace>
          <m:Goods><xsl:value-of select="trns_narrative_description_goods"/></m:Goods>
          <m:PresentationDays><xsl:value-of select="if ($SWIFT2018 = 'Y') then trns_period_presentation_days else ''"/></m:PresentationDays>
          <m:PresentationPeriod><xsl:value-of select="trns_narrative_period_presentation"/></m:PresentationPeriod>
          <m:NotifyAmendments><xsl:value-of select="if (notify_amendment_flag = 'Y') then 'Y' else 'N'" /></m:NotifyAmendments>
          <m:SubstituteInvoice><xsl:value-of select="if (substitute_invoice_flag = 'Y') then 'Y' else 'N'" /></m:SubstituteInvoice>
        </xsl:if>
        <xsl:if test="$SWIFT2018 = 'Y'">
          <m:SpecialPaymentConditions>
            <c:ForBeneficiary><xsl:value-of select="narrative_special_beneficiary" /></c:ForBeneficiary>
            <c:ForReceivingBank><xsl:value-of select="narrative_special_recvbank" /></c:ForReceivingBank>
          </m:SpecialPaymentConditions>
        </xsl:if>

      <!-- <xsl:call-template name="extra-data" />  -->
      <!-- <xsl:call-template name="customisation-fields" /> -->
      </m:TFELCTRF>
    </ServiceRequest>
  </xsl:template>

  <!--  <xsl:include href="../custom/incoming/el_tnx_record_to_TFELCTRF_custom.xsl" />  -->
  <xsl:include href="../commons/CChannelsCommons.xsl" />
</xsl:stylesheet>