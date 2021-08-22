//
//  Post.swift
//  Post
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation

struct Post: Identifiable, FirebaseConvertable {
    let title: String
    let text: String
    let author: User
    let id: UUID
    let timestamp: Date
    
    init(title: String, text: String, author: User, id: UUID = .init(), timestamp: Date = .init()) {
        self.title = title
        self.text = text
        self.author = author
        self.id = id
        self.timestamp = timestamp
    }
}

extension Post {
    @available(*, deprecated, message: "Specify the author with a User object instead.")
    init(title: String, text: String, author: String) {
        self.title = title
        self.author = .init(name: author)
        self.text = text
        self.id = UUID()
        self.timestamp = Date()
    }
    
    static let testPost = Post(title: "Title", text: "Content", author: "First Last")
}
