CLASS zcl_ba_util DEFINITION

  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF tp_constants,
        fieldname TYPE fieldname,
        value     TYPE string,
      END OF tp_constants .
    TYPES:
      tt_constants TYPE STANDARD TABLE OF tp_constants WITH EMPTY KEY .
    TYPES:
      BEGIN OF tp_components,
        fieldname TYPE fieldname,
      END OF tp_components .
    TYPES:
      tt_components TYPE STANDARD TABLE OF tp_components .
    TYPES:
      BEGIN OF tp_msgv,
        msgv1 TYPE symsgv,
        msgv2 TYPE symsgv,
        msgv3 TYPE symsgv,
        msgv4 TYPE symsgv,
      END OF tp_msgv .
    TYPES:
      tt_msgv TYPE STANDARD TABLE OF tp_msgv WITH EMPTY KEY .
    TYPES:
      BEGIN OF tp_rsc_price,
        net_price  TYPE bapicurext,
        price_unit TYPE epein,
      END OF tp_rsc_price .
    TYPES:
      BEGIN OF tp_attachs,
        obj_type   TYPE sofolenti1-obj_type,
        obj_descr  TYPE sofolenti1-obj_descr,
        filename   TYPE rlgrap-filename,
        intformat  TYPE char10,
        chang_date TYPE sofolenti1-chang_date,
        chang_time TYPE sofolenti1-chang_time,
        doc_size   TYPE sofolenti1-doc_size,
        cont_hex   TYPE solix_tab,
        buf_hex    TYPE xstring,
        base64     TYPE string,
        mimetype   TYPE mimetypes-type,
      END OF tp_attachs .
    TYPES:
      tt_attachs TYPE STANDARD TABLE OF tp_attachs WITH EMPTY KEY .

    CONSTANTS gc_msg_error TYPE sy-msgty VALUE 'E' ##NO_TEXT.
    CONSTANTS gc_msgid_gen TYPE sy-msgid VALUE '00' ##NO_TEXT.
    CONSTANTS gc_msgno_gen TYPE sy-msgno VALUE '398' ##NO_TEXT.

    CLASS-METHODS conv_param_to_selopt
      IMPORTING
        !iv_parameter    TYPE string
      RETURNING
        VALUE(rs_selopt) TYPE rsdsselopt .
    CLASS-METHODS get_param_value
      IMPORTING
        !iv_mod  TYPE /pgtpa/param_par-modulo
        !iv_par1 TYPE /pgtpa/param_par-param1
        !iv_par2 TYPE /pgtpa/param_par-param2 OPTIONAL
        !iv_par3 TYPE /pgtpa/param_par-param3 OPTIONAL
        !iv_par4 TYPE /pgtpa/param_par-param4 OPTIONAL
        !iv_par5 TYPE /pgtpa/param_par-param5 OPTIONAL
      EXPORTING
        !ev_data TYPE clike .
    CLASS-METHODS get_param_range
      IMPORTING
        !iv_mod  TYPE /pgtpa/param_par-modulo
        !iv_par1 TYPE /pgtpa/param_par-param1
        !iv_par2 TYPE /pgtpa/param_par-param2 OPTIONAL
        !iv_par3 TYPE /pgtpa/param_par-param3 OPTIONAL
        !iv_par4 TYPE /pgtpa/param_par-param4 OPTIONAL
        !iv_par5 TYPE /pgtpa/param_par-param5 OPTIONAL
      EXPORTING
        !et_data TYPE STANDARD TABLE .
    CLASS-METHODS conv_selopt_to_whereclause
      IMPORTING
        !it_selopt      TYPE ddshselops
      RETURNING
        VALUE(rv_where) TYPE string .
    CLASS-METHODS split_text_2_tline
      IMPORTING
        !iv_text        TYPE clike
      RETURNING
        VALUE(rt_tline) TYPE text_lines .
    CLASS-METHODS split_text_2_msg
      IMPORTING
        !iv_text       TYPE clike
      RETURNING
        VALUE(rt_msgv) TYPE tt_msgv .
    CLASS-METHODS conv_ttline_to_string
      IMPORTING
        !it_tline        TYPE tline_t
      RETURNING
        VALUE(rv_string) TYPE string .
    CLASS-METHODS get_bapiret2
      IMPORTING
        !iv_type         TYPE bapireturn-type
        !iv_cl           TYPE sy-msgid DEFAULT '00'
        !iv_number       TYPE sy-msgno DEFAULT '398'
        !iv_par1         TYPE any OPTIONAL
        !iv_par2         TYPE any OPTIONAL
        !iv_par3         TYPE any OPTIONAL
        !iv_par4         TYPE any OPTIONAL
        !iv_log_no       TYPE bapireturn-log_no DEFAULT space
        !iv_log_msg_no   TYPE bapireturn-log_msg_no DEFAULT 0
        !iv_parameter    TYPE bapiret2-parameter DEFAULT space
        !iv_row          TYPE bapiret2-row DEFAULT 0
        !iv_field        TYPE bapiret2-field DEFAULT space
      RETURNING
        VALUE(rs_return) TYPE bapiret2 .
    CLASS-METHODS get_error_proxy
      IMPORTING
        !io_proxy        TYPE REF TO if_proxy_basis
      RETURNING
        VALUE(rt_return) TYPE bapiret2_tt
      RAISING
        cx_ai_system_fault
        cx_xms_syserr_persist .
    CLASS-METHODS get_attach_doc
      IMPORTING
        !iv_obj_name        TYPE oj_name
        !iv_id_doc          TYPE sibfboriid
      EXPORTING
        VALUE(rv_xstring)   TYPE xstring
        VALUE(ev_file_name) TYPE string
      RETURNING
        VALUE(rv_string)    TYPE string .
    CLASS-METHODS set_return
      IMPORTING
        !iv_type         TYPE bapireturn-type
        !iv_cl           TYPE sy-msgid DEFAULT '00'
        !iv_number       TYPE sy-msgno DEFAULT '398'
        !iv_par1         TYPE any OPTIONAL
        !iv_par2         TYPE any OPTIONAL
        !iv_par3         TYPE any OPTIONAL
        !iv_par4         TYPE any OPTIONAL
        !iv_log_no       TYPE bapireturn-log_no DEFAULT space
        !iv_log_msg_no   TYPE bapireturn-log_msg_no DEFAULT 0
        !iv_parameter    TYPE bapiret2-parameter DEFAULT space
        !iv_row          TYPE bapiret2-row DEFAULT 0
        !iv_field        TYPE bapiret2-field DEFAULT space
      RETURNING
        VALUE(rs_return) TYPE bapiret2 .
    CLASS-METHODS set_bapi_x
      IMPORTING
        !is_bapi      TYPE any
        !it_blanks    TYPE tt_components OPTIONAL
        !it_constants TYPE tt_constants OPTIONAL
      EXPORTING
        !es_bapix     TYPE any .
    CLASS-METHODS exists_attach_doc
      IMPORTING
        !iv_obj_name        TYPE oj_name
        !iv_id_doc          TYPE sibfboriid
      EXPORTING
        VALUE(ev_file_name) TYPE string
      RETURNING
        VALUE(rv_exists)    TYPE flag .
    CLASS-METHODS conv_isodatetime
      IMPORTING
        !iv_iso8601        TYPE csequence
      RETURNING
        VALUE(rv_datetime) TYPE ada_rtime .
    CLASS-METHODS rescale_dec_to_curr
      IMPORTING
        !iv_val         TYPE dec31_14
      RETURNING
        VALUE(rs_price) TYPE tp_rsc_price .
    CLASS-METHODS get_bapiret2_exc
      IMPORTING
        !io_exception     TYPE REF TO cx_root
        !iv_from_previous TYPE abap_bool DEFAULT abap_false
        !iv_msg_type      TYPE sy-msgty OPTIONAL
      RETURNING
        VALUE(rs_return)  TYPE bapiret2 .
    CLASS-METHODS conv_tstmp2syst
      IMPORTING
        !iv_tmsp           TYPE csequence
      RETURNING
        VALUE(rs_datetime) TYPE ada_rtime .
    CLASS-METHODS get_attach_docs
      IMPORTING
        !iv_obj_name      TYPE oj_name
        !iv_id_doc        TYPE sibfboriid
      RETURNING
        VALUE(rt_attachs) TYPE tt_attachs
      RAISING
        cx_obl_parameter_error
        cx_obl_internal_error
        cx_obl_model_error.
    CLASS-METHODS get_stvarv_range
      IMPORTING
        !iv_name TYPE tvarvc-name
      EXPORTING
        !et_data TYPE STANDARD TABLE .
    CLASS-METHODS popup_conf
      IMPORTING
        !iv_title        TYPE csequence DEFAULT 'Confirmation'
        !iv_text         TYPE csequence
        !iv_textbut1     TYPE csequence DEFAULT 'Yes'
        !iv_iconbut1     TYPE icon_name DEFAULT 'ICON_OKAY'
        !iv_textbut2     TYPE csequence DEFAULT 'No'
        !iv_iconbut2     TYPE icon_name DEFAULT 'ICON_CANCEL'
        !iv_default      TYPE char1 DEFAULT '2'
        !iv_cancbut      TYPE xfeld DEFAULT space
        !iv_popuptyp     TYPE icon_name DEFAULT 'ICON_MESSAGE_QUESTION'
      RETURNING
        VALUE(rv_answer) TYPE char1 .
    CLASS-METHODS get_stvarv_value
      IMPORTING
        !iv_name TYPE tvarvc-name
      EXPORTING
        !ev_data TYPE simple .
    CLASS-METHODS check_stvarv_value
      IMPORTING
        !iv_name       TYPE tvarvc-name
        !iv_data       TYPE simple
      RETURNING
        VALUE(rv_bool) TYPE abap_boolean .
    CLASS-METHODS check_stvarv_range
      IMPORTING
        !iv_name       TYPE tvarvc-name
        !iv_data       TYPE simple
        !iv_no_empty   TYPE flag DEFAULT 'X'
      RETURNING
        VALUE(rv_bool) TYPE abap_boolean .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS double_hyphen
      CHANGING
        !cv_val TYPE rsdsselop_ .
    CLASS-METHODS get_dboperator
      IMPORTING
        !iv_option   TYPE tvarv_opti
        !iv_negate   TYPE flag DEFAULT space
      RETURNING
        VALUE(rv_op) TYPE string .

