<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:m="urn:messages.service.ti.apps.tiplus2.misys.com"
                xmlns:c="urn:common.service.ti.apps.tiplus2.misys.com"
                xmlns:x="urn:custom.service.ti.apps.tiplus2.misys.com"
                xmlns="urn:control.services.tiplus2.misys.com"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:core="xalan://com.misys.tiplus2.ticc.GlobalFunctions"
                xmlns:params="xalan://com.misys.tiplus2.ticc.MappingParameters"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                exclude-result-prefixes="core params">

  <xsl:template name="TFILCAPP">
    <xsl:param name="ftiVersion"/>
    <xsl:variable name="SWIFT2018"><xsl:value-of select="params:getSWIFT2018()" /></xsl:variable>
    <xsl:variable name="mapAddressLine4" select="adv_send_mode != '01' and params:getMapAddressLine4() = 'Y'"/>
    <xsl:variable name="mapAlternateApplicantAsApplicant" select="params:getTIMapAlternateApplicantAsApplicant() = 'Y' and for_account_flag = 'Y'"/>
    <m:Context>
      <c:Customer><xsl:value-of select="core:getCustomerFromReference(applicant_reference)" /></c:Customer>
      <c:OurReference><xsl:value-of select="if (bo_ref_id != '' and (tnx_type_code = '01' and prod_stat_code != '98')) then '' else bo_ref_id" /></c:OurReference>
      <c:TheirReference><xsl:value-of select="cust_ref_id" /></c:TheirReference>
      <c:BehalfOfBranch><xsl:value-of select="core:getBOBFromReference(applicant_reference)" /></c:BehalfOfBranch>
    </m:Context>
    <!-- DocumentsReceiveds -->
    <xsl:call-template name="documents-received" />
    <m:EventNotificationss>
      <!--  EventNotifications: Contact details -->
      <xsl:call-template name="corporate-contact" />
      <!--  Client Wording -->
      <xsl:call-template name="client-wording" />
      <xsl:if test="additional_field[@name='country_of_origin'] != ''">
        <m:EventNotifications>
          <m:MessageData><xsl:value-of select="additional_field[@name='country_of_origin']" /></m:MessageData>
          <m:MessageDescription>Origin Of Goods</m:MessageDescription>
          <m:MessageInfo></m:MessageInfo>
          <m:Actioned>N</m:Actioned>
        </m:EventNotifications>
      </xsl:if>
      <xsl:if test="country_of_origin and country_of_origin != ''">
        <m:EventNotifications>
          <m:MessageData><xsl:value-of select="country_of_origin" /></m:MessageData>
          <m:MessageDescription>Origin Of Goods</m:MessageDescription>
          <m:MessageInfo></m:MessageInfo>
          <m:Actioned>N</m:Actioned>
        </m:EventNotifications>
      </xsl:if>
      <xsl:variable name="IncotermAndPlace" select="core:getIncotermAndPlaceGAP(inco_term, inco_place)" />
      <xsl:if test="$IncotermAndPlace != ''">
        <m:EventNotifications>
          <m:MessageData><xsl:value-of select="$IncotermAndPlace" /></m:MessageData>
          <m:MessageDescription>Incoterm and Place</m:MessageDescription>
          <m:MessageInfo></m:MessageInfo>
          <m:Actioned>N</m:Actioned>
        </m:EventNotifications>
      </xsl:if>
      <xsl:if test="$SWIFT2018 = 'N' and cfm_chrg_brn_by_code != '' ">
        <m:EventNotifications>
          <m:MessageData><xsl:value-of select="if (cfm_chrg_brn_by_code = '01') then 'Applicant'
                                               else if (cfm_chrg_brn_by_code = '02') then 'Beneficiary'
                                               else '' " /></m:MessageData>
          <m:MessageDescription>Confirmation Charges</m:MessageDescription>
          <m:MessageInfo></m:MessageInfo>
          <m:Actioned>N</m:Actioned>
        </m:EventNotifications>
      </xsl:if>
      <xsl:if test="adv_send_mode = '99'">
        <m:EventNotifications>
          <m:MessageData><xsl:value-of select="adv_send_mode_text"/></m:MessageData>
          <m:MessageDescription>Send via other method</m:MessageDescription>
          <m:MessageInfo>Additional Information</m:MessageInfo>
          <m:Actioned>N</m:Actioned>
        </m:EventNotifications>
      </xsl:if>
      <xsl:if test="string(core:hasAttachedDocumentMessage(free_format_text)) = 'true'">
        <m:EventNotifications>
          <m:MessageData>This transaction contains attachments. You should connect to Misys Portal.</m:MessageData>
          <m:MessageDescription>Message Text</m:MessageDescription>
          <m:MessageInfo>Additional information</m:MessageInfo>
          <m:Actioned>N</m:Actioned>
        </m:EventNotifications>
      </xsl:if>
      <!-- LicenseDetailsGAP -->
      <xsl:if test="$ftiVersion and $ftiVersion &lt;= 25">
        <xsl:call-template name="linked-licenses-GAP" />
      </xsl:if>
      <!-- NoDataStream -->
      <xsl:call-template name="attachment-notification" />
      <!--  <xsl:call-template name="customisation-eventnotifications" /> -->
    </m:EventNotificationss>
    <!-- EmbeddedItemss -->
    <xsl:call-template name="embedded-items" />
    <xsl:variable name="applicantMnemonic" select="core:getCustomer(applicant_reference)"/>
    <xsl:variable name="applicantNameAndAddress" select="if ($mapAddressLine4) then core:constructNameAndAddress(applicant_name, applicant_address_line_1, applicant_address_line_2, applicant_dom, applicant_address_line_4)
                                                         else core:constructNameAndAddress(applicant_name, applicant_address_line_1, applicant_address_line_2, applicant_dom)" />
    <xsl:variable name="altApplicantNameAndAddress" select="if ($mapAddressLine4) then core:constructNameAndAddress(alt_applicant_name, alt_applicant_address_line_1, alt_applicant_address_line_2, alt_applicant_dom, alt_applicant_address_line_4)
                                                            else core:constructNameAndAddress(alt_applicant_name, alt_applicant_address_line_1, alt_applicant_address_line_2, alt_applicant_dom)" />
    <m:Applicant>
      <c:Customer><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then ''
                                        else $applicantMnemonic" /></c:Customer>
      <c:LegalEntityIdentifier><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then alt_applicant_lei
                                                     else applicant_lei" /></c:LegalEntityIdentifier>
      <c:NameAddress><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then $altApplicantNameAndAddress
                                           else $applicantNameAndAddress" /></c:NameAddress>
      <c:Reference><xsl:value-of select="cust_ref_id" /></c:Reference>
      <c:Country><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then alt_applicant_country else applicant_country"></xsl:value-of></c:Country>
      <xsl:choose>
        <xsl:when test="$mapAlternateApplicantAsApplicant">
          <xsl:call-template name="mt-mx-address">
            <xsl:with-param name="party" select="alt_applicant_address" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="mt-mx-address">
            <xsl:with-param name="party" select="applicant_address" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </m:Applicant>
    <xsl:if test="string(core:hasAttachedDocumentMessage(free_format_text)) = 'false'">
      <m:ApplicantInstructions><xsl:value-of select="free_format_text" /></m:ApplicantInstructions>
    </xsl:if>
    <m:Beneficiary>
      <c:LegalEntityIdentifier><xsl:value-of select="beneficiary_lei" /></c:LegalEntityIdentifier>
      <c:NameAddress><xsl:value-of select="if ($mapAddressLine4) then core:constructNameAndAddress(beneficiary_name, beneficiary_address_line_1, beneficiary_address_line_2, beneficiary_dom, beneficiary_address_line_4)
                                           else core:constructNameAndAddress(beneficiary_name, beneficiary_address_line_1, beneficiary_address_line_2, beneficiary_dom)" /></c:NameAddress>
      <c:Reference><xsl:value-of select="beneficiary_reference" /></c:Reference>
      <c:Country><xsl:value-of select="beneficiary_country" /></c:Country>
      <xsl:call-template name="mt-mx-address">
        <xsl:with-param name="party" select="beneficiary_address" />
      </xsl:call-template>
    </m:Beneficiary>
    <xsl:if test="$SWIFT2018 = 'Y'">
    <m:ConfirmationDetails>
      <c:ConfirmationCharges><xsl:value-of select="if (cfm_chrg_brn_by_code = '01') then 'A'
                                                   else if (cfm_chrg_brn_by_code = '02') then 'B'
                                                   else '' " /></c:ConfirmationCharges>
      <c:RequestedConfirmationParty>
        <c:Customer><xsl:value-of select="requested_confirmation_party/abbv_name" /></c:Customer>
        <c:LegalEntityIdentifier><xsl:value-of select="requested_confirmation_party/lei_code" /></c:LegalEntityIdentifier>
        <c:NameAddress><xsl:value-of select="if ($mapAddressLine4) then core:constructNameAndAddress(requested_confirmation_party/name, requested_confirmation_party/address_line_1, requested_confirmation_party/address_line_2, requested_confirmation_party/dom, requested_confirmation_party/address_line_4)
                                             else core:constructNameAndAddress(requested_confirmation_party/name, requested_confirmation_party/address_line_1, requested_confirmation_party/address_line_2, requested_confirmation_party/dom)" /></c:NameAddress>
        <c:SwiftAddress><xsl:value-of select="requested_confirmation_party/iso_code" /></c:SwiftAddress>
        <c:Reference><xsl:value-of select="requested_confirmation_party/reference" /></c:Reference>
        <c:Contact><xsl:value-of select="requested_confirmation_party/contact_name" /></c:Contact>
        <c:ZipCode><xsl:value-of select="requested_confirmation_party/zipcode" /></c:ZipCode>
        <c:Telephone><xsl:value-of select="requested_confirmation_party/phone" /></c:Telephone>
        <c:FaxNumber><xsl:value-of select="requested_confirmation_party/fax" /></c:FaxNumber>
        <c:TelexNumber><xsl:value-of select="requested_confirmation_party/telex" /></c:TelexNumber>
        <c:Email><xsl:value-of select="requested_confirmation_party/web_address" /></c:Email>
        <xsl:if test="req_conf_party_flag = 'Other'">
          <xsl:call-template name="mt-mx-address">
            <xsl:with-param name="party" select="requested_confirmation_party" />
          </xsl:call-template>
        </xsl:if>
      </c:RequestedConfirmationParty>
      <c:RequestedConfirmationPartyRole><xsl:value-of select="if (req_conf_party_flag = 'Advise Thru Bank') then 'THB'
                                                              else if (req_conf_party_flag = 'Advising Bank') then 'ADV'
                                                              else if (req_conf_party_flag = 'Other') then 'OTH'
                                                              else ''" /></c:RequestedConfirmationPartyRole>
    </m:ConfirmationDetails>
    </xsl:if>
    <m:IssueBy><xsl:value-of select="params:getTIAdviceMethod(adv_send_mode)" /></m:IssueBy>
    <m:LCAmount>
      <c:Amount><xsl:value-of select="lc_amt" /></c:Amount>
      <c:Currency><xsl:value-of select="lc_cur_code" /></c:Currency>
    </m:LCAmount>
    <m:LCAmountSpec>
      <c:Qualifier><xsl:value-of select="if (max_cr_desc_code != '' ) then
                                           (if (max_cr_desc_code = '3') then 'N' else 'O')
                                         else '' " /></c:Qualifier>
      <c:Min><xsl:value-of select="neg_tol_pct" /></c:Min>
      <c:Max><xsl:value-of select="pstv_tol_pct" /></c:Max>
    </m:LCAmountSpec>
    <m:Revocable><xsl:value-of select="if (irv_flag = 'Y' or irv_flag = '') then 'N' else 'Y'" /></m:Revocable>
    <m:Confirmation>
      <xsl:if test="cfm_inst_code = '01'">C</xsl:if>
      <xsl:if test="cfm_inst_code = '02'">M</xsl:if>
      <xsl:if test="cfm_inst_code = '03'">W</xsl:if>
    </m:Confirmation>
    <m:Revolving>
      <c:Revolving><xsl:value-of select="revolving_flag" /></c:Revolving>
      <c:Cumulative><xsl:value-of select="cumulative_flag" /></c:Cumulative>
      <c:Period><xsl:value-of select="if (revolve_period != '' and revolve_frequency != '') then concat(revolve_period, ' ', revolve_frequency) else '' " /></c:Period>
      <c:Revolutions><xsl:value-of select="revolve_time_no" /></c:Revolutions>
      <c:NextDate><xsl:value-of select="if (next_revolve_date and next_revolve_date != '') then core:dateFormatCCToTIPlus(next_revolve_date) else '' " /></c:NextDate>
      <c:NoticeDays><xsl:value-of select="notice_days" /></c:NoticeDays>
      <c:ChargeToFirstPeriod><xsl:value-of select="if (charge_upto = 'p') then 'Y'
                                                   else if (charge_upto = 'e') then 'N'
                                                   else ''" /></c:ChargeToFirstPeriod>
    </m:Revolving>
    <m:Transferable><xsl:value-of select="if (ntrf_flag = 'Y') then 'N'
                                        else if (ntrf_flag = 'N') then 'Y'
                                        else ''" /></m:Transferable>
    <m:StandBy><xsl:value-of select="stnd_by_lc_flag" /></m:StandBy>
    <m:ExpiryDate><xsl:value-of select="if (exp_date and exp_date != '') then core:dateFormatCCToTIPlus(exp_date) else '' " /></m:ExpiryDate>
    <m:ApplicationDate><xsl:value-of select="if (appl_date and appl_date != '') then core:dateFormatCCToTIPlus(appl_date) else '' " /></m:ApplicationDate>
    <m:ExpiryPlace><xsl:value-of select="expiry_place" /></m:ExpiryPlace>
    <m:TermsOfPayment>
      <c:Tenor>
        <c:TenorDays><xsl:value-of select="if (tenor_days and tenor_days != '') then tenor_days else additional_field[@name='tenor_days']" /></c:TenorDays>
        <c:TenorPeriod><xsl:value-of select="if (tenor_period and tenor_period != '') then tenor_period else additional_field[@name='tenor_period']" /></c:TenorPeriod>
      </c:Tenor>
      <c:FromAfter><xsl:value-of select="if (tenor_from_after and tenor_from_after != '') then tenor_from_after else additional_field[@name='tenor_from_after']" /></c:FromAfter>
      <xsl:variable name="tenorFrom" select="if (tenor_days_type and tenor_days_type != '') then params:getTITenorFrom(tenor_days_type) else params:getTITenorFrom(additional_field[@name='tenor_days_type'])" />
      <c:TenorFrom><xsl:value-of select="if ($tenorFrom != '') then $tenorFrom else '' " /></c:TenorFrom>
      <c:TenorText><xsl:value-of select="if ((tenor_days_type and tenor_days_type = '08') or additional_field[@name='tenor_days_type'] = '08') then 'Arrival and Inspection of Goods'
                                         else if (tenor_days_type and tenor_days_type = '99' and tenor_type_details and tenor_type_details != '') then tenor_type_details
                                         else if (additional_field[@name='tenor_days_type'] = '99') then additional_field[@name='tenor_type_details']
                                         else if (tenor_text and tenor_text != '') then tenor_text
                                         else if (additional_field[@name='tenor_text'] != '') then additional_field[@name='tenor_text']
                                         else ''" /></c:TenorText>
      <xsl:variable name="tenor_maturity_date" select="if (tenor_maturity_date and tenor_maturity_date != '') then tenor_maturity_date else additional_field[@name='tenor_maturity_date']" />
      <c:TenorMaturityDate><xsl:value-of select="if ($tenor_maturity_date and $tenor_maturity_date != '') then core:dateFormatCCToTIPlus($tenor_maturity_date) else '' " /></c:TenorMaturityDate>
      <c:MixedPayDtls><xsl:value-of select="draft_term" /></c:MixedPayDtls>
      <xsl:variable name="draweeBank" select="drawee_details_bank/name" />
      <xsl:if test="$draweeBank != ''">
        <xsl:choose>
          <xsl:when test="$draweeBank = 'Issuing Bank'"><c:DraftsDrawnOn>I</c:DraftsDrawnOn></xsl:when>
          <xsl:when test="$draweeBank = 'Advising Bank'"><c:DraftsDrawnOn>A</c:DraftsDrawnOn></xsl:when>
          <xsl:when test="$draweeBank = 'Reimbursing Bank'"><c:DraftsDrawnOn>R</c:DraftsDrawnOn></xsl:when>
          <xsl:otherwise>
            <c:DraftsDrawnOn>O</c:DraftsDrawnOn>
            <c:DraftsDrawnOnBank><xsl:value-of select = "$draweeBank" /></c:DraftsDrawnOnBank>
            <c:DraftsDrawnOnBankDetail>
              <c:LegalEntityIdentifier><xsl:value-of select="drawee_details_bank/lei_code" /></c:LegalEntityIdentifier>
              <xsl:call-template name="mt-mx-address">
                <xsl:with-param name="party" select="drawee_details_bank" />
              </xsl:call-template>
             </c:DraftsDrawnOnBankDetail>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <c:AvailableBy><xsl:value-of select="if (cr_avl_by_code != '') then params:getTIAvailableBy(cr_avl_by_code) else '' " /></c:AvailableBy>
    </m:TermsOfPayment>
    <xsl:variable name="availableWithBankName" select="upper-case(credit_available_with_bank/name)" />
    <xsl:variable name="availableWithBankAddress" select="credit_available_with_bank/address_line_1" />
    <xsl:variable name="availableWithBankDetails" select="if ($mapAddressLine4) then core:constructNameAndAddress(credit_available_with_bank/name, credit_available_with_bank/address_line_1, credit_available_with_bank/address_line_2, credit_available_with_bank/dom, credit_available_with_bank/address_line_4)
                                                          else core:constructNameAndAddress(credit_available_with_bank/name, credit_available_with_bank/address_line_1, credit_available_with_bank/address_line_2, credit_available_with_bank/dom)" />
    <m:AvailableWith>
      <xsl:variable name="availableWithBankNameType" select="if ($availableWithBankName != '') then
                                                               if ($availableWithBankName = 'ISSUING BANK') then 'I'
                                                               else if ($availableWithBankName = 'ANY BANK') then 'W'
                                                               else if ($availableWithBankName = 'ADVISING BANK') then 'A'
                                                               else if ($availableWithBankName = 'OURSELVES') then 'S'
                                                               else if ($availableWithBankName = 'ADVISE THRU BANK') then 'H'
                                                               else 'O'
                                                             else ''" />
      <c:Type><xsl:value-of select="$availableWithBankNameType" /></c:Type>
      <c:Bank><xsl:value-of select="if ($availableWithBankNameType = 'O') then $availableWithBankDetails else ''" /></c:Bank>
      <c:City><xsl:value-of select="if ($availableWithBankName = 'ANY BANK IN (CITY)') then $availableWithBankAddress else '' " /></c:City>
      <c:Ctry><xsl:value-of select="if ($availableWithBankName = 'ANY BANK IN (COUNTRY)') then $availableWithBankAddress else '' " /></c:Ctry>
      <c:LegalEntityIdentifier><xsl:value-of select="credit_available_with_bank/lei_code" /></c:LegalEntityIdentifier>
      <xsl:if test="$availableWithBankNameType = 'O'">
        <xsl:call-template name="mt-mx-address">
          <xsl:with-param name="party" select="credit_available_with_bank" />
        </xsl:call-template>
      </xsl:if>
    </m:AvailableWith>
    <m:ShipmentFrom><xsl:value-of select="ship_from" /></m:ShipmentFrom>
    <m:ShipmentTo><xsl:value-of select="ship_to" /></m:ShipmentTo>
    <m:ShipmentDate><xsl:value-of select="if (last_ship_date and last_ship_date != '') then core:dateFormatCCToTIPlus(last_ship_date) else '' " /></m:ShipmentDate>
    <m:ShipmentPeriod><xsl:value-of select="narrative_shipment_period" /></m:ShipmentPeriod>
    <m:TransShipment><xsl:value-of select="if ($SWIFT2018 = 'Y') then core:getSWIFT2018TransOrPartShipment(tran_ship_detl)
                                           else core:getTransOrPartShipment(tran_ship_detl)" /></m:TransShipment>
    <m:PartShipment><xsl:value-of select="if ($SWIFT2018 = 'Y') then core:getSWIFT2018TransOrPartShipment(part_ship_detl)
                                          else core:getTransOrPartShipment(part_ship_detl)" /></m:PartShipment>
    <m:Incoterm><xsl:value-of select="inco_term" /></m:Incoterm>
    <m:IncoPlace><xsl:value-of select="inco_place" /></m:IncoPlace>
    <xsl:if test="$SWIFT2018 = 'Y'" >
      <m:PresentationDays><xsl:value-of select="period_presentation_days" /></m:PresentationDays>
    </xsl:if>
    <m:PresentationPeriod><xsl:value-of select="narrative_period_presentation" /></m:PresentationPeriod>
    <m:Goods><xsl:value-of select="narrative_description_goods" /></m:Goods>
    <m:Documents><xsl:value-of select="narrative_documents_required" /></m:Documents>
    <m:AdditionalConditions><xsl:value-of select="narrative_additional_instructions" /></m:AdditionalConditions>
    <xsl:if test="$SWIFT2018 = 'Y'">
      <m:SpecialPaymentConditions>
        <c:ForBeneficiary><xsl:value-of select="narrative_special_beneficiary"/></c:ForBeneficiary>
        <c:ForReceivingBank><xsl:value-of select="narrative_special_recvbank" /></c:ForReceivingBank>
      </m:SpecialPaymentConditions>
    </xsl:if>
    <m:IssuanceChgsFor><xsl:value-of select="if (open_chrg_brn_by_code = '01') then 'A'
                                             else if (open_chrg_brn_by_code = '02') then 'B'
                                             else ''" /></m:IssuanceChgsFor>
    <m:OverseasChgsFor><xsl:value-of select="if (corr_chrg_brn_by_code = '01') then 'A'
                                             else if (corr_chrg_brn_by_code = '02') then 'B'
                                             else ''" /></m:OverseasChgsFor>
    <m:AddAmountText><xsl:value-of select="narrative_additional_amount" /></m:AddAmountText>
    <m:AdviseThru>
      <c:LegalEntityIdentifier><xsl:value-of select="advise_thru_bank/lei_code" /></c:LegalEntityIdentifier>
      <c:NameAddress><xsl:value-of select="if ($mapAddressLine4) then core:constructNameAndAddress(advise_thru_bank/name, advise_thru_bank/address_line_1, advise_thru_bank/address_line_2, advise_thru_bank/dom, advise_thru_bank/address_line_4)
                                           else core:constructNameAndAddress(advise_thru_bank/name, advise_thru_bank/address_line_1, advise_thru_bank/address_line_2, advise_thru_bank/dom)" /></c:NameAddress>
      <c:SwiftAddress><xsl:value-of select="advise_thru_bank/iso_code" /></c:SwiftAddress>
      <xsl:call-template name="mt-mx-address">
        <xsl:with-param name="party" select="advise_thru_bank" />
      </xsl:call-template>
    </m:AdviseThru>
    <m:ChargeAccount><xsl:value-of select="fee_act_no" /></m:ChargeAccount>
    <m:PrincipalAccount><xsl:value-of select="principal_act_no" /></m:PrincipalAccount>
    <m:AdvisingBank>
      <c:LegalEntityIdentifier><xsl:value-of select="advising_bank/lei_code" /></c:LegalEntityIdentifier>
      <c:NameAddress><xsl:value-of select="if ($mapAddressLine4) then core:constructNameAndAddress(advising_bank/name, advising_bank/address_line_1, advising_bank/address_line_2, advising_bank/dom, advising_bank/address_line_4)
                                           else core:constructNameAndAddress(advising_bank/name, advising_bank/address_line_1, advising_bank/address_line_2, advising_bank/dom)" /></c:NameAddress>
      <c:SwiftAddress><xsl:value-of select="advising_bank/iso_code" /></c:SwiftAddress>
      <xsl:call-template name="mt-mx-address">
        <xsl:with-param name="party" select="advising_bank" />
      </xsl:call-template>
    </m:AdvisingBank>
    <m:eBankMasterRef><xsl:value-of select="ref_id" /></m:eBankMasterRef>
    <m:eBankEvent><xsl:value-of select="tnx_id" /></m:eBankEvent>
    <xsl:variable name="RulesCode" select="params:getSIRulesCode(applicable_rules)" />
    <xsl:if test="$RulesCode = ('E', 'P', 'I', 'U', 'C', 'O')">
      <m:ApplcableRules><xsl:value-of select="$RulesCode" /></m:ApplcableRules>
      <m:ApplcableRulesNarrative><xsl:value-of select="applicable_rules_text"/></m:ApplcableRulesNarrative>
    </xsl:if>
    <m:PortOfLoading><xsl:value-of select="ship_loading" /></m:PortOfLoading>
    <m:PortOfDischarge><xsl:value-of select="ship_discharge" /></m:PortOfDischarge>
    <m:InstructionsToPayingBank><xsl:value-of select="if ($SWIFT2018 = 'Y') then narrative_payment_instructions else ''" /></m:InstructionsToPayingBank>
    <!-- LicenseDetails -->
    <xsl:if test="$ftiVersion and $ftiVersion &gt;= 27">
      <xsl:call-template name="linked-licenses" />
    </xsl:if>
    <xsl:variable name="startAt"><xsl:value-of select="number(params:getStartAndEndSequenceReference('LC', 'START'))" /></xsl:variable>
    <m:PreallocatedNo><xsl:value-of select="if (bo_ref_id != '' and tnx_type_code = '01')
                                                then substring(bo_ref_id, $startAt,
                                                number(params:getStartAndEndSequenceReference('LC', 'END')) - $startAt + 1)
                                            else ''" /></m:PreallocatedNo>
    <xsl:if test="for_account_flag = 'Y'">
      <m:ApplicantBank>
        <c:Customer><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then $applicantMnemonic
                                          else ''"/></c:Customer>
        <c:LegalEntityIdentifier><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then applicant_lei
                                                       else alt_applicant_lei" /></c:LegalEntityIdentifier>
        <c:NameAddress><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then $applicantNameAndAddress
                                             else $altApplicantNameAndAddress" /></c:NameAddress>
        <c:Reference><xsl:value-of select="cust_ref_id" /></c:Reference>
        <c:Country><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then applicant_country
                                         else alt_applicant_country" /></c:Country>
        <xsl:choose>
          <xsl:when test="$mapAlternateApplicantAsApplicant">
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="applicant_address" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="alt_applicant_address" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </m:ApplicantBank>
    </xsl:if>
    <m:FinalWording>
      <xsl:if test="(sub_tnx_type_code='88') and (prod_stat_code='78' or prod_stat_code='79')">Y</xsl:if>
      <xsl:if test="(prod_stat_code='98') or (sub_tnx_type_code='89' and (prod_stat_code='78' or prod_stat_code='79'))">N</xsl:if>
    </m:FinalWording>
    <m:Provisional>
      <xsl:if test="(prod_stat_code='98') or (prod_stat_code='78') or (prod_stat_code='79' and sub_tnx_type_code='89')">Y</xsl:if>
      <xsl:if test="(prod_stat_code='79') and (sub_tnx_type_code='88')">N</xsl:if>
    </m:Provisional>
    <m:AutoCreateFollowOnEvent><xsl:value-of select="if (prod_stat_code='98') then 'N' else ''" /></m:AutoCreateFollowOnEvent>
  </xsl:template>
</xsl:stylesheet>
