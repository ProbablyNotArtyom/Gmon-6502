# G'mon 6502

G'mon (the Generic Monitor) is a machine monitor based around being small and easy to add to.
Currently, with BASIC included, it sits right under 2KB in size.

## Summary of content

G'mon-6502 includes my monitor as well as a version of TinyBasic that i have transcoded to assemble with KickAssembler
The commands currently implemented in G'mon 6502:

  * Enter (CR)					| [HHHH] {Return} 				- Hex dump address
  * .							| [HHHH][.HHHH] {Return} 		- Hex dump address range
  * :							| [HHHH][:DD] {Return} 			- Poke data
  * g - Go						| [HHHH][G] {Return} 			- Run a program
  * v - Version					| [V] {Return} 					- Print version string
  * t - Text Dump				| [HHHH][T][XXXX] {Return} 		- Dump text string XXXX into memory location HHHH
  * x - Read text from memory	| [HHHH][X}[-X] {Return} 		- Print text string located at HHHH until a CR is printed (X = Number of times to continue after a CR is reached)
  * z - Convert bases			| [HH][Z][-{I}{O}]				- Convert a number (HH) to a different base (Option is H-Hex D-Decimal B-Binary, I=Input Base, O=Output Base)


## Usage

To compile G'mon-6502 for a given system, first edit Configuration.asm.
Variables that will likely need to be changed:

  * RomStart
  * RomSize
  * Clock

There are also config statements for a few things like boot messages and such.
Here you can also enable/disable TinyBasic.

Once that has been changed, replace the `Write` and `Read` functions in Kernal.asm with ones specific to your hardware

Now edit the `Makefile` to specify the command you use to run KickAssembler.
To build, enter the ./src/ directory and run `make` to generate ROM.bin.

The generated ROM can currently be used in [Symon](https://github.com/sethm/symon), a 6502 simulator (so long as Emulated = true).
Otherwise, just burn the ROM to an EEPROM and use it in your system!

## Links

* TinyBasic - [GitHub Repository](https://github.com/jefftranter/6502/tree/master/asm/tinybasic)

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for info about contributing to G'mon-6502.

## Authors

* **Carson Herrington / NotArtyom** - *All Code* - [Website](http://notartyoms-box.com)
