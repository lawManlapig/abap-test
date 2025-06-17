@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'test CDS - Booking (Managed)'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZLAW_I_Booking_M
  as select from zlaw_booking_m
  association [1..1] to /DMO/I_Carrier           as _Carrier         on  $projection.CarrierId = _Carrier.AirlineID
  association [1..1] to /DMO/I_Customer          as _Customer        on  $projection.CustomerId = _Customer.CustomerID
  association [1..1] to /DMO/I_Connection        as _Connection      on  $projection.CarrierId    = _Connection.AirlineID
                                                                     and $projection.ConnectionId = _Connection.ConnectionID
  association [1..1] to /DMO/I_Booking_Status_VH as _BookingStatusVH on  $projection.BookingStatus = _BookingStatusVH.BookingStatus
{
  key travel_id       as TravelId,
  key booking_id      as BookingId,
      booking_date    as BookingDate,
      customer_id     as CustomerId,
      carrier_id      as CarrierId,
      connection_id   as ConnectionId,
      flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price    as FlightPrice,
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,
      last_changed_at as LastChangedAt,

      /* Exposed Association */
      _Carrier,
      _Customer,
      _Connection,
      _BookingStatusVH
}
