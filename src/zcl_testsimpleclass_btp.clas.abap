CLASS zcl_testsimpleclass_btp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_testsimpleclass_btp IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  out->write( 'I am here! The message was changed' ).
  ENDMETHOD.
ENDCLASS.
