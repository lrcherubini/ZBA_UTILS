class ZCL_BA_BAL_LOG_BASE definition
  public
  create public .

public section.

  types:
    BEGIN OF tp_details,
        ident  TYPE numc10,
        strdet TYPE string,
      END OF tp_details .
  types:
    tt_details TYPE STANDARD TABLE OF tp_details WITH KEY ident .
  types TP_T_LOGNUMBERS type BAL_T_LGNM .
  types TP_V_DETLEVEL type BAL_S_MSG-DETLEVEL .
  types TP_V_EXTERNAL_ID type BALNREXT .
  types TP_V_LOGHANDLE type BALLOGHNDL .
  types TP_V_LOG_OBJECT type BALOBJ_D .
  types TP_V_LOG_SUBOBJECT type BALOBJ_D .
  types TP_V_PROB_CLASS type BAL_S_MSG-PROBCLASS .
  types TP_V_REPID type SY-REPID .
  types TP_V_TCODE type SY-TCODE .
  types TP_V_USERNAME type SYUNAME .

  data GV_MAX_MESSAGE_MEMORY type I read-only .
  data GV_DETLEVEL type TP_V_DETLEVEL read-only .
  data GV_LOGOBJECT type TP_V_LOG_OBJECT read-only .
  data GV_LOG_SUBOJECT type TP_V_LOG_SUBOBJECT read-only .
  data GV_LOG_DEBUG_SUBOJECT type TP_V_LOG_SUBOBJECT read-only .
  data GV_MESSAGE_COUNT type I read-only .
  constants GC_PROBCLASS_LOW type TP_V_PROB_CLASS value '4' ##NO_TEXT.
  constants GC_PROBCLASS_MEDIUM type TP_V_PROB_CLASS value '3' ##NO_TEXT.
  constants GC_PROBCLASS_HIGH type TP_V_PROB_CLASS value '2' ##NO_TEXT.
  constants GC_PROBCLASS_VHIGH type TP_V_PROB_CLASS value '1' ##NO_TEXT.
  constants GC_PROBCLASS_NONE type TP_V_PROB_CLASS value SPACE ##NO_TEXT.
  data GV_LOGHANDLE type TP_V_LOGHANDLE read-only .
  data GV_BATCH_MODE type ABAP_BOOL read-only .

  events MAX_MEMORY_LIMIT_REACHED
    exporting
      value(EV_NUMBER_OF_MESSAGES) type I optional .
  events ERROR_ON_LOGING .

  methods ADD_EXCEPTION
    importing
      !IR_EXCEPTION type ref to CX_ROOT
      !IV_AUTOSAVE type ABAP_BOOL default ABAP_FALSE
    returning
      value(RS_EXCEPTION) type SYMSG .
  methods ADD_CUST_MESS
    importing
      !IV_PROBCLASS type TP_V_PROB_CLASS optional
      !IV_AUTOSAVE type ABAP_BOOL default ABAP_FALSE
      !IV_MSGTY type SY-MSGTY
      !IV_MSGID type SY-MSGID
      !IV_MSGNO type SY-MSGNO
      !IV_MSGV1 type ANY optional
      !IV_MSGV2 type ANY optional
      !IV_MSGV3 type ANY optional
      !IV_MSGV4 type ANY optional
      !IV_TEXT_DETAIL type STRING optional
    returning
      value(RS_EXCEPTION) type SYMSG .
  methods ADD_MESSAGE
    importing
      !IV_PROBCLASS type TP_V_PROB_CLASS optional
      !IV_AUTOSAVE type ABAP_BOOL default ABAP_FALSE
      !IV_TEXT_DETAIL type STRING optional
    returning
      value(RS_EXCEPTION) type SYMSG .
  methods ADD_ERRORTEXT
    importing
      !IV_ERROR_TEXT type STRING
      !IV_AUTOSAVE type ABAP_BOOL default ABAP_FALSE
      !IV_TEXT_DETAIL type STRING optional
    returning
      value(RS_EXCEPTION) type SYMSG .
  methods ADD_STATUSTEXT
    importing
      !IV_STATUS_TEXT type STRING
      !IV_AUTOSAVE type ABAP_BOOL default ABAP_FALSE
      !IV_TEXT_DETAIL type STRING optional
    returning
      value(RS_EXCEPTION) type SYMSG .
  methods ADD_BAPIRET2_TAB
    importing
      !IT_BAPIRET2 type BAPIRET2_TT
      !IV_AUTOSAVE type ABAP_BOOL default ABAP_FALSE
    returning
      value(RS_EXCEPTION) type SYMSG .
  methods SET_DETLEVEL
    importing
      !IV_DETLEVEL type I .
  methods GET_DETLEVEL
    returning
      value(RV_DETLEVEL) type I .
  methods SAVE_TO_DB
    importing
      !IV_IN_UPDATE_TASK type ABAP_BOOL default ''
      !IV_2TH_CONNECTION type ABAP_BOOL default 'X'
      !IV_2TH_CONNECT_COMMIT type ABAP_BOOL default 'X'
      !IV_LINK2JOB type ABAP_BOOL default ''
      !IV_SAVE_ALL type ABAP_BOOL default ''
    returning
      value(RT_LOGNUMBERS) type TP_T_LOGNUMBERS .
  methods REFRESH
    returning
      value(RS_EXCEPTION) type SYMSG .
  methods ADD_DEBUG_MESSAGE
    importing
      !IV_MSGV1 type ANY optional
      !IV_MSGV2 type ANY optional
      !IV_MSGV3 type ANY optional
      !IV_MSGV4 type ANY optional
      !IV_HEADERTEXT type C optional
      !IV_AUTOSAVE type ABAP_BOOL default ABAP_FALSE
    returning
      value(RS_EXCEPTION) type SYMSG .
  methods GET_LOGHANDLE
    returning
      value(RV_LOGHANDLE) type TP_V_LOGHANDLE .
  methods REFRESH_MESSAGES
    returning
      value(RS_EXCEPTION) type SYMSG .
  methods CONSTRUCTOR
    importing
      !IV_LOG_OBJECT type BALOBJ_D
      !IV_LOG_SUBOBJECT type BALSUBOBJ
      !IV_DEBUG_SUBOBJECT type BALSUBOBJ optional
      !IV_REORG_IN_DAYS type I default 20
      !IV_EXTERNAL_ID type CLIKE optional
      !IV_MAX_MSG_IN_MEM type I default 999
      !IV_LOGHANDLE type BALLOGHNDL optional
      !IV_LOG_USERNAME type SY-UNAME default SY-UNAME
      !IV_LOG_REPID type SY-REPID default SY-REPID
      !IV_LOG_TCODE type SY-TCODE default SY-TCODE
      !IV_BATCH_MODE type SY-BATCH default ABAP_FALSE
    raising
      ZCX_BAL_EXCEPTION .
  methods CHANGE_EXTNUMBER
    importing
      !IV_EXTERNAL_ID type BALNREXT
    returning
      value(RS_EXCEPTION) type SYMSG
    raising
      ZCX_BAL_EXCEPTION .
  methods GET_HEADER_LOG
    exporting
      !ES_HEADER type BAL_S_LOG
      !ES_STATISTICS type BAL_S_SCNT .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS gc_callback_prog TYPE baluep VALUE 'ZBA_BAL_LOG_BASE' ##NO_TEXT.
    CONSTANTS gc_callback_rout TYPE baluef VALUE 'CALLBACK_MSG_DETAIL' ##NO_TEXT.
    DATA gt_details TYPE tt_details .
    DATA gv_ident_count TYPE tp_details-ident .

    METHODS get_lognumber
      RETURNING
        VALUE(rv_lognumber) TYPE balognr .
    METHODS _error_on_loging .
    METHODS string_to_msgv
      IMPORTING
        !iv_text  TYPE string
      EXPORTING
        !ev_msgv1 TYPE symsgv
        !ev_msgv2 TYPE symsgv
        !ev_msgv3 TYPE symsgv
        !ev_msgv4 TYPE symsgv .
    METHODS _increment_message_count .
