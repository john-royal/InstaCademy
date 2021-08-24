//
//  PostView.swift
//  PostView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostRow: View {
    let post: Post
    let deleteAction: DeleteAction?
    
    @State private var showConfirmDelete = false
    
    typealias DeleteAction = () async throws -> Void
    
    var body: some View {
        VStack {
            Text(post.title)
                .font(.title)
                .padding(.bottom, 8)
            Text(post.text)
                .font(.body)
                .padding(.bottom, 8)
            Text(post.author.name)
                .padding(.bottom, 8)
                .padding()
            HStack {
                Text(post.author.name)
                if let deleteAction = deleteAction {
                    Spacer()
                    deleteButton(with: deleteAction)
                }
            }
            .padding(.bottom, 8)
        }
    }
    
    private func deleteButton(with deleteAction: @escaping DeleteAction) -> some View {
        Button {
            showConfirmDelete = true
        } label: {
            Label("Delete", systemImage: "trash")
                .foregroundColor(Color.red)
                .labelStyle(IconOnlyLabelStyle())
        }
        .alert("Are you sure you want to delete this post?", isPresented: $showConfirmDelete) {
            Button("Delete", role: .destructive, action: {
                Task {
                    try! await deleteAction()
                }
            })
        }
    }
}

struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
        PostRow(post: Post.testPost, deleteAction: {})
    }
}
