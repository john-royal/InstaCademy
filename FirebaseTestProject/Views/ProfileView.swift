//
//  ProfileView.swift
//  ProfileView
//
//  Created by Tim Miller on 8/12/21.
//

import SwiftUI

struct ProfileView: View {
    let user: User
    let signOutAction: () async throws -> Void
    
    @State private var error: Error? {
        didSet { hasError = error != nil }
    }
    @State private var hasError = false
    
    var body: some View {
        VStack{
            Image(systemName: "person.circle")
                .resizable()
                .scaledToFit()
                .padding()
            Button {
                
            } label: {
                Text("Change Photo...")
            }
            Spacer()
            Text("User Name:")
            Text(user.name)
                .font(.title2)
                .bold()
            Spacer()
            Button(action: signOut) {
                Text("Sign Out")
                    .foregroundColor(Color.white)
                    .frame(width: 150, height: 50)
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            Spacer()
        }
        .alert("Cannot Sign Out", isPresented: $hasError, presenting: error, actions: { _ in }) { error in
            Text(error.localizedDescription)
        }
    }
    
    private func signOut() {
        Task {
            do {
                try await signOutAction()
            } catch {
                print("[ProfileView] Cannot sign out: \(error.localizedDescription)")
                self.error = error
            }
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: .testUser, signOutAction: {})
    }
}