ENDCLASS.



CLASS ZCL_BA_BAL_LOG_BASE IMPLEMENTATION.


  METHOD ADD_BAPIRET2_TAB.

    LOOP AT it_bapiret2 INTO DATA(ls_bapiret2).

      rs_exception = add_cust_mess(
          iv_autosave  = abap_false        " Autosave log
          iv_msgty     = ls_bapiret2-type
          iv_msgid     = ls_bapiret2-id
          iv_msgno     = ls_bapiret2-number
          iv_msgv1     = ls_bapiret2-message_v1
          iv_msgv2     = ls_bapiret2-message_v2
          iv_msgv3     = ls_bapiret2-message_v3
          iv_msgv4     = ls_bapiret2-message_v4
      ).

      IF rs_exception IS NOT INITIAL.
        RETURN.

      ENDIF.
    ENDLOOP.

    IF sy-subrc EQ 0 AND iv_autosave EQ abap_true.
      save_to_db( ).

    ENDIF.

  ENDMETHOD.


  METHOD ADD_CUST_MESS.
    DATA: ls_msg  TYPE bal_s_msg,
          lv_temp TYPE string.

    ls_msg-detlevel  = gv_detlevel.

* define data of message for Application Log
    MESSAGE ID iv_msgid TYPE iv_msgty NUMBER iv_msgno
      WITH iv_msgv1 iv_msgv2 iv_msgv3 iv_msgv4
      INTO DATA(lv_dummy).

    ls_msg-msgty     = sy-msgty.
    ls_msg-msgid     = sy-msgid.
    ls_msg-msgno     = sy-msgno.
    ls_msg-msgv1     = sy-msgv1.
    ls_msg-msgv2     = sy-msgv2.
    ls_msg-msgv3     = sy-msgv3.
    ls_msg-msgv4     = sy-msgv4.

    IF iv_probclass IS NOT SUPPLIED.
      CASE sy-msgty.
        WHEN 'A' OR 'X'. ls_msg-probclass = '1'. " Muito import.
        WHEN 'E'.        ls_msg-probclass = '2'. " Import.
        WHEN 'W'.        ls_msg-probclass = '3'. " Médio
        WHEN 'S'.        ls_msg-probclass = '4'. " Informações adicionais
        WHEN 'I'.        ls_msg-probclass = ' '. " Outros
      ENDCASE.

    ELSE.
      ls_msg-probclass = iv_probclass.

    ENDIF.

    IF gv_batch_mode = abap_true.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_temp.
      WRITE: lv_temp.
      NEW-LINE.
    ENDIF.

