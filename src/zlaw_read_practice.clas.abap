CLASS zlaw_read_practice DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zlaw_read_practice IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " READ ENTITIES SHORT VERSION

    " Read single entry
    " Note: if you don't specify any fields... it will only return the key fields
*    READ ENTITY ZLAW_I_Travel_M " Source
*    FROM VALUE #( ( %key-TravelId = '0000004567' ) ) " Filters
*    RESULT DATA(lt_result_short)
*    FAILED DATA(lt_failed_short).

*    " Read single entry with filters + fields exposed
*    READ ENTITY ZLAW_I_Travel_M " Source
*    FROM VALUE #( (  " Filters
*        %key-TravelId = '0000004567'
*
*        " Fields that you want to show
*        %control = VALUE #(
*            AgencyId = if_abap_behv=>mk-on
*            CustomerId = if_abap_behv=>mk-on
*            BeginDate = if_abap_behv=>mk-on
*        )
*    ) )
*    RESULT DATA(lt_result_short)
*    FAILED DATA(lt_failed_short).
*
*    IF lt_result_short[] IS NOT INITIAL. out->write( lt_result_short ). ENDIF.
*    IF lt_failed_short IS NOT INITIAL. out->write( 'Read Failed..' ). ENDIF.

    " Read single entry with filters + fields exposed
*    READ ENTITY ZLAW_I_Travel_M " Source
*    BY \_Booking " Read Association Entity
**    FIELDS ( AgencyId CustomerId BookingFee TotalPrice BeginDate ) " Exposed Fields
*    ALL FIELDS " Expose all fields
*    WITH VALUE #( ( %key-TravelId = '0000000010' )
*                  ( %key-TravelId = '0000000021' ) ) " Filters
*    RESULT DATA(lt_result_short)
*    FAILED DATA(lt_failed_short).
*
*    IF lt_result_short[] IS NOT INITIAL. out->write( lt_result_short ). ENDIF.
*    IF lt_failed_short IS NOT INITIAL. out->write( 'Read Failed..' ). ENDIF.

*    " READ ENTITIES LONG VERSION
*    READ ENTITIES OF ZLAW_I_Travel_M " Root entity
*    ENTITY ZLAW_I_Travel_M " Entity you want to Read
*    ALL FIELDS
*    WITH VALUE #( ( %key-TravelId = '0000000010' )
*                  ( %key-TravelId = '0000000021' ) ) " Filters
*    RESULT DATA(lt_result_travel)
*
*    ENTITY ZLAW_I_Booking_M
*    ALL FIELDS
*    WITH VALUE #( ( %key-TravelId = '0000000010'
*                    %key-BookingId = '0001'  ) ) " Filters
*    RESULT DATA(lt_result_booking)
*    FAILED DATA(lt_failed_long).
*
*    IF lt_failed_long IS NOT INITIAL.
*      out->write( 'Read Failed..' ).
*    ELSE.
*      out->write( lt_result_travel ).
*      out->write( lt_result_booking ).
*    ENDIF.

*    " READ ENTITIES DYNAMIC VERSION
*    DATA: lt_optab          TYPE abp_behv_retrievals_tab,
*          lt_travel         TYPE TABLE FOR READ IMPORT ZLAW_I_Travel_M, " Filters
*          lt_travel_result  TYPE TABLE FOR READ RESULT ZLAW_I_Travel_M, " Result Table
*          lt_booking        TYPE TABLE FOR READ IMPORT ZLAW_I_Booking_M, " Filters
*          lt_booking_result TYPE TABLE FOR READ RESULT ZLAW_I_Booking_M. " Result Table
*
*    lt_travel = VALUE #( (  " Filters
*        %key-TravelId = '0000000010'
*
*        " Fields that you want to show
*        %control = VALUE #(
*            AgencyId = if_abap_behv=>mk-on
*            CustomerId = if_abap_behv=>mk-on
*            BeginDate = if_abap_behv=>mk-on
*        )
*    ) ).
*
*    lt_booking = VALUE #( (  " Filters
*        %key-TravelId = '0000000010'
*
*        " Fields that you want to show
*        %control = VALUE #(
*            BookingDate = if_abap_behv=>mk-on
*            BookingStatus = if_abap_behv=>mk-on
*            BookingId = if_abap_behv=>mk-on
*        )
*    ) ).
*
*    lt_optab = VALUE #( ( op = if_abap_behv=>op-r-read
*                          entity_name = 'ZLAW_I_TRAVEL_M' " Need all CAPS
*                          instances = REF #( lt_travel )
*                          results = REF #( lt_travel_result ) )
*                        ( op = if_abap_behv=>op-r-read_ba
*                          entity_name = 'ZLAW_I_TRAVEL_M' " Need all CAPS
*                          sub_name = '_BOOKING' " Associated Entity
*                          instances = REF #( lt_booking )
*                          results = REF #( lt_booking_result ) ) ).
*
*    READ ENTITIES
*    OPERATIONS lt_optab
*    FAILED DATA(lt_failed_dynamic).
*
*    IF lt_failed_dynamic IS NOT INITIAL.
*      out->write( 'Read Failed..' ).
*    ELSE.
*      out->write( lt_travel_result ).
*      out->write( lt_booking_result ).
*    ENDIF.



    READ ENTITY ZLAW_I_Travel_U
    BY \_Booking
    FIELDS ( AirlineID BookingDate BookingID ConnectionID )
    WITH VALUE #( ( %tky-TravelID = '0000000010' ) )
    RESULT DATA(lt_result_booking_2)
    FAILED DATA(lt_failed_long_2).

    IF lt_failed_long_2 IS NOT INITIAL.
      out->write( 'Read Failed..' ).
    ELSE.
      out->write( lt_result_booking_2 ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
