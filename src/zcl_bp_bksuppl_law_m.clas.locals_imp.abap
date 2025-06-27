CLASS lhc_zlaw_i_booksuppl_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZLAW_I_BookSuppl_M~calculateTotalPrice.

ENDCLASS.

CLASS lhc_zlaw_i_booksuppl_m IMPLEMENTATION.

  METHOD calculateTotalPrice.
    DATA: lt_booking TYPE SORTED TABLE OF ZLAW_I_Booking_M WITH UNIQUE KEY TravelId.

    lt_booking = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ).

    " Get the internal function
    MODIFY ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE
    ENTITY ZLAW_I_Travel_M
    EXECUTE recalculateTotalPrice " Call the Action
    FROM CORRESPONDING #( lt_booking ).
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