ENDCLASS.



CLASS zcl_ba_util IMPLEMENTATION.

* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>CONV_PARAM_TO_SELOPT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_PARAMETER                   TYPE        STRING
* | [<-()] RS_SELOPT                      TYPE        RSDSSELOPT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD conv_param_to_selopt.
    rs_selopt = VALUE
rsdsselopt(
sign   = 'I'
option = 'EQ'
low    = iv_parameter
).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>GET_PARAM_RANGE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_MOD                         TYPE        /PGTPA/PARAM_PAR-MODULO
* | [--->] IV_PAR1                        TYPE        /PGTPA/PARAM_PAR-PARAM1
* | [--->] IV_PAR2                        TYPE        /PGTPA/PARAM_PAR-PARAM2(optional)
* | [--->] IV_PAR3                        TYPE        /PGTPA/PARAM_PAR-PARAM3(optional)
* | [--->] IV_PAR4                        TYPE        /PGTPA/PARAM_PAR-PARAM4(optional)
* | [--->] IV_PAR5                        TYPE        /PGTPA/PARAM_PAR-PARAM5(optional)
* | [<---] ET_DATA                        TYPE        STANDARD TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_param_range.

    CALL FUNCTION '/PGTPA/PARAM_BUSCA_VALORES'
      EXPORTING
        i_modulo            = iv_mod             " Módulo
        i_param1            = iv_par1            " Parâmetro 1
        i_param2            = iv_par2            " Parâmetro 2
        i_param3            = iv_par3            " Parâmetro 3
        i_param4            = iv_par4            " Parâmetro 4
        i_param5            = iv_par5            " Parâmetro 5
      TABLES
        t_range             = et_data            " Retorno de range
      EXCEPTIONS
        nao_encontrado      = 1                  " Valores não encontrados
        range_nao_informado = 2                  " Range não informado
        OTHERS              = 3.

    LOOP AT et_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      ASSIGN COMPONENT 'SIGN' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_field>).

      IF sy-subrc EQ 0 AND <fs_field> IS INITIAL.
        <fs_field> = 'I'.

      ENDIF.

      ASSIGN COMPONENT 'OPTION' OF STRUCTURE <fs_data> TO <fs_field>.

      IF sy-subrc EQ 0 AND <fs_field> IS INITIAL.
        ASSIGN COMPONENT 'HIGH' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_high>).

        IF sy-subrc EQ 0.
          IF <fs_high> IS INITIAL.
            <fs_field> = 'EQ'.

          ELSE.
            <fs_field> = 'BT'.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>CONV_SELOPT_TO_WHERECLAUSE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_SELOPT                      TYPE        DDSHSELOPS
* | [<-()] RV_WHERE                       TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD conv_selopt_to_whereclause.

* Hilfsstrings
    DATA: lv_concat(3),
          lv_fname     TYPE string,
          lv_op        TYPE string,                      "NOT BETWEEN ist wohl das längste
          lv_low(72), lv_high(72).
    DATA: lv_str TYPE string.
    DATA  lv_escape.
    FIELD-SYMBOLS: <fs_str> TYPE any.
    DATA lv_last_shlpname TYPE ddshselopt-shlpname.
    DATA lv_last_shlpfield TYPE ddshselopt-shlpfield.
    DATA lv_last_sign TYPE ddshselopt-sign.
    DATA lv_len TYPE i.

    DATA(lt_selopt) = it_selopt.
* Berechnung der WHERE-Bedingung
    SORT lt_selopt BY shlpname shlpfield sign DESCENDING.

    LOOP AT lt_selopt INTO DATA(ls_selopt).
      CLEAR: lv_concat, lv_fname, lv_op, lv_low, lv_high.
