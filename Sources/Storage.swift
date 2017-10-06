//
//  Storage.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-06-22.
//
//

import Foundation

public final class Storage: Codable {
    
    let uuid: String
    
    let name: String
    
    var enqueuedAt: Int?
    
    var retryCount = 0
    
    var log: Log?
    
    public init<T: Task>(_ type: T.Type) {
        self.name = String(describing: type)
        self.uuid = UUID().uuidString
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Storage.CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(name, forKey: .name)
        try container.encode(enqueuedAt ?? Date().unixTime, forKey: .enqueuedAt)
        try container.encode(retryCount, forKey: .retryCount)
        try container.encodeIfPresent(log, forKey: .log)
    }
    
    func set(log: Log) {
        self.log = log
    }
    
}

struct Log: Codable {
    
    let message: String
    let consumer: String
    let date: Int
    
}

public enum TaskType: String {
    
    case task
    case schedulable
    case periodic
    
    
    init(_ type: String) {
        self = TaskType.init(rawValue: type) ?? .task
    }
}
