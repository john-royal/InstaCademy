//
//  UserService.swift
//  UserService
//
//  Created by John Royal on 8/21/21.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct UserService {
    static let shared = Self()
    
    private init () {}
    
    private var auth = Auth.auth()
    private var users = Firestore.firestore().collection("users")
    
    func signIn(email: String, password: String) async throws -> User {
        let response = try await auth.signIn(withEmail: email, password: password)
        let user = try await users.document(response.user.uid).getDocument()
        guard let userData = user.data() else {
            preconditionFailure("Cannot find data for user \(response.user.uid) (email: \(email), password: \(password))")
        }
        return User(from: userData)
    }
    
    func createAccount(name: String, email: String, password: String) async throws -> User {
        let response = try await auth.createUser(withEmail: email, password: password)
        let newUser = User(name: name)
        try await users.document(response.user.uid).setData(newUser.jsonDict)
        return newUser
    }
}
