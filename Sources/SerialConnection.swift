//
//  SerialConnection.swift
//  screen-improved
//
//  Created by Taylor Lineman on 3/26/25.
//

import ORSSerial

class SerialConnection: NSObject, @unchecked Sendable {
    enum SerialConnectionError: Error {
        case failedToOpenSerialPort
    }
    
    let serialPort: ORSSerialPort
    let standardInputFileHandle = FileHandle.standardInput

    var device: String
    var baudRate: Int
        
    init(device: String, baudRate: Int) throws {
        self.device = device
        self.baudRate = baudRate
        
        let tmp = ORSSerialPort(path: device)
        guard let tmp else { throw SerialConnectionError.failedToOpenSerialPort }
        self.serialPort = tmp
        
        super.init()
        self.serialPort.delegate = self
        self.serialPort.baudRate = NSNumber(value: self.baudRate)
    }
    
    deinit {
        print("Terminating serial connection")
        terminate()
    }
    
    func start() {
        serialPort.open()
        print("Connected to \(self.serialPort.name.bold)!")
        
        // Forward input down the serial connection
        setbuf(stdout, nil)
        standardInputFileHandle.readabilityHandler = { [self] (fileHandle: FileHandle)  in
            let data = fileHandle.availableData
            DispatchQueue.main.async {
                self.send(data)
            }
        }
    }
        
    func terminate() {
        serialPort.close()
        print("Disconnected from \(self.serialPort.name.bold)!")
    }
    
    func send(_ data: Data) {
        serialPort.send(data)
    }
    
    func handleInput() {
        
    }
    
    func printString(input: String) {
        for character in input {
            print(character, terminator: "")
        }
    }
}

extension SerialConnection: ORSSerialPortDelegate {
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: any Error) {
        // Error encountered Error Domain=NSPOSIXErrorDomain Code=16 "Resource busy" UserInfo={NSFilePath=/dev/cu.usbmodem2103, NSLocalizedDescription=Resource busy}
        print("Error encountered \(error)")
    }
    
    func serialPort(_ serialPort: ORSSerialPort, requestDidTimeout request: ORSSerialRequest) {
        print("Request timed out \(request)")
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceiveResponse responseData: Data, to request: ORSSerialRequest) {
        print("Did receive response \(responseData), \(request)")
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceivePacket packetData: Data, matching descriptor: ORSSerialPacketDescriptor) {
        print("Recieved packet \(packetData), descriptor \(descriptor)")
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
