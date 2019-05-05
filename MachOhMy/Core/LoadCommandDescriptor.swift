//
//  LoadCommandDescriptor.swift
//  MachOhMy
//
//  Created by Anton Grachev on 05/05/2019.
//  Copyright © 2019 Anton Grachev. All rights reserved.
//

import Foundation
import MachO

public struct LoadCommandDescriptor {
    
    // MARK: - Properties
    
    public let pointer: UnsafePointer<load_command>
    public var command: load_command {
        return pointer.pointee
    }
    public var type: UInt32 {
        return command.cmd
    }
    
}
