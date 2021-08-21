//
//  PostService.swift
//  PostService
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import FirebaseFirestore

struct PostService {
    static var postsReference: CollectionReference {
        let db = Firestore.firestore()
        return db.collection("posts")
    }
    
    static func getPosts() async throws -> [Post] {
        let postsSnapshots = try await postsReference.getDocuments()
        let posts = postsSnapshots.documents.map { Post(from: $0.data()) }
        return posts
    }
    
    static func upload(_ post: Post) async throws {
        try await postsReference.document(post.id.uuidString).setData(post.jsonDict)
    }
}

extension PostService {
    private static let COMMENT_CHARACTER_LIMIT = 1000
    
    static func fetchComments(for post: Post) async throws -> [Comment] {
        let post = postsReference.document(post.id.uuidString)
        let comments = try await post.collection("comments").getDocuments()
        return comments.documents.map { Comment(from: $0.data()) }
    }
    
    static func addComment(_ comment: Comment, to post: Post) async throws {
        if comment.content.count > COMMENT_CHARACTER_LIMIT {
            throw CommentError.exceedsCharacterLimit
        }
        let post = postsReference.document(post.id.uuidString)
        let comments = post.collection("comments")
        comments.addDocument(data: comment.jsonDict)
    }
    
    enum CommentError: LocalizedError {
        case exceedsCharacterLimit
        
        var errorDescription: String? {
            switch self {
            case .exceedsCharacterLimit:
                return "Your comment has more than \(COMMENT_CHARACTER_LIMIT) characters."
            }
        }
    }
}
