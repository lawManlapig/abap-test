CLASS lhc_ZLAW_I_Travel_M DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZLAW_I_Travel_M RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ZLAW_I_Travel_M RESULT result.
    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION ZLAW_I_Travel_M~acceptTravel RESULT result.

    METHODS copyTravel FOR MODIFY
      IMPORTING keys FOR ACTION ZLAW_I_Travel_M~copyTravel.

    METHODS recalculateTotalPrice FOR MODIFY
      IMPORTING keys FOR ACTION ZLAW_I_Travel_M~recalculateTotalPrice.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION ZLAW_I_Travel_M~rejectTravel RESULT result.

    " Features handler
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZLAW_I_Travel_M RESULT result.

    " Validation Handler
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zlaw_i_travel_m~validatecustomer.
    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR zlaw_i_travel_m~validatedates.

    " Determination Handler
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zlaw_i_travel_m~calculatetotalprice.

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
          APPEND CORRESPONDING #( <lfs_booking_details> ) TO mapped-zlaw_i_booking_m
          ASSIGNING FIELD-SYMBOL(<lfs_booking_new>).
          IF <lfs_booking_details>-BookingId IS INITIAL.
            lv_max_booking += 10.
            <lfs_booking_new>-BookingId = lv_max_booking.
          ENDIF.
        ENDLOOP. " --> LOOP AT <lfs_entities>-%target
      ENDLOOP. " --> LOOP AT entities.. (nested)
    ENDLOOP. " --> LOOP AT entities..

  ENDMETHOD.

  METHOD acceptTravel.
    MODIFY ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE
    ENTITY ZLAW_I_Travel_M
    UPDATE FIELDS ( OverallStatus LastChangedAt )
    WITH VALUE #( FOR ls_keys IN keys ( %tky = ls_keys-%tky
                                        OverallStatus = 'A'
                                        LastChangedAt = cl_abap_context_info=>get_system_date( ) ) ).

    " Check by Reading Entity
    READ ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE
    ENTITY ZLAW_I_Travel_M
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_read_result).

    result = VALUE #( FOR ls_read_result IN lt_read_result (
        %tky = ls_read_result-%tky
        %param = ls_read_result
    ) ).

  ENDMETHOD.

  METHOD copyTravel.

    ASSIGN keys[ %cid = '' ]
    TO FIELD-SYMBOL(<lfs_blank_cid>).

    IF sy-subrc IS NOT INITIAL.
      " data
      DATA: lt_travel                 TYPE TABLE FOR CREATE ZLAW_I_Travel_M,
            lt_booking_cba            TYPE TABLE FOR CREATE ZLAW_I_Travel_M\_Booking,
            lt_booking_supplement_cba TYPE TABLE FOR CREATE ZLAW_I_Booking_M\_BookingSupplement.

      " Read existing
      READ ENTITIES OF ZLAW_I_Travel_M
      IN LOCAL MODE
      ENTITY ZLAW_I_Travel_M
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel_read)
      FAILED DATA(lt_travel_failed).

      READ ENTITIES OF ZLAW_I_Travel_M
      IN LOCAL MODE
      ENTITY ZLAW_I_Travel_M
      BY \_Booking
      ALL FIELDS WITH CORRESPONDING #( lt_travel_read )
      RESULT DATA(lt_booking_read).

      READ ENTITIES OF ZLAW_I_Travel_M
      IN LOCAL MODE
      ENTITY ZLAW_I_Booking_M
      BY \_BookingSupplement
      ALL FIELDS WITH CORRESPONDING #( lt_booking_read )
      RESULT DATA(lt_booking_supplement_read).

      LOOP AT lt_travel_read ASSIGNING FIELD-SYMBOL(<lfs_travel_read>).
