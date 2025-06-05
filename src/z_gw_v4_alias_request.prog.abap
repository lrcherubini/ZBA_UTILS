*&---------------------------------------------------------------------*
*& Report Z_GW_ALIAS_REQUEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_gw_v4_alias_request.

TABLES: /iwfnd/c_v4_msgr.

SELECT-OPTIONS s_serv FOR /iwfnd/c_v4_msgr-group_id OBLIGATORY.

START-OF-SELECTION.

  SELECT *
    INTO TABLE @DATA(gt_msgr)
    FROM /iwfnd/c_v4_msgr
    WHERE group_id IN @s_serv.

  IF sy-subrc NE 0.
    MESSAGE 'No data' TYPE 'E'.

  ENDIF.

  SELECT *
    INTO TABLE @DATA(gt_msgt)
    FROM /iwfnd/c_v4_msgt
    FOR ALL ENTRIES IN @gt_msgr
    WHERE group_id EQ @gt_msgr-group_id.

  SELECT *
    INTO TABLE @DATA(gt_rsag)
    FROM /iwfnd/c_v4_rsag
    FOR ALL ENTRIES IN @gt_msgr
    WHERE group_id EQ @gt_msgr-group_id.

  PERFORM transport_data USING '/IWFND/C_V4_MSGR' gt_msgr.
  PERFORM transport_data USING '/IWFND/C_V4_MSGT' gt_msgt.
  PERFORM transport_data USING '/IWFND/C_V4_RSAG' gt_rsag.

*&---------------------------------------------------------------------*
*&      Form  transport_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM transport_data USING iv_tabname TYPE ddobjname
                          it_table   TYPE STANDARD TABLE.

  DATA: ls_index    TYPE lvc_s_row.
  DATA: lt_index    TYPE lvc_t_row.
  DATA: ls_rowno    TYPE lvc_s_roid.
  DATA: lt_rowno    TYPE lvc_t_roid.
  DATA: ld_lines    LIKE sy-tabix.
  DATA: ld_start    LIKE sy-tabix.
  DATA: ld_len      LIKE sy-tabix.
  DATA: txtref      TYPE REF TO data.
  DATA: ld_answer(1).
  DATA: ld_type_error(1).
  DATA: ld_key_error(1).
  DATA: ld_max_len LIKE sy-tabix.
  DATA: typ1 TYPE c LENGTH 1.
  DATA: ld_contflag LIKE dd02l-contflag.
  DATA: ld_category LIKE e070-korrdev.

  DATA: iko200 LIKE ko200,
        iorder LIKE e070-trkorr,
        itask  LIKE e070-trkorr,
        ie071k LIKE e071k OCCURS 0 WITH HEADER LINE,
        ie071  LIKE e071 OCCURS 0 WITH HEADER LINE.

  FIELD-SYMBOLS: <txt_wa>   TYPE any,
                 <wa_trans> TYPE any,
                 <f1>.
  DATA: bit2       TYPE x VALUE '02'.
  DATA: ls_x030l   LIKE x030l.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname   = iv_tabname
    IMPORTING
      x030l_wa  = ls_x030l
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

  CHECK it_table IS NOT INITIAL.

*  DATA: tl_rows TYPE salv_t_row, "lvc_t_row,
*        wl_rows LIKE LINE OF tl_rows.
*
*  CHECK og_alv IS BOUND AND <fs_t_alv> IS ASSIGNED.
*
**..first get marked lines
*  tl_rows = og_alv->get_selections( )->get_selected_rows( ).
*
*  DESCRIBE TABLE tl_rows LINES ld_lines.
*  IF ld_lines < 1.
*    MESSAGE i105(wusl).
*    EXIT.
*  ENDIF.

*..ask customer if he really wants to transport
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = 'Transportar entradas em tabela'
      text_question  = 'Transportar entradas em tabela marcadas?'
    IMPORTING
      answer         = ld_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.

  CHECK: ld_answer = '1'.
  iko200-pgmid    = 'R3TR'.
  iko200-object   = 'TABU'.
  iko200-objfunc  = 'K'.
  iko200-obj_name = iv_tabname.

  CLEAR ie071.
  REFRESH ie071.
  ie071-pgmid    = 'R3TR'.
  ie071-object   = 'TABU'.
  ie071-obj_name = iv_tabname.
  ie071-objfunc  = 'K'.
  APPEND ie071.

  CLEAR: ld_type_error, ld_key_error.

*..Fill key fields from table <all_table_cell> into tabkey
*  LOOP AT tl_rows INTO wl_rows.
*    READ TABLE <fs_t_alv> INDEX wl_rows
*               ASSIGNING <wa_trans>.

  DATA ol_struct TYPE REF TO cl_abap_structdescr.
  ol_struct ?= cl_abap_structdescr=>describe_by_name( iv_tabname ).
  DATA(tg_fieldcat) = ol_struct->get_ddic_field_list( ).

  LOOP AT it_table ASSIGNING <wa_trans>.
    CHECK: sy-subrc = 0.
    CLEAR: ld_start, ie071k.
    LOOP AT tg_fieldcat INTO DATA(wa_fieldcat) WHERE keyflag EQ 'X'.
      ASSIGN COMPONENT wa_fieldcat-fieldname OF STRUCTURE
                       <wa_trans> TO <f1>.
*.check if field is character type -> otherwise only *-transport
      DESCRIBE FIELD <f1> TYPE typ1.
      IF typ1 NA 'CDNT'.
        ie071k-tabkey+ld_start(1) = '*'.
        ld_type_error = 'X'.
        EXIT.
      ENDIF.
*.Unicode-Change <x>
      DESCRIBE FIELD <f1> LENGTH ld_len IN CHARACTER MODE.
