CLASS zlaw_modify_practice DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zlaw_modify_practice IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*    DATA: lt_book TYPE TABLE FOR CREATE ZLAW_I_Travel_M\_Booking. " Declare type

*    " Modify Short (for Create)
*    MODIFY ENTITY ZLAW_I_Travel_M " Modify which entity
*    CREATE FROM VALUE #( ( " Define the Operation (CUD) -- In line Declaration
*        %cid = 'lawMain' " Identifier,, any value .. mandatory
*        %data-BeginDate = '20200101' " Field you want to update
*        %control-BeginDate = if_abap_behv=>mk-on " activate Field for modify
*    ) )
*
*    " Create by Association
*    CREATE BY \_Booking
*    FROM VALUE #( (
*        %cid_ref = 'lawMain' " Reference mo ito sa Main Entity.. similar sa draftUUID ng CAP Framework
*        %target = VALUE #( (
*            %cid = 'lawBooking'
*            %data-BookingStatus = 'N'
*            %control-BookingStatus = if_abap_behv=>mk-on
*        ) )
*    ) )
*    FAILED FINAL(lt_failed) " FINAL means the table will be read-only
*    MAPPED FINAL(lt_mapped)
*    REPORTED FINAL(lt_reported).
*
*
*
*    IF lt_failed IS NOT INITIAL.
*      out->write( lt_failed ).
*    ELSE.
*      COMMIT ENTITIES.
*      out->write( 'Success Create!' ).
*    ENDIF.
*
*    " Modify Short (for Delete)
*    MODIFY ENTITY ZLAW_I_Travel_M
*    DELETE FROM VALUE #( (  %key-TravelId = '4593' ) ) " Key Fields lang available dito
*    FAILED FINAL(lt_failed2) " FINAL means the table will be read-only
*    MAPPED FINAL(lt_mapped2)
*    REPORTED FINAL(lt_reported2).
*
*    IF lt_failed IS NOT INITIAL.
*      out->write( lt_failed ).
*    ELSE.
*      COMMIT ENTITIES.
*      out->write( 'Success Delete!' ).
*    ENDIF.

    " Modify with use of AUTO FILL CID
    MODIFY ENTITY ZLAW_I_Travel_M " Modify which entity
    CREATE AUTO FILL CID WITH VALUE #( ( " AUTO FILL CID populates the %cid.. so no need to define explicitly
        %data-BeginDate = '20200101'
        %control-BeginDate = if_abap_behv=>mk-on
    ) )
    FAILED FINAL(lt_failed)
    MAPPED FINAL(lt_mapped)
    REPORTED FINAL(lt_reported).



    IF lt_failed IS NOT INITIAL.
      out->write( lt_failed ).
    ELSE.
      COMMIT ENTITIES.
      out->write( 'Success Create!' ).
    ENDIF.

    " Modify Long Form (Update)
    MODIFY ENTITIES OF ZLAW_I_Travel_M
    " NOTE: You can specify multiple entities in this block of EML Code :)
    ENTITY ZLAW_I_Travel_M " Which Entity to modify
    UPDATE FIELDS ( BeginDate BookingFee )
    WITH VALUE #( (
        %key-TravelId = '0000004597'
        BeginDate = '19990101'
        BookingFee = '100.00'
    ) )

    " Another Entity inside the block :)
    ENTITY ZLAW_I_Travel_M
    DELETE FROM VALUE #( ( %key-TravelId = '0000004594' ) )

    FAILED FINAL(lt_failed2)
    MAPPED FINAL(lt_mapped2)
    REPORTED FINAL(lt_reported2).

    IF lt_failed IS NOT INITIAL.
      out->write( lt_failed ).
    ELSE.
      COMMIT ENTITIES.
      out->write( 'Success Modify!' ).
    ENDIF.


    " Modify with auto fill cid set fields
    " NOT RECOMMENDED as this will take up a lot on the performance
    MODIFY ENTITY ZLAW_I_Travel_M
    UPDATE SET FIELDS WITH VALUE #( (
        %key-TravelId = '0000004598'
        BeginDate = '19990101'
        BookingFee = '100.00'
    ) ).

    COMMIT ENTITIES.
  ENDMETHOD.
ENDCLASS.
