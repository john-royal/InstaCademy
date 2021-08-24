//
//  SignOutView.swift
//  SignOutView
//
//  Created by Tim Miller on 8/12/21.
//

import SwiftUI

struct ProfileView: View {
    let user: User
    let signOutAction: () -> Void
    
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
            Button(action: signOutAction) {
                Text("Sign Out")
                    .foregroundColor(Color.white)
                    .frame(width: 150, height: 50)
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            Spacer()
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: .testUser, signOutAction: {})
    }
}
