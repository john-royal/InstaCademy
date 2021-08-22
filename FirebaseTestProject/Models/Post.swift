//
//  Post.swift
//  Post
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation
import FirebaseFirestore

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
    
    func contains(_ str:String) -> Bool {
        // Not 100% sure works -- "generic" (we still have to do a specific if-case for each type) functionality for not requiring specific property names
        // as in the case commented below
        let stringValues = self.jsonDict.values.map { val -> String in
            if let value = val as? String {
                return value
            }
            // We don't want to search on ANY UUIDs
            if let _ = val as? UUID {
                return ""
            }
            if let value = val as? Date {
                return DateFormatter.postFormat(date: value).lowercased()
            }
            return ""
        }
        
        
        let filteredStrings = stringValues.filter({ $0 != "" && $0.contains(str.lowercased()) })
        
        return filteredStrings.count > 0
        
        // 100% sure works with the specific properties
//        let lowercaseString = str.lowercased()
//        let lowercaseTitle = title.lowercased()
//        let lowercaseAuthor = author.lowercased()
//        let lowercaseText = text.lowercased()
//        let lowercaseDate = DateFormatter.postFormat(date: timestamp).lowercased()
//        return  lowercaseTitle.contains(lowercaseString) ||
//                lowercaseAuthor.contains(lowercaseString) ||
//                lowercaseText.contains(lowercaseString) ||
//                lowercaseDate.contains(lowercaseString)
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
    
    static func getPosts() async throws -> [Post] {
        let postsSnapshots = try await postsReference.getDocuments()
        let posts = postsSnapshots.documents.map { Post(from: $0.data()) }
        return posts
    }
    
    static func upload(_ post: Post) async throws {
        try await postsReference.document(post.id.uuidString).setData(post.jsonDict)
    }
    
    static func delete(post: Post) async throws {
        try await postsReference.document(post.id.uuidString).delete()
    }
}

extension DateFormatter {
    static func postFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return formatter.string(from: date)
    }
}
