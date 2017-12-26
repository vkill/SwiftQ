//
//  WorkStream.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-26.
//

import Foundation
import Async

final class WorkStream: Async.Stream, Async.ConnectionContext  {
    
    typealias Input = Task
    
    typealias Output = Task
    
    var upstream: ConnectionContext?
    
    var downstream: AnyInputStream<Output>?
    
    /// Remaining downstream demand
    var downstreamDemand: UInt = 0
    
    init() { }
    
    
    func input(_ event: InputEvent<Task>) {
        switch event {
        case .close:
            downstream?.close()
        case .connect(let upstream):
            self.upstream = upstream
        case .error(let error):
            downstream?.error(error)
        case .next(let next):
            
            next.execute().do { _ in
                self.downstream?.next(next)
                }.catch { error in
                   self.downstream?.error(error) // Pass this error along. Next stream must handle this.
                }
        }
    }
    
    func connection(_ event: ConnectionEvent) {
        switch event {
        case .cancel:
            self.downstreamDemand = 0
        case .request(let demand):
            self.downstreamDemand += demand
        }
        
        guard downstreamDemand > 0 else {
            upstream?.request()
            return
        }
        
        
    }
    
    
    func output<S>(to inputStream: S) where S : Async.InputStream, Output == S.Input {
        self.downstream = AnyInputStream(inputStream)
        inputStream.connect(to: self)
    }
    
    
}