//
//  MachHeaderDescriptor.swift
//  MachOhMy
//
//  Created by Anton Grachev on 04/05/2019.
//  Copyright © 2019 Anton Grachev. All rights reserved.
//

import Foundation
import MachO

final class MachHeaderDescriptor {
    
    // MARK: - Properties
    
    let pointer: UnsafePointer<mach_header>
    var header: mach_header {
        return pointer.pointee
    }
    var is64Bit: Bool {
        return (header.magic == MH_MAGIC_64) || (header.magic == MH_CIGAM_64)
    }
    
    // MARK: - Init
    
    init(pointer:UnsafePointer<mach_header>) {
        self.pointer = pointer
    }
    
}
