*&---------------------------------------------------------------------*
*& Report ZST7_ORDERS_XML
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZST7_ORDERS_XML.


TABLES : VBAK, VBAP, KNA1.

DATA : BEGIN OF I_ORDERS OCCURS 100,
         ORDER_NUM     TYPE STRING,
         DATE          TYPE STRING,
         CUSTOMER_CODE TYPE STRING,
         CUSTOMER_NAME TYPE STRING.
DATA : END OF I_ORDERS.

DATA : BEGIN OF I_ITEMS  OCCURS 100,
         ORDER_NUM TYPE STRING,
         MATNR     TYPE STRING,
         QUANTITY  TYPE STRING,
         AMOUNT    TYPE STRING.
DATA : END OF I_ITEMS.

SELECT-OPTIONS: L_DATE FOR SY-DATUM DEFAULT SY-DATUM.
SELECT-OPTIONS: L_ORDER FOR VBAK-VBELN.
PARAMETERS : FNAME TYPE LOCALFILE DEFAULT 'C:\Users\Owner\Documents\DOWN.xml'.

PERFORM SELECT_ORDERS.
PERFORM MAKE_XML.

*&---------------------------------------------------------------------*
*&      Form  select_orders
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SELECT_ORDERS.


  SELECT  * FROM VBAK ."where vbeln in l_order and
*                           "erdat in l_date.
*    write :/ ' Order '.
*    write :/ '-------------------------'.
    SELECT SINGLE * FROM KNA1 WHERE KUNNR = VBAK-KUNNR.
    i_orders-order_num = vbak-vbeln.
    i_orders-date = vbak-erdat.
    i_orders-customer_code = vbak-kunnr.
    i_orders-customer_name = kna1-name1.
   append i_orders.
*    write :/ 'Order Number : ', vbak-vbeln.
*    write :/ 'Order Date   : ', vbak-erdat.
*    write :/ 'Customer Code: ', vbak-kunnr.
*    write :/ 'Customer Name: ', kna1-name1.
*    skip 1.
*    write :/ 'Items  '.
*    write :/ '------------------------------------------'.
    SELECT * FROM VBAP WHERE VBELN = VBAK-VBELN.
      I_ITEMS-ORDER_NUM = VBAP-VBELN.
      I_ITEMS-MATNR = VBAP-MATNR.
      I_ITEMS-QUANTITY = VBAP-KWMENG.
      I_ITEMS-AMOUNT = VBAP-NETPR.
      APPEND I_ITEMS.
*      write:/ vbap-matnr,
*              vbap-kwMENG,
*              vbap-netpr.
    ENDSELECT.
    DESCRIBE TABLE I_ITEMS LINES  DATA(LV_SIZE).
    IF LV_SIZE = 100.
      EXIT.
    ENDIF.
*    skip 1.
  ENDSELECT.



ENDFORM.                    "select_orders


*&---------------------------------------------------------------------*
*&      Form  make_xml
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MAKE_XML.
  DATA: LO_IXML TYPE REF TO IF_IXML.
  DATA: LO_DOCUMENT TYPE REF TO IF_IXML_DOCUMENT.
  DATA: M_XMLDOC TYPE REF TO CL_XML_DOCUMENT.
  DATA: ORDERS  TYPE REF TO IF_IXML_ELEMENT.
  DATA: ORDER TYPE REF TO IF_IXML_ELEMENT.
  DATA: ITEMS TYPE REF TO IF_IXML_ELEMENT.
  DATA: ITEM TYPE REF TO IF_IXML_ELEMENT.

  LO_IXML = CL_IXML=>CREATE( ).

  LO_DOCUMENT = LO_IXML->CREATE_DOCUMENT( ).

  ORDERS = LO_DOCUMENT->CREATE_SIMPLE_ELEMENT(
    NAME   = 'Orders'
    PARENT = LO_DOCUMENT ).
  LOOP AT I_ORDERS.
    ORDER = LO_DOCUMENT->CREATE_SIMPLE_ELEMENT(
      NAME   = 'Order'
      PARENT = ORDERS ).

    LO_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME   = 'order_num'
                                        PARENT = ORDER
                                        VALUE  = I_ORDERS-ORDER_NUM ).
    LO_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME   = 'date'
                                        PARENT = ORDER
                                        VALUE  = I_ORDERS-DATE ).
    LO_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME   = 'customer_code'
                                        PARENT = ORDER
                                        VALUE  = I_ORDERS-CUSTOMER_CODE ).
    LO_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME   = 'customer_name'
                                        PARENT = ORDER
                                        VALUE  = I_ORDERS-CUSTOMER_NAME ).

    ITEMS = LO_DOCUMENT->CREATE_SIMPLE_ELEMENT(
      NAME   = 'Items'
      PARENT = ORDER ).
    LOOP AT I_ITEMS WHERE ORDER_NUM = I_ORDERS-ORDER_NUM.
      ITEM = LO_DOCUMENT->CREATE_SIMPLE_ELEMENT(
        NAME   = 'Item'
        PARENT = ITEMS ).
      LO_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME   = 'matnr'
                                          PARENT = ITEM
                                          VALUE  = I_ITEMS-MATNR ).
      LO_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME   = 'quantity'
                                          PARENT = ITEM
                                          VALUE  = I_ITEMS-QUANTITY ).
      LO_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME   = 'amount'
                                          PARENT = ITEM
                                          VALUE  = I_ITEMS-AMOUNT ).
    ENDLOOP.

  ENDLOOP.


  CREATE OBJECT M_XMLDOC.
  M_XMLDOC->CREATE_WITH_DOM( DOCUMENT = LO_DOCUMENT ).
  M_XMLDOC->EXPORT_TO_FILE( FNAME ).

ENDFORM.                    "make_xml
