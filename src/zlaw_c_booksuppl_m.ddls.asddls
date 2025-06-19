@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'test CDS - Book Supplement (Consumption)'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZLAW_C_BookSuppl_M
  as projection on ZLAW_I_BookSuppl_M
{
  key TravelId,
  key BookingId,
      @ObjectModel.text.element: [ 'SupplementDescription' ]
  key BookingSupplementId,
      SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LastChangedAt,
      
      /* Adhoc Association */
      _SupplementText.Description as SupplementDescription: localized,
      
      /* Associations */
      _Booking: redirected to parent ZLAW_C_Booking_M,
      _Supplement,
      _SupplementText,
      _Travel: redirected to ZLAW_C_Travel_M // To tell that this is part of the business object only
}
