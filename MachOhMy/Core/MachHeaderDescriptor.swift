//
//  MachHeaderDescriptor.swift
//  MachOhMy
//
//  Created by Anton Grachev on 04/05/2019.
//  Copyright © 2019 Anton Grachev. All rights reserved.
//

import Foundation
import MachO

public struct MachHeaderDescriptor {
    
    // MARK: - Properties
    
    let pointer: UnsafePointer<mach_header>
    var machHeader: mach_header {
        return pointer.pointee
    }
    var is64Bit: Bool {
        return (machHeader.magic == MH_MAGIC_64) || (machHeader.magic == MH_CIGAM_64)
    }
    
}
