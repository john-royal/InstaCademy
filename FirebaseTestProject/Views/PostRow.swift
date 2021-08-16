//
//  PostView.swift
//  PostView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostRow: View {
    @Binding var post: Post
    @State var isPresenting: Bool = false
    @State private var showAlert: Bool = false
    @State private var systemImage: String = ""
    let deletePostAction:((Post) -> Void)
    
    init(post: Binding<Post>, deletePostAction: @escaping (Post) -> Void) {
        self._post = post
        self.deletePostAction = deletePostAction
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(post.title)
                    .font(.largeTitle)
                    .padding(.leading)
                Spacer()
                // Does not hide view on click -- this is a GOOD thing in my opinion
                // as it allows user to re-click on the Favorite if they mislicked.
                // If they leave the page and come back after removing a favorite,
                // it will not be there
                // we COULD pass the postData in here and refresh page each time button
                // is tapped
                let userid = UserDefaults.standard.value(forKey: "userid") != nil ? UUID(uuidString: UserDefaults.standard.value(forKey: "userid") as! String) : UUID(uuidString: "00854E9E-8468-421D-8AA2-605D8E6C61D9")
                if userid == post.authorid {
                    Button(action: {
                        showAlert = true
                    }, label: {
                        Label("", systemImage: "trash")
                    })
                    .buttonStyle(PlainButtonStyle())
                }
                Button(action: {
                    Task {
                        post.isFavorite = !post.isFavorite
                        post.isFavorite ?
                            try await PostService.upload(favorite: post) : try await PostService.delete(favorite: post)
                    }
                }, label: {
                    Label("", systemImage: post.isFavorite ? "heart.fill" : "heart")
                })
                .padding()
                .buttonStyle(PlainButtonStyle())
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Do you want to delete this post?"),
                      primaryButton: .cancel(),
                      secondaryButton: .destructive(Text("Delete")) {
                    deletePostAction(post)
                })
            }
            HStack {
                Text(post.author)
                    .padding()
                    .foregroundColor(Color(uiColor: UIColor.systemBlue))
                    .onTapGesture {
                        isPresenting = true
                    }.sheet(isPresented: $isPresenting, onDismiss: {
                        isPresenting = false
                    }) {
                        PostsList(postData: PostData(dataType: .singleAuthor(author: post.author)))
                    }
                Spacer()
                Text(DateFormatter.postFormat(date: post.timestamp))
            }
            .padding([.leading, .bottom, .trailing], 20)
            Spacer()
            Text(post.text)
                .font(.body)
                .padding(.bottom)
                .padding(.leading, 30)
        }
        .border(Color.black, width: 0.5)
    }
}

extension DateFormatter {
    static func postFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return formatter.string(from: date)
    }
}

//struct PostRow_Previews: PreviewProvider {
//    static var previews: some View {
//        PostRow(post: Post(title: "", text: "", author: ""), deletePostAction: { post in
//            print(post)
//        })
//    }
//}
