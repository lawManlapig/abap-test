CLASS zlaw_travel_aux DEFINITION
  PUBLIC
  INHERITING FROM cl_abap_behv
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    " Static Methods
    CLASS-METHODS get_cause_from_message
      IMPORTING
                msgid             TYPE symsgid
                msgno             TYPE symsgno
                is_dependent      TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(fail_cause) TYPE if_abap_behv=>t_fail_cause.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zlaw_travel_aux IMPLEMENTATION.
  METHOD get_cause_from_message.
    IF msgid = '/DMO/CM_FLIGHT_LEGAC'.
      CASE msgno.
        WHEN '009' OR '016' OR '017'.
          fail_cause = COND #(
              WHEN is_dependent = abap_true
              THEN if_abap_behv=>cause-dependency
              ELSE if_abap_behv=>cause-not_found ).
        WHEN '032'.
          fail_cause = if_abap_behv=>cause-locked.
        WHEN '046'.
          fail_cause = if_abap_behv=>cause-unauthorized.
      ENDCASE.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
