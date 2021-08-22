//
//  Post.swift
//  Post
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation

struct Post: Identifiable, FirebaseConvertable {
    let title: String
    let author: User
    let text: String
    let id: UUID
    let timestamp: Date
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
