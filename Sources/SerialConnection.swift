//
//  SerialConnection.swift
//  cereal
//
//  Created by Taylor Lineman on 3/26/25.
//

import ORSSerial
import ArgumentParser

class SerialConnection: NSObject, @unchecked Sendable {
    enum SerialConnectionError: LocalizedError {
        case failedToOpen
        case failedToStart
        
        var errorDescription: String? {
            switch self {
            case .failedToOpen:
                return "Failed to open serial port"
            case .failedToStart:
                return "Failed to start serial port"
            }
        }
    }
    
    enum StopBits: UInt, EnumerableFlag {
        case one = 1
        case two = 2
    }
    
    enum Parity: EnumerableFlag {
        case none
        case odd
        case even
        
        var orsserialParity: ORSSerialPortParity {
            switch self {
            case .none:
                return .none
            case .odd:
                return .odd
            case .even:
                return .even
            }
        }
    }
    
    enum FlowControl: EnumerableFlag {
        case rts_cts
        case dtr_dsr
        case dcd
    }

    
    let serialPort: ORSSerialPort
    let standardInputFileHandle = FileHandle.standardInput

    var device: String
    var baudRate: Int
    
    var terminateBecauseOfError: Bool = false
    
    init(device: String, baudRate: Int, stopBits: StopBits, parity: Parity, flowControls: [FlowControl]) throws {
        self.device = device
        self.baudRate = baudRate
        
        let tmp = ORSSerialPort(path: device)
        guard let tmp else { throw SerialConnectionError.failedToOpen }
        self.serialPort = tmp
        
        super.init()
        self.serialPort.delegate = self
        self.serialPort.baudRate = NSNumber(value: self.baudRate)
        
        serialPort.numberOfStopBits = stopBits.rawValue
        serialPort.parity = parity.orsserialParity
        serialPort.usesDTRDSRFlowControl = flowControls.contains(.dtr_dsr)
        serialPort.usesRTSCTSFlowControl = flowControls.contains(.rts_cts)
        serialPort.usesDCDOutputFlowControl = flowControls.contains(.dcd)
    }
    
    deinit {
        if serialPort.isOpen {
            terminate()
        }
    }
    
    func start() throws {
        guard !serialPort.isOpen else { terminate(); throw SerialConnectionError.failedToOpen }
        serialPort.open()
        guard serialPort.isOpen else { terminate(); throw SerialConnectionError.failedToOpen }
        
        // Forward input down the serial connection
        setbuf(stdout, nil)
        standardInputFileHandle.readabilityHandler = { [self] (fileHandle: FileHandle)  in
            let data = fileHandle.availableData
            DispatchQueue.main.async {
                self.send(data)
            }
        }
    }
        
    func terminate(error: Error? = nil) {
        serialPort.close()
        if let error {
            terminateBecauseOfError = true
            print("Disconnecting from \(self.serialPort.name.bold) because of an error")
            print("Error".red.bold, error.localizedDescription)
            cereal.exit(withError: cereal.exitCode(for: error))
        }
    }
    
    func send(_ data: Data) {
        serialPort.send(data)
    }
    
    func printString(input: String) {
        for character in input {
            print(character, terminator: "")
        }
    }
}

extension SerialConnection: ORSSerialPortDelegate {
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: any Error) {
        terminate(error: error)
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        if let string = String(data: data, encoding: .utf8) {
            printString(input: string)
        }
    }
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        terminate()
    }
}
