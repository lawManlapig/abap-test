@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'test CDS - Booking Approver'
@Metadata.ignorePropagatedAnnotations: true
@UI.headerInfo: {
    typeName: 'Booking',
    typeNamePlural: 'Bookings',
    title: {
        type: #STANDARD,
        value: 'BookingId'
    }
}
@Search.searchable: true
define view entity ZLAW_C_Booking_Approver_M
  as projection on ZLAW_I_Booking_M
{
      @UI.facet: [{
          id: 'Booking',
          purpose: #STANDARD,
          parentId: '',
          position: 1,
          label: 'Booking',
          type: #IDENTIFICATION_REFERENCE
      }]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
  key TravelId,
      @UI: {
          lineItem: [{
              position: 1,
              importance: #HIGH
          }],
          identification: [{ position: 1 }],
          selectionField: [{ position: 1 }]
      }
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
  key BookingId,
      @UI: {
          lineItem: [{
              position: 2,
              importance: #HIGH
          }],
          identification: [{ position: 2 }]
      }
      BookingDate,
      @UI: {
          lineItem: [{
              position: 3,
              importance: #HIGH
          }],
          identification: [{ position: 3 }]
      }
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      @Consumption.valueHelpDefinition: [{
        entity: {
            name: '/DMO/I_Customer',
            element: 'CustomerID'
        }
      }]
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      @UI.hidden: true
      _Customer.FirstName         as CustomerName,
      @UI: {
          lineItem: [{
              position: 4,
              importance: #HIGH
          }],
          identification: [{ position: 4 }]
      }
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierId,
      @UI.hidden: true
      _Carrier.Name               as CarrierName,
      @UI: {
          lineItem: [{
              position: 5,
              importance: #HIGH
          }],
          identification: [{ position: 5 }]
      }
      ConnectionId,
      @UI: {
          lineItem: [{
              position: 6,
              importance: #HIGH
          }],
          identification: [{ position: 6 }]
      }
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI: {
          lineItem: [{
              position: 7,
              importance: #HIGH
          }],
          identification: [{ position: 7 }]
      }
      FlightPrice,
      CurrencyCode,
      @UI:{
        lineItem: [{
            position: 8,
            importance: #HIGH,
            label: 'Status'
        }],
        identification: [{
            position: 8,
            label: 'Status'
        }],
        textArrangement: #TEXT_ONLY
      }
      @Consumption.valueHelpDefinition: [{
        entity: {
            name: '/DMO/I_Booking_Status_VH',
            element: 'BookingStatus'
        }
      }]
      @ObjectModel.text.element: [ 'BookingStatusText' ]
      BookingStatus,
      @UI.hidden: true
      _BookingStatusVH._Text.Text as BookingStatusText : localized,
      @UI.hidden: true
      LastChangedAt,
      /* Associations */
      _BookingStatusVH,
      _BookingSupplement,
      _Carrier,
      _Connection,
      _Customer,
      _Travel : redirected to parent ZLAW_C_Travel_Approver_M
}