* add this message to log
    IF iv_text_detail IS NOT INITIAL.
*     define callback routine
      ls_msg-params-callback-userexitp = gc_callback_prog.
      ls_msg-params-callback-userexitf = gc_callback_rout.
      ls_msg-params-callback-userexitt = space.

      APPEND VALUE tp_details(
          ident  = CONV tp_details-ident( gv_ident_count + 1 )
          strdet = iv_text_detail
      ) TO gt_details.

* put his identifier into the parameters of the message
      APPEND VALUE bal_s_par(
          parname  = 'MSG_IDENT'
          parvalue = CONV tp_details-ident( gv_ident_count + 1 )
      ) TO ls_msg-params-t_par.

    ENDIF.

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_s_msg      = ls_msg
        i_log_handle = gv_loghandle
      EXCEPTIONS
        OTHERS       = 1.
    IF sy-subrc <> 0.
      MOVE-CORRESPONDING sy TO rs_exception.
      _error_on_loging( ).
    ELSE.
      _increment_message_count( ).
      IF iv_autosave EQ abap_true.
        save_to_db( ).

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD ADD_DEBUG_MESSAGE.
    DATA: ls_msg                 TYPE bal_s_msg,
          lt_abap_callstack      TYPE abap_callstack,
          ls_abap_callstack_line TYPE abap_callstack_line.

    CALL FUNCTION 'SYSTEM_CALLSTACK'
      IMPORTING
        callstack = lt_abap_callstack
      EXCEPTIONS
        OTHERS    = 99.

    IF ( sy-subrc NE 0 ).
      EXIT.
    ENDIF.

    READ TABLE lt_abap_callstack
         INTO ls_abap_callstack_line
         INDEX 2.

    ls_msg-msgv2 = ls_abap_callstack_line-include.
    ls_msg-msgv3 = ls_abap_callstack_line-line.
    ls_msg-msgv1 = ls_abap_callstack_line-mainprogram.
    ls_msg-msgv4 = iv_headertext.


