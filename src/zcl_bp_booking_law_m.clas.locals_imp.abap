CLASS lhc_zlaw_i_booking_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE ZLAW_I_Booking_M\_Bookingsupplement.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZLAW_I_Booking_M RESULT result.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zlaw_i_booking_m~calculatetotalprice.

ENDCLASS.

CLASS lhc_zlaw_i_booking_m IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.
    DATA: lv_max_booking_supplement TYPE /dmo/booking_supplement_id.

    " Read Entity from Main
    READ ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE " To make it faster because it will only check for Auth etc. only once.
    ENTITY ZLAW_I_Booking_M
    BY \_BookingSupplement
    FROM CORRESPONDING #( entities ) " Since you already have the filters, you can use Corresponding para mas mabilis
    LINK DATA(lt_booking_supplement_result). " Use 'LINK' instead of 'RESULT' to determine the result of the associated Travel only.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>)
    GROUP BY <lfs_entities>-%tky. " Use if entity has many keys

      " Get all Bookings
      lv_max_booking_supplement = REDUCE #(
          INIT lv_max = CONV /dmo/booking_supplement_id( '0' )
          FOR ls_booking_supplement_result IN lt_booking_supplement_result
          USING KEY entity
          WHERE ( source-TravelId = <lfs_entities>-TravelId
            AND   source-BookingId = <lfs_entities>-BookingId )
          NEXT lv_max = COND /dmo/booking_supplement_id(
              WHEN lv_max < ls_booking_supplement_result-target-BookingSupplementId
              THEN ls_booking_supplement_result-target-BookingSupplementId
              ELSE lv_max ) ).

      lv_max_booking_supplement = REDUCE #(
          INIT lv_max_booking_local = lv_max_booking_supplement
          FOR ls_entity IN entities
          USING KEY entity
          WHERE ( TravelId = <lfs_entities>-TravelId
            AND   BookingId = <lfs_entities>-BookingId )
          FOR ls_booking IN ls_entity-%target
          NEXT lv_max_booking_local = COND /dmo/booking_supplement_id(
              WHEN lv_max_booking_local < ls_booking-BookingSupplementId
              THEN ls_booking-BookingSupplementId
              ELSE lv_max_booking_local ) ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities_draft>)
      USING KEY entity WHERE %tky = <lfs_entities>-%tky.
        LOOP AT <lfs_entities>-%target ASSIGNING FIELD-SYMBOL(<lfs_booking_details>).
          APPEND CORRESPONDING #( <lfs_booking_details> ) TO mapped-zlaw_i_booksuppl_m
          ASSIGNING FIELD-SYMBOL(<lfs_booking_new>).

          IF <lfs_booking_details>-BookingSupplementId IS INITIAL.
            lv_max_booking_supplement += 1.
            <lfs_booking_new>-BookingSupplementId = lv_max_booking_supplement.
          ENDIF.
        ENDLOOP. " --> LOOP AT <lfs_entities>-%target
      ENDLOOP. " --> LOOP AT entities.. (nested)
    ENDLOOP. " --> LOOP AT entities..


  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE
    ENTITY ZLAW_I_Travel_M
    BY \_Booking
    FIELDS ( TravelId BookingStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_booking_read).

    result = VALUE #( FOR ls_booking IN lt_booking_read
                      ( %tky = ls_booking-%tky
                        %features-%assoc-_BookingSupplement = COND #( WHEN ls_booking-BookingStatus = 'X'
                                                   THEN if_abap_behv=>fc-o-disabled
                                                   ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD calculateTotalPrice.
    DATA: lt_travel TYPE SORTED TABLE OF ZLAW_I_Travel_M WITH UNIQUE KEY TravelId.

    lt_travel = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ).

    " Get the internal function
    MODIFY ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE
    ENTITY ZLAW_I_Travel_M
    EXECUTE recalculateTotalPrice " Call the Action
    FROM CORRESPONDING #( lt_travel ).
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
