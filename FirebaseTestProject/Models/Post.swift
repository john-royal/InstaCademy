//
//  Post.swift
//  Post
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation

struct Post: FirebaseConvertable {
    let title: String
    let author: String
    let text: String
    let id: UUID
    let timestamp: Date
    
    init(title: String, text: String, author: String) {
        self.title = title
        self.author = author
        self.text = text
        self.id = UUID()
        self.timestamp = Date()
    }
    static let testPost = Post(title: "Title", text: "Content", author: "First Last")
}