* define data of message for Application Log
    ls_msg-msgty     = 'S'.
    ls_msg-msgid     = 'S06'.
    ls_msg-msgno     = '890'.
    ls_msg-probclass = gc_probclass_low.
    ls_msg-detlevel =  gv_loghandle.

    CONDENSE ls_msg-msgv1 NO-GAPS.
    CONDENSE ls_msg-msgv2 NO-GAPS.
    CONDENSE ls_msg-msgv3.
    CONDENSE ls_msg-msgv4.


* add this message to log file
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_s_msg      = ls_msg
        i_log_handle = gv_loghandle
      EXCEPTIONS
        OTHERS       = 1.
    IF sy-subrc <> 0.
      MOVE-CORRESPONDING sy TO rs_exception.
      _error_on_loging( ).
    ELSE.
      _increment_message_count( ).
      IF iv_autosave EQ abap_true.
        save_to_db( ).

      ENDIF.
    ENDIF.


    CLEAR ls_msg.

* define data of message for Application Log
    ls_msg-msgty     = 'S'.
    ls_msg-msgid     = 'S06'.
    ls_msg-msgno     = '891'.
    ls_msg-msgv1     = iv_msgv1.
    ls_msg-msgv2     = iv_msgv2.
    ls_msg-msgv3     = iv_msgv3.
    ls_msg-msgv4     = iv_msgv4.
    ls_msg-probclass = gc_probclass_low.
    ls_msg-detlevel  = gv_detlevel.

    CONDENSE ls_msg-msgv1 NO-GAPS.
    CONDENSE ls_msg-msgv2 NO-GAPS.
    CONDENSE ls_msg-msgv3 NO-GAPS.
    CONDENSE ls_msg-msgv4 NO-GAPS.


* add this message to log file
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_s_msg      = ls_msg
        i_log_handle = gv_loghandle
      EXCEPTIONS
        OTHERS       = 1.
    IF sy-subrc <> 0.
      MOVE-CORRESPONDING sy TO rs_exception.
      _error_on_loging( ).
    ELSE.
      _increment_message_count( ).
      IF iv_autosave EQ abap_true.
        save_to_db( ).

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD ADD_ERRORTEXT.

    DATA: lv_msg1(50)   TYPE c,
          lv_msg2(50)   TYPE c,
          lv_msg3(50)   TYPE c,
          lv_msg4(50)   TYPE c,
          lv_temp       TYPE string ##NEEDED,
          lv_gui_active TYPE c.

    string_to_msgv( EXPORTING iv_text = iv_error_text
                    IMPORTING ev_msgv1 = lv_msg1
                              ev_msgv2 = lv_msg2
                              ev_msgv3 = lv_msg3
                              ev_msgv4 = lv_msg4 ).

    MESSAGE e899(smoiws) WITH lv_msg1 lv_msg2 lv_msg3 lv_msg4 INTO lv_temp.
    rs_exception = add_message( iv_probclass = gc_probclass_high iv_autosave = iv_autosave iv_text_detail = iv_text_detail ).

  ENDMETHOD.


  METHOD ADD_EXCEPTION.
    DATA: lv_text TYPE string,
          ls_exc  TYPE bal_s_exc.
    IF gv_batch_mode = abap_true.
      lv_text = ir_exception->get_text( ).
      WRITE: lv_text.
      NEW-LINE.
    ENDIF.
    ls_exc-detlevel = gv_detlevel.
    ls_exc-exception = ir_exception.
    ls_exc-msg_count = gv_message_count.
    ls_exc-msgty = 'E'.
    ls_exc-probclass = '4'.

    CALL FUNCTION 'BAL_LOG_EXCEPTION_ADD' "#EC CI_SROFC_NESTED
      EXPORTING
        i_log_handle = gv_loghandle
        i_s_exc      = ls_exc
