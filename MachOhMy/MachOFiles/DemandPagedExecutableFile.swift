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

    private func loadCommand<T>(pointer: UnsafeRawPointer) -> T {
        return UnsafeRawPointer(pointer).bindMemory(to: T.self, capacity: 1).pointee
    }
    
}

extension DemandPagedExecutableFile: MachOFileDescriptor {
    
    public var header: MachHeaderDescriptor {
        return machHeader
    }
    
}
