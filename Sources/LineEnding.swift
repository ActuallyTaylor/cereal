//
//  LineEnding.swift
//  cereal
//
//  Created by Taylor Lineman on 2/3/26.
//

import ArgumentParser
import Foundation

enum LineEnding: String, EnumerableFlag {
    case cr = "cr"
    case lf = "lf"
    case crlf = "crlf"
    
    var data: Data {
        switch self {
        case .cr:
            Data(bytes: [13], count: 1)
        case .lf:
            Data(bytes: [10], count: 1)
        case .crlf:
            Data(bytes: [13, 10], count: 2)
        }
    }
}
