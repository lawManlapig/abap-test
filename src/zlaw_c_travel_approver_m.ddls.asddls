@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'test CDS - Travel Approver'
@Metadata.ignorePropagatedAnnotations: true
@UI.headerInfo: {
    typeName: 'Travel',
    typeNamePlural: 'Travels',
    title: {
        type: #STANDARD,
        value: 'TravelId'
    }
}
@Search.searchable: true
define root view entity ZLAW_C_Travel_Approver_M
  provider contract transactional_query
  as projection on ZLAW_I_Travel_M
{
      @UI.facet: [{
          id: 'Travel',
          purpose: #STANDARD,
          parentId: '',
          position: 1,
          label: 'Travel',
          type: #IDENTIFICATION_REFERENCE
      },{
          id: 'Booking',
          purpose: #STANDARD,
          parentId: '',
          position: 2,
          label: 'Booking',
          type: #LINEITEM_REFERENCE,
          targetElement: '_Booking'
      }]

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
  key TravelId,
      @UI: {
          lineItem: [{
              position: 2,
              importance: #HIGH
          }],
          identification: [{ position: 2 }],
          selectionField: [{ position: 2 }]
      }
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      @Consumption.valueHelpDefinition: [{
        entity: {
            name: '/DMO/I_Agency',
            element: 'AgencyID'
        }
      }]
      @ObjectModel.text.element: [ 'AgencyName' ]
      AgencyId,
      @UI.hidden: true
      _Agency.Name        as AgencyName,
      @UI: {
          lineItem: [{
              position: 3,
              importance: #HIGH
          }],
          identification: [{ position: 3 }],
          selectionField: [{ position: 3 }]
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
      _Customer.FirstName as CustomerName,
      @UI.identification: [{ position: 4 }]
      BeginDate,
      @UI.identification: [{ position: 5 }]
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI: {
          lineItem: [{
              position: 4,
              importance: #MEDIUM
          }],
          identification: [{ position: 6 }]
      }
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI: {
          lineItem: [{
              position: 5,
              importance: #MEDIUM
          }],
          identification: [{ position: 7 }]
      }
      TotalPrice,
      @Consumption.valueHelpDefinition: [{
        entity: {
            name: 'I_Currency',
            element: 'Currency'
        }
      }]
      CurrencyCode,
      @UI: {
          lineItem: [{
              position: 6,
              importance: #MEDIUM
          }],
          identification: [{ position: 8 }]
      }
      Description,
      @UI:{
        lineItem: [{
            position: 7,
            importance: #HIGH
        },{
            type: #FOR_ACTION,
            dataAction: 'acceptTravel',
            label: 'Accept Travel'
        },{
            type: #FOR_ACTION,
            dataAction: 'rejectTravel',
            label: 'Reject Travel'
        }],
        identification: [{
            position: 9,
            importance: #HIGH
        },{
            type: #FOR_ACTION,
            dataAction: 'acceptTravel',
            label: 'Accept Travel'
        },{
            type: #FOR_ACTION,
            dataAction: 'rejectTravel',
            label: 'Reject Travel'
        }],
        textArrangement: #TEXT_ONLY
      }
      @EndUserText.label: 'Overall Status'
      @Consumption.valueHelpDefinition: [{
        entity: {
            name: '/DMO/I_Overall_Status_VH',
            element: 'OverallStatus'
        }
      }]
      @ObjectModel.text.element: [ 'OverallStatusText' ]
      OverallStatus,
      @UI.hidden: true
      _Status._Text.Text  as OverallStatusText : localized,
      @UI.hidden: true
      CreatedBy,
      @UI.hidden: true
      CreatedAt,
      @UI.hidden: true
      LastChangedBy,
      @UI.hidden: true
      LastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZLAW_C_Booking_Approver_M,
      _Currency,
      _Customer,
      _Status
}
