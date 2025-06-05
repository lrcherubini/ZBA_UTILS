*&---------------------------------------------------------------------*
*& Report ZCOPY_STATUS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcopy_status.

TYPES: BEGIN OF tp_subobj,
         custmnr TYPE lxecustmnr,
         objtype TYPE lxeobjtype,
         objname TYPE lxeobjname,
       END OF tp_subobj.

TYPES: BEGIN OF tp_texts.
         INCLUDE TYPE tp_subobj AS subobj.
         INCLUDE TYPE lxe_pcx_s1.
       TYPES: END OF tp_texts.

TYPES: tpt_t002  TYPE STANDARD TABLE OF h_t002,
       tpt_colob TYPE STANDARD TABLE OF lxe_colob,
       tpt_texts TYPE STANDARD TABLE OF tp_texts WITH EMPTY KEY.

TYPES: BEGIN OF tp_alltxt,
         tlang TYPE sy-langu,
         tilan TYPE lxeisolang,
         texts TYPE tpt_texts,
       END OF tp_alltxt.

TYPES: tpt_alltxt TYPE STANDARD TABLE OF tp_alltxt.

DATA: tg_langs   TYPE tpt_t002,
      tg_salltxt TYPE tpt_alltxt,
      tg_talltxt TYPE tpt_alltxt,
      tg_scolob  TYPE tpt_colob,
      tg_tcolob  TYPE tpt_colob.


DATA: vg_nprog TYPE rsmpe-program,
      vg_nlang TYPE sy-langu,
      vg_nilan TYPE lxeisolang,
      vg_nstat TYPE rsmpe-status.

PARAMETERS: p_prog TYPE rsmpe-program OBLIGATORY DEFAULT 'SAPLSALV_METADATA_STATUS',
            p_stat TYPE rsmpe-status OBLIGATORY DEFAULT 'SALV_TABLE_STANDARD'.

START-OF-SELECTION.

  CLEAR: tg_scolob,
         tg_tcolob,
         tg_langs,
         tg_salltxt,
         tg_talltxt,
         vg_nprog,
         vg_nlang,
         vg_nilan,
         vg_nstat.

  PERFORM zf_copy_status.
  PERFORM zf_get_languages CHANGING tg_langs.
  PERFORM zf_pre_select USING vg_nprog CHANGING vg_nlang vg_nilan tg_tcolob.

  DELETE tg_langs WHERE spras EQ vg_nlang.

  PERFORM zf_pre_select USING p_prog CHANGING vg_nlang vg_nilan tg_scolob.

  PERFORM zf_translation.

