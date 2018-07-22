# ZachLang

Implementation of assembly languages made by Zachtronics.

## Module specifications

### General notes
* Different assembly modules can connect to each other
* There is no -999/999 integer limitation
* Instruction count limitation is not present.

### TIS-100
A TIS-100 module.

* ID: `TIS-100`
* Registers: ACC and BAK
* Ports: RIGHT/DOWN/LEFT/UP
* Notes:
  * Reading operation counts as sleep, and can advance time.
  * ANY special register not tested.

### 诚尚Micro
A SHENZHEN I/O ChengShangMicro module.

* ID: `CSMicro`
* Registers: ACC and DAT
* Ports: x0, x1, x2, x3, p0, p1
* Notes:
  * Ports p0 and p1 are not tested, as any non-blocking port.
  * Visualizer does not display instruction states
  * GEN instruction not implemented

### EXA
```
LINK 8
GRAB 21
```

* ID: `EXA`
* Registers: X, T, F
* Ports: M
* Notes:
  * Limited port compatibility with other modules.
  * Communication not implemented
  * May not be accurate
  * Files implementation limited (only one file, index always 0)
  * Host implementation limited to one host
  * Replication not implemented
  * Keyword implementation kinda done, but not really.
  * Constant keywords can be created via `'` or `"` quoting.
  * `@` character acts as comment starter
  * `VOID` operator just reads the provided register.
  * No, seriously, you expected full implementation of assembly from a game that haven't even released yet?


### NumberInput
Manual user number input field.

* ID: `NumberInput`
* Ports: num
* Notes:
  * Allows arbitrary text input, please don't do it.

### VisualizationModule
Simple visualization module.

* ID: `VisModule`
* Ports: in
* Notes:
  * Apart from TIS-100 version, sending values, less than -1 will reset it to color 0
  * Palette and size can be configured.

## Compiling from source
### Libraries
* `hscript` (not used atm)
* `heaps`
* `hldx`
### Haxe
You need Haxe 4-preview 4 and HL 1.6 at least to compile the visual code.

## Resources
* Fonts taken from Heaps sample resources.
* Assembly languages and most of the modules invented by Zachtronics.

## License
This work licensed under MIT license.
Copyright on actual assembly language and module specifications belong to Zachtronics.