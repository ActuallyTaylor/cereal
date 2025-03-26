//
//  Picker.swift
//  screen-improved
//
//  Created by Taylor Lineman on 3/26/25.
//

import ANSITerminal

struct Picker<T> where T: CustomStringConvertible, T: Equatable {
    enum KeyCodes: Int {
        case upArrow = 65
        case downArrow = 66
        case enter = 13
    }

    struct PickerOption {
        var title: String
        var value: T
        var selected: Bool
        var row: Int
    }
    
    var title: String
    var options: [T]
    var defaultOption: T? = nil
    
    func choose() -> T? {
        guard options.count > 0 else { return nil }
        
        cursorOff()
        clearScreen()
        
        write("◆".lightCyan.bold)
        
        moveRight()
        write(title)
        
        moveDown()
        var optionRow = readCursorPos().row
        var options = options.map({ option in
            optionRow += 1
            return PickerOption(title: option.description, value: option, selected: false, row: optionRow - 1)
        })
        
        if let defaultOption,
           let defaultIndex = options.firstIndex(where: {$0.value == defaultOption}) {
            options[defaultIndex].selected = true
        } else {
            // Select first option
            options[0].selected = true
        }
        
        func renderOption(_ option: PickerOption) {
            moveTo(option.row, 0)
            clearLine()
            
            write("│".lightCyan)
            moveRight()
            
            if option.selected {
                write("●".lightGreen)
            } else {
                write("○".gray)
            }
            
            moveRight()
            
            if option.selected {
                write(option.title.bold)
            } else {
                write(option.title)
            }
        }
        
        func renderCap(with selection: String? = nil) {
            moveTo(optionRow, 0)
            clearLine()
            write("└".lightCyan)
            
            if let selection {
                moveRight()
                write(selection.bold)
            }
        }
        
        // Render all options
        for option in options {
            renderOption(option)
        }
        
        renderCap()
        
        func switchSelectedOption(from oldOption: Int, to newOption: Int) {
            options[oldOption].selected = false
            options[newOption].selected = true
            
            renderOption(options[oldOption])
            renderOption(options[newOption])
        }
        
        while true {
            clearBuffer()
            
            if keyPressed() {
                let keyCode = readCode()
                
                let selectedOption = options.firstIndex(where: { $0.selected })!
                if keyCode == KeyCodes.upArrow.rawValue {
                    var newSelectedOption = selectedOption.advanced(by: -1)
                    if newSelectedOption < 0 {
                        newSelectedOption = options.count - 1
                    }
                    switchSelectedOption(from: selectedOption, to: newSelectedOption)
                } else if keyCode == KeyCodes.downArrow.rawValue {
                    var newSelectedOption = selectedOption.advanced(by: 1)
                    if newSelectedOption >= options.count {
                        newSelectedOption = 0
                    }
                    switchSelectedOption(from: selectedOption, to: newSelectedOption)
                } else if keyCode == KeyCodes.enter.rawValue {
                    break
                }
            }
        }
        
        let selection = options.first(where: {$0.selected})
        renderCap(with: selection?.title)
        moveLineDown()
        
        // Reset screen
        setDefault()
        writeln()
        clearLine()
        
        return selection?.value
    }

}