*.check if key is longer than C120 --> error
      ld_max_len = ld_len + ld_start.
      IF ld_max_len > 120.
        ie071k-tabkey+ld_start(1) = '*'.
        ld_key_error = 'X'.
        EXIT.
      ENDIF.
      ie071k-tabkey+ld_start(ld_len) = <f1>.
      ADD ld_len TO ld_start.
    ENDLOOP.
    ie071k-pgmid      = 'R3TR'.
    ie071k-mastertype = 'TABU'.
    ie071k-object     = 'TABU'.
    ie071k-mastername = iv_tabname.
    ie071k-objname    = iv_tabname.
    APPEND ie071k.
  ENDLOOP.

  IF ld_type_error = 'X'.
    MESSAGE i320(tk) WITH iv_tabname.
  ENDIF.
  IF ld_key_error = 'X'.
    MESSAGE i320(tk) WITH iv_tabname.
  ENDIF.

*..check category of table
  SELECT SINGLE contflag FROM dd02l INTO ld_contflag
           WHERE tabname  = iv_tabname
             AND as4local = 'A'.

  IF sy-subrc = 0 AND
     ( ld_contflag = 'C' OR ld_contflag = 'G') AND
     ls_x030l-flagbyte O bit2.
    ld_category = 'CUST'.
  ELSE.
    ld_category = 'SYST'.
  ENDIF.

  CALL FUNCTION 'TR_ORDER_CHOICE_CORRECTION'
    EXPORTING
      iv_category = ld_category
*     IV_CLI_DEP  = 'X'
    IMPORTING
      ev_order    = iorder
      ev_task     = itask
    EXCEPTIONS
      OTHERS      = 3.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
    EXPORTING
      wi_simulation         = ' '
      wi_suppress_key_check = ' '
      wi_trkorr             = itask
    TABLES
      wt_e071               = ie071
      wt_e071k              = ie071k
    EXCEPTIONS
      OTHERS                = 68.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

**..transport text table as well
*  IF NOT gd-txt_tab IS INITIAL.
*    CLEAR: ie071, ie071k.
*    REFRESH: ie071k, ie071.
*    iko200-pgmid    = 'R3TR'.
*    iko200-object   = 'TABU'.
*    iko200-objfunc  = 'K'.
*    iko200-obj_name = gd-txt_tab.
*    ie071-pgmid     = 'R3TR'.
*    ie071-object    = 'TABU'.
*    ie071-obj_name  = gd-txt_tab.
*    ie071-objfunc   = 'K'.
*    APPEND ie071.
**.....fill keyfields from text table into tabkey (create <txt_wa>,
**.....because of langu field
*    CREATE DATA txtref TYPE (gd-txt_tab).
*    ASSIGN txtref->* TO <txt_wa>.
*    LOOP AT lt_index INTO ls_index.
*      READ TABLE <all_table_cell> INDEX ls_index-index
*                 ASSIGNING <wa_trans>.
*      CHECK: sy-subrc = 0.
*      CLEAR: ld_start, ie071k.
*      LOOP AT gt_fieldcat_txttab INTO wa_fieldcat
*                       WHERE key = true.
**...........Fill language with current one
*        IF wa_fieldcat-datatype = 'LANG'.
*          ASSIGN COMPONENT wa_fieldcat-fieldname
*                           OF STRUCTURE <txt_wa> TO <f1>.
*          <f1> = sy-langu.
*        ELSE.
*          ASSIGN COMPONENT wa_fieldcat-fieldname OF STRUCTURE
*                        <wa_trans> TO <f1>.
*        ENDIF.
**.Unicode-Change <x>
*        DESCRIBE FIELD <f1> LENGTH ld_len IN CHARACTER MODE.
**.check if key is longer than C120 --> error  "Note 1982083
*        ld_max_len = ld_len + ld_start.
*        IF ld_max_len > 120.
*          ie071k-tabkey+ld_start(1) = '*'.
*          ld_key_error = 'X'.
*          EXIT.
*        ENDIF.
*        ie071k-tabkey+ld_start(ld_len) = <f1>.
*        ADD ld_len TO ld_start.
*      ENDLOOP.
*      ie071k-pgmid      = 'R3TR'.
*      ie071k-mastertype = 'TABU'.
*      ie071k-object     = 'TABU'.
*      ie071k-mastername = gd-txt_tab.
*      ie071k-objname    = gd-txt_tab.
*      APPEND ie071k.
*    ENDLOOP.
**..check category of table
*    SELECT SINGLE contflag FROM dd02l INTO ld_contflag
*          WHERE tabname  = gd-txt_tab
*            AND as4local = 'A'.
*    IF sy-subrc = 0 AND
*       ( ld_contflag = 'C' OR ld_contflag = 'G') AND
*       gd-clnt = true.
*      ld_category = 'CUST'.
*    ELSE.
*      ld_category = 'SYST'.
*    ENDIF.
*    CALL FUNCTION 'TR_ORDER_CHOICE_CORRECTION'
*      EXPORTING
*        iv_category = ld_category
**       IV_CLI_DEP  = 'X'
*      IMPORTING
*        ev_order    = iorder
*        ev_task     = itask
*      EXCEPTIONS
*        OTHERS      = 3.
*    IF sy-subrc <> 0.
*      EXIT.
*    ENDIF.
*    CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
*      EXPORTING
*        wi_simulation         = ' '
*        wi_suppress_key_check = ' '
*        wi_trkorr             = itask
*      TABLES
*        wt_e071               = ie071
*        wt_e071k              = ie071k
*      EXCEPTIONS
*        OTHERS                = 68.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*  ENDIF.

*.If everything o.k., send message
  MESSAGE s101(wusl).

ENDFORM.                    " transport_data
