@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'test CDS - Flight Connection'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
// CTRL space > SHIFT + ENTER = Template
@UI.headerInfo: {
    typeName: 'Connection',
    typeNamePlural: 'Connections'
}
define view entity ZLAW_I_Flight_Connection
  as select from /dmo/connection
{
      @UI.lineItem: [{ position: 1 }]
  key carrier_id      as CarrierId,
      @UI.lineItem: [{ position: 2 }]
  key connection_id   as ConnectionId,
      airport_from_id as AirportFromId,
      @UI.lineItem: [{ position: 3 }]
      airport_to_id   as AirportToId,
      @UI.lineItem: [{ position: 4 }]
      departure_time  as DepartureTime,
      @UI.lineItem: [{ position: 5 }]
      arrival_time    as ArrivalTime,
      @Semantics.quantity.unitOfMeasure: 'DistanceUnit'
      distance        as Distance,
      distance_unit   as DistanceUnit
}
