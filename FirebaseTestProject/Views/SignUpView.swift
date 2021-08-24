//
//  SignUpView.swift
//  SignUpView
//
//  Created by Tim Miller on 8/12/21.
//

import SwiftUI

struct SignUpView: View {
    let action: (String, String, String) async throws -> Void
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var error: Error? {
        didSet { hasError = error != nil }
    }
    @State private var hasError = false
    
    var body: some View {
        VStack {
            Image("login")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            VStack {
                TextField("Name", text: $name)
                    .padding()
                    .background(Color.secondary)
                    .cornerRadius(15)
                    .textContentType(.name)
                TextField("Email Address", text: $email)
                    .padding()
                    .background(Color.secondary)
                    .cornerRadius(15)
                    .textContentType(.emailAddress)
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.secondary)
                    .cornerRadius(15)
                    .textContentType(.password)
                Button(action: createAccount) {
                    Text("Create Account")
                        .foregroundColor(Color.white)
                        .frame(width: 150, height: 50)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
            }
            .padding()
            Spacer()
        }
        .onSubmit(createAccount)
        .alert("Cannot Create Account", isPresented: $hasError, presenting: error, actions: { _ in }) { error in
            Text(error.localizedDescription)
        }
    }
    
    private func createAccount() {
        Task {
            do {
                try await action(name, email, password)
            } catch {
                print("[SignUpView] Cannot create account: \(error.localizedDescription)")
                self.error = error
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(action: { _, _, _ in })
    }
}