*&---------------------------------------------------------------------*
*&      Form  ZF_COPY_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zf_copy_status .

  CALL FUNCTION 'RS_CUA_COPY_STA'
    EXPORTING
      im_program              = p_prog
      im_status               = p_stat
    IMPORTING
      cobjectname             = vg_nstat
      s_status                = p_stat
      cprogram                = vg_nprog
      s_program               = p_prog
    EXCEPTIONS
      not_executed            = 1
      insufficient_parameters = 2
      unknown_version         = 3
      s_program_not_found     = 4
      t_program_not_found     = 5
      s_status_not_found      = 6
      t_status_found          = 7
      wrong_program_type      = 8
      invalid_status_name     = 9
      permission_failure      = 10
      generation_failure      = 11
      OTHERS                  = 12.

  IF sy-subrc NE 0.
    MESSAGE i419(ec).
    LEAVE LIST-PROCESSING.

  ENDIF.

  CALL FUNCTION 'RS_TOOL_ACCESS'
    EXPORTING
      operation           = 'ACTIVATE'
      object_name         = vg_nprog
      enclosing_object    = vg_nprog
      object_type         = 'CUAD'
    EXCEPTIONS
      not_executed        = 1
      invalid_object_type = 2
      OTHERS              = 3.

  IF sy-subrc NE 0.
    MESSAGE ID     sy-msgid
            TYPE   'I'
            NUMBER sy-msgno
            WITH   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    LEAVE LIST-PROCESSING.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ZF_PRE_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zf_pre_select USING pu_prog  TYPE rsmpe-program
                CHANGING pc_nlang TYPE sy-langu
                         pc_nilan TYPE lxeisolang
                         pc_colob TYPE tpt_colob.

  DATA: wl_trkey TYPE trkey,
        tl_e071  TYPE TABLE OF e071,
        wl_e071  LIKE LINE OF tl_e071,
        tl_e071k TYPE TABLE OF e071k,
        wl_langs LIKE LINE OF tg_langs.

  DATA: vl_mlang TYPE sy-langu,
        vl_milan TYPE lxeisolang.

  REFRESH pc_colob.

  SELECT COUNT(*)
    FROM progdir
    WHERE name  EQ pu_prog
      AND state EQ 'A'.

  IF sy-subrc NE 0.
    MESSAGE i398(00) WITH 'Report not found'.
    LEAVE LIST-PROCESSING.

  ENDIF.

  CALL FUNCTION 'RS_CORR_CHECK'
    EXPORTING
      object          = pu_prog
      object_class    = 'SCUA'
      suppress_dialog = 'X'
    IMPORTING
      transport_key   = wl_trkey
      master_language = vl_mlang
    EXCEPTIONS
      OTHERS          = 0.

  IF pc_nlang IS INITIAL.
    pc_nlang = vl_mlang.

    CALL FUNCTION 'LXE_T002_CHECK_LANGUAGE'
      EXPORTING
        r3_lang            = pc_nlang
      IMPORTING
        o_language         = pc_nilan
      EXCEPTIONS
        language_not_in_cp = 1
        unknown            = 2
        OTHERS             = 3.

    IF sy-subrc NE 0.
      MESSAGE i398(00) WITH 'Invalid language (tab. T002)' pc_nlang.
      LEAVE LIST-PROCESSING.

    ENDIF.
  ENDIF.

  wl_trkey-sub_type = 'CUAD'.

  IF wl_trkey-sub_type IS INITIAL. " tkey - E071
    wl_e071-object   = wl_trkey-obj_type.
    wl_e071-obj_name = wl_trkey-obj_name.
    wl_e071-pgmid    = 'R3TR'.

  ELSE.
    wl_e071-object   = wl_trkey-sub_type.
    wl_e071-obj_name = wl_trkey-sub_name.
    wl_e071-pgmid    = 'LIMU'.

  ENDIF.

  APPEND wl_e071 TO tl_e071.

  CALL FUNCTION 'LXE_OBJ_EXPAND_TRANSPORT'
    TABLES
      in_e071  = tl_e071
      in_e071k = tl_e071k
      ex_colob = pc_colob.

  IF pc_colob IS INITIAL.
    MESSAGE i398(00) WITH `There aren't texts to be translated`.
    LEAVE LIST-PROCESSING.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZF_GET_LANGUAGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zf_get_languages CHANGING pc_t_langs TYPE tpt_t002.

  DATA: wl_langs   LIKE LINE OF pc_t_langs,
        wl_t002t   TYPE t002t,
        vl_allowed TYPE scplangss,
        vl_cplang  TYPE t002t-sprsl,
        vl_strlen  TYPE i,
        vl_offset  TYPE i.

  REFRESH pc_t_langs.

  CALL FUNCTION 'SCP_ALLOWED_LANGUAGES'
    IMPORTING
      languages = vl_allowed.

  CHECK vl_allowed IS NOT INITIAL.

  vl_strlen = strlen( vl_allowed ).

  CLEAR: vl_offset.

  WHILE ( vl_offset LT vl_strlen ).
    MOVE vl_allowed+vl_offset(1) TO vl_cplang.

    CLEAR wl_t002t.

    SELECT SINGLE *
      INTO wl_t002t
      FROM t002t
      WHERE spras EQ sy-langu
        AND sprsl EQ vl_cplang.

    IF sy-subrc EQ 0.
      MOVE : wl_t002t-sprsl TO wl_langs-spras,
             wl_t002t-sptxt TO wl_langs-sptxt.

      APPEND wl_langs TO pc_t_langs.

    ENDIF.

    ADD 1 TO vl_offset.

  ENDWHILE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZF_PROCESS_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zf_process_read USING pu_slang    TYPE sy-langu
                           pu_silan    TYPE lxeisolang
                           pu_colob    TYPE lxe_colob
                           pu_w_langs  LIKE LINE OF tg_langs
                  CHANGING pc_w_alltxt TYPE LINE OF tpt_alltxt
                           pc_t_alltxt TYPE tpt_alltxt.

  DATA: "tl_colob TYPE tpt_colob,
