//
//  Post.swift
//  Post
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct Post: FirebaseConvertable {
    let title: String
    let author: String
    let authorid: UUID
    let text: String
    let id: UUID
    let timestamp: Date
    var isFavorite: Bool = false
    
    init(title: String, text: String, author: String) {
        self.title = title
        self.author = author == "" ? "Brad" : author
        let userid = UserDefaults.standard.value(forKey: "userid") != nil ? UUID(uuidString: UserDefaults.standard.value(forKey: "userid") as! String) : UUID(uuidString: "00854E9E-8468-421D-8AA2-605D8E6C61D9")
        self.authorid = userid!
        self.text = text
        self.id = UUID()
        self.timestamp = Date()
    }
    
    private enum CodingKeys: String, CodingKey {
        case title
        case author
        case authorid
        case text
        case id
        case timestamp
    }
    
    //Custom Decoder for `isFavorite` since we don't set it using th Firebase.posts collections
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(String.self, forKey: .author)
        text = try container.decode(String.self, forKey: .text)
        id = try container.decode(UUID.self, forKey: .id)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        authorid = try container.decode(UUID.self, forKey: .authorid)
    }
    
    func postSearch(_ string:String) -> Bool {
        let lowercaseString = string.lowercased()
        let lowercaseTitle = title.lowercased()
        let lowercaseAuthor = author.lowercased()
        let lowercaseText = text.lowercased()
        let lowercaseDate = DateFormatter.postFormat(date: timestamp).lowercased()
        return  lowercaseTitle.contains(lowercaseString) ||
                lowercaseAuthor.contains(lowercaseString) ||
                lowercaseText.contains(lowercaseString) ||
                lowercaseDate.contains(lowercaseString)
    }
    
    static let testPost = Post(title: "Title", text: "Content", author: "First Last")
}

struct Favorite: FirebaseConvertable {
    let postid: UUID //Primary Key, so to speak
    let userid: UUID
    
    init(postid: String, userid: String) {
        self.postid = UUID(uuidString: postid)!
        self.userid = UUID(uuidString: userid)!
    }
}

protocol FirebaseConvertable: Codable {
    init(from jsonDict: [String: Any])
    var jsonDict: [String: Any] { get }
}

extension FirebaseConvertable {
    init(from jsonDict: [String: Any]) {
        let data = try! JSONSerialization.data(withJSONObject: jsonDict)
        let newInstance = try! JSONDecoder().decode(Self.self, from: data)
        self = newInstance
    }
    var jsonDict: [String: Any] {
        let data = try! JSONEncoder().encode(self)
        let jsonObject = try! JSONSerialization.jsonObject(with: data)
        return jsonObject as! [String: Any]
    }
}

struct PostService {
    static var postsReference: CollectionReference {
        let db = Firestore.firestore()
        return db.collection("posts")
    }
    
    static var favoritesReference: CollectionReference {
        let db = Firestore.firestore()
        return db.collection("favorites")
    }
    
    static func getPosts() async throws -> [Post] {
        let postsSnapshots = try await postsReference.getDocuments()
        let posts = postsSnapshots.documents.map { Post(from: $0.data()) }
        print(posts)
        
        return posts
    }
    
    static func getFavorites() async throws -> [Post] {
        let favoritesSnapshots = try await favoritesReference.getDocuments()
        let favorites = favoritesSnapshots.documents.map { Favorite(from: $0.data()) }
        let postsSnapshots = try await postsReference.getDocuments()
        let posts = postsSnapshots.documents.map { Post(from: $0.data()) }
        // INFO: Filter by Specific User -- Map Filter to PostID
        // ASSUME: Value stored inside UserDefaults (since it is not sensitive data) -- type: UUID
        let userid = UserDefaults.standard.value(forKey: "userid") != nil ? UUID(uuidString: UserDefaults.standard.value(forKey: "userid") as! String) : UUID(uuidString: "00854E9E-8468-421D-8AA2-605D8E6C61D9")
        let favoritesIDsForUser = favorites.filter({ $0.userid == userid }).map({ $0.postid })
        let favoritedPosts = posts.filter({ favoritesIDsForUser.contains($0.id) })
        return favoritedPosts
    }
    
    static func upload(post: Post) async throws {
        try await postsReference.document(post.id.uuidString).setData(post.jsonDict)
    }
    
    static func upload(favorite: Post) async throws {
        let userid = UserDefaults.standard.value(forKey: "userid") as? String ?? "00854E9E-8468-421D-8AA2-605D8E6C61D9"
        try await favoritesReference.document(favorite.id.uuidString).setData(Favorite(postid: favorite.id.uuidString, userid: userid).jsonDict)
    }
    
    static func delete(post: Post) async throws {
        try await postsReference.document(post.id.uuidString).delete()
    }
    
    static func delete(favorite: Post) async throws {
        try await favoritesReference.document(favorite.id.uuidString).delete()
    }
}