* IMPORTING
*       E_S_MSG_HANDLE   =
*       E_MSG_WAS_LOGGED =
*       E_MSG_WAS_DISPLAYED       =
      EXCEPTIONS
        OTHERS       = 1.
    IF sy-subrc = 0.
      _increment_message_count( ).

      IF iv_autosave EQ abap_true.
        save_to_db( ).

      ENDIF.
    ELSE.
      MOVE-CORRESPONDING sy TO rs_exception.
      _error_on_loging( ).
    ENDIF.
  ENDMETHOD.


  METHOD ADD_MESSAGE.
    DATA: ls_msg  TYPE bal_s_msg,
          lv_temp TYPE string.

    ls_msg-detlevel  = gv_detlevel.

* define data of message for Application Log
    ls_msg-msgty     = sy-msgty.
    ls_msg-msgid     = sy-msgid.
    ls_msg-msgno     = sy-msgno.
    ls_msg-msgv1     = sy-msgv1.
    ls_msg-msgv2     = sy-msgv2.
    ls_msg-msgv3     = sy-msgv3.
    ls_msg-msgv4     = sy-msgv4.

    IF iv_probclass IS NOT SUPPLIED.
      CASE sy-msgty.
        WHEN 'A' OR 'X'. ls_msg-probclass = '1'. " Muito import.
        WHEN 'E'.        ls_msg-probclass = '2'. " Import.
        WHEN 'W'.        ls_msg-probclass = '3'. " Médio
        WHEN 'S'.        ls_msg-probclass = '4'. " Informações adicionais
        WHEN 'I'.        ls_msg-probclass = ' '. " Outros
      ENDCASE.

    ELSE.
      ls_msg-probclass = iv_probclass.

    ENDIF.

    IF gv_batch_mode = abap_true.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_temp.
      WRITE: lv_temp.
      NEW-LINE.
    ENDIF.

* add this message to log
    IF iv_text_detail IS NOT INITIAL.
*     define callback routine
      ls_msg-params-callback-userexitp = gc_callback_prog.
      ls_msg-params-callback-userexitf = gc_callback_rout.
      ls_msg-params-callback-userexitt = space.

      APPEND VALUE tp_details(
          ident  = CONV tp_details-ident( gv_ident_count + 1 )
          strdet = iv_text_detail
      ) TO gt_details.