*        wl_colob LIKE LINE OF tl_colob,
    tl_textx TYPE TABLE OF lxe_pcx_s1,
    wl_textx LIKE LINE OF tl_textx,
    wl_wrkob TYPE lxe_wrkob.

  DATA: wl_texts  LIKE LINE OF pc_w_alltxt-texts.

  DATA: tl_props  TYPE TABLE OF lxe_pcx_s2,
        tl_where  TYPE TABLE OF rsdswhere,
        vl_status TYPE c.

  DATA: vl_tilan TYPE lxeisolang.

  CALL FUNCTION 'LXE_T002_CHECK_LANGUAGE'
    EXPORTING
      r3_lang            = pu_w_langs-spras
    IMPORTING
      o_language         = vl_tilan
    EXCEPTIONS
      language_not_in_cp = 1
      unknown            = 2
      OTHERS             = 3.

  IF sy-subrc NE 0.
    MESSAGE i398(00) WITH 'Invalid language (tab. T002)' pu_w_langs-spras.
    EXIT.

  ENDIF.

  CLEAR pc_w_alltxt.
  pc_w_alltxt-tlang = pu_w_langs-spras.
  pc_w_alltxt-tilan = vl_tilan.

*  tl_colob[] = pu_colob[].
*  DELETE tl_colob WHERE objtype CS 'CAD'.

  REFRESH: tl_props,
           tl_where.

  CLEAR: wl_wrkob,
         vl_status.

*  LOOP AT tl_colob INTO wl_colob.

  CLEAR wl_wrkob.
  REFRESH tl_textx.

  CALL FUNCTION 'LXE_OBJ_CONVERT_OL_WLB'
    EXPORTING
      in_custmnr = pu_colob-custmnr
      in_objtype = pu_colob-objtype
      in_objname = pu_colob-objname
    IMPORTING
      custmnr    = wl_wrkob-custmnr
      objtype    = wl_wrkob-objtype
      objname    = wl_wrkob-objname.

  wl_wrkob-targ_lang = pu_w_langs-spras.
  wl_wrkob-domatyp   = pu_colob-domatyp.
  wl_wrkob-domanam   = pu_colob-domanam.
  wl_wrkob-colltyp   = pu_colob-colltyp.
  wl_wrkob-collnam   = pu_colob-collnam.
  wl_wrkob-orig_lang = pu_colob-orig_lang.
  wl_wrkob-sour_lang = pu_slang.

  CALL FUNCTION 'LXE_OBJ_TRANSLATION_STATUS2'
    EXPORTING
      t_lang  = vl_tilan
      s_lang  = pu_silan
      custmnr = wl_wrkob-custmnr
      objtype = wl_wrkob-objtype
      objname = wl_wrkob-objname
    IMPORTING
      stattrn = wl_wrkob-stattrn
      cnttot  = wl_wrkob-cnttot
      cntnew  = wl_wrkob-cntnew
      cntmod  = wl_wrkob-cntmod
      cntavl  = wl_wrkob-cntavl.

  IF wl_wrkob-cnttot GT 0.
    CALL FUNCTION 'LXE_OBJ_TEXT_PAIR_READ'
      EXPORTING
        t_lang        = vl_tilan
        s_lang        = pu_silan
        custmnr       = wl_wrkob-custmnr
        objtype       = wl_wrkob-objtype
        objname       = wl_wrkob-objname
