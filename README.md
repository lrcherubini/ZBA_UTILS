# ZBA_UTILS

Collection of legacy ABAP utilities and example programs.

## Overview

This repository contains various ABAP classes and reports. The code was
originally developed as quick utilities and is **not** aligned with SAP's
Clean Core or Clean ABAP guidelines. It serves as reference material or
starting point for further clean-up.

### Main Components

- **Application Log helper (`zcl_ba_bal_log_base`)**
  - Provides methods to write messages to the SAP Application Log.
  - Example usage is shown in `zba_bal_log_samples.prog.abap` which displays
    logs using `BAL_DSP_LOG_DISPLAY`.
- **Generic Utility class (`zcl_ba_util`)**
  - Contains helper methods for select-option handling, conversions and
    attachment retrieval.
- **Sample reports**
  - `zicon.prog.abap` – lists SAP icons and their texts.
  - `ztransp_table_content.prog.abap` – utility to transport table contents.
  - `zcopy_status.prog.abap` – copies GUI statuses and their translations.
  - `z_gw_v4_alias_request.prog.abap` – exports Gateway customizing to
    transport requests.

Additional table and data definitions reside in the `src` folder.

## Repository Layout

```
src/        ABAP source code managed via abapGit
.abapgit.xml  Configuration for abapGit
```

## State of the Code

The programs demonstrate direct `FORM` routines, global variables and other
patterns that do not adhere to Clean ABAP principles. Use this repository for
learning or migration purposes, but expect refactoring effort if aiming for a
Clean Core approach.

