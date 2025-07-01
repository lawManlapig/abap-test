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
        cid          TYPE abp_behv_cid OPTIONAL
        travel_id    TYPE /dmo/travel_id OPTIONAL
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
      " Mapping from entity - mapping ng fields ng entity
      " Using control - ang mapapasa lang ay yung mga may changes... pag wala kang nilagay, lahat ng field ipapasa
      ls_travel_in = CORRESPONDING #( <lfs_entities> MAPPING FROM ENTITY USING CONTROL ).

      " Call the Legacy Code / Function Module
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_CREATE'
        EXPORTING
          is_travel         = CORRESPONDING /dmo/s_travel_in( ls_travel_in )
          iv_numbering_mode = /dmo/if_flight_legacy=>numbering_mode-late
        IMPORTING
          es_travel         = ls_travel_out
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
    DATA: lt_messages  TYPE /dmo/t_message,
          ls_travel_in TYPE /dmo/travel,
          ls_travelx   TYPE /dmo/s_travel_inx.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>).
      ls_travel_in = CORRESPONDING #( <lfs_entities> MAPPING FROM ENTITY ).
      ls_travelx-_intx = CORRESPONDING #( <lfs_entities> MAPPING FROM ENTITY ).
      ls_travelx-travel_id = <lfs_entities>-TravelID.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = CORRESPONDING /dmo/s_travel_in( ls_travel_in )
          is_travelx  = ls_travelx
        IMPORTING
          et_messages = lt_messages.

      " Get the Result
      map_messages(
        EXPORTING
            cid = <lfs_entities>-%cid_ref
            travel_id = <lfs_entities>-TravelID
            messages = lt_messages
        IMPORTING
            failed_added = DATA(lv_failed_added)
        CHANGING
            failed = failed-travel
            reported = reported-travel
      ).
    ENDLOOP.

  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
    DATA: ls_travel_out TYPE /dmo/travel,
          lt_messages   TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>)
    GROUP BY <lfs_keys>-%tky.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <lfs_keys>-TravelID
        IMPORTING
          es_travel    = ls_travel_out
          et_messages  = lt_messages.

      " Get the Result
      map_messages(
        EXPORTING
            travel_id = <lfs_keys>-TravelID
            messages = lt_messages
        IMPORTING
            failed_added = DATA(lv_failed_added)
        CHANGING
            failed = failed-travel
            reported = reported-travel
      ).

      IF lv_failed_added = abap_false.
        INSERT CORRESPONDING #( ls_travel_out MAPPING TO ENTITY ) INTO TABLE result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
    TRY.
        DATA(lr_lock) = cl_abap_lock_object_factory=>get_instance( iv_name = '/DMO/ETRAVEL' ).
      CATCH cx_abap_lock_failure INTO DATA(lo_error).
        RAISE SHORTDUMP lo_error.
    ENDTRY.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).

      TRY.
          lr_lock->enqueue(
            it_parameter  = VALUE #( (  name = 'TRAVEL_ID' value = REF #( <lfs_keys>-TravelID ) ) )
          ).
        CATCH cx_abap_foreign_lock INTO DATA(lo_f_lock).
          " Get the Result
          map_messages(
            EXPORTING
                travel_id = <lfs_keys>-TravelID
                messages = VALUE #( (
                    msgid = '/DMO/CM_FLIGHT_LEGAC'
                    msgno = '032'
                    msgty = 'E'
                    msgv1 = <lfs_keys>-TravelID
                    msgv2 = lo_f_lock->user_name
                ) )
            CHANGING
                failed = failed-travel
                reported = reported-travel
          ).
        CATCH cx_abap_lock_failure.
      ENDTRY.
    ENDLOOP.

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
        <lfs_failed>-TravelID = travel_id.
        <lfs_failed>-%fail-cause = zlaw_travel_aux=>get_cause_from_message(
                                     msgid = <lfs_messages>-msgid
                                     msgno = <lfs_messages>-msgno ).

        failed_added = abap_true.

        APPEND INITIAL LINE TO reported ASSIGNING FIELD-SYMBOL(<lfs_reported>).
        <lfs_reported>-%cid = cid.
        <lfs_reported>-TravelID = travel_id.
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
