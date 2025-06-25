CLASS lhc_ZLAW_I_Travel_M DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZLAW_I_Travel_M RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ZLAW_I_Travel_M RESULT result.

    " Hander for Numbering
    METHODS earlynumbering_cba_Booking FOR NUMBERING
      IMPORTING entities FOR CREATE ZLAW_I_Travel_M\_Booking.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE ZLAW_I_Travel_M.

ENDCLASS.

CLASS lhc_ZLAW_I_Travel_M IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
*    DATA: lt_travel_temp TYPE TABLE FOR MAPPED EARLY zlaw_i_travel_m.
    DATA: lv_current_number TYPE i.

    DATA(lt_entities) = entities.

    " Make sure the travel ID is not present
    DELETE lt_entities WHERE TravelId IS NOT INITIAL.

    TRY.
        " Generate the TravelID
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = '/DMO/TRV_M'
            quantity          = CONV #( lines( lt_entities ) )
          IMPORTING
            number            = DATA(lv_latest_number)
            returncode        = DATA(lv_return_code)
            returned_quantity = DATA(lv_quantity)
        ).
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lo_error).
        LOOP AT lt_entities INTO DATA(ls_errors).
          " Error handling
          APPEND VALUE #(
            %cid = ls_errors-%cid
            %key = ls_errors-%key
          ) TO failed-zlaw_i_travel_m. " Error table

          APPEND VALUE #(
            %cid = ls_errors-%cid
            %key = ls_errors-%key
            %msg = lo_error
          ) TO reported-zlaw_i_travel_m. " Error table
        ENDLOOP.

        EXIT.
    ENDTRY.

    ASSERT lv_quantity = lines( lt_entities ).

    " Get the new unassigned number
    lv_current_number = lv_latest_number - lv_quantity.

    " Loop
    " Recommendation: Use Field Symbol if you are planning to change anything.. else use INTO DATA
    LOOP AT lt_entities INTO DATA(ls_entities).
      lv_current_number += 1.

      " Fill 'mapped' table
      APPEND VALUE #(
        %cid = ls_entities-%cid
        TravelId = lv_current_number
      ) TO mapped-zlaw_i_travel_m.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.
    DATA: lv_max_booking TYPE /dmo/booking_id.

    " Read Entity from Main
    READ ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE " To make it faster because it will only check for Auth etc. only once.
    ENTITY ZLAW_I_Travel_M
    BY \_Booking
    FROM CORRESPONDING #( entities ) " Since you already have the filters, you can use Corresponding para mas mabilis
    LINK DATA(lt_booking_result). " Use 'LINK' instead of 'RESULT' to determine the result of the associated Travel only.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>)
    GROUP BY <lfs_entities>-TravelId.

      " Get all Bookings
      lv_max_booking = REDUCE #(
          INIT lv_max = CONV /dmo/booking_id( '0' )
          FOR ls_booking_result IN lt_booking_result
          USING KEY entity
          WHERE ( source-TravelId = <lfs_entities>-TravelId )
          NEXT lv_max = COND /dmo/booking_id(
              WHEN lv_max < ls_booking_result-target-BookingId
              THEN ls_booking_result-target-BookingId
              ELSE lv_max ) ).

      lv_max_booking = REDUCE #(
          INIT lv_max_booking_local = lv_max_booking
          FOR ls_entity IN entities
          USING KEY entity
          WHERE ( TravelId = <lfs_entities>-TravelId )
          FOR ls_booking IN ls_entity-%target
          NEXT lv_max_booking_local = COND /dmo/booking_id(
              WHEN lv_max_booking_local < ls_booking-BookingId
              THEN ls_booking-BookingId
              ELSE lv_max_booking_local ) ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities_draft>)
      USING KEY entity WHERE TravelId = <lfs_entities>-TravelId.
        LOOP AT <lfs_entities>-%target ASSIGNING FIELD-SYMBOL(<lfs_booking_details>).
          IF <lfs_booking_details>-BookingId IS INITIAL.
            lv_max_booking += 10.

            APPEND CORRESPONDING #( <lfs_booking_details> ) TO mapped-zlaw_i_booking_m
            ASSIGNING FIELD-SYMBOL(<lfs_booking_new>).
            <lfs_booking_new>-BookingId = lv_max_booking.

          ENDIF.
        ENDLOOP. " --> LOOP AT <lfs_entities>-%target
      ENDLOOP. " --> LOOP AT entities.. (nested)
    ENDLOOP. " --> LOOP AT entities..

  ENDMETHOD.

ENDCLASS.
