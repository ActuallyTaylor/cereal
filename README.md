# Cereal 🥣
`cereal` is a terminal based Serial Console. It was written as an alternative to using `screen` when interacting with serial devices.

<img width="706" alt="sample" src="https://github.com/user-attachments/assets/54fa15e4-c7c6-4175-90e4-4673058babf3" />

<!--
## Installation
`cereal` is availabe via [Homebrew](https://
```
brew tap actuallytaylor/casks
brew install --cask cereal
```
-->
## Features
- Connect to serial devices (tty, cu, etc...).
  -  If no device is provided to the command, you will be able to select from a list of connected serial ports.
- Set a baud rate for the serial connection.
  -  If no baud rate is provided, you can select from a set of commonly used baud rates. The default is 9600
- Receive and display *utf8* data from the serial connection.
- Keystrokes are captured and sent back to the serial connection.
- Exit with <kbd>ctrl</kbd> + <kbd>c</kbd>.

## Command Line Usage
```
$ cereal -h
USAGE: cereal [--device <device>] [--baud-rate <baud-rate>]

OPTIONS:
  -d, --device <device>   The serial port to connect too
  -b, --baud-rate <baud-rate>
                          Baud rate to communicate with
  -h, --help              Show help information.
```

## TODO
1. Add keybinds to toggle RTS & DTR pins.
2. Add a view of the current state of the RTS, DTR, CTS, DSR, and DCD pins.

## Credits
- [Swift Argument Parser](https://github.com/apple/swift-argument-parser.git)
- [ANSITerminal](https://github.com/pakLebah/ANSITerminal.git) 
- [ORSSerialPort](https://github.com/armadsen/ORSSerialPort)
