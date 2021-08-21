//
//  CommentsList.swift
//  CommentsList
//
//  Created by John Royal on 8/21/21.
//

import SwiftUI

// MARK: - CommentsList

struct CommentsList: View {
    let comments: [Comment]
    let submitAction: (String) async throws -> Void
    
    @State private var comment = ""
    @State private var error: Error?
    @State private var isError = false
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if comments.isEmpty {
                emptyState
            } else {
                List(comments) {
                    CommentRow(comment: $0)
                }
            }
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                newCommentForm
            }
        }
    }
    
    private var emptyState: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("No Comments")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Be the first to leave a comment.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    private var newCommentForm: some View {
        HStack {
            TextField("Comment", text: $comment)
            if isLoading {
                ProgressView()
            } else {
                Button(action: submitComment) {
                    Label("Post", systemImage: "paperplane")
                }
                .disabled(comment.isEmpty)
            }
        }
        .disabled(isLoading)
        .onSubmit(submitComment)
        .alert("Cannot Post Comment", isPresented: $isError, presenting: error, actions: { _ in }) { error in
            Text(error.localizedDescription)
        }
    }
    
    private func submitComment() {
        Task {
            isLoading = true
            do {
                try await submitAction(comment)
                comment = ""
            } catch {
                self.error = error
                isError = true
            }
            isLoading = false
        }
    }
}

// MARK: - Presenter View

extension CommentsList {
    struct Presenter: View {
        let post: Post
        @State private var comments: [Comment] = []
        @State private var didLoadComments = false
        @EnvironmentObject private var userService: UserService
        
        var body: some View {
            if didLoadComments {
                CommentsList(comments: comments, submitAction: submitComment(content:))
            } else {
                ProgressView()
                    .navigationTitle("Comments")
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear(perform: loadComments)
            }
        }
        
        private func loadComments() {
            Task {
                // TODO: Replace this force try with a more robust permanent solution.
                comments = try! await PostService.fetchComments(for: post)
                didLoadComments = true
            }
        }
        
        private func submitComment(content: String) async throws {
            guard let author = userService.user else {
                preconditionFailure("Cannot submit comment without a signed-in user")
            }
            let comment = Comment(author: author, content: content)
            try await PostService.addComment(comment, to: post)
            comments.append(comment)
        }
    }
}

// MARK: - Preview

struct CommentsList_Previews: PreviewProvider {
    struct PreviewContainer: View {
        @State private var comments: [Comment] = []
        
        var body: some View {
            CommentsList(comments: comments, submitAction: handleSubmit(_:))
        }
        
        private func handleSubmit(_ content: String) async {
            await timeout(.seconds(1))
            let comment = Comment(author: .init(name: "Jane Doe"), content: content)
            comments.append(comment)
        }
        
        private func timeout(_ timeout: DispatchTimeInterval) async {
            return await withCheckedContinuation { continuation in
                DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                    continuation.resume()
                }
            }
        }
    }
    
    static var previews: some View {
        NavigationView {
            PreviewContainer()
        }
    }
}
