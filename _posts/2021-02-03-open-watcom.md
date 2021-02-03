---
layout: post
title:  "Building an Open Watcom Linux-to-DOS cross-compiler"
date:   2021-02-03
---

Nowadays, [Open Watcom v2](https://github.com/open-watcom/open-watcom-v2) seems to be the go-to free software compiler for 16-bit DOS. It can run on DOS natively, but you can also cross-compile from modern operating systems, including 64-bit Linux.

Although there is an official [Wiki](https://github.com/open-watcom/open-watcom-v2/wiki/Build) about building the toolchain, to me it reads more like a reference for those already in the know (and it's a lot of words anyway!)

Below I reproduce just the steps I had to take to get a fully working toolchain.

1. `git clone git@github.com:open-watcom/open-watcom-v2.git`, `cd open-watcom-v2`
2. in _setvars.sh_, I uncommented `export OWDOSBOX=dosbox`, since I already had DOSBox installed
3. `source setvars.sh`
4. `./buildrel.sh`

This will use your system GCC to build the Open Watcom toolchain (for all possible hosts & targets).

Assuming everything went fine, to use the newly-build compiler, some environment variables need to be configured -- unlike GCC, where it usually suffices to have it in `PATH`. 

```sh
export WATCOM=$(pwd)/rel
export PATH=$WATCOM/binl64:$WATCOM/binl:$PATH
export INCLUDE=$WATCOM/h
```

Let's see if we can compile a minimal program...

```sh
wcl -bt=dos $WATCOM/src/hello.c
```

...and run it.

```sh
dosbox hello.exe
```

## Using DOS system calls

Open Watcom provides an implementation of the Standard C library; however, if you prefer to indulge in the quirkiness of DOS system calls, you can also do that, using Watcom's funky `#pragma aux` syntax. The following program illustrates a call to the _INT 21h AH=09h_ function (display string):

```c
void print(char *string);
#pragma aux print = \
        "mov ah, 09h"   \
        "int 0x21"      \
        parm    [dx]    \
        modify  [ax];

int main(void) {
    /* string must be terminated with '$' */
    print("hello, world\n$");
    return 0;
}
```

For portability, though, it might be better to include `<dos.h>` and use the wrappers found there (such as `_dos_write`), which should still be a lighter abstraction than `<stdio.h>`.