*   Für jedes Feld gibt es einen geklammerten Block für die
*   Include-Bedingungen und einen Block für die Exclude-Bedingungen.
*   Die Include-Bedingungen werden mit OR verknüpft.
*   Die Exclude-Bedingungen könnten ebenfalls OR-verknüpft werden,
*   wenn insgesamt ein NOT vorangestellt wird.
*   Im ABAP werden aber solche Selektionsbedingungen gemäß
*   NOT ( A OR B OR C) = NOT A AND NOT B AND NOT C umgewandelt.
*   Das NOT wird außerdem nach Möglichkeit mit in den Ausdruck
*   hineingezogen. (z.B.: NOT ( Feld = 'ABC') wird zu (Feld <> 'ABC').
*   Da die Datenbank meist mit AND-Bedingungen besser zurecht kommt,
*   wird diese Umwandlung hier ebenfalls vorgenommen.
      IF sy-tabix = 1.
        rv_where = '('.
      ELSEIF ls_selopt-shlpname = lv_last_shlpname AND
             ls_selopt-shlpfield = lv_last_shlpfield AND
             ls_selopt-sign = lv_last_sign.
        IF ls_selopt-sign = 'I'.
          lv_concat = 'OR'.
        ELSE.
          lv_concat = 'AND'.
        ENDIF.
      ELSE.                              "Feld- oder Incl/Excl-Wechsel
        lv_str = ') AND ('.
        CONCATENATE rv_where lv_str INTO rv_where SEPARATED BY ' '.
      ENDIF.
      lv_fname = ls_selopt-shlpfield.
      CONDENSE lv_fname NO-GAPS.
*      IF gen_alias_names = 'X'.
*        CONCATENATE ls_selopt-shlpname '~' lv_fname INTO lv_fname.
*      ENDIF.
* Ersetzen der Operatornamen
      IF ls_selopt-sign = 'I'.
        lv_op = get_dboperator( iv_option = ls_selopt-option iv_negate = ' ' ).
      ELSE.                              "Mit Negation des Operators
        lv_op = get_dboperator( iv_option = ls_selopt-option iv_negate = 'X' ).
      ENDIF.
*   Wenn Hochkommas enthalten sind, müssen diese verdoppelt werden.
      double_hyphen( CHANGING cv_val = ls_selopt-low ).
      lv_low = ls_selopt-low.
*      CONCATENATE '''' ls_selopt-low '''' INTO lv_low.
* Bei CP-Selektion die Wildcards ersetzen. Unter Umständen muß mit
*  lv_escape gearbeitet werden.
*  lv_escape ist allerdings bei Pooltabellen nicht unterstützt.
      IF ls_selopt-option = 'CP' OR ls_selopt-option = 'NP'.
*     Zuvor bereits übergebene % und _ werden maskiert.
*     * und + werden dann auf % und _ abgebildet.
*     Allerdings können auch die schon mit # maskiert sein.
*     Daraus folgt folgender Abbildungsvorschrift:
*     %  -> #%
*     _  -> #_
*     ## -> #
*     #* -> *
*     #+ -> +
*     *  -> %
*     +  -> _
        ASSIGN lv_low TO <fs_str>.
*-    Kommt ein '%' oder ein '_' vor? In dem Fall muessten wir
*     maskieren. Das ist wichtig zu wissen fuer das Vorkommen von '#'
*        IF <fs_str> CA '%_' AND  lv_escape_allowed = 'X'.
*           lv_escape = 'X'.
*        ENDIF.

        WHILE <fs_str> CA '#*+%_'.                       "#EC CI_NESTED
          ASSIGN <fs_str>+sy-fdpos(*) TO <fs_str>.
          IF <fs_str>(1) CA '%_' AND  lv_escape = 'X'.
            lv_len = strlen( lv_low ).
            IF lv_len < 72.
              SHIFT <fs_str> RIGHT BY 1 PLACES.
              <fs_str>(1) = '#'.
              ASSIGN <fs_str>+1(*) TO <fs_str>.
            ENDIF.
          ELSEIF <fs_str>(1) = '#'.
            lv_len = strlen( <fs_str> ).
            IF lv_len > 1 AND <fs_str>+1(1) CA '#_%' AND  lv_escape NE space.
              ASSIGN <fs_str>+1(*) TO <fs_str>.
            ELSE.
              SHIFT <fs_str> LEFT BY 1 PLACES.
            ENDIF.
*-          '##' wird zu '#' oder bleibt '##'
*           '#_' wird zu '_' oder bleibt '#_' ('#' wird ignoriert,
*                also bleibt '_', das evtl. maskiert wird)
*           '#%' wird zu '%' oder bleibt '#%' ('#' wird ignoriert,
*                also bleibt '%', das evtl. maskiert wird)
          ELSEIF <fs_str>(1) = '*'.
            <fs_str>(1) = '%'.
          ELSEIF <fs_str>(1) = '+'.
            <fs_str>(1) = '_'.
          ENDIF.
*       Das eben behandelte Zeichen nicht mehr berücksichtigen.
          lv_len = strlen( <fs_str> ).
          IF lv_len > 1.
            ASSIGN <fs_str>+1(*) TO <fs_str>.
          ELSE.
            EXIT.
          ENDIF.
        ENDWHILE.
        IF  lv_escape <> space.
          lv_high = '  lv_escape ''#'''.
          CLEAR  lv_escape.
        ENDIF.
      ENDIF.

      IF ls_selopt-option = 'BT'." OR ls_selopt-option = 'NB'.
*     Wenn Hochkommas im HIGH-Teil enthalten sind, müssen diese
*     auch dort verdoppelt werden.
        double_hyphen( CHANGING cv_val = ls_selopt-high ).
        lv_high = ls_selopt-high.
*        lv_high = condense( |'{ ls_selopt-high }'| ).

        CONCATENATE rv_where lv_concat '(' lv_fname 'GE' lv_low
                  INTO rv_where SEPARATED BY ' '.


        CONCATENATE rv_where 'AND' lv_fname 'LE' lv_high ')'
                  INTO rv_where SEPARATED BY ' '.

      ELSE.
        CONCATENATE rv_where lv_concat lv_fname lv_op lv_low
                  INTO rv_where SEPARATED BY ' '.

      ENDIF.

      lv_last_shlpname = ls_selopt-shlpname.
      lv_last_shlpfield = ls_selopt-shlpfield.
      lv_last_sign = ls_selopt-sign.
    ENDLOOP.
* Feldklammer am Ende noch schließen.
    IF NOT rv_where IS INITIAL.
      CONCATENATE rv_where ' )' INTO rv_where.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_GL_UTIL=>DOUBLE_HYPHEN
* +-------------------------------------------------------------------------------------------------+
* | [<-->] CV_VAL                         TYPE        RSDSSELOP_
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD double_hyphen.

    CHECK to_lower( cv_val ) NS 'datetime'.

    FIELD-SYMBOLS: <fs_str> TYPE csequence.
    ASSIGN cv_val TO <fs_str>.
    WHILE <fs_str> CA ''''.
      ASSIGN <fs_str>+sy-fdpos(*) TO <fs_str>.
      SHIFT <fs_str> RIGHT BY 1 PLACES.
      <fs_str>(1) = ''''.
*         <STR> hinter das zusätzliche Hochkomma plazieren
      ASSIGN <fs_str>+2(*) TO <fs_str>.
    ENDWHILE.
    cv_val = condense( |'{ cv_val }'| ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>GET_ATTACH_DOC
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_OBJ_NAME                    TYPE        OJ_NAME
* | [--->] IV_ID_DOC                      TYPE        SIBFBORIID
* | [<---] RV_XSTRING                     TYPE        XSTRING
* | [<---] EV_FILE_NAME                   TYPE        STRING
* | [<-()] RV_STRING                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_attach_doc.

    TYPES: BEGIN OF tp_id,
             so_obj_tp TYPE so_obj_tp,
             so_obj_yr TYPE so_obj_yr,
             so_obj_no TYPE so_obj_no,
           END OF tp_id.

    DATA: lt_id TYPE TABLE OF tp_id,
          ls_id TYPE tp_id.

    DATA: lv_phio_class       TYPE c LENGTH 50,
          lv_cluster_key      TYPE c LENGTH 33,
          lt_phio_cluster_aux TYPE scmst_r3db_cont_cluster,
          lt_phio_cluster     TYPE scmst_r3db_cont_cluster.

    SELECT instid_b
      FROM srgbtbrel
      INTO TABLE @DATA(lt_keys)
      WHERE reltype = 'ATTA' " anexos.
        AND instid_a = @iv_id_doc
        AND typeid_a = @iv_obj_name.

    IF sy-subrc IS INITIAL.

      LOOP AT lt_keys INTO DATA(ls_keys).
        CLEAR ls_id.
        ls_id-so_obj_tp = substring( val = ls_keys-instid_b off = 17 len = 3 ).
        ls_id-so_obj_yr = substring( val = ls_keys-instid_b off = 20 len = 2 ).
        ls_id-so_obj_no = substring( val = ls_keys-instid_b off = 22 len = 12 ).
        APPEND ls_id TO lt_id.
      ENDLOOP.

      IF lt_id IS NOT INITIAL.

        "SELECT *
        "  FROM sood
        "  INTO TABLE @DATA(lt_sood)
        "  FOR ALL ENTRIES IN @lt_id
        "  WHERE objtp = @lt_id-so_obj_tp
        "    AND objyr = @lt_id-so_obj_yr
        "    AND objno = @lt_id-so_obj_no.
        "IF sy-subrc IS INITIAL.


        SELECT objtp,
               objyr,
               objno,
               objid,
               class,
               filename
          FROM soc3n
          INTO TABLE @DATA(lt_soc3n)
          FOR ALL ENTRIES IN @lt_id
          WHERE objtp = @lt_id-so_obj_tp
            AND objyr = @lt_id-so_obj_yr
            AND objno = @lt_id-so_obj_no.

        IF sy-subrc IS INITIAL.

          SELECT phio_id,                          "#EC CI_NO_TRANSFORM
                 loio_id,
                 ph_class,
                 lo_class
            FROM soffphio
            INTO TABLE @DATA(lt_soffphio)
            FOR ALL ENTRIES IN @lt_soc3n
            WHERE loio_id  = @lt_soc3n-objid
              AND lo_class = @lt_soc3n-class.

          IF sy-subrc IS INITIAL.
            DATA: lt_soffcont1 TYPE SORTED TABLE OF soffcont1 WITH UNIQUE DEFAULT KEY.

            SELECT mandt,                          "#EC CI_NO_TRANSFORM
                   relid,
                   phio_id,
                   srtf2,
                   ph_class,
                   clustr,
                   clustd   ##SELECT_FAE_WITH_LOB[CLUSTD]
              FROM soffcont1

              FOR ALL ENTRIES IN @lt_soffphio
              WHERE phio_id = @lt_soffphio-phio_id
                AND relid = 'IR'
                AND srtf2 = 0
              INTO CORRESPONDING FIELDS OF TABLE @lt_soffcont1.


            IF sy-subrc IS INITIAL.

              DATA: lv_len TYPE i.
              DATA: lv_phio_id TYPE soffcont1-phio_id.

              DATA: lt_soffcont1_aux LIKE lt_soffcont1.
              SORT lt_soffphio BY loio_id lo_class.
              LOOP AT lt_soc3n INTO DATA(ls_soc3n).
                CLEAR lt_soffcont1_aux.
                READ TABLE lt_soffphio INTO DATA(ls_soffphio) WITH KEY  loio_id  = ls_soc3n-objid lo_class = ls_soc3n-class BINARY SEARCH.
                IF sy-subrc IS INITIAL.
                  lt_soffcont1_aux = FILTER #( lt_soffcont1 WHERE mandt = sy-mandt AND relid = 'IR' AND  phio_id = ls_soffphio-phio_id ).
                ENDIF.

                READ TABLE lt_soffcont1_aux INTO DATA(ls_soffcont1) INDEX 1.

                " get content from db
                CLEAR:  lv_phio_class, lt_phio_cluster.
                DATA(lv_tabname)      = 'SOFFCONT1'.
                CONCATENATE ls_soffcont1-phio_id '#' INTO lv_cluster_key.


                PERFORM db_import_cont IN PROGRAM scms_r3db_sub
                  USING
                    sy-mandt
                    lv_tabname
                    lv_cluster_key
                  CHANGING
                    lv_phio_class
                    lt_phio_cluster.


                READ TABLE lt_phio_cluster INTO DATA(ls_phio_cluster) INDEX 1.
                DATA: lv_xstring_file TYPE xstring.
                CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
                  EXPORTING
                    input_length = ls_phio_cluster-comp_size
                  IMPORTING
                    buffer       = lv_xstring_file
                  TABLES
                    binary_tab   = ls_phio_cluster-cont_bin.
                IF sy-subrc <> 0.
* Implement suitable error handling here
                ENDIF.

                CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
                  EXPORTING
                    input  = lv_xstring_file
                  IMPORTING
                    output = rv_string.

                rv_xstring = lv_xstring_file.

                ev_file_name = ls_soc3n-filename.


              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
        "ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>GET_BAPIRET2
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TYPE                        TYPE        BAPIRETURN-TYPE
* | [--->] IV_CL                          TYPE        SY-MSGID (default ='00')
* | [--->] IV_NUMBER                      TYPE        SY-MSGNO (default ='398')
* | [--->] IV_PAR1                        TYPE        ANY(optional)
* | [--->] IV_PAR2                        TYPE        ANY(optional)
* | [--->] IV_PAR3                        TYPE        ANY(optional)
* | [--->] IV_PAR4                        TYPE        ANY(optional)
* | [--->] IV_LOG_NO                      TYPE        BAPIRETURN-LOG_NO (default =SPACE)
* | [--->] IV_LOG_MSG_NO                  TYPE        BAPIRETURN-LOG_MSG_NO (default =0)
* | [--->] IV_PARAMETER                   TYPE        BAPIRET2-PARAMETER (default =SPACE)
* | [--->] IV_ROW                         TYPE        BAPIRET2-ROW (default =0)
* | [--->] IV_FIELD                       TYPE        BAPIRET2-FIELD (default =SPACE)
* | [<-()] RS_RETURN                      TYPE        BAPIRET2
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_bapiret2.

    DATA: lv_par1 TYPE sy-msgv1,
          lv_par2 TYPE sy-msgv2,
          lv_par3 TYPE sy-msgv3,
          lv_par4 TYPE sy-msgv4.

    WRITE iv_par1 TO lv_par1. CONDENSE lv_par1.
    WRITE iv_par2 TO lv_par2. CONDENSE lv_par2.
    WRITE iv_par3 TO lv_par3. CONDENSE lv_par3.
    WRITE iv_par4 TO lv_par4. CONDENSE lv_par4.

    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type       = iv_type
        cl         = iv_cl
        number     = iv_number
        par1       = lv_par1
        par2       = lv_par2
        par3       = lv_par3
        par4       = lv_par4
        log_no     = iv_log_no
        log_msg_no = iv_log_msg_no
        parameter  = iv_parameter
        row        = iv_row
        field      = iv_field
      IMPORTING
        return     = rs_return.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_GL_UTIL=>GET_DBOPERATOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_OPTION                      TYPE        TVARV_OPTI
* | [--->] IV_NEGATE                      TYPE        FLAG (default =SPACE)
* | [<-()] RV_OP                          TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_dboperator.

    IF iv_negate = space.
      rv_op = iv_option.
      CASE iv_option.
        WHEN 'BT'.
          rv_op = 'BETWEEN'.
        WHEN 'NB'.
          rv_op = 'NOT BETWEEN'.
        WHEN 'CP'.
          rv_op = 'LIKE'.
        WHEN 'NP'.
          rv_op = 'NOT LIKE'.
      ENDCASE.
    ELSE.                                "Negation des Operators
      CASE iv_option.
        WHEN 'EQ'.
          rv_op = 'NE'.
        WHEN 'NE'.
          rv_op = 'EQ'.
        WHEN 'GT'.
          rv_op = 'LE'.
        WHEN 'LE'.
          rv_op = 'GT'.
        WHEN 'GE'.
          rv_op = 'LT'.
        WHEN 'LT'.
          rv_op = 'GE'.
        WHEN 'BT'.
          rv_op = 'NOT BETWEEN'.
        WHEN 'NB'.
          rv_op = 'BETWEEN'.
        WHEN 'CP'.
          rv_op = 'NOT LIKE'.
        WHEN 'NP'.
          rv_op = 'LIKE'.
        WHEN OTHERS.
          CLEAR rv_op.                   "Unbekannter Operator
      ENDCASE.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>GET_ERROR_PROXY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_PROXY                       TYPE REF TO IF_PROXY_BASIS
* | [<-()] RT_RETURN                      TYPE        BAPIRET2_TT
* | [!CX!] CX_AI_SYSTEM_FAULT
* | [!CX!] CX_XMS_SYSERR_PERSIST
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_error_proxy.

    DATA: lo_msg_id TYPE REF TO cl_wsprotocol_message_id.

    lo_msg_id ?= io_proxy->get_protocol( if_wsprotocol=>message_id ).

    DATA(lo_persist) = NEW cl_xms_persist( ).

    CALL METHOD lo_persist->read_msg_pub
      EXPORTING
        im_msgguid = lo_msg_id->if_wsprotocol_message_id~get_message_id( )
        im_pid     = 'SENDER'
        im_version = '000'
        im_client  = sy-mandt
      IMPORTING
        ex_message = DATA(lo_message).

    lo_message->eo->get_attributes(
      IMPORTING
        eo_attr = DATA(ls_attr) ).

    DATA(lv_msg) = |{ ls_attr-category } { ls_attr-area }.{ ls_attr-id }: { ls_attr-text }|.
    lv_msg = REDUCE string( INIT lv_str = lv_msg
                            FOR ls_stack IN ls_attr-stack
                            NEXT lv_str = |{ lv_str } { ls_stack-value }| ).

    LOOP AT split_text_2_msg( condense( lv_msg ) ) INTO DATA(ls_msg).

      APPEND get_bapiret2(
        iv_type   = gc_msg_error
        iv_cl     = gc_msgid_gen
        iv_number = gc_msgno_gen
        iv_par1   = ls_msg-msgv1
        iv_par2   = ls_msg-msgv2
        iv_par3   = ls_msg-msgv3
        iv_par4   = ls_msg-msgv4 )
        TO rt_return.

    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>GET_PARAM_VALUE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_MOD                         TYPE        /PGTPA/PARAM_PAR-MODULO
* | [--->] IV_PAR1                        TYPE        /PGTPA/PARAM_PAR-PARAM1
* | [--->] IV_PAR2                        TYPE        /PGTPA/PARAM_PAR-PARAM2(optional)
* | [--->] IV_PAR3                        TYPE        /PGTPA/PARAM_PAR-PARAM3(optional)
* | [--->] IV_PAR4                        TYPE        /PGTPA/PARAM_PAR-PARAM4(optional)
* | [--->] IV_PAR5                        TYPE        /PGTPA/PARAM_PAR-PARAM5(optional)
* | [<---] EV_DATA                        TYPE        CLIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_param_value.

    CALL FUNCTION '/PGTPA/PARAM_BUSCA_VALORES'
      EXPORTING
        i_modulo            = iv_mod             " Módulo
        i_param1            = iv_par1            " Parâmetro 1
        i_param2            = iv_par2            " Parâmetro 2
        i_param3            = iv_par3            " Parâmetro 3
        i_param4            = iv_par4            " Parâmetro 4
        i_param5            = iv_par5            " Parâmetro 5
      IMPORTING
        e_valor             = ev_data
      EXCEPTIONS
        nao_encontrado      = 1                  " Valores não encontrados
        range_nao_informado = 2                  " Range não informado
        OTHERS              = 3.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>SET_BAPI_X
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_BAPI                        TYPE        ANY
* | [--->] IT_BLANKS                      TYPE        TT_COMPONENTS(optional)
* | [--->] IT_CONSTANTS                   TYPE        TT_CONSTANTS(optional)
* | [<---] ES_BAPIX                       TYPE        ANY
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_bapi_x.

    DATA: lo_struct_in  TYPE REF TO cl_abap_structdescr,
          lo_struct_out TYPE REF TO cl_abap_structdescr,
          lo_type       TYPE REF TO cl_abap_typedescr.

    TRY.
        lo_struct_in  ?= cl_abap_typedescr=>describe_by_data( is_bapi ).
        lo_struct_out ?= cl_abap_typedescr=>describe_by_data( es_bapix ).

      CATCH cx_root.
        RETURN.

    ENDTRY.

    CHECK lo_struct_in->kind  EQ cl_abap_typedescr=>kind_struct
      AND lo_struct_out->kind EQ cl_abap_typedescr=>kind_struct.

    LOOP AT lo_struct_in->get_components( ) INTO DATA(ls_components).

      FREE lo_type.

      ASSIGN COMPONENT ls_components-name OF STRUCTURE is_bapi TO FIELD-SYMBOL(<fs_in>).

      CHECK sy-subrc EQ 0 AND <fs_in> IS NOT INITIAL.

      ASSIGN COMPONENT ls_components-name OF STRUCTURE es_bapix TO FIELD-SYMBOL(<fs_out>).

      CHECK sy-subrc EQ 0.

      lo_type ?= cl_abap_typedescr=>describe_by_data( <fs_out> ).

      IF lo_type->get_relative_name( ) NE ls_components-type->get_relative_name( ).
        <fs_out> = abap_true.

      ELSE.
        <fs_out> = <fs_in>.

      ENDIF.

    ENDLOOP.

    LOOP AT it_blanks INTO DATA(ls_blanks).

      ASSIGN COMPONENT ls_blanks-fieldname OF STRUCTURE es_bapix TO <fs_out>.

      CHECK sy-subrc EQ 0.

      <fs_out> = abap_true.

    ENDLOOP.

    LOOP AT it_constants INTO DATA(ls_constants).

      ASSIGN COMPONENT ls_constants-fieldname OF STRUCTURE es_bapix TO <fs_out>.

      CHECK sy-subrc EQ 0.

      <fs_out> = ls_constants-value.

    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>SET_RETURN
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TYPE                        TYPE        BAPIRETURN-TYPE
* | [--->] IV_CL                          TYPE        SY-MSGID (default ='00')
* | [--->] IV_NUMBER                      TYPE        SY-MSGNO (default ='398')
* | [--->] IV_PAR1                        TYPE        ANY(optional)
* | [--->] IV_PAR2                        TYPE        ANY(optional)
* | [--->] IV_PAR3                        TYPE        ANY(optional)
* | [--->] IV_PAR4                        TYPE        ANY(optional)
* | [--->] IV_LOG_NO                      TYPE        BAPIRETURN-LOG_NO (default =SPACE)
* | [--->] IV_LOG_MSG_NO                  TYPE        BAPIRETURN-LOG_MSG_NO (default =0)
* | [--->] IV_PARAMETER                   TYPE        BAPIRET2-PARAMETER (default =SPACE)
* | [--->] IV_ROW                         TYPE        BAPIRET2-ROW (default =0)
* | [--->] IV_FIELD                       TYPE        BAPIRET2-FIELD (default =SPACE)
* | [<-()] RS_RETURN                      TYPE        BAPIRET2
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_return.

    DATA: lv_par1 TYPE sy-msgv1,
          lv_par2 TYPE sy-msgv2,
          lv_par3 TYPE sy-msgv3,
          lv_par4 TYPE sy-msgv4.

    WRITE iv_par1 TO lv_par1. CONDENSE lv_par1.
    WRITE iv_par2 TO lv_par2. CONDENSE lv_par2.
    WRITE iv_par3 TO lv_par3. CONDENSE lv_par3.
    WRITE iv_par4 TO lv_par4. CONDENSE lv_par4.

    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type       = iv_type
        cl         = iv_cl
        number     = iv_number
        par1       = lv_par1
        par2       = lv_par2
        par3       = lv_par3
        par4       = lv_par4
        log_no     = iv_log_no
        log_msg_no = iv_log_msg_no
        parameter  = iv_parameter
        row        = iv_row
        field      = iv_field
      IMPORTING
        return     = rs_return.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>SPLIT_TEXT_2_MSG
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TEXT                        TYPE        CLIKE
* | [<-()] RT_MSGV                        TYPE        TT_MSGV
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD split_text_2_msg.

    DATA: lv_text  TYPE html4096.
    DATA: lt_lines TYPE trtexts,
          ls_msgv  LIKE LINE OF rt_msgv.

    CLEAR rt_msgv.

    lv_text = condense( iv_text ).

    CALL FUNCTION 'TR_SPLIT_TEXT'
      EXPORTING
        iv_text  = lv_text
        iv_len   = 50
      IMPORTING
        et_lines = lt_lines.

    LOOP AT lt_lines INTO DATA(ls_lines).

      DATA(lv_msgv) = COND i( WHEN sy-tabix MOD 4 GT 0 THEN sy-tabix MOD 4 ELSE 4 ).

      ASSIGN COMPONENT lv_msgv OF STRUCTURE ls_msgv TO FIELD-SYMBOL(<fs_msgv>).

      CHECK sy-subrc EQ 0.

      <fs_msgv> = ls_lines.

      IF lv_msgv EQ 4.
        APPEND ls_msgv TO rt_msgv.
        CLEAR ls_msgv.

      ENDIF.
    ENDLOOP.

    IF lv_msgv NE 4.
      APPEND ls_msgv TO rt_msgv.

    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>SPLIT_TEXT_2_TLINE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TEXT                        TYPE        CLIKE
* | [<-()] RT_TLINE                       TYPE        TEXT_LINES
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD split_text_2_tline.

    DATA: lv_text  TYPE html4096.
    DATA: lt_lines TYPE trtexts.

    CLEAR rt_tline.

    lv_text = condense( iv_text ).

    CALL FUNCTION 'TR_SPLIT_TEXT'
      EXPORTING
        iv_text  = lv_text
        iv_len   = 132
      IMPORTING
        et_lines = lt_lines.

    LOOP AT lt_lines INTO DATA(ls_lines).

      IF sy-tabix EQ 1.
        APPEND VALUE tline( tdformat = '*' tdline = ls_lines ) TO rt_tline.

      ELSE.
        APPEND VALUE tline( tdformat = '' tdline = ls_lines ) TO rt_tline.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>CONV_TTLINE_TO_STRING
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_TLINE                       TYPE        TLINE_T
* | [<-()] RV_STRING                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD conv_ttline_to_string.

    LOOP AT it_tline INTO DATA(ls_text_lines).

      rv_string  = |{ rv_string } { ls_text_lines-tdline } { cl_abap_char_utilities=>cr_lf }|.

    ENDLOOP.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>CONV_ISODATETIME
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ISO8601                     TYPE        CSEQUENCE
* | [<-()] RV_DATETIME                    TYPE        ADA_RTIME
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD conv_isodatetime.

    DATA: lv_iso8601 TYPE char20.

    CHECK iv_iso8601 IS NOT INITIAL.

    IF strlen( iv_iso8601 ) GE 19 AND iv_iso8601+19 NE 'Z'.
      lv_iso8601 = iv_iso8601(19) && 'Z'.

    ELSEIF strlen( iv_iso8601 ) EQ 10.
      lv_iso8601 = iv_iso8601 && 'T00:00:00Z'.

    ELSE.
      lv_iso8601 = iv_iso8601.

    ENDIF.

    IF lv_iso8601+10(1) EQ space.
      lv_iso8601+10(1) = 'T'.

    ENDIF.

    TRY.
        rv_datetime = cl_xlf_date_time=>parse( CONV #( lv_iso8601 ) ).

      CATCH cx_xlf_illegal_argument INTO DATA(lo_xarg).

    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>EXISTS_ATTACH_DOC
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_OBJ_NAME                    TYPE        OJ_NAME
* | [--->] IV_ID_DOC                      TYPE        SIBFBORIID
* | [<---] EV_FILE_NAME                   TYPE        STRING
* | [<-()] RV_EXISTS                      TYPE        FLAG
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD exists_attach_doc.

    TYPES: BEGIN OF tp_id,
             so_obj_tp TYPE so_obj_tp,
             so_obj_yr TYPE so_obj_yr,
             so_obj_no TYPE so_obj_no,
           END OF tp_id.

    DATA: lt_id TYPE TABLE OF tp_id,
          ls_id TYPE tp_id.

    DATA: lv_phio_class       TYPE c LENGTH 50,
          lv_cluster_key      TYPE c LENGTH 33,
          lt_phio_cluster_aux TYPE scmst_r3db_cont_cluster,
          lt_phio_cluster     TYPE scmst_r3db_cont_cluster.

    SELECT instid_b
      FROM srgbtbrel
      INTO TABLE @DATA(lt_keys)
      WHERE reltype = 'ATTA' " anexos.
        AND instid_a = @iv_id_doc
        AND typeid_a = @iv_obj_name.

    IF sy-subrc IS INITIAL.

      LOOP AT lt_keys INTO DATA(ls_keys).
        CLEAR ls_id.
        ls_id-so_obj_tp = substring( val = ls_keys-instid_b off = 17 len = 3 ).
        ls_id-so_obj_yr = substring( val = ls_keys-instid_b off = 20 len = 2 ).
        ls_id-so_obj_no = substring( val = ls_keys-instid_b off = 22 len = 12 ).
        APPEND ls_id TO lt_id.
      ENDLOOP.

      IF lt_id IS NOT INITIAL.

        "SELECT *
        "  FROM sood
        "  INTO TABLE @DATA(lt_sood)
        "  FOR ALL ENTRIES IN @lt_id
        "  WHERE objtp = @lt_id-so_obj_tp
        "    AND objyr = @lt_id-so_obj_yr
        "    AND objno = @lt_id-so_obj_no.
        "IF sy-subrc IS INITIAL.


        SELECT objtp,
               objyr,
               objno,
               objid,
               class,
               filename
          FROM soc3n
          INTO TABLE @DATA(lt_soc3n)
          FOR ALL ENTRIES IN @lt_id
          WHERE objtp = @lt_id-so_obj_tp
            AND objyr = @lt_id-so_obj_yr
            AND objno = @lt_id-so_obj_no.

        IF sy-subrc IS INITIAL.

          SELECT phio_id,                          "#EC CI_NO_TRANSFORM
                 loio_id,
                 ph_class,
                 lo_class
            FROM soffphio
            INTO TABLE @DATA(lt_soffphio)
            FOR ALL ENTRIES IN @lt_soc3n
            WHERE loio_id  = @lt_soc3n-objid
              AND lo_class = @lt_soc3n-class.

          IF sy-subrc IS INITIAL.
            DATA: lt_soffcont1 TYPE SORTED TABLE OF soffcont1 WITH UNIQUE DEFAULT KEY.

            SELECT mandt,                          "#EC CI_NO_TRANSFORM
                   relid,
                   phio_id,
                   srtf2,
                   ph_class,
                   clustr,
                   clustd   ##SELECT_FAE_WITH_LOB[CLUSTD]
              FROM soffcont1

              FOR ALL ENTRIES IN @lt_soffphio
              WHERE phio_id = @lt_soffphio-phio_id
                AND relid = 'IR'
                AND srtf2 = 0
              INTO CORRESPONDING FIELDS OF TABLE @lt_soffcont1.


            IF sy-subrc IS INITIAL.

              DATA: lv_len TYPE i.
              DATA: lv_phio_id TYPE soffcont1-phio_id.

              DATA: lt_soffcont1_aux LIKE lt_soffcont1.
              SORT lt_soffphio BY loio_id lo_class.
              LOOP AT lt_soc3n INTO DATA(ls_soc3n).

                ev_file_name = ls_soc3n-filename.
                rv_exists = abap_true.

              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
        "ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>RESCALE_DEC_TO_CURR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_VAL                         TYPE        DEC31_14
* | [<-()] RS_PRICE                       TYPE        TP_RSC_PRICE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD rescale_dec_to_curr.

    CLEAR rs_price.

    DATA(lv_val)   = iv_val.
    DATA(lv_scale) = cl_abap_math=>get_scale_normalized( CONV decfloat34( lv_val ) ).

    IF lv_scale GT 6.
      lv_val   = round( val = lv_val dec = 6 ).
      lv_scale = cl_abap_math=>get_scale_normalized( CONV decfloat34( lv_val ) ).

    ENDIF.

    rs_price-price_unit = COND #( WHEN lv_scale GT 2 THEN CONV epein( 10 ** ( lv_scale - 2 ) )
                                  ELSE 1 ).
    rs_price-net_price  = CONV bapicurext( lv_val * rs_price-price_unit ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>GET_BAPIRET2_EXC
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_EXCEPTION                   TYPE REF TO CX_ROOT
* | [--->] IV_FROM_PREVIOUS               TYPE        ABAP_BOOL (default =ABAP_FALSE)
* | [--->] IV_MSG_TYPE                    TYPE        SY-MSGTY(optional)
* | [<-()] RS_RETURN                      TYPE        BAPIRET2
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_bapiret2_exc.
* Copied from CL_SADL_GW_LOG=>GET_SYMSG_FROM_EXCEPTION

    DATA: ls_msg TYPE symsg.

    CHECK io_exception IS BOUND.

    DATA(lo_ex) = io_exception.

    IF iv_from_previous = abap_true.
      WHILE lo_ex->previous IS BOUND.
        lo_ex = lo_ex->previous.

      ENDWHILE.
    ENDIF.

    IF lo_ex IS INSTANCE OF if_t100_message.
      ls_msg       = cl_message_helper=>get_t100_for_object( CAST #( lo_ex ) ).
      ls_msg-msgty = COND #( WHEN lo_ex IS INSTANCE OF if_t100_dyn_msg AND CAST if_t100_dyn_msg( lo_ex )->msgty IS NOT INITIAL
                             THEN CAST if_t100_dyn_msg( lo_ex )->msgty
                             ELSE COND #( WHEN ls_msg-msgty IS INITIAL THEN 'E' ELSE ls_msg-msgty ) ).

    ELSE.
      DATA(lo_class)    = CAST cl_abap_classdescr( cl_abap_classdescr=>describe_by_object_ref( lo_ex ) ).
      cl_message_helper=>get_text_params( EXPORTING obj = lo_ex IMPORTING params = DATA(lt_param) ).
      ls_msg = VALUE #( msgty = 'E' msgid = 'SADL_GW_DT_COMMON' msgno = 002 msgv1 = substring_after( val   = lo_class->absolute_name sub = '=' )
                        msgv2 = COND #( WHEN lo_ex->textid IS NOT INITIAL AND line_exists( lt_param[ value = lo_ex->textid ] )
                      THEN lt_param[                                                                 value = lo_ex->textid ]-param ) ).

      DATA(lv_text) = lo_ex->get_text( ).

      DO 2 TIMES.
        ASSIGN COMPONENT |MSGV{ sy-index + 2 }| OF STRUCTURE ls_msg TO FIELD-SYMBOL(<fs_value>).
        <fs_value> = lv_text.
        SHIFT lv_text BY strlen( <fs_value> ) PLACES.

      ENDDO.
    ENDIF.

    rs_return = get_bapiret2(
      iv_type   = COND #( WHEN iv_msg_type IS INITIAL THEN ls_msg-msgty ELSE iv_msg_type )
      iv_cl     = ls_msg-msgid
      iv_number = ls_msg-msgno
      iv_par1   = ls_msg-msgv1
      iv_par2   = ls_msg-msgv2
      iv_par3   = ls_msg-msgv3
      iv_par4   = ls_msg-msgv4
    ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>CONV_TSTMP2SYST
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TMSP                        TYPE        CSEQUENCE
* | [<-()] RS_DATETIME                    TYPE        ADA_RTIME
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD conv_tstmp2syst.

    DATA: lv_issue     TYPE tzntstmpl,
          lv_timestamp TYPE timestamp,
          lv_datum     TYPE sy-datum,
          lv_uzeit     TYPE sy-uzeit.

    DATA(lo_pattern_ref) = cl_abap_regex=>create_pcre( pattern     = '^\d+(\.{0,1}\d*){0,1}$'  " Ex.: 20200831114803.5211140
                                                       ignore_case = 'X'
                                                       extended    = 'X' ).

    FIND REGEX lo_pattern_ref IN condense( iv_tmsp ) MATCH COUNT DATA(lv_count).

    CHECK sy-subrc EQ 0 AND CONV tzntstmpl( iv_tmsp ) IS NOT INITIAL.

    lv_issue = iv_tmsp.

    CALL METHOD cl_abap_tstmp=>normalize
      EXPORTING
        tstmp_in  = CONV tzntstmpl( iv_tmsp )
      RECEIVING
        tstmp_out = lv_issue.

    CALL METHOD cl_abap_tstmp=>move_to_short
      EXPORTING
        tstmp_src = lv_issue
      RECEIVING
        tstmp_out = lv_timestamp.

    CALL METHOD cl_abap_tstmp=>systemtstmp_utc2syst
      EXPORTING
        utc_tstmp = lv_timestamp
      IMPORTING
        syst_date = rs_datetime-datum     " System Date
        syst_time = rs_datetime-zeit.     " System Time

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>GET_ATTACH_DOCS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_OBJ_NAME                    TYPE        OJ_NAME
* | [--->] IV_ID_DOC                      TYPE        SIBFBORIID
* | [<-()] RT_ATTACHS                     TYPE        TT_ATTACHS
* | [!CX!] CX_OBL_PARAMETER_ERROR
* | [!CX!] CX_OBL_INTERNAL_ERROR
* | [!CX!] CX_OBL_MODEL_ERROR
* | [!CX!] ZCX_MM_PARADIGMA
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_attach_docs.

    DATA: ls_data          TYPE sofolenti1,
          lt_object_header TYPE STANDARD TABLE OF solisti1.

    DATA: lv_error TYPE symsgv.

    DATA(gs_obj)   = VALUE sibflporb( instid = iv_id_doc typeid = iv_obj_name catid = 'BO' ).
    DATA(lr_relat) = VALUE obl_t_relt( ( sign = 'I' option = 'EQ' low = 'ATTA' ) ).

    CALL METHOD cl_binary_relation=>read_links
      EXPORTING
        is_object           = gs_obj                   " Start object
        it_relation_options = lr_relat                 " OBL: Select Options for Relationship Types
      IMPORTING
        et_links            = DATA(lt_links).          " Table with Relationship Records

    LOOP AT lt_links INTO DATA(ls_links).

      CLEAR: ls_data,
             lt_object_header.

      APPEND INITIAL LINE TO rt_attachs ASSIGNING FIELD-SYMBOL(<fs_attachs>).

      CALL FUNCTION 'SO_DOCUMENT_READ_API1'
        EXPORTING
          document_id                = CONV so_entryid( ls_links-instid_b )  " ID of folder entry to be viewed
        IMPORTING
          document_data              = ls_data                               " Complete attributes of folder entry
        TABLES
          object_header              = lt_object_header                      " Header data for document (spec.header)
          contents_hex               = <fs_attachs>-cont_hex                 " Table for Binary Content
        EXCEPTIONS
          document_id_not_exist      = 1                                     " Specified folder entry does not exist
          operation_no_authorization = 2                                     " No authorization to view folder entry
          x_error                    = 3                                     " Internal error or database inconsistency
          OTHERS                     = 4.

      IF sy-subrc NE 0.
        CASE sy-subrc.
          WHEN 1. lv_error = 'Specified folder entry does not exist'.
          WHEN 2. lv_error = 'No authorization to view folder entry'.
          WHEN 3. lv_error = 'Internal error or database inconsistency'.
          WHEN OTHERS. lv_error = 'Other'.
        ENDCASE.

      ENDIF.

      LOOP AT lt_object_header INTO DATA(ls_object_header).

        SPLIT ls_object_header-line AT '=' INTO DATA(lv_attrib) DATA(lv_value).

        CASE lv_attrib.
          WHEN '&SO_FILENAME'. <fs_attachs>-filename  = lv_value.
          WHEN '&SO_FORMAT'.   <fs_attachs>-intformat = lv_value.
        ENDCASE.

        CLEAR: lv_attrib,
               lv_value.

      ENDLOOP.

      FIND ALL OCCURRENCES OF '.' IN <fs_attachs>-filename MATCH OFFSET DATA(lv_offset).

      IF sy-subrc EQ 0.
        TRANSLATE <fs_attachs>-filename+lv_offset TO LOWER CASE.

      ENDIF.

      MOVE-CORRESPONDING ls_data TO <fs_attachs>.

      CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
        EXPORTING
          input_length = CONV i( <fs_attachs>-doc_size )
        IMPORTING
          buffer       = <fs_attachs>-buf_hex
        TABLES
          binary_tab   = <fs_attachs>-cont_hex
        EXCEPTIONS
          failed       = 1
          OTHERS       = 2.

      IF sy-subrc NE 0.


      ENDIF.

      CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
        EXPORTING
          input  = <fs_attachs>-buf_hex
        IMPORTING
          output = <fs_attachs>-base64.

      CALL FUNCTION 'SDOK_MIMETYPE_GET'
        EXPORTING
          extension = <fs_attachs>-obj_type
        IMPORTING
          mimetype  = <fs_attachs>-mimetype.

    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>CHECK_STVARV_RANGE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_NAME                        TYPE        TVARVC-NAME
* | [--->] IV_DATA                        TYPE        SIMPLE
* | [--->] IV_NO_EMPTY                    TYPE        FLAG (default ='X')
* | [<-()] RV_BOOL                        TYPE        ABAP_BOOLEAN
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD check_stvarv_range.

    DATA(lv_low) = CONV tvarvc-low( condense( |{ iv_data }| ) ).

    SELECT FROM tvarvc
      FIELDS sign, opti AS option, low, high
      WHERE type EQ 'S'
        AND name EQ @iv_name
      INTO TABLE @DATA(lr_result).

    IF iv_no_empty IS NOT INITIAL AND lr_result IS INITIAL.
      rv_bool = abap_false.

    ELSE.
      rv_bool = COND #( WHEN lv_low IN lr_result
                        THEN abap_true
                        ELSE abap_false ).

    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>CHECK_STVARV_VALUE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_NAME                        TYPE        TVARVC-NAME
* | [--->] IV_DATA                        TYPE        SIMPLE
* | [<-()] RV_BOOL                        TYPE        ABAP_BOOLEAN
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD check_stvarv_value.

    DATA(lv_low) = CONV tvarvc-low( condense( |{ iv_data }| ) ).

    SELECT SINGLE FROM tvarvc
      FIELDS low
      WHERE type EQ 'P'
        AND name EQ @iv_name
      INTO @DATA(lv_result).

    rv_bool = COND #( WHEN lv_result EQ lv_low
                      THEN abap_true
                      ELSE abap_false ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>GET_STVARV_RANGE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_NAME                        TYPE        TVARVC-NAME
* | [<---] ET_DATA                        TYPE        STANDARD TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_stvarv_range.

    SELECT FROM tvarvc
      FIELDS sign, opti AS option, low, high
      WHERE type EQ 'S'
        AND name EQ @iv_name
      INTO TABLE @et_data.

    LOOP AT et_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      ASSIGN COMPONENT 'SIGN' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_field>).

      IF sy-subrc EQ 0 AND <fs_field> IS INITIAL.
        <fs_field> = 'I'.

      ENDIF.

      ASSIGN COMPONENT 'OPTION' OF STRUCTURE <fs_data> TO <fs_field>.

      IF sy-subrc EQ 0 AND <fs_field> IS INITIAL.
        ASSIGN COMPONENT 'HIGH' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_high>).

        IF sy-subrc EQ 0.
          IF <fs_high> IS INITIAL.
            <fs_field> = 'EQ'.

          ELSE.
            <fs_field> = 'BT'.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>GET_STVARV_VALUE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_NAME                        TYPE        TVARVC-NAME
