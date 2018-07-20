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
* * Reading operation counts as sleep, and can advance time.
* * ANY special register not implemented.

### 诚尚Micro
A SHENZHEN I/O ChengShangMicro module.

* ID: `CSMicro`
* Registers: ACC and DAT
* Ports: x0, x1, x2, x3, p0, p1
* Notes:
* * Ports p0 and p1 are not tested, as any non-blocking port.
* * Visualizer does not display instruction states
* * GEN instruction not implemented

### EXA
```
LINK 8
GRAB 21
```

* ID: `EXA`
* Registers: X, T, F, M, G, C
* Ports: *
* Notes:
* * Limited port compatibility with other modules.

### NumberInput
Manual user number input field.

* ID: `NumberInput`
* Ports: num
* Notes:
* * Allows arbitrary text input, please don't do it.

### VisualizationModule
Simple visualization module.

* ID: `VisModule`
* Ports: in
* Notes:
* * Apart from TIS-100 version, sending values, less than -1 will reset it to color 0
* * Palette and size can be configured.

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