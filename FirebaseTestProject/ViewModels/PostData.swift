//
//  PostData.swift
//  PostData
//
//  Created by Ben Stone on 8/9/21.
//

import Foundation

@MainActor class PostData: ObservableObject {
    @Published var posts: [Post] = []
    var dataType: DataType
    
    init(dataType: DataType) {
        self.dataType = dataType
        setPosts()
    }
    
    func setPosts() {
        Task {
            // Favorites HAS to go here for this to work correctly --
            // the async calls (this one and the posts one) need to happen PRIOR to
            // setting self.posts
            let favorites = try await PostService.getFavorites()
            
            switch dataType {
            case .all:
                await loadPosts()
            case .singleAuthor(let author):
                await loadPosts()
                posts = posts.filter({$0.author == author})
            case .favorites:
                await loadFavorites()
            }
            
            // Placing it here removes the clunkiness of putting it inside
            // each method, loadPosts and loadFavorites
            // Each view needs to annotate favorites anyway, can place it here
            let favoritesID = favorites.map({ $0.id })
            for i in 0..<self.posts.count {
                if favoritesID.contains(self.posts[i].id) {
                    self.posts[i].isFavorite = true
                }
            }
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
    
    func loadFavorites() async {
        do {
            let posts = try await PostService.getFavorites()
            self.posts = posts
        }
        catch {
            print(error)
        }
    }
    
    func index(of post: Post) -> Int? {
        for i in posts.indices {
            if posts[i].id == post.id {
                return i
            }
        }
        return nil
    }
    
    // Returns if Succeeded
    func remove(post: Post) -> Bool {
        // Returns if element not found
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return false }
        posts.remove(at: index)
        Task {
            try await PostService.delete(post: post)
        }
        // We can return true here because we only want to know if the index exists
        return true
    }
}

extension PostData {
    enum DataType {
        case all
        case singleAuthor(author: String)
        case favorites
    }
}
