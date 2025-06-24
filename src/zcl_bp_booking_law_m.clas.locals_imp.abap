CLASS lhc_zlaw_i_booking_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE ZLAW_I_Booking_M\_Bookingsupplement.

ENDCLASS.

CLASS lhc_zlaw_i_booking_m IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
