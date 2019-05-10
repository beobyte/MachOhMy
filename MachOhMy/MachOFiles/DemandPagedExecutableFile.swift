//
//  DemandPagedExecutableFile.swift
//  MachOhMy
//
//  Created by Anton Grachev on 04/05/2019.
//  Copyright © 2019 Anton Grachev. All rights reserved.
//

import Foundation
import MachO

public final class DemandPagedExecutableFile {

    // MARK: - Properties

    private let machHeader: MachHeaderDescriptor

    // MARK: - Init

    init(machHeader: MachHeaderDescriptor) {
        self.machHeader = machHeader
    }

    // MARK: - Public methods

    public func uuid() -> UUID? {
        guard let uuid = dataFromLoadCommand(LC_UUID) as UUID? else {
            return nil
        }
        return uuid
    }

    public func cryptId() -> UInt32? {
        guard let cryptId = dataFromLoadCommand(LC_ENCRYPTION_INFO) as UInt32? else {
            return nil
        }
        return cryptId
    }

    public func cryptId64() -> UInt32? {
        guard let cryptId = dataFromLoadCommand(LC_ENCRYPTION_INFO_64) as UInt32? else {
            return nil
        }
        return cryptId
    }
    
    public func codeSignature() -> Any? {
        guard let codeSignature = dataFromLoadCommand(LC_CODE_SIGNATURE) as Any? else {
            return nil
        }
        return codeSignature
    }

    // MARK: - Private methods
    
    private func dataFromLoadCommand<T>(_ commandType: Int32) -> T? {
        var data: T?
        
        for loadCommand in loadCommands {
            if loadCommand.type != commandType {
                continue
            }

            switch commandType {
            case LC_UUID:
                if let uuid = uuidFromLoadCommand(pointer: loadCommand.pointer) as? T? {
                    data = uuid
                }
                break;

            case LC_ENCRYPTION_INFO:
                if let cryptId = cryptIdFromLoadCommand(pointer: loadCommand.pointer) as? T? {
                    data = cryptId
                }
                break;

            case LC_ENCRYPTION_INFO_64:
                if let cryptId = cryptId64FromLoadCommand(pointer: loadCommand.pointer) as? T? {
                    data = cryptId
                }
                break;
                
            case LC_CODE_SIGNATURE:
                if let codeSignature = codeSignatureFromLoadCommand(pointer: loadCommand.pointer) as? T? {
                    data = codeSignature
                }
                break;

            default:
                print("Unsupported load command type: \(commandType)")
            }
        }

        return data
    }

    private func uuidFromLoadCommand(pointer: UnsafeRawPointer) -> UUID? {
        let uuidCommand = loadCommand(pointer: pointer) as uuid_command
        return UUID(uuid: uuidCommand.uuid)
    }

    private func cryptIdFromLoadCommand(pointer: UnsafeRawPointer) -> UInt32? {
        let encryptionInfoCommand = loadCommand(pointer: pointer) as encryption_info_command
        return encryptionInfoCommand.cryptid
    }

    private func cryptId64FromLoadCommand(pointer: UnsafeRawPointer) -> UInt32? {
        let encryptionInfoCommand = loadCommand(pointer: pointer) as encryption_info_command_64
        return encryptionInfoCommand.cryptid
    }
    
    private func codeSignatureFromLoadCommand(pointer: UnsafeRawPointer) -> Any? {
        let codeSignatureCommand = loadCommand(pointer: pointer) as linkedit_data_command
        let dataStart = UnsafeRawPointer(header.pointer).advanced(by: Int(codeSignatureCommand.dataoff))
        let superBlob = UnsafeRawPointer(dataStart).bindMemory(to: CSSuperBlob.self, capacity: 1).pointee
        if superBlob.magic != embeddedSignatureMagic {
            return nil
        }
        
        // TODO: Implement
        
        return nil
    }

    private func loadCommand<T>(pointer: UnsafeRawPointer) -> T {
        return UnsafeRawPointer(pointer).bindMemory(to: T.self, capacity: 1).pointee
    }
    
}

// MARK: - MachOFileDescriptor protocol

extension DemandPagedExecutableFile: MachOFileDescriptor {
    
    public var header: MachHeaderDescriptor {
        return machHeader
    }
    
}

// MARK: - Internal types and constants

private extension DemandPagedExecutableFile {
    
    // Based on https://opensource.apple.com/source/Security/Security-57337.50.23/codesign_wrapper/codesign.c.auto.html
    
    var embeddedSignatureMagic: UInt32 { return 0xfade0cc0 }
    var requirementsBlobMagic: UInt32 { return 0xfade0c01 }
    var codeDirectoryBlobMagic: UInt32 { return 0xfade0c02 }
    var entitlementsBlobMagic: UInt32 { return 0xfade7171 }
    
    struct CSBlobIndex {
        let type: UInt32    /* type of entry */
        let offset: UInt32  /* offset of entry */
    }
    
    struct CSSuperBlob {
        let magic: UInt32           /* magic number */
        let length: UInt32          /* total length of SuperBlob */
        let count: UInt32           /* number of index entries following */
        let index: [CSBlobIndex]    /* (count) entries */
    }
    
}
