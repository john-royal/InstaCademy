//
//  SignInView.swift
//  SignInView
//
//  Created by Tim Miller on 8/12/21.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    let signInAction: (String, String) async -> Void
    let signUpAction: (String, String) async -> Void
    @State private var email = ""
    @State private var password = ""
    
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
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.secondary)
                        .cornerRadius(15)
                    HStack {
                        Button {
                            guard !email.isEmpty, !password.isEmpty else {
                                return
                            }
                            Task {
                                await signInAction(email, password)
                            }
                        } label: {
                            Text("Sign In")
                                .foregroundColor(Color.white)
                                .frame(width: 150, height: 50)
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                        NavigationLink("Create Account", destination: SignUpView(action: signUpAction))
                            .foregroundColor(Color.white)
                            .frame(width: 150, height: 50)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                }
                .padding()
                Spacer()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(signInAction: { _, _ in }, signUpAction: { _, _ in })
    }
}
