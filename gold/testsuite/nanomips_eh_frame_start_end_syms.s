
    .section .text, "ax", @progbits
    # Dummy function to generate eh frame
    .cfi_startproc
    .ent _start
_start:
    addiu $a1, $a2, 1

    .end _start
    .cfi_endproc
    .size _start, .-_start

    .extern __eh_frame_start
    .extern __eh_frame_end
    # If not referenced, eh frame start/end symbols are not added
    .section .reference_start_end, "aw", @progbits
    .4byte __eh_frame_start
    .4byte __eh_frame_end

    .ifdef hdr
    .4byte __eh_frame_hdr_start
    .4byte __eh_frame_hdr_end
    .endif


