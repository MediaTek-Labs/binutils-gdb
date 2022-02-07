# This shell script emits a C file. -*- C -*-
# It does some substitutions.
fragment <<EOF

struct ld_emulation_xfer_struct ld_${EMULATION_NAME}_emulation =
{
  ${LDEMUL_BEFORE_PARSE-gld${EMULATION_NAME}_before_parse},
  ${LDEMUL_SYSLIB-syslib_default},
  ${LDEMUL_HLL-hll_default},
  ${LDEMUL_AFTER_PARSE-after_parse_default},
  ${LDEMUL_AFTER_OPEN-after_open_default},
  ${LDEMUL_AFTER_CHECK_RELOCS-after_check_relocs_default},
  ${LDEMUL_BEFORE_PLACE_ORPHANS-before_place_orphans_default},
  ${LDEMUL_AFTER_ALLOCATION-after_allocation_default},
  ${LDEMUL_SET_OUTPUT_ARCH-set_output_arch_default},
  ${LDEMUL_CHOOSE_TARGET-ldemul_default_target},
  ${LDEMUL_BEFORE_ALLOCATION-before_allocation_default},
  ${LDEMUL_GET_SCRIPT-gld${EMULATION_NAME}_get_script},
  "${EMULATION_NAME}",
  "${OUTPUT_FORMAT}",
  ${LDEMUL_FINISH-finish_default},
  ${LDEMUL_CREATE_OUTPUT_SECTION_STATEMENTS-NULL},
  ${LDEMUL_OPEN_DYNAMIC_ARCHIVE-NULL},
  ${LDEMUL_PLACE_ORPHAN-NULL},
  ${LDEMUL_SET_SYMBOLS-NULL},
  ${LDEMUL_PARSE_ARGS-NULL},
  ${LDEMUL_ADD_OPTIONS-NULL},
  ${LDEMUL_HANDLE_OPTION-NULL},
  ${LDEMUL_UNRECOGNIZED_FILE-NULL},
  ${LDEMUL_LIST_OPTIONS-NULL},
  ${LDEMUL_RECOGNIZED_FILE-NULL},
  ${LDEMUL_FIND_POTENTIAL_LIBRARIES-NULL},
  ${LDEMUL_NEW_VERS_PATTERN-NULL},
  ${LDEMUL_EXTRA_MAP_FILE_TEXT-NULL},
  ${LDEMUL_EMIT_CTF_EARLY-NULL},
  ${LDEMUL_ACQUIRE_STRINGS_FOR_CTF-NULL},
  ${LDEMUL_NEW_DYNSYM_FOR_CTF-NULL},
  ${LDEMUL_PRINT_SYMBOL-NULL}
};
EOF