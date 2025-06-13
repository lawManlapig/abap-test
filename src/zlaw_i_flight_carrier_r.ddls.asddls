@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'test CDS - Carrier Info (Read Only)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZLAW_I_Flight_Carrier_R
  as select from /dmo/carrier
{
  key carrier_id    as CarrierId,
      @Semantics.text: true // Makes field act as text field for any ID
//      @Semantics.language: true // Default Language
      name          as Name,
      currency_code as CurrencyCode
}
