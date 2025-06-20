@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'test CDS - Booking Supplement (Managed)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZLAW_I_BookSuppl_M
  as select from zlaw_bksuppl_m
  association        to parent ZLAW_I_Booking_M as _Booking        on  $projection.TravelId  = _Booking.TravelId
                                                                   and $projection.BookingId = _Booking.BookingId
  association [1..1] to ZLAW_I_Travel_M         as _Travel         on  $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Supplement       as _Supplement     on  $projection.BookingSupplementId = _Supplement.SupplementID
  association [1..*] to /DMO/I_SupplementText   as _SupplementText on  $projection.SupplementId = _SupplementText.SupplementID
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,

      /* Exposed Associations */
      _Supplement,
      _SupplementText,
      _Booking,
      _Travel
}
