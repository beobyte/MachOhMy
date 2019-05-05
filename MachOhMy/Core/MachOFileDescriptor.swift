//
//  MachOFileDescriptor.swift
//  MachOhMy
//
//  Created by Anton Grachev on 05/05/2019.
//  Copyright © 2019 Anton Grachev. All rights reserved.
//

import Foundation
import MachO

public protocol MachOFileDescriptor: class {
    
    var header: MachHeaderDescriptor { get }
    var loadCommands: [LoadCommandDescriptor] { get }
    
}

extension MachOFileDescriptor {
    
    public var loadCommands: [LoadCommandDescriptor] {
        get {
            var loadCommands = [LoadCommandDescriptor]()
            
            let headerSize = header.is64Bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
            var cursor = UnsafeRawPointer(header.pointer).advanced(by: headerSize)
            for _ in 0..<header.machHeader.ncmds {
                let commandPointer = UnsafeRawPointer(cursor).bindMemory(to: load_command.self, capacity: 1)
                let loadCommand = LoadCommandDescriptor(pointer: commandPointer)
                loadCommands.append(loadCommand)
                cursor = UnsafeRawPointer(cursor).advanced(by: Int(commandPointer.pointee.cmdsize))
            }
            
            return loadCommands
        }
    }
    
}