*       limit         = sel_limit_for_tables
        read_only     = space
      IMPORTING
        pstatus       = vl_status
        colltyp       = wl_wrkob-colltyp
        collnam       = wl_wrkob-collnam
        domatyp       = wl_wrkob-domatyp
        domanam       = wl_wrkob-domanam
      TABLES
        lt_pcx_s1     = tl_textx
        lt_whereclaus = tl_where.

    IF tl_textx IS INITIAL.
      MESSAGE i398(00) WITH `There aren't texts to be translated` pu_w_langs-spras.
      EXIT.

    ENDIF.

    CALL FUNCTION 'LXE_PP1_PROPOSALS_GET'
      EXPORTING
        t_lang   = vl_tilan
        s_lang   = pu_silan
        custmnr  = wl_wrkob-custmnr
        objtype  = wl_wrkob-objtype
        domatyp  = wl_wrkob-domatyp
        domanam  = wl_wrkob-domanam
      IMPORTING
        pstatus  = vl_status
      TABLES
        t_pcx_s1 = tl_textx
        t_pcx_s2 = tl_props.

    LOOP AT tl_textx INTO wl_textx.
      CLEAR wl_texts.

      MOVE-CORRESPONDING wl_textx TO wl_texts.
      MOVE-CORRESPONDING wl_wrkob TO wl_texts.

      APPEND wl_texts TO pc_w_alltxt-texts.

    ENDLOOP.
  ENDIF.
*  ENDLOOP.

  APPEND pc_w_alltxt TO pc_t_alltxt.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZF_PROCESS_WRITE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zf_process_write USING pu_w_salltxt LIKE LINE OF tg_salltxt
                   CHANGING pc_w_talltxt LIKE LINE OF tg_talltxt.

  DATA: wl_stext   LIKE LINE OF pu_w_salltxt-texts,
        tl_textx   TYPE TABLE OF lxe_pcx_s1,
        wl_textx   LIKE LINE OF tl_textx,
        wl_subobjx TYPE tp_subobj.

  DATA: vl_objtype  LIKE wl_stext-objtype,
        vl_objtypex LIKE wl_stext-objtype,
        vl_tlen     TYPE i,
        vl_slen     TYPE i.

  FIELD-SYMBOLS: <fl_w_texts> LIKE LINE OF pc_w_talltxt-texts.

  CHECK pu_w_salltxt-texts IS NOT INITIAL.

  REFRESH tl_textx.
  CLEAR: vl_objtype,
         vl_objtypex.

  LOOP AT pc_w_talltxt-texts ASSIGNING <fl_w_texts>.

    vl_tlen = strlen( <fl_w_texts>-objtype ) - 1.
    vl_objtype = <fl_w_texts>-objtype(vl_tlen).

    IF vl_objtypex IS NOT INITIAL AND vl_objtypex NE vl_objtype.
      PERFORM zf_write_transl USING vg_nilan pc_w_talltxt-tilan wl_subobjx tl_textx.

      REFRESH tl_textx.

    ENDIF.

    vl_objtypex = vl_objtype.
    wl_subobjx = <fl_w_texts>-subobj.

    CLEAR wl_stext.
    LOOP AT pu_w_salltxt-texts INTO wl_stext WHERE s_text EQ <fl_w_texts>-s_text.

      vl_slen = strlen( wl_stext-objtype ) - 1.

      IF wl_stext-objtype(vl_slen) NE vl_objtype.
        CLEAR wl_stext.

      ELSE.
        EXIT.

      ENDIF.
    ENDLOOP.

    IF wl_stext-t_text IS NOT INITIAL.
      <fl_w_texts>-t_text = wl_stext-t_text.

    ENDIF.

    CLEAR wl_textx.
    MOVE-CORRESPONDING <fl_w_texts> TO wl_textx.
    APPEND wl_textx TO tl_textx.

  ENDLOOP.

  PERFORM zf_write_transl USING vg_nilan pc_w_talltxt-tilan wl_subobjx tl_textx.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZF_WRITE_TRANSL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zf_write_transl USING pu_silan   TYPE lxeisolang
                           pu_tilan   TYPE lxeisolang
                           pu_subobj  TYPE tp_subobj
                           pu_t_texts TYPE lxe_tt_pcx_s1.

  DATA: vl_pstatus TYPE lxestatprc,
        vl_err_msg TYPE lxestring.

  CALL FUNCTION 'LXE_OBJ_TEXT_PAIR_WRITE'
    EXPORTING
      t_lang    = pu_tilan                 " ISO Language ID
      s_lang    = pu_silan                 " ISO Language ID
      custmnr   = pu_subobj-custmnr        " Customer Number
      objtype   = pu_subobj-objtype        " Type of Translation Object
      objname   = pu_subobj-objname        " Name of Translation Object
