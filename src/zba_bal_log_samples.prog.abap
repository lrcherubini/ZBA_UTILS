*&---------------------------------------------------------------------*
*& Report ZBA_BAL_LOG_SAMPLES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zba_bal_log_samples.

CLASS lcl_class DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS foo RAISING cx_demo_constructor.
ENDCLASS.

DATA gr_bal TYPE REF TO zcl_ba_bal_log_base.

PARAMETERS: p_obj TYPE balhdr-object DEFAULT 'ZMIG',
            p_sub TYPE balhdr-subobject DEFAULT 'ARUN',
            p_ext TYPE balhdr-extnumber DEFAULT '1234567890'.

START-OF-SELECTION.

  PERFORM create_log.
  PERFORM add_msg_from_exception.
  PERFORM add_msg_from_message.
  PERFORM add_msg_from_errortext.
  PERFORM add_msg_from_statustext.
  PERFORM add_msg_from_debug_message.
  PERFORM add_msg_from_cust_message.
  PERFORM save.
  PERFORM display.

CLASS lcl_class IMPLEMENTATION.
  METHOD foo.
    RAISE EXCEPTION TYPE cx_demo_constructor.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*& Form create_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM create_log .

  TRY.
      CREATE OBJECT gr_bal
        EXPORTING
          iv_log_object    = p_obj
          iv_log_subobject = p_sub
*         iv_debug_subobject =
*         iv_reorg_in_days = 3
          iv_external_id   = p_ext
*         iv_max_msg_in_mem  = 999
*         iv_loghandle     =
*         iv_log_username  = SY-UNAME
*         iv_log_repid     = SY-REPID
*         iv_log_tcode     = SY-TCODE
*         iv_batch_mode    = abap_false
        .

      gr_bal->save_to_db( ).

    CATCH zcx_bal_exception INTO DATA(lo_bal). " Exception Class for BAL OO Framework
      MESSAGE lo_bal->get_text( ) TYPE 'E'.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM save .

  gr_bal->save_to_db( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_msg_from_exception
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM add_msg_from_exception .

  TRY.
      lcl_class=>foo( ).
    CATCH cx_demo_constructor INTO DATA(lo_demo).
      gr_bal->add_exception( lo_demo ).

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_msg_from_message
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM add_msg_from_message .

  CALL FUNCTION 'J_1B_BRANCH_READ'
    EXPORTING
      branch            = '1000'                 " Branch
      company           = '2001'                 " Company
    EXCEPTIONS
      branch_not_found  = 1                " Branch is not assigned to plant
      address_not_found = 2                " Address of branch is not maintained
      company_not_found = 3                " Plant is not assigned to company
      OTHERS            = 4.

  IF sy-subrc NE 0.
    gr_bal->add_message( ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_msg_from_errortext
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM add_msg_from_errortext .

  gr_bal->add_errortext( `Chame esse método para mensagens do tipo 'E' com texto livre` ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_msg_from_statustext
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM add_msg_from_statustext .

  gr_bal->add_statustext( `Chame esse método para mensagens do tipo 'S' com texto livre` ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_msg_from_debug_message
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM add_msg_from_debug_message .

  gr_bal->add_debug_message(
    EXPORTING
      iv_msgv1      = 'Parametro1'
      iv_msgv2      = 'Parametro2'
      iv_msgv3      = 'Parametro3'
      iv_msgv4      = 'Parametro4'
      iv_headertext = 'Pilha ABAP que originou log'
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM display .

  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXCEPTIONS
      profile_inconsistent = 1                " Inconsistent display profile
      internal_error       = 2                " Internal data formatting error
      no_data_available    = 3                " No data to be displayed found
      no_authority         = 4                " No display authorization
      OTHERS               = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_msg_from_cust_message
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM add_msg_from_cust_message .

  gr_bal->add_cust_mess( iv_msgty = 'W'
                         iv_msgid = 'ZGL_INTEGRATIONS'
                         iv_msgno = '005'
                         iv_msgv1 = 'Programa de Exemplo de Logs'
                         iv_msgv2 = 'usando classe ZCL_GL_BAL_LOG_BASE' ).

ENDFORM.
