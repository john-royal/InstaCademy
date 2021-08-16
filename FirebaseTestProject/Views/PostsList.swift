//
//  ContentView.swift
//  FirebaseTestProject
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostsList: View {
    @StateObject var postData: PostData
    @State private var isPresenting: Bool = false
    @State private var isEditing = false
    @State private var searchText: String = ""
    @Namespace var namespace
    
    var body: some View {
        NavigationView {
            VStack {
                // Searchable Posts
                SearchBar(text: $searchText)
                let posts = searchText == "" ?
                                    postData.posts :
                                    postData.posts.filter({ $0.postSearch(searchText) })
                
                let prefSize = 0.9
                ScrollView(.vertical) {
                    GeometryReader { g in
                        VStack {
                            ForEach(posts, id: \.id) { post in
                                PostRow(post: binding(for: post), deletePostAction: { post in
                                    let succeed = postData.remove(post: post)
                                    if(succeed) {
                                        postData.setPosts()
                                    }
                                })
                            }
                        }
                        .frame(width: g.size.width*prefSize)
                    }
                }
                .alignmentGuide(HorizontalAlignment.center, computeValue: { d in
                    let scrollViewWidth = d.width*2
                    let scrollViewWidthPrefSize = scrollViewWidth*prefSize
                    let midwayPoint = (scrollViewWidth - scrollViewWidthPrefSize) / 2
                    return d[HorizontalAlignment.center] - midwayPoint
                })
                // Unable to make List shorter width, centered, and space between items --
                // switched to ForEach above -- 
                // this is for adding comments and keeping a reasoanble spacing between posts
//                List(posts, id: \.text) { post in
//                    PostRow(post: binding(for: post), deletePostAction: { post in
//                        let succeed = postData.remove(post: post)
//                        if(succeed) {
//                            postData.setPosts()
//                        }
//                    }).border(Color.black, width: 1)
//                }
                .navigationTitle("Posts")
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Create Post") {
                            isPresenting = true
                        }
                    }
                })
            }
            .sheet(isPresented: $isPresenting, content: {
                NavigationView {
                    NewPostForm()
                        .toolbar(content: {
                            Button("Dismiss") {
                                isPresenting = false
                            }
                        })
                        // Need to reload postData (there is a more efficient way to do this, e.g. check for if not "Dismiss" pressed, but figured it was a minor case
                        .onDisappear {
                            Task {
                                // Need to reset list of posts -- if user added a new post, it should appear
                                // Additionally, this will change the list of posts for the Favorites page
                                postData.setPosts()
                            }
                        }
                }
            })
        }.background(Color.blue)
    }
}

extension PostsList {
    func binding(for post: Post) -> Binding<Post> {
        guard let index = postData.index(of: post) else {
            fatalError("Post not found")
        }
        return $postData.posts[index]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PostsList(postData: PostData(dataType: .all))
    }
}
