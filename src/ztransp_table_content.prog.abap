*&---------------------------------------------------------------------*
*& Report ZTRANSP_TABLE_CONTENT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztransp_table_content.

*--------------------------------------------------------------------*
* Declarações
*--------------------------------------------------------------------*
DATA: tg_fieldcat TYPE lvc_t_fcat.

DATA: tg_alv TYPE REF TO data.

FIELD-SYMBOLS <fs_t_alv> TYPE STANDARD TABLE.

DATA: og_alv  TYPE REF TO cl_salv_table,
      og_grid TYPE REF TO cl_gui_alv_grid.

*--------------------------------------------------------------------*
* Tela de Seleção
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
  PARAMETERS: p_tab TYPE dd02l-tabname OBLIGATORY.
  SELECTION-SCREEN SKIP.

SELECTION-SCREEN END OF BLOCK b01.

*&---------------------------------------------------------------------*
*&  Include           Y21_SD_COMPARE_DOCSE01
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
* Prog. SALV_DEMO_TABLE_EVENTS
*---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.

ENDCLASS.                    "lcl_handle_events DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
* Prog. SALV_DEMO_TABLE_EVENTS
*---------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.
    PERFORM zf_handle_user_command USING e_salv_function.

  ENDMETHOD.                    "on_user_command

ENDCLASS.                    "lcl_handle_events IMPLEMENTATION

*--------------------------------------------------------------------*
* START-OF-SELECTION.
*--------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM zf_val_entradas.

  PERFORM zf_sel_docs.

  PERFORM zf_rel_alv.

*&---------------------------------------------------------------------*
*&      Form  ZF_VAL_ENTRADAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zf_val_entradas .

  DATA: wl_dd02l TYPE dd02l.

  SELECT SINGLE *
    INTO wl_dd02l
    FROM dd02l
    WHERE tabname  EQ p_tab
      AND as4local EQ 'A'
      AND tabclass EQ 'TRANSP'.

  IF sy-subrc NE 0.
    MESSAGE 'Nome informado não é uma tabela' TYPE 'I'.
    LEAVE LIST-PROCESSING.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZF_SEL_DOCS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zf_sel_docs .

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = p_tab
    CHANGING
      ct_fieldcat            = tg_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc NE 0.
    MESSAGE 'Erro ao gerar fieldcat' TYPE 'I'.
    LEAVE LIST-PROCESSING.

  ENDIF.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      i_style_table             = space
      it_fieldcatalog           = tg_fieldcat
*     i_length_in_byte          =
    IMPORTING
      ep_table                  = tg_alv
*     e_style_fname             =
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.

  IF sy-subrc NE 0.
    MESSAGE 'Erro ao gerar tabela dinâmica' TYPE 'I'.
    LEAVE LIST-PROCESSING.

  ENDIF.

  ASSIGN tg_alv->* TO <fs_t_alv>.

  IF <fs_t_alv> IS NOT ASSIGNED.
    MESSAGE 'Erro ao acessar tabela dinâmica' TYPE 'I'.
    LEAVE LIST-PROCESSING.

  ENDIF.

  SELECT *
    INTO TABLE <fs_t_alv>
    FROM (p_tab).

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZF_REL_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zf_rel_alv .

  CHECK <fs_t_alv> IS ASSIGNED.

  cl_salv_table=>factory( IMPORTING r_salv_table = og_alv CHANGING t_table = <fs_t_alv> ).

  PERFORM zf_layout USING og_alv.

  PERFORM zf_events USING og_alv.

  og_alv->display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZF_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zf_layout USING pu_o_alv TYPE REF TO cl_salv_table.

  DATA: wl_layout TYPE salv_s_layout_key.

  pu_o_alv->set_screen_status(
    EXPORTING
      report        = sy-repid
      pfstatus      = 'SALV_TABLE_STANDARD' ). " Prog. SAPLSALV_METADATA_STATUS

  pu_o_alv->get_functions( )->set_all( abap_on ).

  wl_layout-report = sy-repid.
  wl_layout-handle = 'ALV'.
  pu_o_alv->get_layout( )->set_key( wl_layout ).
  pu_o_alv->get_layout( )->set_save_restriction( cl_salv_layout=>restrict_none ).

  pu_o_alv->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ).

  pu_o_alv->get_columns( )->set_optimize( 'X' ).
*  pu_o_alv->get_columns( )->set_color_column( 'COLOR' ).


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZF_EVENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zf_events USING pu_o_alv TYPE REF TO cl_salv_table.

  DATA: ol_events TYPE REF TO lcl_handle_events.

  DATA: ol_salv_events TYPE REF TO cl_salv_events_table.

  ol_salv_events = pu_o_alv->get_event( ).

  CREATE OBJECT ol_events.

  SET HANDLER ol_events->on_user_command FOR ol_salv_events.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZF_HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zf_handle_user_command USING pu_salv_function TYPE salv_de_function.

  CASE pu_salv_function.
    WHEN 'TRANSPORT'.
      PERFORM transport_data.

    WHEN OTHERS.
  ENDCASE.

  CALL METHOD og_alv->refresh
    EXPORTING
      refresh_mode = if_salv_c_refresh=>full.

  og_alv->get_columns( )->set_optimize( 'X' ).

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  transport_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM transport_data.

  DATA: ls_index    TYPE lvc_s_row.
  DATA: lt_index    TYPE lvc_t_row.
  DATA: ls_rowno    TYPE lvc_s_roid.
  DATA: lt_rowno    TYPE lvc_t_roid.
  DATA: ld_lines    LIKE sy-tabix.
  DATA: ld_start    LIKE sy-tabix.
  DATA: ld_len      LIKE sy-tabix.
  DATA: wa_fieldcat TYPE lvc_s_fcat.
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
      tabname   = p_tab
    IMPORTING
      x030l_wa  = ls_x030l
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

  DATA: tl_rows TYPE salv_t_row, "lvc_t_row,
        wl_rows LIKE LINE OF tl_rows.

  CHECK og_alv IS BOUND AND <fs_t_alv> IS ASSIGNED.

*..first get marked lines
  tl_rows = og_alv->get_selections( )->get_selected_rows( ).

  DESCRIBE TABLE tl_rows LINES ld_lines.
  IF ld_lines < 1.
    MESSAGE i105(wusl).
    EXIT.
  ENDIF.

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
  iko200-obj_name = p_tab.

  CLEAR ie071.
  REFRESH ie071.
  ie071-pgmid    = 'R3TR'.
  ie071-object   = 'TABU'.
  ie071-obj_name = p_tab.
  ie071-objfunc  = 'K'.
  APPEND ie071.

  CLEAR: ld_type_error, ld_key_error.

*..Fill key fields from table <all_table_cell> into tabkey
  LOOP AT tl_rows INTO wl_rows.
    READ TABLE <fs_t_alv> INDEX wl_rows
               ASSIGNING <wa_trans>.
    CHECK: sy-subrc = 0.
    CLEAR: ld_start, ie071k.
    LOOP AT tg_fieldcat INTO wa_fieldcat WHERE key EQ 'X'.
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
    ie071k-mastername = p_tab.
    ie071k-objname    = p_tab.
    APPEND ie071k.
  ENDLOOP.

  IF ld_type_error = 'X'.
    MESSAGE i320(tk) WITH p_tab.
  ENDIF.
  IF ld_key_error = 'X'.
    MESSAGE i320(tk) WITH p_tab.
  ENDIF.

*..check category of table
  SELECT SINGLE contflag FROM dd02l INTO ld_contflag
           WHERE tabname  = p_tab
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
