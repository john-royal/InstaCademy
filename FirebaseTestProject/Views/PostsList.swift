//
//  ContentView.swift
//  FirebaseTestProject
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostsList: View {
    @StateObject var postData: PostData
    
    @Environment(\.user) private var user
    
    var body: some View {
        NavigationView {
            List(postData.posts) { post in
                PostRow(post: post, deleteAction: post.author.id == user.id ? { try await postData.delete(post) } : nil)
            }
            .refreshable {
                await postData.loadPosts()
            }
            .navigationTitle("Posts")
            .onAppear {
                Task {
                    await postData.loadPosts()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PostsList(postData: .init(user: .testUser))
    }
}
