//
//  ExecutableFile.swift
//  MachOhMy
//
//  Created by Anton Grachev on 04/05/2019.
//  Copyright © 2019 Anton Grachev. All rights reserved.
//

import Foundation
import MachO

public final class ExecutableFile {
    
    // MARK: - Internal types
    
    private final class LoadCommand<ContentType> {
        
        let content: ContentType
        
        init(content: ContentType) {
            self.content = content
        }
        
    }
    
    // MARK: - Properties
    
    private let machHeader: MachHeaderDescriptor
    
    // MARK: - Init
    
    init(machHeader: MachHeaderDescriptor) {
        self.machHeader = machHeader
    }
    
    // MARK: - Public methods
    
    public func uuid() -> UUID? {
        guard let command = findLoadCommand(LC_UUID) as LoadCommand<UUID>? else {
            return nil
        }
        return command.content
    }
    
    public func encryptionInfo() -> UInt32? {
        guard let command = findLoadCommand(LC_ENCRYPTION_INFO) as LoadCommand<UInt32>? else {
            return nil
        }
        return command.content
    }
    
    public func encryptionInfo64() -> UInt32? {
        guard let command = findLoadCommand(LC_ENCRYPTION_INFO_64) as LoadCommand<UInt32>? else {
            return nil
        }
        return command.content
    }
    
    // MARK: - Private methods
    
    private func findLoadCommand<T>(_ loadCommand: Int32) -> LoadCommand<T>? {
        let headerSize = machHeader.is64Bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
        var cursor = UnsafeRawPointer(machHeader.pointer).advanced(by: headerSize)
        
        var resultCommand: LoadCommand<T>?
        
        for _ in 0..<machHeader.header.ncmds {
            let commandPointer = UnsafeRawPointer(cursor).bindMemory(to: segment_command_64.self, capacity: 1)
            let segmentCommand = commandPointer.pointee
            if segmentCommand.cmd != loadCommand {
                cursor = UnsafeRawPointer(cursor).advanced(by: Int(segmentCommand.cmdsize))
                continue
            }
            
            switch loadCommand {
            case LC_UUID:
                if let command = uuidLoadCommand(pointer: cursor) as? LoadCommand<T>? {
                    resultCommand = command
                }
                break;
                
            case LC_ENCRYPTION_INFO:
                if let command = encryptionInfoLoadCommand(pointer: cursor) as? LoadCommand<T>? {
                    resultCommand = command
                }
                break;
                
            case LC_ENCRYPTION_INFO_64:
                if let command = encryptionInfo64LoadCommand(pointer: cursor) as? LoadCommand<T>? {
                    resultCommand = command
                }
                break;
                
            default:
                print("Unsupported load command: \(loadCommand)")
            }
        }
        
        return resultCommand
    }
    
    private func uuidLoadCommand(pointer: UnsafeRawPointer) -> LoadCommand<UUID>? {
        let uuidCommand = loadCommand(pointer: pointer) as uuid_command
        return LoadCommand<UUID>(content: UUID(uuid: uuidCommand.uuid))
    }
    
    private func encryptionInfoLoadCommand(pointer: UnsafeRawPointer) -> LoadCommand<UInt32>? {
        let encryptionInfoCommand = loadCommand(pointer: pointer) as encryption_info_command
        return LoadCommand<UInt32>(content: encryptionInfoCommand.cryptid)
    }
    
    private func encryptionInfo64LoadCommand(pointer: UnsafeRawPointer) -> LoadCommand<UInt32>? {
        let encryptionInfoCommand = loadCommand(pointer: pointer) as encryption_info_command_64
        return LoadCommand<UInt32>(content: encryptionInfoCommand.cryptid)
    }
    
    private func loadCommand<T>(pointer: UnsafeRawPointer) -> T {
        return UnsafeRawPointer(pointer).bindMemory(to: T.self, capacity: 1).pointee
    }
    
}
