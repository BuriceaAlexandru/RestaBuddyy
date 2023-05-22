
import SwiftUI
import Firebase
import FirebaseAuth

struct ChangePasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var showCurrentPassword = false
    @State private var showNewPassword = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                Form {
                    Section(header: Text("Current Password")) {
                        HStack {
                            if showCurrentPassword {
                                TextField("Enter your current password", text: $currentPassword)
                            } else {
                                SecureField("Enter your current password", text: $currentPassword)
                            }
                            Button(action: {
                                showCurrentPassword.toggle()
                            }) {
                                Image(systemName: showCurrentPassword ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(Color.secondary)
                            }
                        }
                    }
                    
                    Section(header: Text("New Password")) {
                        HStack {
                            if showNewPassword {
                                TextField("Enter a new password", text: $newPassword)
                            } else {
                                SecureField("Enter a new password", text: $newPassword)
                            }
                            Button(action: {
                                showNewPassword.toggle()
                            }) {
                                Image(systemName: showNewPassword ? "eye.fill" : "eye.slash.fill")
                                    .foregroundColor(Color.secondary)
                            }
                        }
                    }
                    
                    Section {
                        Button(action: changePassword) {
                            Text("Change Password")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    if !errorMessage.isEmpty {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }
                }
                .navigationTitle("Change Password")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Done")
                        }
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    func changePassword() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "You are not logged in."
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)

        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

