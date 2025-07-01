CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Travel.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Travel.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Travel.

    METHODS read FOR READ
      IMPORTING keys FOR READ Travel RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Travel.

    METHODS rba_Booking FOR READ
      IMPORTING keys_rba FOR READ Travel\_Booking FULL result_requested RESULT result LINK association_links.

    METHODS cba_Booking FOR MODIFY
      IMPORTING entities_cba FOR CREATE Travel\_Booking.

    " Variables
    TYPES: tt_failed   TYPE TABLE FOR FAILED zlaw_i_travel_u\\travel,
           tt_reported TYPE TABLE FOR REPORTED zlaw_i_travel_u\\travel.

    " Helper Methods
    METHODS map_messages
      IMPORTING
        cid          TYPE abp_behv_cid
        messages     TYPE /dmo/t_message
      EXPORTING
        failed_added TYPE abap_boolean
      CHANGING
        failed       TYPE tt_failed
        reported     TYPE tt_reported.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
    DATA: ls_travel_in  TYPE /dmo/travel,
          ls_travel_out TYPE /dmo/travel,
          lt_messages   TYPE /dmo/t_message.

    " Loop the parameter
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>).
      ls_travel_in = CORRESPONDING #( <lfs_entities> MAPPING FROM ENTITY USING CONTROL ).

      " Call the Legacy Code / Function Module
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_CREATE'
        EXPORTING
          is_travel         = CORRESPONDING /dmo/s_travel_in( ls_travel_in )
*         it_booking        =
*         it_booking_supplement =
          iv_numbering_mode = /dmo/if_flight_legacy=>numbering_mode-late
        IMPORTING
          es_travel         = ls_travel_out
*         et_booking        =
*         et_booking_supplement =
          et_messages       = lt_messages.

      " Get the Result
      map_messages(
        EXPORTING
            cid = <lfs_entities>-%cid
            messages = lt_messages
        IMPORTING
            failed_added = DATA(lv_failed_added)
        CHANGING
            failed = failed-travel
            reported = reported-travel
      ).

      IF lv_failed_added = abap_false.
        " Fill-out the mapped table to return the result to front-end
        INSERT VALUE #(
            %cid = <lfs_entities>-%cid
             TravelID = ls_travel_out-travel_id " Came from Legacy BAPI
          ) INTO TABLE mapped-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Booking.
  ENDMETHOD.

  METHOD cba_Booking.
  ENDMETHOD.


  METHOD map_messages.
    failed_added = abap_false.

    LOOP AT messages ASSIGNING FIELD-SYMBOL(<lfs_messages>).
      IF <lfs_messages>-msgty = 'E' OR <lfs_messages>-msgty = 'A'.
        APPEND INITIAL LINE TO failed ASSIGNING FIELD-SYMBOL(<lfs_failed>).
        <lfs_failed>-%cid = cid.
        <lfs_failed>-%fail-cause = zlaw_travel_aux=>get_cause_from_message(
                                     msgid = <lfs_messages>-msgid
                                     msgno = <lfs_messages>-msgno ).

        failed_added = abap_true.

        APPEND INITIAL LINE TO reported ASSIGNING FIELD-SYMBOL(<lfs_reported>).
        <lfs_reported>-%cid = cid.
        <lfs_reported>-%msg = new_message( " Available in super class cl_abap_behavior_handler
                                id       = <lfs_messages>-msgid
                                number   = <lfs_messages>-msgno
                                severity = CONV #( <lfs_messages>-msgty )
                                v1       = <lfs_messages>-msgv1
                                v2       = <lfs_messages>-msgv2
                                v3       = <lfs_messages>-msgv3
                                v4       = <lfs_messages>-msgv4
                              ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
