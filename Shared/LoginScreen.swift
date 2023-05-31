//
//  LoginScreen.swift
//  Exercise Assistant
//
//  Created by Sam Engel on 5/28/23.
//

import Foundation
import Firebase
import SwiftUI

struct LoginScreen: View {
    @State var email = ""
    @State var password = ""

    var body: some View {
        VStack {
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            Button(action: { login() }) {
                Text("Sign in")
            }
        }
        .padding()
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                WorkoutAPI.userID = Auth.auth().tenantID;
            }
        }
    }
}
