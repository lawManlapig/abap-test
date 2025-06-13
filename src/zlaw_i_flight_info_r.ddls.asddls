@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'test CDS - Flight Information(Read Only)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZLAW_I_Flight_Info_R
  as select from /dmo/flight
{
      @UI.lineItem: [{ position: 1 }]
  key carrier_id     as CarrierId,
      @UI.lineItem: [{ position: 2 }]
  key connection_id  as ConnectionId,
      @UI.lineItem: [{ position: 3 }]
  key flight_date    as FlightDate,
      @UI.lineItem: [{ position: 4 }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price          as Price,
      @UI.hidden: true
      currency_code  as CurrencyCode,
      @UI.lineItem: [{ position: 5 }]
      plane_type_id  as PlaneTypeId,
      @UI.lineItem: [{ position: 6 }]
      seats_max      as SeatsMax,
      @UI.lineItem: [{ position: 7 }]
      seats_occupied as SeatsOccupied
}
