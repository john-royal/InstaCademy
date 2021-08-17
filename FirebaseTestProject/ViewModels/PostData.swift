//
//  PostData.swift
//  PostData
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation

@MainActor class PostData: ObservableObject {
    @Published var posts: [Post] = []
    
    private let user: User
    
    init(user: User) {
        self.user = user
        
        Task {
            await loadPosts()
        }
    }
    
    func loadPosts() async {
        do {
            let posts = try await PostService.getPosts()
            self.posts = posts
        }
        catch {
            print(error)
        }
    }
    
    func delete(_ post: Post) async throws {
        guard post.author.id == user.id else {
            preconditionFailure("User is not permitted to delete post")
        }
        try await PostService.delete(post)
        posts.removeAll { $0 == post }
    }
}