*     autodist  =
*     rfc_copy  =
    IMPORTING
      pstatus   = vl_pstatus               " Process Status
      err_msg   = vl_err_msg
    TABLES
      lt_pcx_s1 = pu_t_texts.              " Text Pairs

  CASE vl_pstatus.
    WHEN 'S'. " Successful
      vl_err_msg = |Successful { pu_tilan }. { vl_err_msg }|.

    WHEN 'F'. " Incorrect
      vl_err_msg = |Incorrect { pu_tilan }. { vl_err_msg }|.

    WHEN 'D'. " Deleted
      vl_err_msg = |Deleted { pu_tilan }. { vl_err_msg }|.

    WHEN 'A'. " Canceled
      vl_err_msg = |Canceled { pu_tilan }. { vl_err_msg }|.

    WHEN OTHERS.
  ENDCASE.

  MESSAGE i398(00) WITH vl_err_msg.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZF_TRANSLATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zf_translation .

  DATA: wl_langs   LIKE LINE OF tg_langs,
        wl_salltxt LIKE LINE OF tg_salltxt,
        wl_talltxt LIKE LINE OF tg_talltxt,
        wl_scolob  LIKE LINE OF tg_scolob,
        wl_tcolob  LIKE LINE OF tg_tcolob.

  DATA: vl_strln TYPE i.

  REFRESH: tg_salltxt,
           tg_talltxt.

  LOOP AT tg_langs INTO wl_langs.

    LOOP AT tg_scolob INTO wl_scolob.

      vl_strln = strlen( wl_scolob-objtype ) - 1.

      LOOP AT tg_tcolob INTO wl_tcolob.
        IF strlen( wl_scolob-objtype ) EQ strlen( wl_tcolob-objtype ) AND
           wl_scolob-objtype(vl_strln) EQ wl_tcolob-objtype(vl_strln).

          CLEAR: wl_salltxt,
                 wl_talltxt.

          PERFORM zf_process_read USING vg_nlang vg_nilan wl_scolob wl_langs
                               CHANGING wl_salltxt tg_salltxt.

          CHECK wl_salltxt IS NOT INITIAL.

          PERFORM zf_process_read USING vg_nlang vg_nilan wl_tcolob wl_langs
                               CHANGING wl_talltxt tg_talltxt.

          CHECK wl_talltxt IS NOT INITIAL.

          PERFORM zf_process_write USING wl_salltxt wl_talltxt.

          EXIT.

        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

  IF tg_talltxt IS INITIAL.
    MESSAGE i398(00) WITH 'Action aborted'.
    LEAVE LIST-PROCESSING.

  ENDIF.

ENDFORM.