* put his identifier into the parameters of the message
      APPEND VALUE bal_s_par(
          parname  = 'MSG_IDENT'
          parvalue = CONV tp_details-ident( gv_ident_count + 1 )
      ) TO ls_msg-params-t_par.

    ENDIF.

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_s_msg      = ls_msg
        i_log_handle = gv_loghandle
      EXCEPTIONS
        OTHERS       = 1.

    IF sy-subrc <> 0.
      MOVE-CORRESPONDING sy TO rs_exception.
      _error_on_loging( ).

    ELSE.
      _increment_message_count( ).
      IF iv_autosave EQ abap_true.
        save_to_db( ).

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD ADD_STATUSTEXT.
    DATA: lv_msg1(50) TYPE c,
          lv_msg2(50) TYPE c,
          lv_msg3(50) TYPE c,
          lv_msg4(50) TYPE c,
          lv_temp     TYPE string ##NEEDED.

    string_to_msgv( EXPORTING iv_text = iv_status_text
                   IMPORTING ev_msgv1 = lv_msg1
                             ev_msgv2 = lv_msg2
                             ev_msgv3 = lv_msg3
                             ev_msgv4 = lv_msg4 ).

    MESSAGE s899(smoiws) WITH lv_msg1 lv_msg2 lv_msg3 lv_msg4 INTO lv_temp.
    rs_exception = add_message( iv_probclass = gc_probclass_none iv_autosave = iv_autosave iv_text_detail = iv_text_detail ).

  ENDMETHOD.


  METHOD CHANGE_EXTNUMBER.

    DATA ls_log TYPE bal_s_log.

    CALL FUNCTION 'BAL_LOG_HDR_READ' "#EC CI_SROFC_NESTED
      EXPORTING
        i_log_handle  = gv_loghandle      " Log handle
      IMPORTING
        e_s_log       = ls_log            " Log header data
      EXCEPTIONS
        log_not_found = 1                 " Log not found
        OTHERS        = 2.

    IF sy-subrc NE 0.
      MOVE-CORRESPONDING sy TO rs_exception.
      _error_on_loging( ).

    ENDIF.

    ls_log-extnumber = iv_external_id.

    CALL FUNCTION 'BAL_LOG_HDR_CHANGE' "#EC CI_SROFC_NESTED
      EXPORTING
        i_log_handle            = gv_loghandle     " Log handle
        i_s_log                 = ls_log           " Log header data
      EXCEPTIONS
        log_not_found           = 1                " Log header not found
        log_header_inconsistent = 2                " Log header is inconsistent
        OTHERS                  = 3.

    IF sy-subrc NE 0.
      MOVE-CORRESPONDING sy TO rs_exception.
      _error_on_loging( ).

    ELSE.
      save_to_db( ).

    ENDIF.

  ENDMETHOD.


  METHOD CONSTRUCTOR.

    DATA: lv_days       TYPE int2,
          ls_logheader  TYPE bal_s_log,
          lt_log_header TYPE balhdr_t,
          lt_log_handle TYPE bal_t_logh,
          ls_log_filter TYPE bal_s_lfil,
          lt_msg_handle TYPE bal_t_msgh.

    IF iv_loghandle IS NOT INITIAL.
      gv_loghandle = iv_loghandle.
      gv_max_message_memory = iv_max_msg_in_mem.
      gv_logobject = iv_log_object.
      gv_log_suboject = iv_log_subobject.
      IF iv_debug_subobject IS INITIAL.
        gv_log_debug_suboject = iv_log_subobject.
      ELSE.
        gv_log_debug_suboject = iv_debug_subobject.
      ENDIF.

      ls_log_filter-log_handle = VALUE bal_r_logh( ( sign = 'I' option = 'EQ' low = gv_loghandle ) ).

      CALL FUNCTION 'BAL_GLB_SEARCH_LOG'
        EXPORTING
          i_s_log_filter = ls_log_filter
        IMPORTING
          e_t_log_handle = lt_log_handle
        EXCEPTIONS
          log_not_found  = 1                " Log not found
          OTHERS         = 2.

      IF sy-subrc NE 0.
        CALL FUNCTION 'BAL_DB_SEARCH' "#EC CI_SROFC_NESTED
          EXPORTING
            i_s_log_filter     = ls_log_filter
          IMPORTING
            e_t_log_header     = lt_log_header
          EXCEPTIONS
            log_not_found      = 1                " No log found
            no_filter_criteria = 2                " Filter criteria missing
            OTHERS             = 3.

      ENDIF.

      IF sy-subrc EQ 0.
        CALL FUNCTION 'BAL_DB_LOAD' "#EC CI_SROFC_NESTED
          EXPORTING
            i_t_log_header         = lt_log_header
            i_t_log_handle         = lt_log_handle
            i_do_not_load_messages = space
            i_lock_handling        = 2
          IMPORTING
            e_t_msg_handle         = lt_msg_handle
          EXCEPTIONS
            no_logs_specified      = 1                " No logs specified
            log_not_found          = 2                " Log not found
            log_already_loaded     = 3                " Log is already loaded
            OTHERS                 = 4.

      ELSE.
        RAISE EXCEPTION TYPE zcx_bal_exception.

      ENDIF.
    ELSE.

      IF iv_external_id IS NOT INITIAL.
        ls_logheader-extnumber = iv_external_id.
      ENDIF.

      ls_logheader-object    = iv_log_object.
      ls_logheader-subobject = iv_log_subobject.
      ls_logheader-aluser    = iv_log_username.
      ls_logheader-alprog    = iv_log_repid.
      ls_logheader-altcode   = iv_log_tcode.
      gv_max_message_memory = iv_max_msg_in_mem.
      gv_logobject = iv_log_object.
      gv_log_suboject = iv_log_subobject.
      IF iv_debug_subobject IS INITIAL.
        gv_log_debug_suboject = iv_log_subobject.
      ELSE.
        gv_log_debug_suboject = iv_debug_subobject.
      ENDIF.
