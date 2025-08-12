<?xml version="1.0" encoding="UTF-8"?>
<!--
    Document   : TIPlusCommons.xsl
    Created on : April 13, 2016, 3:19 PM
    Description:
        Extraction of transformation for the following tags that is used
        on almost all mapping scripts.
        - Linked Licenses
        - Variation for Reduction/Increase of Local Undertaking
        - Variation Line Item for Irregular Reduction/Increase
        - Charges
        - Attachments
        - Standbys and Guarantees (Undertaking Off) Renewals
        - Local Undertaking Renewals
        - Amendment Instructions
        - Cross Reference
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:params="xalan://com.misys.tiplus2.ticc.MappingParameters"
                xmlns:core="xalan://com.misys.tiplus2.ticc.GlobalFunctions"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                exclude-result-prefixes="xsl params core">
                
  <!-- Linked Licenses -->
  <xsl:template name="linked-licenses">
    <linked_licenses>
      <xsl:if test="LinkedLicenses != ''">
        <xsl:for-each select="LinkedLicenses">
          <license>
            <ls_ref_id></ls_ref_id>
            <bo_ref_id><xsl:value-of select="MasterRef"/></bo_ref_id>
            <ls_number><xsl:value-of select="LicenseNumber"/></ls_number>
            <ls_allocated_amt><xsl:value-of select="core:getAmountFromAmountCCYForLicenses(AllocatedAmount)"/></ls_allocated_amt>
          </license>
        </xsl:for-each>
      </xsl:if>
    </linked_licenses>
  </xsl:template>
  
  <!-- Variation for Reduction/Increase of Local Undertaking -->
  <xsl:template name="variation-local-undertaking">
    <variation>
      <xsl:if test="RegularRedInc">
        <type xsi:nil="true"><xsl:value-of select="if (RegularRedInc = 'Y') then '01'
                                                   else if (IrregularRedInc = 'Y') then '02'
                                                   else ''"/></type>
      </xsl:if>
      <advise_flag><xsl:value-of select="AdviseRedInc"/></advise_flag>
      <advise_reduction_days><xsl:value-of select="AdviseRedIncNoticeDays"/></advise_reduction_days>
      <maximum_nb_days><xsl:value-of select="if (MaximumIncrease != '') then MaximumIncrease
                                               else if (MaximumDecrease != '') then MaximumDecrease
                                               else ''"/></maximum_nb_days>
      <frequency><xsl:value-of select="RedIncFrequency"/></frequency>
      <period><xsl:value-of select="if (RedIncFrequency != '') then RedIncForPeriod else ''"/></period>
      <day_in_month><xsl:value-of select="DayInMonth"/></day_in_month>
      <variation_lines>
        <xsl:if test="RegularRedInc = 'Y'">
          <variation_line_item>
            <sequence><xsl:value-of select="position()"/></sequence>
            <operation><xsl:value-of select="if (RedIncOperationCode = 'I') then '01'
                                               else if (RedIncOperationCode = 'R') then '02'
                                               else ''"/></operation>
            <first_date><xsl:value-of select="if (RedIncFirstDate != '') then core:dateFormatTIPlusToCC(RedIncFirstDate, 'RedIncFirstDate') else ''"/></first_date>
            <xsl:choose>
              <xsl:when test="RedIncByAmount = 'Y'">
                <amount><xsl:value-of select="core:getCCAmount(RedIncAmount, RedIncCurrency)"/></amount>
                <cur_code><xsl:value-of select="RedIncCurrency"/></cur_code>
              </xsl:when>
              <xsl:otherwise>
                <percent><xsl:value-of select="core:getFirstArrayIndex(RedIncPercent)"/></percent>
              </xsl:otherwise>
            </xsl:choose>
          </variation_line_item>
        </xsl:if>
        <xsl:if test="IrregularRedInc = 'Y'">
          <xsl:for-each select="IrregularRepaymentSchedules">
            <xsl:call-template name="variation-line-item-irregular"/>
          </xsl:for-each>
        </xsl:if>
      </variation_lines>
    </variation>
  </xsl:template>

  <!-- Variation Line Item for Irregular Reduction/Increase -->
  <xsl:template name="variation-line-item-irregular">
    <variation_line_item>
      <sequence><xsl:value-of select="position()"/></sequence>
      <operation><xsl:value-of select="if (OperationCode = 'I') then '01'
                                       else if (OperationCode = 'R') then '02'
                                       else ''"/></operation>
      <first_date><xsl:value-of select="if (RepaymentDate != '') then core:dateFormatTIPlusToCC(RepaymentDate, 'RepaymentDate') else ''"/></first_date>
      <xsl:choose>
        <xsl:when test="Percentage != ''">
          <percent><xsl:value-of select="core:getFirstArrayIndex(Percentage)"/></percent>
        </xsl:when>
        <xsl:otherwise>
          <amount><xsl:value-of select="core:getCCAmount(Amount, Currency)"/></amount>
          <cur_code><xsl:value-of select="Currency"/></cur_code>
        </xsl:otherwise>
      </xsl:choose>
    </variation_line_item>
  </xsl:template>

  <!-- Charges -->
  <xsl:template name="charges">
    <xsl:param name="amendApprovalRequired" select="false()"/>
    <xsl:variable name="FCCVersion"><xsl:value-of select="params:getFCCVersion()" /></xsl:variable>
    <xsl:variable name="chgDescAddEventRef"><xsl:value-of select="params:getChgDescAddEventRef()" /></xsl:variable>
    <xsl:variable name="chgDescAddPeriodicType"><xsl:value-of select="params:getChgDescAddPeriodicType()" /></xsl:variable>
    <xsl:variable name="eventRef"><xsl:value-of select="EventRef" /></xsl:variable>
    <charges>
      <xsl:for-each select="Charges">
        <xsl:variable name="periodicType"><xsl:value-of select="if (PeriodicType = 'S') then '(Periodic in Advance)'
                                                                else if (PeriodicType = 'E') then '(Periodic in Arrears)'
                                                                else ''" /></xsl:variable>
        <xsl:variable name="addComment">
          <xsl:value-of select="if ($chgDescAddEventRef = 'Y' and $eventRef != '') then concat($eventRef, ' - ') else ''" />
          <xsl:value-of select="AddComment" />
          <xsl:value-of select="if ($chgDescAddPeriodicType = 'Y' and $periodicType != '') then concat(' ', $periodicType) else ''" />
        </xsl:variable>
        <charge>
          <chrg_id><xsl:value-of select="if ($FCCVersion = '52') then ChgId else ''" /></chrg_id>
          <chrg_code><xsl:value-of select="if ($FCCVersion = '52') then ChgCode else 'OTHER'" /></chrg_code>
          <amt><xsl:value-of select="core:getCCAmount(ChgCalcAmt, ChgCalcCcy)" /></amt>
          <cur_code><xsl:value-of select="ChgCalcCcy" /></cur_code>
          <status><xsl:value-of select="if (Status = 'Y') then '03'
                                        else if (Status = 'N') then 
                                          if ((PeriodicType = 'S' and $amendApprovalRequired) or (PeriodicType = 'E' and SettleDate = '')) then '04'
                                          else '01'
                                        else if (Status = 'W') then '02'
                                        else if (Status = 'U') then '05'
                                        else '99'" /></status>
          <exchange_rate><xsl:value-of select="if (ExchangeRate != '') then replace(ExchangeRate, ',', '.') else ''" /></exchange_rate>
          <eqv_amt><xsl:value-of select="core:getCCAmount(EquivChgAmt, EquivChgCcy)" /></eqv_amt>
          <eqv_cur_code><xsl:value-of select="EquivChgCcy" /></eqv_cur_code>
          <inception_date><xsl:value-of select="if (ChgInceptionDate != '') then core:dateFormatTIPlusToCC(ChgInceptionDate, 'ChgInceptionDate') else ''" /></inception_date>
          <settlement_date><xsl:value-of select="if (SettleDate != '') then core:dateFormatTIPlusToCC(SettleDate, 'SettleDate') else ''" /></settlement_date>
          <additional_comment><xsl:value-of select="core:getFormattedNarrative($addComment)" /></additional_comment>
          <created_in_session>Y</created_in_session>
        </charge>
      </xsl:for-each>
    </charges>
  </xsl:template>
  
  <!-- Attachments -->
  <xsl:template name="attachments">
    <xsl:param name="checkAttachments" select="false()"/>
    <attachments>
      <xsl:for-each select="AttachedDocuments[(upper-case(../DraftNum) = ('DPR001-0', '0')) or (not(upper-case(DocumentId) = ('TFELCPYCD','TFEGTPYCD','TFESBPYCD','TFODCACCD','TFIDCACCD')))]">
        <xsl:if test="DocumentReference != '' and (not(BankDocument) or (BankDocument = 'N'))">
          <xsl:variable name="fileName" select="if (not(contains(DocumentReference, '.')))
                                                  then core:getFilenameWithExt(DocumentReference, Mime)
                                                else DocumentReference" />
           <attachment>
             <file_name><xsl:value-of select="$fileName" /></file_name>
             <title><xsl:value-of select="DocumentDesc" /></title>
             <type>02</type>
             <exported_file_path><xsl:value-of select="$fileName" /></exported_file_path>
             <mime_type><xsl:value-of select="Mime" /></mime_type>
             <xsl:choose>
               <xsl:when test="params:getExternalDMS() = 'Y'">
                 <doc_id><xsl:value-of select="$fileName" /></doc_id>
               </xsl:when>
               <xsl:otherwise>
                 <file_attachment><xsl:value-of select="DocDetails" /></file_attachment>
               </xsl:otherwise>
             </xsl:choose>
           </attachment>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="MailingDocs">
        <xsl:if test="DocumentReference != '' and
                      (($checkAttachments and IsCustomerAttachedDocument = 'N' and (not(BankDocument) or (BankDocument = 'N'))) or
                      (not($checkAttachments) and (not(BankDocument) or (BankDocument = 'N'))))">
          <xsl:variable name="fileName" select="if (not(contains(DocumentReference, '.')))
                                                  then core:getFilenameWithExt(DocumentReference, Mime)
                                                else DocumentReference" />
          <attachment>
            <file_name><xsl:value-of select="$fileName" /></file_name>
            <title><xsl:value-of select="DocTypeDesc" /></title>
            <type>02</type>
            <exported_file_path><xsl:value-of select="$fileName" /></exported_file_path>
            <mime_type><xsl:value-of select="Mime" /></mime_type>
              <xsl:choose>
                <xsl:when test="params:getExternalDMS() = 'Y'">
                 <doc_id><xsl:value-of select="$fileName" /></doc_id>
                </xsl:when>
                <xsl:otherwise>
                 <file_attachment><xsl:value-of select="DocDetails" /></file_attachment>
                </xsl:otherwise>
              </xsl:choose>
          </attachment>
        </xsl:if>
      </xsl:for-each>
    </attachments>
  </xsl:template>
  
  <!-- Documents -->
  <xsl:template name="documents">
    <documents>
      <xsl:for-each select="MailingDocs">
        <xsl:if test="not(BankDocument) or (BankDocument = 'N')">
          <document>
            <xsl:variable name="code" select="params:getColDotCodeMaps(DocTypeId)" />
            <code><xsl:value-of select="if ($code = '' or (string-length($code) &lt; 1)) then '99' else $code" /></code>
            <name><xsl:value-of select="DocTypeDesc" /></name>
            <first_mail><xsl:value-of select="FirstMail" /></first_mail>
            <second_mail><xsl:value-of select="SecondMail" /></second_mail>
            <total><xsl:value-of select="TotalMail" /></total>
            <mapped_attachment_name><xsl:value-of select="if (DocumentReference != '') then DocTypeDesc else ''" /></mapped_attachment_name>
            <doc_no><xsl:value-of select="DocumentFaceReference"/></doc_no>
            <doc_date><xsl:value-of select="if (DocumentDate != '') then core:dateFormatTIPlusToCC(DocumentDate, 'DocumentDate') else ''"/></doc_date>
          </document>
        </xsl:if>
      </xsl:for-each>
    </documents>
  </xsl:template>

 <!-- Collection Drafts -->
  <xsl:template name="collection-drafts">
    <xsl:variable name="FCCVersion"><xsl:value-of select="params:getFCCVersion()" /></xsl:variable>
    <xsl:variable name="FCCPatch"><xsl:value-of select="params:getFCCPatch()" /></xsl:variable>
    <xsl:choose>
      <xsl:when test="$FCCVersion &gt; 62 or ($FCCVersion = 62 and $FCCPatch &gt;= 4)">
        <payment_tenors>
          <xsl:for-each select="CollectionDrafts">
            <payment_tenor>
              <xsl:call-template name="new-common-collection-drafts" />
           </payment_tenor>
          </xsl:for-each>
        </payment_tenors>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="old-collection-drafts" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- New Common Collection Drafts -->
  <xsl:template name="new-common-collection-drafts">
    <xsl:variable name="draftAgainst" select="AgainstCode" />
    <xsl:variable name="draftStatus" select="StatusCode" />
    <payment_tenor_id><xsl:value-of select="InternalIdentifier"/></payment_tenor_id>
    <payment_cur_code><xsl:value-of select="DraftCcy"/></payment_cur_code>
    <payment_amt><xsl:value-of select="core:getCCAmount(DraftAmt, DraftCcy)"/></payment_amt>
    <maturity_date xsi:nil="true"><xsl:value-of select="if (MaturityDate != '') then core:dateFormatTIPlusToCC(MaturityDate, 'MaturityDate') else ''"/></maturity_date>
    <tenor_days><xsl:value-of select="TenorDays"/></tenor_days>
    <tenor_period><xsl:value-of select="TenorPeriod"/></tenor_period>
    <tenor_from_after><xsl:value-of select="FromAfter"/></tenor_from_after>
    <draft_text><xsl:value-of select="DraftText"/></draft_text>
    <tenor_base_date xsi:nil="true"><xsl:value-of select="if (PaymentBaseDate != '') then core:dateFormatTIPlusToCC(PaymentBaseDate, 'PaymentBaseDate') else ''"/></tenor_base_date>
    <tenor_id><xsl:value-of select="Identifier"/></tenor_id>
    <payment_tenor_id><xsl:value-of select="InternalIdentifier"/></payment_tenor_id>
    <tenor_code><xsl:value-of select="TenorCode"/></tenor_code>
    <status><xsl:value-of select="if ($draftStatus = 'WP' and $draftAgainst = 'P' ) then '01'
                                  else if ($draftStatus = 'WA' and $draftAgainst = 'A') then '02'
                                  else if ($draftStatus = 'WV' and $draftAgainst = 'V') then '02'
                                  else if ($draftStatus = 'WP' and $draftAgainst = ('A','V')) then '03'
                                  else if ($draftStatus = 'RT' and $draftAgainst = 'A') then '03'
                                  else if ($draftStatus = 'P') then '04'
                                  else ''" /></status>
    <draft_against><xsl:value-of select="AgainstCode"/></draft_against>
    <draft_outstanding_amt><xsl:value-of select="core:getCCAmount(OutstandingAmt, OutstandingCcy)"/></draft_outstanding_amt>
    <draft_outstanding_ccy><xsl:value-of select="OutstandingCcy"/></draft_outstanding_ccy>
    <xsl:variable name="tenorType" select="if ($draftAgainst = 'P') then '01'
                                           else if ($draftAgainst = 'A') then '02'
                                           else if ($draftAgainst = 'V') then '03'
                                           else ''"/>
    <tenor_type><xsl:value-of select="$tenorType"/></tenor_type>
    <xsl:choose>
      <xsl:when test="$tenorType = '01'">
        <xsl:variable name="tenorText" select="upper-case(TenorText)"/>
        <xsl:variable name="draftTenorFrom" select="if ($tenorText = 'AIR WAYBILL') then 'A'
                                                    else if ($tenorText = 'ARRIVAL OF GOODS') then 'G'
                                                    else if ($tenorText = 'BILL OF EXCHANGE') then 'E'
                                                    else if ($tenorText = 'BILL OF LADING') then 'L'
                                                    else if ($tenorText = 'INVOICE') then 'I'
                                                    else if ($tenorText = 'SHIPMENT DATE') then 'P'
                                                    else if ($tenorText = 'SIGHT') then 'S'
                                                    else if ($tenorText != '') then 'O'
                                                    else ''"/>
        <tenor_days_type_sight><xsl:value-of select="$draftTenorFrom"/></tenor_days_type_sight>
        <tenor_type_details_sight><xsl:value-of select="if ($draftTenorFrom = 'O') then TenorText else ''"/></tenor_type_details_sight>
      </xsl:when>
      <xsl:otherwise>
        <tenor_days_type><xsl:value-of select="TenorCode"/></tenor_days_type>
        <tenor_type_details><xsl:value-of select="if (TenorCode = 'O') then TenorNarrative else ''"/></tenor_type_details>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Old Collection Drafts -->
  <xsl:template name="old-collection-drafts">
    <xsl:variable name="draftAgainst" select="CollectionDrafts[1]/AgainstCode"/>
    <xsl:variable name="tenorType" select="if ($draftAgainst = 'P') then '01'
                                                 else if ($draftAgainst = 'A') then '02'
                                                 else if ($draftAgainst = 'V') then '03'
                                                 else ''"/>
    <tenor_maturity_date xsi:nil="true"><xsl:value-of select="if (CollectionDrafts[1]/MaturityDate != '') then core:dateFormatTIPlusToCC(CollectionDrafts[1]/MaturityDate, 'MaturityDate') else ''" /></tenor_maturity_date>
    <tenor_base_date xsi:nil="true"><xsl:value-of select="if (CollectionDrafts[1]/PaymentBaseDate != '') then core:dateFormatTIPlusToCC(CollectionDrafts[1]/PaymentBaseDate, 'PaymentBaseDate') else ''" /></tenor_base_date> 
    <tenor_days><xsl:value-of select="CollectionDrafts[1]/TenorDays" /></tenor_days>
    <tenor_period><xsl:value-of select="CollectionDrafts[1]/TenorPeriod" /></tenor_period>
    <tenor_from_after><xsl:value-of select="CollectionDrafts[1]/FromAfter" /></tenor_from_after>
    <tenor_type><xsl:value-of select="$tenorType"/></tenor_type>
    <xsl:variable name="draftTenorFrom" select="upper-case(CollectionDrafts[1]/TenorText)" />
    <xsl:choose>
      <xsl:when test="$tenorType = '01'">
        <tenor_days_type><xsl:value-of select="if ($draftTenorFrom = 'AIR WAYBILL') then 'A'
                                               else if ($draftTenorFrom = 'ARRIVAL OF GOODS') then 'G'
                                               else if ($draftTenorFrom = 'BILL OF EXCHANGE') then 'E'
                                               else if ($draftTenorFrom = 'BILL OF LADING') then 'L'
                                               else if ($draftTenorFrom = 'INVOICE') then 'I'
                                               else if ($draftTenorFrom = 'SHIPMENT DATE') then 'P'
                                               else if ($draftTenorFrom = 'SIGHT') then 'S'
                                               else if ($draftTenorFrom != '') then 'O'
                                               else ''" /></tenor_days_type>
      </xsl:when>
      <xsl:otherwise>
        <tenor_days_type><xsl:value-of select="CollectionDrafts[1]/TenorCode"/></tenor_days_type>
      </xsl:otherwise>
    </xsl:choose>
    <tenor_type_details><xsl:value-of select="if ($draftTenorFrom != '') then CollectionDrafts[1]/TenorNarrative else ''" /></tenor_type_details>
  </xsl:template>
  
  <!-- Standbys and Guarantees (Undertaking Off) Renewals -->
  <xsl:template name="renewals">
    <renew_flag xsi:nil="true"><xsl:value-of select="Renewal"/></renew_flag>
    <renew_on_code xsi:nil="true"><xsl:value-of select="if ((upper-case(RenewalBasisType) = 'REGULAR RENEWAL') or ((upper-case(RenewalBasisType) = 'FIRST RENEWAL/ROLLING RENEWAL') and RenewalOnExpiry = 'Y')) then '01' 
                                                        else if (RenewalOnCalendarDate = 'Y') then '02'
                                                        else ''"/></renew_on_code>
    <renewal_calendar_date xsi:nil="true"><xsl:value-of select="if (RenewalCalendarDate != '') then core:dateFormatTIPlusToCC(RenewalCalendarDate,'RenewalCalendarDate') else ''"/></renewal_calendar_date>
    <renew_for_nb xsi:nil="true"><xsl:value-of select="core:getFirstArrayIndex(RenewFor)"/></renew_for_nb>
    <renew_for_period xsi:nil="true"><xsl:value-of select="core:getRenewForPeriod(RenewFor)"/></renew_for_period>
    <advise_renewal_flag xsi:nil="true"><xsl:value-of select="AdviseRenewal"/></advise_renewal_flag>
    <advise_renewal_days_nb xsi:nil="true"><xsl:value-of select="AdviseNoticeDays"/></advise_renewal_days_nb>
    <xsl:variable name="rollingRenewal" select="if (upper-case(RenewalBasisType) = 'FIRST RENEWAL/ROLLING RENEWAL') then RollingRenewal
                                                else if (upper-case(RegularRenewForType) = 'OTHER' or RollingRenewalNumber != '' or RollingRenewalCancellationNotice != '') then 'Y'
                                                else 'N'"/>
    <rolling_renewal_flag xsi:nil="true"><xsl:value-of select="$rollingRenewal"/></rolling_renewal_flag>
    <xsl:if test="$rollingRenewal = 'Y'">
      <rolling_renew_on_code xsi:nil="true"><xsl:value-of select="if ((upper-case(RollingRenewalOn) = 'EVERY') or (upper-case(RegularRenewForType) = 'OTHER')) then '03'
                                                                  else if ((upper-case(RenewalBasisType) = 'REGULAR RENEWAL') or ((upper-case(RenewalBasisType) = 'FIRST RENEWAL/ROLLING RENEWAL') and (upper-case(RollingRenewalOn) = 'EXPIRY')))then '01'
                                                                  else ''"/></rolling_renew_on_code>
      <rolling_renew_for_nb xsi:nil="true"><xsl:value-of select="if (upper-case(RegularRenewForType) = 'OTHER') then core:getFirstArrayIndex(RenewFor) else core:getFirstArrayIndex(RollingRenewalFor)"/></rolling_renew_for_nb>
      <xsl:variable name="renewalForPeriod" select="if (upper-case(RenewalBasisType) = 'REGULAR RENEWAL') then core:getRenewForPeriod(RenewFor)
                                                    else core:getRenewForPeriod(RollingRenewalFor)"/>
      <rolling_renew_for_period xsi:nil="true"><xsl:value-of select="$renewalForPeriod"/></rolling_renew_for_period>
      <rolling_renewal_nb xsi:nil="true"><xsl:value-of select="RollingRenewalNumber"/></rolling_renewal_nb>
      <rolling_day_in_month xsi:nil="true"><xsl:value-of select="if (upper-case($renewalForPeriod) = ('M','Q','Y')) then
                                                                   if (RegularRenewalEvery != '') then core:getRollingDayInMonth(RegularRenewalEvery)
                                                                   else core:getRollingDayInMonth(RollingRenewalFor)
                                                                 else ''"/></rolling_day_in_month>
      <rolling_cancellation_days xsi:nil="true"><xsl:value-of select="RollingRenewalCancellationNotice"/></rolling_cancellation_days>
    </xsl:if>
    <renew_amt_code xsi:nil="true"><xsl:value-of select="if (Renewal = 'Y') then
                                                           if (RenewalAmountOn = 'Original') then '01'
                                                           else if (RenewalAmountOn = 'Current') then '02'
                                                           else ''
                                                         else ''"/></renew_amt_code>
    <projected_expiry_date xsi:nil="true"><xsl:value-of select="if (Renewal = 'Y' and ProjectedFinalExpiryDate != '' and (upper-case(RenewalBasisType) = 'FIRST RENEWAL/ROLLING RENEWAL')) then core:dateFormatTIPlusToCC(ProjectedFinalExpiryDate,'ProjectedFinalExpiryDate') else ''"/></projected_expiry_date>
    <final_expiry_date xsi:nil="true"><xsl:value-of select="if (AdjustedFinalExpiryDate != '') then core:dateFormatTIPlusToCC(AdjustedFinalExpiryDate,'AdjustedFinalExpiryDate')
                                                            else if ((upper-case(RenewalBasisType) = 'REGULAR RENEWAL') and ProjectedFinalExpiryDate != '') then core:dateFormatTIPlusToCC(ProjectedFinalExpiryDate,'ProjectedFinalExpiryDate')
                                                            else ''"/></final_expiry_date>
  </xsl:template>

  <!-- Local Undertaking Renewals -->
  <xsl:template name="undertaking-renewals">
    <xsl:variable name="isRegularCalendarDays" select="if (((upper-case(RenewalBasisType) = 'REGULAR RENEWAL') and (upper-case(RegularRenewOnType) = 'CALENDAR DAYS'))) then 'Y' else ''"/>
    <renew_flag xsi:nil="true"><xsl:value-of select="Renewal"/></renew_flag>
    <renewal_type xsi:nil="true"><xsl:value-of select="if (upper-case(RenewalBasisType) = 'REGULAR RENEWAL') then '01'
                                                       else if (upper-case(RenewalBasisType) = 'FIRST RENEWAL/ROLLING RENEWAL') then '02'
                                                       else ''"/></renewal_type>
    <renew_on_code xsi:nil="true"><xsl:value-of select="if ((upper-case(RenewalBasisType) = 'FIRST RENEWAL/ROLLING RENEWAL') and RenewalOnExpiry = 'Y') then '01'
                                                        else if ($isRegularCalendarDays = 'Y' or RenewalOnCalendarDate = 'Y') then '02'
                                                        else ''"/></renew_on_code>
    <renew_for_nb xsi:nil="true"><xsl:value-of select="if ($isRegularCalendarDays = 'Y') then RenewalCalendarDays
                                                       else core:getFirstArrayIndex(RenewFor)"/></renew_for_nb>
    <renew_for_period xsi:nil="true"><xsl:value-of select="if ($isRegularCalendarDays = 'Y') then 'D'
                                                           else if (((upper-case(RenewalBasisType) = 'REGULAR RENEWAL') and (upper-case(RegularRenewOnType) = 'OTHER'))) then core:getRenewForPeriod(RegularRenewFor)
                                                           else core:getRenewForPeriod(RenewFor)"/></renew_for_period>
    <advise_renewal_flag xsi:nil="true"><xsl:value-of select="AdviseRenewal"/></advise_renewal_flag>
    <advise_renewal_days_nb xsi:nil="true"><xsl:value-of select="AdviseRenewalNoticeDays"/></advise_renewal_days_nb>
    <final_expiry_date xsi:nil="true"><xsl:value-of select="if (AdjustedFinalExpiryDate != '') then core:dateFormatTIPlusToCC(AdjustedFinalExpiryDate, 'AdjustedFinalExpiryDate')
                                                            else if (FinalExpiryDate != '') then core:dateFormatTIPlusToCC(FinalExpiryDate, 'FinalExpiryDate')
                                                            else ''"/></final_expiry_date>
    <renew_amt_code xsi:nil="true"><xsl:value-of select="if (Renewal = 'Y') then
                                                           if (RenewalAmountOn = 'Original') then '01'
                                                           else if (RenewalAmountOn = 'Current') then '02'
                                                           else ''
                                                         else ''"/></renew_amt_code>
    <rolling_cancellation_days xsi:nil="true"><xsl:value-of select="RollingRenewalCancellationNotice"/></rolling_cancellation_days>
    <narrative_cancellation><xsl:value-of select="RollingRenewalCancellationNarrative"/></narrative_cancellation>
    <xsl:if test="upper-case(RollingRenewal) = 'Y'">
      <renewal_calendar_date xsi:nil="true"><xsl:value-of select="if (RenewalCalendarDate != '') then core:dateFormatTIPlusToCC(RenewalCalendarDate,'RenewalCalendarDate') else ''"/></renewal_calendar_date>
      <rolling_renewal_flag xsi:nil="true"><xsl:value-of select="RollingRenewal"/></rolling_renewal_flag>
      <rolling_renewal_nb xsi:nil="true"><xsl:value-of select="RollingRenewalNumber"/></rolling_renewal_nb>
      <xsl:variable name="renewalForPeriod" select="if (upper-case(RenewalBasisType) = 'REGULAR RENEWAL') then core:getRenewForPeriod(RegularRenewFor)
                                                    else core:getRenewForPeriod(RollingRenewalFor)"/>
      <rolling_day_in_month xsi:nil="true"><xsl:value-of select="if ($renewalForPeriod = ('M', 'Q', 'Y')) then
                                                                   if (upper-case(RenewalBasisType) = 'REGULAR RENEWAL') then core:getRollingDayInMonth(RegularRenewFor)
                                                                   else core:getRollingDayInMonth(RollingRenewalFor)
                                                                 else ''"/></rolling_day_in_month>
      <rolling_renew_for_period xsi:nil="true"><xsl:value-of select="$renewalForPeriod"/></rolling_renew_for_period>
      <rolling_renew_for_nb xsi:nil="true"><xsl:value-of select="core:getFirstArrayIndex(RollingRenewalFor)"/></rolling_renew_for_nb>
      <rolling_renew_on_code xsi:nil="true"><xsl:value-of select="if (upper-case(RollingRenewalOn) = 'EXPIRY') then '01'
                                                                  else if (upper-case(RollingRenewalOn) = 'EVERY') then '02'
                                                                  else ''"/></rolling_renew_on_code>
    </xsl:if>
  </xsl:template>

  <!-- Amend Instructions contents -->
  <xsl:template name="AmendInstructions">
    <amend>
      <operation><xsl:value-of select="Type" /></operation>
      <text><xsl:value-of select="Text" /></text>
    </amend>
  </xsl:template>

  <xsl:template name="mt-mx-address">
    <xsl:param name="party"/>

    <xsl:if test="node()[codepoint-equal(name(), concat($party,'MXName'))] != ''">
      <xsl:element name="name">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXName'))]"/></xsl:element>
      <xsl:element name="department">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXDepartment'))]"/></xsl:element>
      <xsl:element name="sub_department">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXSubDepartment'))]"/></xsl:element>
      <xsl:element name="street_name">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXStreetName'))]"/></xsl:element>
      <xsl:element name="building_number">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXBuildingNumber'))]"/></xsl:element>
      <xsl:element name="building_name">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXBuildingName'))]"/></xsl:element>
      <xsl:element name="floor">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXFloor'))]"/></xsl:element>
      <xsl:element name="post_box">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXPostBox'))]"/></xsl:element>
      <xsl:element name="room">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXRoom'))]"/></xsl:element>
      <xsl:element name="post_code">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXPostCode'))]"/></xsl:element>
      <xsl:element name="town_name">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXTownName'))]"/></xsl:element>
      <xsl:element name="town_location_name">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXTownLocationName'))]"/></xsl:element>
      <xsl:element name="district_name">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXDistrictName'))]"/></xsl:element>
      <xsl:element name="country_sub_division">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXCountrySubDivision'))]"/></xsl:element>
      <xsl:element name="country">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXCountry'))]"/></xsl:element>
      <xsl:element name="hybrid_line_1">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXAddr1'))]"/></xsl:element>
      <xsl:element name="hybrid_line_2">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:value-of select="node()[codepoint-equal(name(), concat($party,'MXAddr2'))]"/></xsl:element>
    </xsl:if>
  </xsl:template>
  
  <!-- Cross Reference -->
  <xsl:template name="cross-references">
      <xsl:param name="prodCode"/>
      <xsl:param name="typeCode"/>
    <cross_references>
      <cross_reference>
        <bo_ref_id><xsl:value-of select="MasterRef" /></bo_ref_id>
        <bo_tnx_id><xsl:value-of select="LinkedClaimRef" /></bo_tnx_id>
        <product_code><xsl:value-of select="$prodCode" /></product_code>
        <child_product_code><xsl:value-of select="$prodCode" /></child_product_code>
        <child_bo_tnx_id><xsl:value-of select="EventRef" /></child_bo_tnx_id>
        <type_code><xsl:value-of select="$typeCode" /></type_code>
      </cross_reference>
    </cross_references>
  </xsl:template>
  
</xsl:stylesheet>
