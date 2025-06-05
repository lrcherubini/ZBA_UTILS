REPORT zicon.

START-OF-SELECTION.

  DATA: ol_struct TYPE REF TO cl_abap_structdescr,
        ol_elem   TYPE REF TO cl_abap_elemdescr,
        tl_comp   TYPE cl_abap_structdescr=>component_table,
        wl_comp   LIKE LINE OF tl_comp,
        wl_dfies  TYPE dfies.

  TYPES: BEGIN OF tp_icon,
           id        TYPE icon-id,
           name      TYPE icon-name,
           oleng     TYPE icon-oleng,
           button    TYPE icon-button,
           status    TYPE icon-status,
           message   TYPE icon-message,
           function  TYPE icon-function,
           textfield TYPE icon-textfield,
           internal  TYPE icon-internal,
           locked    TYPE icon-locked,
           i_class   TYPE icon-i_class,
           i_group   TYPE icon-i_group,
           i_member  TYPE icon-i_member,
           quickinfo TYPE icont-quickinfo,
           shorttext TYPE icont-shorttext,
         END OF tp_icon.

  DATA: tl_icon TYPE TABLE OF tp_icon,
        wl_icon LIKE LINE OF tl_icon.

  DATA: vl_pos   TYPE i.

  FIELD-SYMBOLS <fl_field>.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE tl_icon
    FROM icon
    LEFT JOIN icont
      ON  icont~id    EQ icon~id
      AND icont~langu EQ 'E'.

  ol_struct ?= cl_abap_typedescr=>describe_by_data( wl_icon ).
  tl_comp = ol_struct->get_components( ).

  DELETE tl_comp WHERE name EQ 'MANDT'.

  LOOP AT tl_comp INTO wl_comp.

    ADD 1 TO vl_pos.

    ol_elem ?= wl_comp-type.

    wl_dfies = ol_elem->get_ddic_field( ).

    IF wl_dfies-outputlen LT 6.
      wl_dfies-outputlen = 6.

    ENDIF.

    CASE wl_comp-name.
      WHEN 'ID'.
        WRITE AT vl_pos(wl_dfies-outputlen) 'Icon'.
        ADD wl_dfies-outputlen TO vl_pos.

        WRITE AT 8(wl_dfies-outputlen) wl_dfies-reptext.
        ADD wl_dfies-outputlen TO vl_pos.

      WHEN OTHERS.
        WRITE AT vl_pos(wl_dfies-outputlen) wl_dfies-reptext.
        ADD wl_dfies-outputlen TO vl_pos.

    ENDCASE.
  ENDLOOP.

  ULINE.

  LOOP AT tl_icon INTO wl_icon.

    CLEAR vl_pos.

    LOOP AT tl_comp INTO wl_comp.

      ASSIGN COMPONENT wl_comp-name OF STRUCTURE wl_icon TO <fl_field>.

      ADD 1 TO vl_pos.

      ol_elem ?= wl_comp-type.

      wl_dfies = ol_elem->get_ddic_field( ).

      IF wl_dfies-outputlen LT 6.
        wl_dfies-outputlen = 6.

      ENDIF.

      CASE wl_comp-name.
        WHEN 'ID'.
          WRITE AT /vl_pos(wl_dfies-outputlen) <fl_field>.

          ADD wl_dfies-outputlen TO vl_pos.

          WRITE AT vl_pos(wl_dfies-outputlen) <fl_field> USING EDIT MASK ' ____'.

          ADD wl_dfies-outputlen TO vl_pos.

        WHEN OTHERS.
          WRITE AT vl_pos(wl_dfies-outputlen) <fl_field>.

          ADD wl_dfies-outputlen TO vl_pos.

      ENDCASE.
    ENDLOOP.
  ENDLOOP.
