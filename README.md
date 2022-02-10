# ZX81 Game Framework
ZX81 machine code program framework. You know, for games.

## About the code

The code is written to be used with the excellent assembler BRASS. It is TASM compatible and cross platform. Get it free [here](http://www.benryves.com/bin/brass/).

Assemble the code thusly:

```
brass [assembler file] [output binary name] -s -l [listing file name]
```

So for this framework you'd probably type:

```
brass a_main.asm mygame.p -s -l mygame.html
```

The -s switch enabled case sensitivity. You need to be sensitive. It's just good practice. One day you'll use linux and you'll thank me.

The html listing file is a great resource when debugging, as is the .sym file that is generated alongside your binary. This can be used in a debugger to see symbols instead of numbers when disassembling or stepping through the code. In EightyOne for example, just drag and drop the .sym file onto the main window and the debugger will then use them.

The main file is called a_main, simply so it shows at the top of an alphabetically sorted listing. It contains the basic stuff needed to make a ZX81 auto-running 'P' type file:
* The System variables
* BASIC REM containing your game
* BASIC RAND USR for running it
* Display file

The files prefixed with 's_' are the 'screens':
* Title
* Game
* Game over
* Instructions
* Key redefinition

Any file not prefixed belongs to the 'general' category.

Each file is decalred to be part of a module. A module defines a namespace. Any labels defined with an underscore as their first character are considered local, and are only available outside of the file in question by prefixing the reference to it with the module name. Ex:

```
---- ABC.ASM
.module ABC

mygreatcode:            ; globally accessible
    ...
_mylocaldata:           ; local label
    ...

---- DEF.ASM
.module DEF

    ...
_mylocaldata:           ; local label
    ...


---- MAIN.ASM
    ...
    call mygreatcode            ; woop!
    ...
    ld   hl,ABC._mylocaldata    ; double woop!
    ld   de,DEF._mylocaldata    ; double double woop!
    ...
```

In this example you can call the function as normal from any source file/module. No underscore, global scope. Here you see two variables with the _same name_ being accessed unambiguously. You gotta love that, right?

"Oh SirMorris! Why'd you do this madness!" I hear you ask. Well, any sufficiently large program will have a _lot_ of labels, and by constraining them to have a local scope means you can re-use the names in many modules, without having to arbitrarily prefix the label name with some random word or number in order to avoid clashes elsewhere. Trust me, it's good. Just remember to start your file with `.module ...` and end it with `.endmodule`. You don't _technically_ need to end the module - the next module definition to come along will kinda do that for you - but it's good practice.

Another thing you'll find all over the shop is the use of temporary labels. These are markers that are valid until another of the same type is encountered. Ex:

```
    ...
-:  some code
    some code
    jr   {-}
    ...
    ...
-:  more code
    more code
    jr   {-}
```

Here we see a temporary label in use then later in the same code another is encountered. There is no ambiguity about which label is which, the second one becomes active as soon as it's declared. You can go forward as well as backward:

```
    ...
    jr   {+}
    some code
+:  some code
    ...
```

It should be obvious that temporary labels are useful for localised loops and skips. When you have nested loops or jumps over a large distance you should probably use text labels. Similarly if you like to use nice descriptive accurate label names to document the code as you go then this is always encouraged..!

Temporary labels are great, and they have other powers too, see the BRASS documentation.