* | [<---] EV_DATA                        TYPE        SIMPLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_stvarv_value.

    SELECT SINGLE FROM tvarvc
      FIELDS low
      WHERE type EQ 'P'
        AND name EQ @iv_name
      INTO @ev_data.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_GL_UTIL=>POPUP_CONF
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TITLE                       TYPE        CSEQUENCE (default ='Confirmation')
* | [--->] IV_TEXT                        TYPE        CSEQUENCE
* | [--->] IV_TEXTBUT1                    TYPE        CSEQUENCE (default ='Yes')
* | [--->] IV_ICONBUT1                    TYPE        ICON_NAME (default ='ICON_OKAY')
* | [--->] IV_TEXTBUT2                    TYPE        CSEQUENCE (default ='No')
* | [--->] IV_ICONBUT2                    TYPE        ICON_NAME (default ='ICON_CANCEL')
* | [--->] IV_DEFAULT                     TYPE        CHAR1 (default ='2')
* | [--->] IV_CANCBUT                     TYPE        XFELD (default =SPACE)
* | [--->] IV_POPUPTYP                    TYPE        ICON_NAME (default ='ICON_MESSAGE_QUESTION')
* | [<-()] RV_ANSWER                      TYPE        CHAR1
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD popup_conf.

    IF sy-batch IS NOT INITIAL.
      rv_answer = '1'. " Sim
      RETURN.

    ENDIF.

* Available POPUP_TYPE:
    " ICON_MESSAGE_INFORMATION
    " ICON_MESSAGE_WARNING
    " ICON_MESSAGE_ERROR
    " ICON_MESSAGE_QUESTION
    " ICON_MESSAGE_CRITICAL

* Answer => 1 - Sim / 2 - Não / A - Cancelar
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = iv_title
        text_question         = iv_text
        text_button_1         = iv_textbut1
        icon_button_1         = iv_iconbut1
        text_button_2         = iv_textbut2
        icon_button_2         = iv_iconbut2
        default_button        = iv_default
        display_cancel_button = iv_cancbut
        popup_type            = iv_popuptyp
      IMPORTING
        answer                = rv_answer
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.

  ENDMETHOD.

ENDCLASS.
