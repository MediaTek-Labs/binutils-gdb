# BALC Trampolines – design

If this feature is enabled via command line (see gold/options.h:1216), R_NANOMIPS_PC25_S1 type relocations related to the BALC instruction are used to identify potential locations where the 32-bit BALC can be replaced by a trampoline. The feature is turned on by default.

A special relocation, R_NANOMIPS_NOTRAMP (see elfcpp/nanomips.h:102), is introduced to enable this functionality to be turned off at the instruction level. After the RELAX and EXPAND phases, another linker phase, TRAMPOLINES, is introduced to generate the trampolines (see nanomips.cc, do_relax() method). This phase consists of two passes. In the first pass through all relocations of the mentioned type, occurrences of 32-bit BALC instructions are identified and code segmentation is performed into areas that can be covered by a single trampoline. In this phase, a special container is also constructed in which the locations where the trampolines have been decided to be, that is, the calls of the trampolines, are kept. This data set ie. addresses in it must be maintained during Gold's iterative process. An identical algorithm, but at the section level, has already been applied in the case of conditional branches. In the second pass, some of the 32-bit BALC instructions (a small number) are replaced by trampolines (three instructions), and the others by 16-bit BALC jumps to trampolines. In order to achieve this, two new transformations have been introduced (see nanomips-insn-property.h:80):

- BALC_TRAMP which generates a trampoline,
- BALC_CALL which converts BLAC32 to BALC16.

BALC_TRAMP does not change the relocation, it remains R_NANOMIPS_PC25_S1 and targets the original symbol.

BALC_TRAMP:

Instead of BALC32 <target_function> with R_NANOMIPS_PC25_S1 relocation, we'll have:
A: BALC16 C
B: BC16 D
C: BC32 <target_function> with R_NANOMIPS_PC25_S1 relocation
D:

BALC16 C is necessary to save the return address in RA, and BC16 D is necessary to jump over the trampoline on return.
This can be achieved with a shorter sequence of instructions, using ADDIUPC, but in that case, branch prediction is significantly compromised. In that case, trampoline looks like:

A: LAPC $rt, 4
B: BC32 <target_function>

BALC_CALL replaces R_NANOMIPS_PC25_S1 with R_NANOMIPS_PC11_S1, which still targets the original symbol (although it is too far away). In the relocation application phase, during each R_NANOMIPS_PC11_S1 that is applied to the BALC instruction, it is first checked (by searching the container) whether a trampoline call is expected at the given location, and if so, instead of the address of the target symbol, the address of the target trampoline is used.

    struct Balc_trampoline       // Represents balc32 instruction (candidate) in the code
    {
      Address address;           // Current address of balc32 instruction
      Address target;            // balc32 target
      bool ignore{true};         // Should this balc32 be ignored in the trampolines algorithm?
      bool is_trampoline{false}; // This balc32 is going to become a trampoline

      Balc_trampoline(Address address_, Address target_)
        : address(address_), target(target_) { }
    };

    struct Balc_trampoline_target // Represents a target of balc32 instruction
    {
      int count{0};      // How many calls to this target
      size_t first;      // Index of first balc32 which calls this target
      size_t trampoline; // Index of trampoline which will be used instead of real target
      size_t last;       // Index of last balc32 which calls this target
      Address target;    // Real target address
    };

See nanomips.cc:6120. We start with an array of balc32 candidates (Balc_trampoline). Then we create an intermediate array of targets (Balc_trampoline_target) and in a few passes populate all fields.
There should be a least 4 calls to the same target in a range of 2048 bytes. Then one of them is converted to a trampoline, and the others become trampoline calls (nanomips.cc:6131). Trampoline is the last candidate within reach of the first BALC candidate.

Ideally, the trampoline will become the center BALC within the 2048 byte frame, while the other BALCs will become calls to it (forward or backward). However, this algorithm does not guarantee that some of the marginal BALC will not go out of the range of +-1024 bytes relative to the trampoline (middle BALC). This can happen due to an "expand" operation or due to shifting entire sections by several bytes due to alignment. In that case, such BALC will remain BALC32. This is of course not completely optimal, but we currently have no idea how to overcome it. We rely on the assumption that this will happen very rarely and has no significant impact on code size.

*The current problem* occurs when maintaining addresses in the container in cases when entire sections are moved (e.g. in order to be 4 bytes aligned). This problem does not exist with conditional branching because they are processed at the section level, not at the entire code. An investigation is in progress.
