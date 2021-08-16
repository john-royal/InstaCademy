//
//  NewPostForm.swift
//  NewPostForm
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct NewPostForm: View {
    @State var postContent = ""
    @State var title = ""
    @State var author = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
            TextField("Post content", text: $postContent)
            TextField("Author", text: $author)
            Button("Submit") {
                Task {
                    do {
                        try await PostService.upload(post: Post(title: title, text: postContent, author: author))
                        presentationMode.wrappedValue.dismiss()
                    }
                    catch {
                        print(error)
                    }
                }
            }
        }
    }
}

struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm()
    }
}