*        APPEND INITIAL LINE TO lt_travel ASSIGNING FIELD-SYMBOL(<lfs_travel_new>).
*        " Copy the data from existing
*        <lfs_travel_new>-%cid = keys[ KEY entity TravelId = <lfs_travel_read>-TravelId ]-%cid.
*        <lfs_travel_new>-%data = CORRESPONDING #( <lfs_travel_read> EXCEPT TravelId ).

        " Copy the values from existing
        APPEND VALUE #(
            %cid = keys[ KEY entity TravelId = <lfs_travel_read>-TravelId ]-%cid
            %data = CORRESPONDING #( <lfs_travel_read> EXCEPT TravelId )
        ) TO lt_travel ASSIGNING FIELD-SYMBOL(<lfs_travel_new>).

        " Manipulate some values if needed
        <lfs_travel_new>-BeginDate = cl_abap_context_info=>get_system_date(  ).
        <lfs_travel_new>-EndDate = cl_abap_context_info=>get_system_date(  ) + 30.
        <lfs_travel_new>-OverallStatus = 'O'.

        APPEND VALUE #( %cid_ref = <lfs_travel_new>-%cid )
        TO lt_booking_cba ASSIGNING FIELD-SYMBOL(<lfs_booking_new>).

        LOOP AT lt_booking_read ASSIGNING FIELD-SYMBOL(<lfs_booking_read>)
        USING KEY entity
        WHERE TravelId = <lfs_travel_read>-TravelId.
          APPEND VALUE #(
              %cid = <lfs_travel_new>-%cid && <lfs_booking_read>-BookingId
              %data = CORRESPONDING #( <lfs_booking_read> EXCEPT TravelId )
          ) TO <lfs_booking_new>-%target ASSIGNING FIELD-SYMBOL(<lfs_booking_new2>).

          " Manipulate values
          <lfs_booking_new2>-BookingStatus = 'N'.

          APPEND VALUE #( %cid_ref = <lfs_booking_new2>-%cid )
          TO lt_booking_supplement_cba ASSIGNING FIELD-SYMBOL(<lfs_booking_supp_new>).

          LOOP AT lt_booking_supplement_read ASSIGNING FIELD-SYMBOL(<lfs_bk_supp_new>)
          USING KEY entity
          WHERE BookingId = <lfs_booking_read>-BookingId
          AND   TravelId = <lfs_travel_read>-TravelId.

            APPEND VALUE #(
                %cid = <lfs_travel_new>-%cid && <lfs_booking_read>-BookingId && <lfs_bk_supp_new>-BookingSupplementId
                %data = CORRESPONDING #( <lfs_bk_supp_new> EXCEPT TravelId BookingId )
            ) TO <lfs_booking_supp_new>-%target.

          ENDLOOP. " --> LOOP AT lt_booking_supplement_read ..
        ENDLOOP. " --> LOOP AT lt_booking_read ..
      ENDLOOP. " --> LOOP AT lt_travel_read ..

      " MODIFY ENTITY
      MODIFY ENTITIES OF ZLAW_I_Travel_M
      IN LOCAL MODE
      ENTITY ZLAW_I_Travel_M
      CREATE FIELDS ( AgencyId CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus Description )
      WITH lt_travel

      ENTITY ZLAW_I_Travel_M
      CREATE BY \_Booking
      FIELDS ( BookingId BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice CurrencyCode BookingStatus )
      WITH lt_booking_cba

      ENTITY ZLAW_I_Booking_M
      CREATE BY \_BookingSupplement
      FIELDS ( BookingSupplementId SupplementId Price CurrencyCode )
      WITH lt_booking_supplement_cba

      MAPPED DATA(lt_mapped).

      " Send to Front-End
      mapped-zlaw_i_travel_m = lt_mapped-zlaw_i_travel_m.
    ENDIF.
  ENDMETHOD.

  METHOD recalculateTotalPrice.
    TYPES: BEGIN OF lty_total,
             price TYPE /dmo/total_price,
             curr  TYPE /dmo/currency_code,
           END OF lty_total.

    DATA: lt_total TYPE STANDARD TABLE OF lty_total.

    " Read the entity (MAIN)
    READ ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE
    ENTITY ZLAW_I_Travel_M
    FIELDS ( BookingFee CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel_result).

    " Read by Association (Child)
    READ ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE
    ENTITY ZLAW_I_Travel_M
    BY \_Booking
    FIELDS ( FlightPrice CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_booking_result).

    " Read by Association (Child of Child)
    READ ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE
    ENTITY ZLAW_I_Booking_M
    BY \_BookingSupplement
    FIELDS ( Price CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_booking_supplement_result).

    LOOP AT lt_travel_result ASSIGNING FIELD-SYMBOL(<lfs_travel>).
      lt_total = VALUE #( ( price = <lfs_travel>-BookingFee curr = <lfs_travel>-CurrencyCode ) ).

      LOOP AT lt_booking_result ASSIGNING FIELD-SYMBOL(<lfs_booking>)
      USING KEY entity
      WHERE TravelId = <lfs_travel>-TravelId
      AND CurrencyCode IS NOT INITIAL.
        APPEND VALUE #(
            price = <lfs_booking>-FlightPrice
            curr  = <lfs_booking>-CurrencyCode
        ) TO lt_total.

        LOOP AT lt_booking_supplement_result ASSIGNING FIELD-SYMBOL(<lfs_booking_supplement>)
        USING KEY entity
        WHERE TravelId = <lfs_booking>-TravelId
        AND BookingId = <lfs_booking>-BookingId
        AND CurrencyCode IS NOT INITIAL.
          APPEND VALUE #(
              price = <lfs_booking_supplement>-Price
              curr  = <lfs_booking_supplement>-CurrencyCode
          ) TO lt_total.
        ENDLOOP.
      ENDLOOP.

      LOOP AT lt_total ASSIGNING FIELD-SYMBOL(<lfs_total>).

        IF <lfs_total>-curr = <lfs_travel>-CurrencyCode.
          DATA(lv_converted_price) = <lfs_total>-price.
        ELSE.
          CALL METHOD /dmo/cl_flight_amdp=>convert_currency
            EXPORTING
              iv_amount               = <lfs_total>-price
              iv_currency_code_source = <lfs_total>-curr
              iv_currency_code_target = <lfs_travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = lv_converted_price.
        ENDIF.

        " Total Price
        <lfs_travel>-TotalPrice += lv_converted_price.
      ENDLOOP. " --> LOOP AT lt_total..
    ENDLOOP. " --> LOOP AT lt_travel_result..

    " Modify
    MODIFY ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE
    ENTITY ZLAW_I_Travel_M
    UPDATE FIELDS ( TotalPrice )
    WITH CORRESPONDING #( lt_travel_result ).
  ENDMETHOD.

  METHOD rejectTravel.
    MODIFY ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE
    ENTITY ZLAW_I_Travel_M
    UPDATE FIELDS ( OverallStatus LastChangedAt )
    WITH VALUE #( FOR ls_keys IN keys ( %tky = ls_keys-%tky
                                        OverallStatus = 'X'
                                        LastChangedAt = cl_abap_context_info=>get_system_date(  ) ) ).

    " Check by Reading Entity
    READ ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE
    ENTITY ZLAW_I_Travel_M
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_read_result).

    result = VALUE #( FOR ls_read_result IN lt_read_result (
        %tky = ls_read_result-%tky
        %param = ls_read_result
    ) ).
  ENDMETHOD.

  METHOD get_instance_features.
    " Read the importing parameters
    READ ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE
    ENTITY ZLAW_I_Travel_M
    FIELDS ( TravelId OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel_read_result).

    result = VALUE #(
        FOR ls_travel_read IN lt_travel_read_result
        ( %tky = ls_travel_read-%tky
          " Feature Control for Actions
          %features-%action-acceptTravel = COND #( WHEN ls_travel_read-OverallStatus = 'A'
                                                   THEN if_abap_behv=>fc-o-disabled
                                                   ELSE if_abap_behv=>fc-o-enabled )
          %features-%action-rejectTravel = COND #( WHEN ls_travel_read-OverallStatus = 'X'
                                                   THEN if_abap_behv=>fc-o-disabled
                                                   ELSE if_abap_behv=>fc-o-enabled )
          " Feature Control for Associations
          %features-%assoc-_Booking = COND #( WHEN ls_travel_read-OverallStatus = 'X'
                                                   THEN if_abap_behv=>fc-o-disabled
                                                   ELSE if_abap_behv=>fc-o-enabled ) )
    ).
  ENDMETHOD.

  METHOD validateCustomer.
    " Read key
    READ ENTITY IN LOCAL MODE ZLAW_I_Travel_M
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel_read).

    DATA: lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_customer = CORRESPONDING #( lt_travel_read DISCARDING DUPLICATES MAPPING customer_id = CustomerId ).
    DELETE lt_customer WHERE customer_id IS INITIAL.

    SELECT FROM /dmo/customer
    FIELDS customer_id
    FOR ALL ENTRIES IN @lt_customer
    WHERE customer_id = @lt_customer-customer_id
    INTO TABLE @DATA(lt_customer_db).

    " Check if field is blank
    LOOP AT lt_travel_read INTO DATA(ls_travel).
      IF ls_travel-CustomerId IS INITIAL OR NOT
         line_exists( lt_customer_db[ customer_id = ls_travel-CustomerId ] ).

        " Error Message
        APPEND VALUE #(
            %tky = ls_travel-%tky
        ) TO failed-zlaw_i_travel_m.

        APPEND VALUE #(
            %tky = ls_travel-%tky
            %msg = NEW /dmo/cm_flight_messages(
                          textid      =  /dmo/cm_flight_messages=>customer_unkown
                          customer_id = ls_travel-CustomerId
                          severity    = if_abap_behv_message=>severity-error )
            %element-CustomerId = if_abap_behv=>mk-on " Mark the field to prompt error from
        ) TO reported-zlaw_i_travel_m.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDates.
    READ ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE
    ENTITY ZLAW_I_Travel_M
    FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels).

    LOOP AT lt_travels INTO DATA(ls_travels).
      " End Date before Begin Date
      IF ls_travels-BeginDate > ls_travels-EndDate.
        APPEND VALUE #(
          %tky = ls_travels-%tky
        ) TO failed-zlaw_i_travel_m.

        APPEND VALUE #(
          %tky = ls_travels-%tky
          %msg = NEW /dmo/cm_flight_messages(
                        textid      =  /dmo/cm_flight_messages=>begin_date_bef_end_date
                        begin_date  = ls_travels-BeginDate
                        end_date    = ls_travels-EndDate
                        travel_id   = ls_travels-TravelId
                        severity    = if_abap_behv_message=>severity-error )
          %element-BeginDate = if_abap_behv=>mk-on
          %element-EndDate = if_abap_behv=>mk-on
        ) TO reported-zlaw_i_travel_m.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculateTotalPrice.

    " Get the internal function
    MODIFY ENTITIES OF ZLAW_I_Travel_M
    IN LOCAL MODE
    ENTITY ZLAW_I_Travel_M
    EXECUTE recalculateTotalPrice " Call the Action
    FROM CORRESPONDING #( keys ).

  ENDMETHOD.

ENDCLASS.
