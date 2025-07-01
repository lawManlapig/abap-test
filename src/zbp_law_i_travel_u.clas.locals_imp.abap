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
  ENDMETHOD.

  " Save(4th) : Everything is done... nothing more to do.. this will save the data in the DB
  "             dito natritrigger yung COMMIT WORK
  METHOD save.
  ENDMETHOD.

  " Cleanup(situational. in happy path, it's 5th) : Cleans the transaction buffer.
  METHOD cleanup.
  ENDMETHOD.

  " Cleanup Finalize(during fails) : cleans transaction buffer is Finalize / Check before save fails.
  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
