//
//  MainTabView.swift
//  MainTabView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var userService = UserService()
    
    var body: some View {
        TabView {
            PostsList()
                .tabItem {
                    Label("Posts", systemImage: "list.dash")
                }
            NewPostForm()
                .tabItem {
                    Label("New Post", systemImage: "plus.circle")
                }
        }
        .environmentObject(userService)
        .onAppear {
            // TODO: Replace this with Tim’s authentication UI. This is a placeholder to facilitate the development of comments, which rely on there being an authenticated user.
            Task {
                try! await userService.signIn(email: "A21-3@testuser.com", password: "password")
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
