//
//  CommentsViewModel.swift
//  CommentsViewModel
//
//  Created by John Royal on 8/21/21.
//

import Foundation

@MainActor class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    
    private let post: Post
    private let user: User
    
    init(post: Post, user: User) {
        self.post = post
        self.user = user
    }
    
    func loadComments() async throws {
        comments = try await PostService.fetchComments(for: post)
    }
    
    func submitComment(content: String) async throws {
        let comment = Comment(author: user, content: content)
        try await PostService.addComment(comment, to: post)
        comments.append(comment)
    }
    
    func deleteComments(at indexSet: IndexSet) async throws {
        for i in indexSet {
            let comment = comments[i]
            try await PostService.removeComment(comment, from: post, user: user)
            comments.removeAll { $0 == comment }
        }
    }
}
