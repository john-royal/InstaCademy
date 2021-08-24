//
//  SignUpView.swift
//  SignUpView
//
//  Created by Tim Miller on 8/12/21.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    let action: (String, String) async -> Void
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        
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
                Button {
                    Task {
                        await action(email, password)
                    }
                } label: {
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
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(action: { _, _ in })
    }
}
