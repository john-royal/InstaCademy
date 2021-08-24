//
//  NewCommentForm.swift
//  NewCommentForm
//
//  Created by John Royal on 8/21/21.
//

import SwiftUI

struct NewCommentForm: View {
    let submitAction: (String) async -> Bool
    
    @State private var comment = ""
    @State private var isLoading = false
    
    var body: some View {
        HStack {
            TextField("Comment", text: $comment)
            if isLoading {
                ProgressView()
            } else {
                Button(action: handleSubmit) {
                    Label("Post", systemImage: "paperplane")
                }
                .disabled(comment.isEmpty)
            }
        }
        .disabled(isLoading)
        .onSubmit(handleSubmit)
    }
    
    private func handleSubmit() {
        Task {
            isLoading = true
            let isSuccess = await submitAction(comment)
            if isSuccess {
                comment = ""
            }
            isLoading = false
        }
    }
}

struct NewCommentForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Text("Preview")
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        NewCommentForm(submitAction: { _ in true })
                    }
                }
        }
    }
}
