//
//  MachHeaderFileProvider.swift
//  MachOhMy
//
//  Created by Anton Grachev on 04/05/2019.
//  Copyright © 2019 Anton Grachev. All rights reserved.
//

import Foundation
import MachO

public final class MachHeaderFileProvider {
    
    // MARK: - Public methods
    
    static func executableFile() -> ExecutableFile? {
        guard let pointer = findHeader(with: MH_EXECUTE) else {
            return nil
        }
        let machHeader = MachHeaderDescriptor(pointer: pointer)
        return ExecutableFile(machHeader: machHeader)
    }
    
    // MARK: - Private methods
    
    private static func findHeader(with filetype: Int32) -> UnsafePointer<mach_header>? {
        var machHeader: UnsafePointer<mach_header>?
        
        for i in 0..<_dyld_image_count() {
            if let header = _dyld_get_image_header(i), header.pointee.filetype == filetype {
                machHeader = header
                break
            }
        }
        
        return machHeader
    }
    
}
