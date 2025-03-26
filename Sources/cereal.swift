// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import ANSITerminal
import ORSSerial

@main
struct cereal: ParsableCommand {
    enum ArgumentError: Error {
        case invalidDevice
        case invalidBaudRate
    }
    
    @Option(name: .shortAndLong, help: "The serial port to connect too")
    var device: String?
    
    @Option(name: .shortAndLong, help: "Baud rate to communicate with")
    var baudRate: Int?
    
    mutating func run() throws {
        if device == nil {
            let ports = ORSSerialPortManager.shared().availablePorts.map({$0.name})
            let picker = Picker(title: "Select a Serial Device", options: ports)
            guard let deviceName = picker.choose() else { throw ArgumentError.invalidDevice }
            guard let serialDevice = ORSSerialPortManager.shared().availablePorts.first(where: {$0.name == deviceName}) else { throw ArgumentError.invalidDevice }
            device = serialDevice.path
        }
        
        if baudRate == nil {
            let bauds = [300, 1200, 2400, 4800, 9600, 19200, 38400, 57600, 115200]
            let picker = Picker(title: "Select Baud Rate", options: bauds, defaultOption: 9600)
            baudRate = picker.choose()
        }
        
        guard let device else { throw ArgumentError.invalidDevice }
        guard let baudRate else { throw ArgumentError.invalidBaudRate }
        
        clearScreen()
        
        let connection = try SerialConnection(device: device, baudRate: baudRate)
        connection.start()
        
        RunLoop.main.run()

        print("Screen Complete! Have a nice day :)".bold.green)
    }
}
