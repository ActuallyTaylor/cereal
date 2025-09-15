// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import ANSITerminal
import ORSSerial

public let CEREAL_VERSION = "1.1.2"

@main
struct cereal: ParsableCommand {
    enum ArgumentError: LocalizedError {
        case invalidDevice
        case pickerReturnedNoDevice
        case pickerReturnedInvalidDevice
        case invalidBaudRate
        
        var errorDescription: String? {
            switch self {
            case .invalidDevice:
                return "No serial device specified"
            case .invalidBaudRate:
                return "Invalid baud rate specified"
            case .pickerReturnedNoDevice:
                return "Internal error: Picker returned no device"
            case .pickerReturnedInvalidDevice:
                return "Internal error: Picker returned invalid device"
            }
        }
    }
    
    @Flag(name: .shortAndLong, help: "Print version")
    var version: Bool = false

    @Option(name: .shortAndLong, help: "Path to Serial Device.")
    var device: String?
    
    @Option(name: .shortAndLong, help: "Buad rate for serial connection")
    var baudRate: Int?
    
    @Flag(help: "# of Stop Bits for the serial connection.")
    var stopBits: SerialConnection.StopBits = .one
    
    @Flag(help: "Parity for the serial connection.")
    var parity: SerialConnection.Parity = .none
    
    @Flag(help: "Flow Control options (multiple options allowed)")
    var flowControl: [SerialConnection.FlowControl] = []
    
    mutating func run() throws {
        if version {
            runVersion()
            return
        }
        
        do {
            if device == nil {
                let ports = ORSSerialPortManager.shared().availablePorts.map({$0.name})
                let picker = Picker(title: "Select a Serial Device", options: ports)
                guard let deviceName = try picker.choose() else { throw ArgumentError.pickerReturnedNoDevice }
                guard let serialDevice = ORSSerialPortManager.shared().availablePorts.first(where: {$0.name == deviceName}) else { throw ArgumentError.pickerReturnedInvalidDevice }
                device = serialDevice.path
            }
            
            if baudRate == nil {
                let bauds = [300, 1200, 2400, 4800, 9600, 19200, 38400, 57600, 115200]
                let picker = Picker(title: "Select Baud Rate", options: bauds, defaultOption: 9600)
                baudRate = try picker.choose()
            }
            
            guard let device else { throw ArgumentError.invalidDevice }
            guard let baudRate else { throw ArgumentError.invalidBaudRate }
            
            // Start intercepting ctrl-c so we can exit gracefully.
            signal(SIGINT, SIG_IGN) // // Make sure the signal does not terminate the application.
            
            let sigintSrc = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
            sigintSrc.setEventHandler {
                cereal.exitGracefully()
            }
            sigintSrc.resume()

            clearScreen()
            
            let connection = try SerialConnection(device: device, baudRate: baudRate, stopBits: stopBits, parity: parity, flowControls: flowControl)
            try connection.start()
            
            RunLoop.main.run()
        } catch let error as PickerError {
            switch error {
            case .gracefulExit:
                cereal.exitGracefully()
            case .noOptions:
                try exitWithError(error: error)
            }
        } catch {
            try exitWithError(error: error)
        }
    }
    
    static func exitGracefully() {
        cursorOn()
        setDefault()
        writeln()
        moveToColumn(0)
        print("Cereal Complete! Have a nice day :)".bold.green)
        cereal.exit(withError: ExitCode(0))
    }
    
    func exitWithError(error: Error) throws {
        cursorOn()
        setDefault()
        let errorCode = cereal.exitCode(for: error)
        if errorCode.isSuccess {
            print("Cereal Complete! Have a nice day :)".bold.green)
            throw errorCode
        } else {
            print("Error:".bold.red, error.localizedDescription)
            throw errorCode
        }
    }
        
    func runVersion() {
        print("cereal", CEREAL_VERSION)
    }
}
