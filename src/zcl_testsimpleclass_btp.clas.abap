CLASS zcl_testsimpleclass_btp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TESTSIMPLECLASS_BTP IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  out->write( 'I am here! The message was changed. I am the best!' ).
  ENDMETHOD.
ENDCLASS.
