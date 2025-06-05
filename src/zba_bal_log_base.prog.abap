*&---------------------------------------------------------------------*
*& Subroutinenpool ZBA_BAL_LOG_BASE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
PROGRAM zba_bal_log_base.

*--------------------------------------------------------------------
* FORM CALLBACK_MSG_DETAIL
*--------------------------------------------------------------------
FORM callback_msg_detail TABLES it_params STRUCTURE spar.   "#EC CALLED

  DATA: lt_details TYPE zcl_ba_bal_log_base=>tt_details,
        lv_xstrdet TYPE xstring.

  READ TABLE it_params INTO DATA(ls_data) WITH KEY param = 'MSG_IDENT'.

  CHECK sy-subrc EQ 0.

  DATA(lv_ident) = CONV numc10( ls_data-value ).

  READ TABLE it_params INTO ls_data WITH KEY param = '%LOGNUMBER'.

  CHECK sy-subrc EQ 0.

  DATA(lv_lognum) = CONV balognr( ls_data-value ).

  IMPORT details = lt_details
    FROM DATABASE bal_indx(al)
    ID lv_lognum.

  READ TABLE lt_details INTO DATA(ls_detail) WITH KEY ident = lv_ident.

  CHECK sy-subrc EQ 0.

  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
    EXPORTING
      text     = ls_detail-strdet
*     mimetype = space
      encoding = '1160'
    IMPORTING
      buffer   = lv_xstrdet
    EXCEPTIONS
      failed   = 1
      OTHERS   = 2.

  IF sy-subrc NE 0.
    cl_abap_browser=>show_html(
      html_string  = ls_detail-strdet
      context_menu = 'X' ).

  ELSE.
    cl_abap_browser=>show_html(
      html_xstring = lv_xstrdet
      context_menu = 'X' ).

  ENDIF.

ENDFORM.
