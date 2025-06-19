@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'test CDS - Travel (Consumption)'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZLAW_C_Travel_M
  /* provider contract transactional_query
  This is needed for the provider entity.. No need to define in the child entity/ies */
  provider contract transactional_query
  as projection on ZLAW_I_Travel_M
{
  key TravelId,
      @ObjectModel.text.element: [ 'AgencyName' ] // Can only be added here.. bawal sa MDE File
      AgencyId,
      @ObjectModel.text.element: [ 'CustomerFirstName' ]
      CustomerId,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      @ObjectModel.text.element: [ 'StatusText' ]
      OverallStatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Adhoc Associations */
      _Agency.Name        as AgencyName,
      _Customer.FirstName as CustomerFirstName,
      _Status._Text.Text  as StatusText : localized,

      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZLAW_C_Booking_M, // Needed to establish parent-child relationship
      _Currency,
      _Customer,
      _Status
}
