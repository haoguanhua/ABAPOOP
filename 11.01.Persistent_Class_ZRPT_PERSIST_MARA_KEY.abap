*&---------------------------------------------------------------------*
*& Report  ZRPT_PERSIST_MARA_KEY
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*   This is test program for persist table operation by business key
*   generation date: 2016.08.14 by user Aaron Hao
*   NO. 11.01 Aaron Hao 2016/8/4
*---------------------------------------------------------------------*

REPORT  zrpt_persist_mara_key.

SELECTION-SCREEN BEGIN OF BLOCK block_h1 WITH FRAME TITLE title_h1.
PARAMETERS:
  get RADIOBUTTON GROUP radp,
  create  RADIOBUTTON GROUP radp,
  delete RADIOBUTTON GROUP radp.
SELECTION-SCREEN END OF BLOCK block_h1.


SELECTION-SCREEN BEGIN OF BLOCK block_h2 WITH FRAME TITLE title_h2.
PARAMETERS:
  lv_matr LIKE ztb_mara_01-matnr,
  lv_desc LIKE ztb_mara_01-maktx,
  lv_cdate  LIKE ztb_mara_01-ersda,
  lv_type LIKE ztb_mara_01-mtart.
SELECTION-SCREEN END OF BLOCK block_h2.

*-----------------------------------------------------------------------
* declaration
*-----------------------------------------------------------------------
*
DATA:
      lv_material_agent TYPE REF TO zca_persist_mara_key,
      lv_material TYPE REF TO zcl_persist_mara_key.
DATA:
      lv_result1 TYPE REF TO object,
      lv_result2 TYPE REF TO zcl_persist_mara_key.
*-------------------------------------------------------------------*
* selection screen
*-------------------------------------------------------------------*
AT SELECTION-SCREEN.

*---------------------------------------------------------------------*
* load-of-program
*---------------------------------------------------------------------*
LOAD-OF-PROGRAM.
  title_h1 = text-001.
  title_h2 = text-002.
*-------------------------------------------------------------------*
* start selection
*-------------------------------------------------------------------*
START-OF-SELECTION.
  lv_material_agent = zca_persist_mara_key=>agent.
*-------------------------------------------------------------------*
* read object from table
*-------------------------------------------------------------------*
  IF get EQ 'X'.
    TRY.
        CALL METHOD lv_material_agent->get_persistent
          EXPORTING
            i_matnr = lv_matr
          RECEIVING
            result  = lv_result1.

        lv_result2 ?= lv_result1.
        lv_desc = lv_result2->get_maktx( ).
        lv_cdate = lv_result2->get_ersda( ).
        lv_type = lv_result2->get_mtart( ).
        WRITE:/ lv_matr, lv_desc, lv_cdate, lv_type.

      CATCH cx_os_object_not_found .
        MESSAGE 'Object does not exist' TYPE 'I' DISPLAY LIKE 'I'.
    ENDTRY.
*-------------------------------------------------------------------*
* save persistent object into the table
*-------------------------------------------------------------------*
  ELSEIF create EQ 'X'.
    TRY.
        CALL METHOD lv_material_agent->create_persistent
          EXPORTING
            i_matnr = lv_matr
            i_maktx = lv_desc
            i_ersda = lv_cdate
            i_mtart = lv_type
          RECEIVING
            result  = lv_material.
        COMMIT WORK.
        WRITE 'Object created'.
      CATCH cx_os_object_existing .
        MESSAGE 'Object already exists' TYPE 'I' DISPLAY LIKE 'I'.
    ENDTRY.
*--------------------------------------------------------------------*
* delete persistent object from table
*--------------------------------------------------------------------*
  ELSEIF delete EQ 'X'.
    TRY.
        CALL METHOD lv_material_agent->get_persistent
          EXPORTING
            i_matnr = lv_matr
          RECEIVING
            result  = lv_result1.
      CATCH cx_os_object_not_found .
        MESSAGE 'Object does not exist' TYPE 'I' DISPLAY LIKE 'I'.
    ENDTRY.
    lv_result2 ?= lv_result1.
    TRY.
        CALL METHOD lv_material_agent->delete_persistent
          EXPORTING
            i_matnr = lv_matr.
        COMMIT WORK.
        WRITE 'Object Deleted'.
      CATCH cx_os_object_not_existing .
        MESSAGE 'Object does not exist' TYPE 'I' DISPLAY LIKE 'I'.
    ENDTRY.
  ENDIF.