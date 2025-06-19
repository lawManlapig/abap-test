@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'test CDS - Booking (Consumption)'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZLAW_C_Booking_M
  as projection on ZLAW_I_Booking_M
{
  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      CarrierId,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _BookingStatusVH,
      _BookingSupplement: redirected to composition child ZLAW_C_BookSuppl_M,
      _Carrier,
      _Connection,
      _Customer,
      _Travel: redirected to parent ZLAW_C_Travel_M
}
