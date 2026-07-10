# =========================================================
# Shell behaviour
# =========================================================

setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT    # sort file10 after file9, not after file1
setopt INTERACTIVE_COMMENTS # allow # comments on the command line
setopt EXTENDED_GLOB        # ^, ~, **/, glob qualifiers like *(.)

# Treat /, ., - etc. as word boundaries so Ctrl-W deletes path segments
WORDCHARS=''
