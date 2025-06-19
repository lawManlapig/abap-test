CLASS zlaw_table_insert DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zlaw_table_insert IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    " Initialize
    DELETE FROM zlaw_booking_m.
    DELETE FROM zlaw_bksuppl_m.
    DELETE FROM zlaw_travel_m.

    INSERT zlaw_booking_m FROM (
        SELECT FROM /dmo/booking AS Booking
        FIELDS
            travel_id,
            booking_id,
            booking_date,
            customer_id,
            carrier_id,
            connection_id,
            flight_date,
            flight_price,
            currency_code ).

    INSERT zlaw_bksuppl_m FROM (
      SELECT FROM /dmo/book_suppl AS BookSUPPL
      FIELDS
           travel_id,
           booking_id,
           booking_supplement_id,
           supplement_id,
           price,
           currency_code ).

    INSERT zlaw_travel_m FROM (
      SELECT FROM /dmo/travel AS travel
      FIELDS
        travel~travel_id,
        agency_id,
        customer_id,
        begin_date,
        end_date,
        booking_fee,
        total_price,
        currency_code,
        description,
        status AS overall_status,
        createdby AS created_by,
        createdat AS created_at,
        lastchangedby AS last_changed_by,
        lastchangedat AS last_changed_at
    ).

    COMMIT WORK.

    out->write( 'Success!' ).
  ENDMETHOD.
ENDCLASS.
