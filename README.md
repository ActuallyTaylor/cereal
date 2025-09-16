# Cereal 🥣
`cereal` is a terminal based Serial Console. It was written as an alternative to using `screen` for interacting with serial devices on macOS.

<img width="706" alt="sample" src="https://github.com/user-attachments/assets/54fa15e4-c7c6-4175-90e4-4673058babf3" />

## Installation
`cereal` is availabe via [Homebrew](https://brew.sh). 
```
brew tap actuallytaylor/formulae
brew update
brew install cereal-console
```

## Features
- Connect to serial devices (tty, cu, etc...).
  -  If no device is provided to the command, you will be able to select from a list of connected serial ports.
- Set a baud rate for the serial connection.
  -  If no baud rate is provided, you can select from a set of commonly used baud rates. The default is 9600
- Receive and display *utf8* data from the serial connection.
- Keystrokes are captured and sent back to the serial connection.
- Exit with <kbd>ctrl</kbd> + <kbd>c</kbd>.
- Set Connection Parity.
- Set flow control options.
- Set # of stop bits.

## Command Line Usage
```
$ cereal -h
USAGE: cereal [--version] [--device <device>] [--baud-rate <baud-rate>] [--one] [--two] [--none] [--odd] [--even] [--rts_cts] [--dtr_dsr] [--dcd] [--cr] [--lf] [--crlf]

OPTIONS:
  -v, --version           Print version
  -d, --device <device>   Path to Serial Device.
  -b, --baud-rate <baud-rate>
                          Buad rate for serial connection
  --one/--two             # of Stop Bits for the serial connection. (default:
                          --one)
  --none/--odd/--even     Parity for the serial connection. (default: --none)
  --rts_cts/--dtr_dsr/--dcd
                          Flow Control options (multiple options allowed)
  --cr/--lf/--crlf        Change which line ending is sent when return / enter
                          is pressed. (default: --cr)
  -h, --help              Show help information.
```

## TODO
1. Add keybinds to toggle RTS & DTR pins.
2. Add a view of the current state of the RTS, DTR, CTS, DSR, and DCD pins.

## Credits
- [Swift Argument Parser](https://github.com/apple/swift-argument-parser.git)
- [ANSITerminal](https://github.com/pakLebah/ANSITerminal.git) 
- [ORSSerialPort](https://github.com/armadsen/ORSSerialPort)
