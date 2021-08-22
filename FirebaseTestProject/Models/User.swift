//
//  User.swift
//  User
//
//  Created by John Royal on 8/21/21.
//

import Foundation

struct User: Equatable, FirebaseConvertable {
    let id: UUID
    var name: String
    
    init(id: UUID = .init(), name: String) {
        self.id = id
        self.name = name
    }
    
    static let preview = User(id: UUID(uuidString: "9264E796-F622-44DA-88A4-2622D6E97F2B")!, name: "Jane Doe")
}