*   Delete logs after the days customized in ALCCMCUST
      lv_days = iv_reorg_in_days.
      ls_logheader-aldate_del = sy-datum + lv_days.
      gv_detlevel = 1.

*   Get the log handle.
      CALL FUNCTION 'BAL_LOG_CREATE'
        EXPORTING
          i_s_log      = ls_logheader
        IMPORTING
          e_log_handle = gv_loghandle
        EXCEPTIONS
          OTHERS       = 1.

      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_bal_exception.

      ENDIF.
    ENDIF.

    gv_batch_mode  = iv_batch_mode.
    gv_ident_count = lines( lt_msg_handle ).

  ENDMETHOD.


  METHOD GET_DETLEVEL.
    rv_detlevel = gv_detlevel.
  ENDMETHOD.


  METHOD GET_HEADER_LOG.

    CALL FUNCTION 'BAL_LOG_HDR_READ'
      EXPORTING
        i_log_handle  = gv_loghandle
      IMPORTING
        e_s_log       = es_header
        e_statistics  = es_statistics
      EXCEPTIONS
        log_not_found = 1
        OTHERS        = 2.

  ENDMETHOD.


  METHOD GET_LOGHANDLE.
    rv_loghandle = gv_loghandle.
  ENDMETHOD.


  METHOD GET_LOGNUMBER.

    CHECK gv_loghandle IS NOT INITIAL.

    DO 5 TIMES.
      SELECT SINGLE lognumber
        FROM balhdr
        WHERE log_handle EQ @gv_loghandle
        INTO @rv_lognumber.

      IF sy-subrc EQ 0.
        EXIT.

      ENDIF.

      WAIT UP TO 1 SECONDS.

    ENDDO.

  ENDMETHOD.


  METHOD REFRESH.

    CALL FUNCTION 'BAL_LOG_REFRESH'
      EXPORTING
        i_log_handle  = gv_loghandle
      EXCEPTIONS
        log_not_found = 1.
    IF sy-subrc <> 0.
      MOVE-CORRESPONDING sy TO rs_exception.
      _error_on_loging( ).
    ELSE.
      gv_detlevel = 1 .
      gv_message_count = 0.
    ENDIF.
  ENDMETHOD.


  METHOD REFRESH_MESSAGES.

    CALL FUNCTION 'BAL_LOG_MSG_DELETE_ALL'
      EXPORTING
        i_log_handle  = gv_loghandle
      EXCEPTIONS
        log_not_found = 1.
    IF sy-subrc <> 0.
      MOVE-CORRESPONDING sy TO rs_exception.
      _error_on_loging( ).
    ELSE.
      gv_detlevel = 1 .
      gv_message_count = 0.
    ENDIF.
  ENDMETHOD.


  METHOD SAVE_TO_DB.

    DATA: lt_loghdl  TYPE bal_t_logh,
          lt_details TYPE tt_details.

    IF gv_loghandle IS NOT INITIAL.

      IF iv_save_all = abap_false.
        APPEND gv_loghandle TO lt_loghdl.

      ENDIF.

      IF gt_details IS NOT INITIAL.
        DATA(lv_lognumber) = get_lognumber( ).

        IF lv_lognumber IS NOT INITIAL.
          IMPORT details = lt_details
            FROM DATABASE bal_indx(al)
            ID lv_lognumber.

          APPEND LINES OF lt_details TO gt_details.
          SORT gt_details BY ident.

        ENDIF.
      ENDIF.

      CALL FUNCTION 'BAL_DB_SAVE'  "#EC CI_SROFC_NESTED
        EXPORTING                  "#EC CI_IMUD_NESTED
          i_client             = sy-mandt
          i_in_update_task     = iv_in_update_task
          i_save_all           = iv_save_all
          i_t_log_handle       = lt_loghdl
          i_2th_connection     = iv_2th_connection
          i_2th_connect_commit = iv_2th_connect_commit
          i_link2job           = iv_link2job
        IMPORTING
          e_new_lognumbers     = rt_lognumbers
        EXCEPTIONS
          OTHERS               = 1.

      IF sy-subrc <> 0.
        _error_on_loging( ).

      ELSE.
        gv_message_count = 0.

        IF gt_details IS NOT INITIAL.
          TRY.
              lv_lognumber = rt_lognumbers[ 1 ]-lognumber.

            CATCH cx_sy_itab_line_not_found.
              lv_lognumber = get_lognumber( ).

          ENDTRY.

          IF lv_lognumber IS NOT INITIAL.
            TRY.
                EXPORT details = gt_details
                   TO DATABASE bal_indx(al)
                   ID lv_lognumber.

              CATCH cx_sy_compression_error.       " Cause: More than 2 GB of data is to be exported. Runtime error: EXPORT_TOO_MUCH_DATA
              CATCH cx_sy_expimp_db_sql_error.     " Cause: SQL error in export to the database. Runtime error: DBIF_...
              CATCH cx_sy_export_buffer_no_memory. " Cause: The size of the data cluster exceeds a quarter of the total size of the associated application buffer. Runtime error: EXPORT_BUFFER_NO_MEMORY
              CATCH cx_sy_export_no_shared_memory. " Cause: Data cluster is too large for the associated application buffer. This buffer is almost completely filled. Runtime error: EXPORT_NO_SHARED_MEMORY
            ENDTRY.

            CLEAR gt_details.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD SET_DETLEVEL.
    IF iv_detlevel < 9.
      gv_detlevel = iv_detlevel.
    ENDIF.

  ENDMETHOD.


  METHOD STRING_TO_MSGV.

    DATA: lv_offset TYPE i,
          lv_temp   TYPE string,
          lv_len    TYPE i,
          lv_varnam TYPE string.

    FIELD-SYMBOLS:<fs_msg> TYPE c.

    lv_offset = 0.
    lv_len = strlen( iv_text ).

    WHILE lv_len > 0 AND sy-index <= 4 .
      lv_temp = sy-index.
      CONCATENATE 'EV_MSGV' lv_temp INTO lv_varnam.
      ASSIGN (lv_varnam) TO <fs_msg>.
      IF lv_len >= 50.
        <fs_msg> = iv_text+lv_offset(50).
      ELSE.
        <fs_msg> = iv_text+lv_offset(lv_len).
      ENDIF.
      lv_offset = lv_offset + 50.
      lv_len = lv_len - 50.
    ENDWHILE.

  ENDMETHOD.


  METHOD _ERROR_ON_LOGING.

    RAISE EVENT error_on_loging.

  ENDMETHOD.


  METHOD _INCREMENT_MESSAGE_COUNT.
    ADD 1 TO gv_ident_count.
    ADD 1 TO gv_message_count.
    IF gv_message_count >= gv_max_message_memory.
*   Store log to DB now.
      save_to_db( ).
*  Raise event the number was reached
      RAISE EVENT max_memory_limit_reached EXPORTING ev_number_of_messages = gv_message_count.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
