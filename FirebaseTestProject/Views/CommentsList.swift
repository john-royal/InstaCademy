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
    let deleteAction: (Comment) async throws -> Void
    
    @State private var comment = ""
    @State private var error: PostService.CommentError?
    @State private var isError = false
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if comments.isEmpty {
                emptyState
            } else {
                commentsList
            }
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $isError, error: error, actions: { _ in }) { error in
            Text(error.failureReason ?? "Sorry, something went wrong.")
        }
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
    
    private var commentsList: some View {
        List {
            ForEach(comments) {
                CommentRow(comment: $0)
            }
            .onDelete(perform: handleDelete(indexSet:))
        }
    }
    
    private var newCommentForm: some View {
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
            do {
                try await submitAction(comment)
                comment = ""
            } catch {
                handleError(error)
            }
            isLoading = false
        }
    }
    
    private func handleDelete(indexSet: IndexSet) {
        Task {
            do {
                for index in indexSet {
                    try await deleteAction(comments[index])
                }
            } catch {
                handleError(error)
            }
        }
    }
    
    private func handleError<E: Error>(_ error: E) {
        if let error = error as? PostService.CommentError {
            self.error = error
        } else {
            self.error = .unknown
        }
        isError = true
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
                CommentsList(comments: comments, submitAction: submitComment(content:), deleteAction: deleteComment(_:))
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
            guard let user = userService.user else {
                preconditionFailure("Cannot submit comment without a signed-in user")
            }
            let comment = Comment(author: user, content: content)
            try await PostService.addComment(comment, to: post)
            comments.append(comment)
        }
        
        private func deleteComment(_ comment: Comment) async throws {
            guard let user = userService.user else {
                preconditionFailure("Cannot delete comment without a signed-in user")
            }
            try await PostService.removeComment(comment, from: post, user: user)
            comments.removeAll { $0 == comment }
        }
    }
}

// MARK: - Preview

struct CommentsList_Previews: PreviewProvider {
    struct PreviewContainer: View {
        @State private var comments: [Comment] = []
        
        var body: some View {
            CommentsList(comments: comments, submitAction: handleSubmit(_:), deleteAction: handleDelete(_:))
        }
        
        private func handleSubmit(_ content: String) async {
            await timeout(.seconds(1))
            let comment = Comment(author: .init(name: "Jane Doe"), content: content)
            comments.append(comment)
        }
        
        private func handleDelete(_ comment: Comment) async throws {
            comments.removeAll { $0 == comment }
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
