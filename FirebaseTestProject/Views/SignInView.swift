//
//  SignInView.swift
//  SignInView
//
//  Created by Tim Miller on 8/12/21.
//

import SwiftUI

struct SignInView<CreateAccountView: View>: View {
    let action: (String, String) async throws -> Void
    let createAccountView: CreateAccountView
    
    @State private var email = ""
    @State private var password = ""
    @State private var error: Error? {
        didSet { hasError = error != nil }
    }
    @State private var hasError = false
    
    var body: some View {
        NavigationView {
            VStack {
                Image("login")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                VStack {
                    TextField("Email Address", text: $email)
                        .padding()
                        .background(Color.secondary)
                        .cornerRadius(15)
                        .textContentType(.emailAddress)
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.secondary)
                        .cornerRadius(15)
                        .textContentType(.newPassword)
                    HStack {
                        Button(action: signIn) {
                            Text("Sign In")
                                .foregroundColor(Color.white)
                                .frame(width: 150, height: 50)
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                        NavigationLink("Create Account", destination: createAccountView)
                            .foregroundColor(Color.white)
                            .frame(width: 150, height: 50)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                }
                .padding()
                Spacer()
            }
            .onSubmit(signIn)
        }
        .alert("Cannot Sign In", isPresented: $hasError, presenting: error, actions: { _ in }) { error in
            Text(error.localizedDescription)
        }
    }
    
    private func signIn() {
        Task {
            do {
                try await action(email, password)
            } catch {
                print("[SignInView] Cannot sign in: \(error.localizedDescription)")
                self.error = error
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(action: { _, _ in }, createAccountView: EmptyView())
    }
}
