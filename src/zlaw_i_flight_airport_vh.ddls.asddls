@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'test CDS - Airport Info (Value Help)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Search.searchable: true
define view entity ZLAW_I_Flight_Airport_VH
  as select from /dmo/airport
{
      @Search: {
          defaultSearchElement: true,
          fuzzinessThreshold: 0.7
      }
  key airport_id as AirportId,
      @Search: {
          defaultSearchElement: true,
          fuzzinessThreshold: 0.7
      }
      name       as Name,
      @Search: {
          defaultSearchElement: true,
          fuzzinessThreshold: 0.7
      }
      city       as City,
      @Search: {
          defaultSearchElement: true,
          fuzzinessThreshold: 0.7
      }
      country    as Country
}
