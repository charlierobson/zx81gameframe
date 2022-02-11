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


## Higher level functionality

### The input system

The input system is logically arranged as a number of buttons. At any time you can tell whether the button:
* Is not pressed
* Has just been pressed
* Is held
* Has just been released

The button has an 8 frame memory of its past inputs, held in a single byte. Every time the input is read it will shift the state memory along one and insert the current state as bit 0. This is how you can determine all of the states mentioned above. 

For example:

|Input byte|Meaning|
| :-: | :- |
| %00000000 | Button not pressed for 8 frames |
| %00000001 | Button just pressed |
| %00000010 | Button just released |
| %00011111 | Button held for 3 frames |

In code you would simply look at the 2 least significant bits to determine a number of states. 01 is just pressed, 10 just released etc.

Each button can be represented by a key, joystick or both. Neither makes no sense here. The joystick in this case is the ZXpand joystick, but the code could be altered for other input types. The button is defined in a 5 byte structure:

```
	.byte	%00001000,$7F,%00000001,0		; startgame
```

|Byte|Meaning|
| :-: | :- |
|0|Joystick switch mask|
|1|Keyboard half row input port address|
|2|Keyboard column bit mask|
|3|key state|

For ZXpand the joystick bits are:
```
7 6 5 4 3 2 1 0
U D L R F - - -
```

The keyboard is mapped like so:

|Half row port address|Column bit mapping|
| :-: | :- |
|$FE|- - - V C X Z SHIFT|	
|$FD|- - - G F D S A|
|$FB|- - - T R E W Q|
|$F7|- - - 5 4 3 2 1|
|$EF|- - - 6 7 8 9 0|
|$DF|- - - Y U I O P|
|$BF|- - - H J K L NEWLINE|	
|$7F|- - - B N M . SPACE|

So referring back to the example entry above you see this button is mapped to:
* joystick bit 3 (%00001000)
  * which from the table above is the fire button.
* half row $7f, bit 0 (%00000001)
  * which from the table above yields SPACE

To ignore a joystick direction or key for a button you simply use the mask $FF, %11111111. Ignored keys should still use a valid half row port address.

Ignore joystick:
```
	.byte	%11111111,$7F,%00000001,0		; startgame
```
Ignore key:
```
	.byte	%00001000,$7F,%11111111,0		; startgame
```

There are 5 buttons declared at present and you are, of course, at liberty to add or remove at your pleasure. If you do this, however, be sure to update the start of the INPUT._read method to call the correct number of updates. The code is structured such that the last update is a fall-through into the update routine, saving a CALL/RET cost.

Ideally you would call INPUT._read at the start of every game loop. You can of course do this in your main loop, straight after any frame synchronisation that you might do. However the input routine has been written to have a constant run time, coming in at 724 t-states at last count. This is about the right length to replace the built-in key scanning in the display routine's vertical sync interrupt. If you change the number of buttons the change in processing time will need to be considered.

Functions exist for taking a port/mask pair and resolving them to a key name. This is used by the redefinition code. It's fairly straight forward so I won't explain it.
