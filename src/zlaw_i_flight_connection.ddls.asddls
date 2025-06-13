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
  as select from /dmo/connection as connection
  association [1..*] to ZLAW_I_Flight_Info_R as _flightInfo on  $projection.CarrierId    = _flightInfo.CarrierId
                                                            and $projection.ConnectionId = _flightInfo.ConnectionId
{
      // Facet
      @UI.facet: [{
          purpose: #STANDARD,
          type: #IDENTIFICATION_REFERENCE, // Single value structure
          position: 1,
          label: 'Connection Details',
          id: 'ConnectionDetails'
      },{
          purpose: #STANDARD,
          type: #LINEITEM_REFERENCE, // Display as Table
          position: 2,
          label: 'Flight Details',
          id: 'FlightDetails',
          targetElement: '_flightInfo' // Source Table
      }]


      @UI.lineItem: [{ position: 1 }] // Line Item
      @UI.identification: [{ position: 1 }] // Facet
  key connection.carrier_id      as CarrierId,
      @UI.lineItem: [{
          position: 2,
          cssDefault.width: '9rem'
      }]
      @UI.identification: [{ position: 2 }]
  key connection.connection_id   as ConnectionId,
      @UI.selectionField: [{ position: 1 }]
      @UI.lineItem: [{
        position: 3,
        cssDefault.width: '9rem'
      }]
      @UI.identification: [{ position: 3 }]
      connection.airport_from_id as AirportFromId,
      @UI.selectionField: [{ position: 2 }]
      @UI.lineItem: [{
          position: 4,
          cssDefault.width: '9rem'
      }]
      @UI.identification: [{ position: 4 }]
      connection.airport_to_id   as AirportToId,
      @UI.lineItem: [{ position: 5 }]
      @UI.identification: [{ position: 5 }]
      connection.departure_time  as DepartureTime,
      @UI.lineItem: [{ position: 6 }]
      @UI.identification: [{ position: 6 }]
      connection.arrival_time    as ArrivalTime,
      @Semantics.quantity.unitOfMeasure: 'DistanceUnit'
      @UI.identification: [{ position: 7 }]
      connection.distance        as Distance,
      @UI.hidden: true
      connection.distance_unit   as DistanceUnit,

      /* Exposed Association */
      _flightInfo
}
