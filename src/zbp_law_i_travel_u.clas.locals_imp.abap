CLASS lsc_ZLAW_I_TRAVEL_U DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS adjust_numbers REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZLAW_I_TRAVEL_U IMPLEMENTATION.

  " Finalize(1st) : Last chance to modify your Transaction Buffer Data.
  "                 After leaving this method, you will not be able to use EML anymore.
  METHOD finalize.
  ENDMETHOD.

  " Check Before Save(2nd) : Parang validation method.. used to check transaction buffer.
  "                          Last chance to go back to Interaction Phase (UI).
  "                          Same with Validations in Managed Scenario.
  "                          After nito, wala na talagang balikan XD
  METHOD check_before_save.
  ENDMETHOD.

*** this is the point of no return ika nga ***
*** lahat ng methods sa baba, labas na ng transaction buffer ***

  " Adjust Number(3rd) : Late value assignment (late numbering)
  METHOD adjust_numbers.
    DATA: lt_travel_mapping             TYPE /dmo/if_flight_legacy=>tt_ln_travel_mapping,
          lt_booking_mapping            TYPE /dmo/if_flight_legacy=>tt_ln_booking_mapping,
          lt_booking_supplement_mapping TYPE /dmo/if_flight_legacy=>tt_ln_bookingsuppl_mapping.

    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_ADJ_NUMBERS'
      IMPORTING
        et_travel_mapping       = lt_travel_mapping
        et_booking_mapping      = lt_booking_mapping
        et_bookingsuppl_mapping = lt_booking_supplement_mapping.

    " Fill mapped table
    mapped-travel = VALUE #(
        FOR ls_travel IN lt_travel_mapping
        (
            %tmp = VALUE #( TravelID = ls_travel-preliminary-travel_id )
            TravelID = ls_travel-final-travel_id
        ) ).

    mapped-booking = VALUE #(
        FOR ls_booking IN lt_booking_mapping
        (
            %tmp = VALUE #( TravelID = ls_booking-preliminary-travel_id
                            BookingID = ls_booking-preliminary-booking_id )
            TravelID = ls_booking-final-travel_id
            BookingID = ls_booking-final-booking_id
        ) ).

  ENDMETHOD.

  " Save(4th) : Everything is done... nothing more to do.. this will save the data in the DB
  "             dito natritrigger yung COMMIT WORK
  METHOD save.
    " Simulation lang ng save BAPI / Function Module
    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_SAVE'.
  ENDMETHOD.

  " Cleanup(situational. in happy path, it's 5th) : Cleans the transaction buffer.
  METHOD cleanup.
    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_INITIALIZE'.
  ENDMETHOD.

  " Cleanup Finalize(during fails) : cleans transaction buffer is Finalize / Check before save fails.
  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
