# Catholicon

A functional code-golf programming language.

## Compilation

To compile, run

    MIX_ENV=prod mix escript.build

However, if you would like debug messages, instead run

    MIX_ENV=dev mix escript.build

## Usage

    ./catholicon [OPTION]... FILE/CODE
    Example: ./catholicon -eu Ċ (reads one line of input then immediately outputs it)

      -e, --eval    Evaluate code given on the command line rather than reading a file
      -u, --unicode Assume code is in unicode rather than in Catholicon's code page.
      -s, --silent  Don't output the result of evaluation.
      -l, --literal Output using IO.puts instead of IO.inspect
