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
      @ObjectModel.text.element: [ 'CustomerFirstName' ]
      CustomerId,
      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierId,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      @ObjectModel.text.element: [ 'BookingStatusText' ]
      @UI.textArrangement: #TEXT_ONLY
      BookingStatus,
      LastChangedAt,

      /* Adhoc Associations */
      _Customer.FirstName         as CustomerFirstName,
      _Carrier.Name               as CarrierName,
      _BookingStatusVH._Text.Text as BookingStatusText: localized,

      /* Associations */
      _BookingStatusVH,
      _BookingSupplement : redirected to composition child ZLAW_C_BookSuppl_M,
      _Carrier,
      _Connection,
      _Customer,
      _Travel            : redirected to parent ZLAW_C_Travel_M
}
