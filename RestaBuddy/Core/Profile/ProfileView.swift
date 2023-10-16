import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

struct AddCardView: View {
    @Binding var isPresented: Bool
    @State private var cardNumber = ""
    @State private var cvv = ""
    @State private var expirationDate = Date() // actualizăm la un obiect de tip Date
    @State private var selectedImage: UIImage? // Definim variabila selectedImage

    var body: some View {
        VStack {
            if #available(iOS 14.0, *) {
                TextField("Card number", text: $cardNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .keyboardType(.numberPad) // setăm tastatura pentru cifre
                    .onChange(of: cardNumber) { newValue in // validare pentru cardNumber
                        if newValue.count > 16 {
                            cardNumber = String(newValue.prefix(16))
                        }
                        if let _ = Int(newValue) {
                            // numai cifre, lăsăm textul cum este
                        } else {
                            cardNumber = String(newValue.filter { "0123456789".contains($0) })
                        }
                    }
            } else {
                // Fallback on earlier versions
            }
            if #available(iOS 14.0, *) {
                TextField("CVV", text: $cvv)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .keyboardType(.numberPad) // setăm tastatura pentru cifre
                    .onChange(of: cvv) { newValue in // validare pentru cvv
                        if newValue.count > 4 {
                            cvv = String(newValue.prefix(4))
                        }
                        if let _ = Int(newValue) {
                            // numai cifre, lăsăm textul cum este
                        } else {
                            cvv = String(newValue.filter { "0123456789".contains($0) })
                        }
                    }
            } else {
                // Fallback on earlier versions
            }
            DatePicker("Expiration date", selection: $expirationDate, displayedComponents: .date) // utilizăm DatePicker pentru a permite utilizatorului să selecteze o dată validă
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
            HStack {
                Button(action: {
                    // Add Card action
                    addCard()
                    isPresented = false
                }, label: {
                    Text("Add Card")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                })
                Spacer()
                Button(action: {
                    // Cancel action
                    isPresented = false
                }, label: {
                    Text("Cancel")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                })
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding()
    }

    func addCard() {
        // Add card to Firestore
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let last4 = String(cardNumber.suffix(4)) // get last 4 digits of card number
        db.collection("users").document(uid).collection("cards").addDocument(data: [
            "cardNumber": last4, // save last 4 digits of card number
            "cvv": cvv,
            "expirationDate": expirationDate
        ]) { error in
            if let error = error {
                print("Error adding card: \(error.localizedDescription)")
            } else {
                print("Card added successfully.")
            }
        }
    }
   
}
struct ProfileView: View {
    @State private var isShowingLogin = false
    @State private var isShowingAddCard = false
    @State private var userEmail = ""
    @State private var cards: [String] = []
    @State private var cardListener: ListenerRegistration?
    @State private var cardNumbers: [String] = []
    @State private var isShowingChangePassword = false
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var imageData: Data?


    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 50)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            ZStack {
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(Circle()) // adăugăm această linie pentru a păstra marginile rotunde
                                        .frame(width: 80, height: 80) // adăugăm această linie pentru a fixa dimensiunea imaginii
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.black)
                                        .padding(.trailing, 5)
                                }

                                    Button(action: {
                                        // Select image action
                                        isShowingImagePicker = true
                                    }) {

                                        Text("Select Image")
                                            .font(.system(size: 10))
                                            .foregroundColor(.gray)

                                    }
                                    .frame(width: 100, height: 40)

                                    .padding(.bottom, 5)
                                    .alignmentGuide(.bottom) { d in d[.bottom] }

                            }
                            .sheet(isPresented: $isShowingImagePicker, onDismiss: loadImage) {
                                ImagePicker(selectedImage : $selectedImage)
                            }

                                
                                
                            
                            
                            

                            VStack(alignment: .leading, spacing: 10) {
                                Text(userEmail)
                                    .font(.subheadline)
                                
//                                Text("+40 727-456-780")
//                                    .font(.subheadline)
                                
                                if cardNumbers.count > 0 {
                                    ForEach(cardNumbers, id: \.self) { cardNumber in
                                        HStack{
                                            Text("**** **** **** \(String(cardNumber.suffix(4)))") // show last 4 digits of card number
                                                .font(.subheadline)
                                            Spacer()

                                            Button(action: {
                                                // Delete card action
                                                deleteCard(cardNumber)
                                            }, label: {
                                                Image(systemName: "trash.fill")
                                                    .foregroundColor(.blue)
                                            })

                                        }
                                        
                                    }
                                }
                            }
                            
                            Spacer()
                            
                        }
                        .padding(.horizontal)
                        
                        Divider()
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .resizable()
                                    .frame(width: 25, height: 30)
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 10)
                                
                                Button(action: {
                                                    isShowingChangePassword = true
                                                }) {
                                                    Text("Change Password")
                                                        .font(.headline)
                                                        .foregroundColor(.black)
                                                }
                                                .sheet(isPresented: $isShowingChangePassword) {
                                                    ChangePasswordView()
                                                }
                                
                            }
                            
                            HStack {
                                Image(systemName: "creditcard.fill")
                                    .resizable()
                                    .frame(width: 25, height: 30)
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 10)
                                
                                Button(action: {
                                    // Action for Add Card button
                                    isShowingAddCard = true
                                }, label: {
                                    Text("Add Card")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                })
                                
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        Button(action: {
                            // Action for Log Out button
                            isShowingLogin = true
                        }, label: {
                            Text("Log Out")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        })
                    
                    .fullScreenCover(isPresented: $isShowingLogin, content: {
                        // View for login
                        ContentView()
                        
                    })
                        .padding(.bottom, 50)
                    }
                    .padding(.horizontal)
                }
                .navigationTitle("")
                .navigationBarHidden(true)
                .onAppear {
                    // Get user's email address and update state variable
                    if let userEmail = Auth.auth().currentUser?.email {
                        self.userEmail = userEmail
                    }
                }
                .fullScreenCover(isPresented: $isShowingAddCard, content: {
                    AddCardView(isPresented: $isShowingAddCard)
                })
                
            } else {
                // Fallback on earlier versions
            }
        }
        
        
        .onAppear {
            // Get user's email address and update state variable
            if let userEmail = Auth.auth().currentUser?.email {
                self.userEmail = userEmail
            }
            listenForCards()
            
            
            // Add listener for the "cards" collection in Firestore
            let db = Firestore.firestore()
            guard let uid = Auth.auth().currentUser?.uid else { return }
            self.cardListener = db.collection("users").document(uid).collection("cards").addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    print("Error getting cards: \(error?.localizedDescription ?? "unknown error")")
                    return
                }
                
                // Update the "cards" array with the card data retrieved from Firestore
                self.cards = snapshot.documents.compactMap { $0.data()["cardNumber"] as? String }
                
                // Update the "cardNumbers" array with the new data
                self.cardNumbers = self.cards
            }
        }
        .onDisappear {
            // Stop listening for changes to the "cards" collection in Firestore
            self.cardListener?.remove()
            cardListener?.remove()
        }
        
        
        
    }
    func listenForCards() {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Listen for changes to the user's cards collection
        cardListener = db.collection("users").document(uid).collection("cards").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening for cards: \(error.localizedDescription)")
            } else {
                cardNumbers = snapshot?.documents.map { $0.data()["cardNumber"] as? String ?? "" } ?? []
            }
        }
    }

    func deleteCard(_ cardNumber: String) {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("cards")
            .whereField("cardNumber", isEqualTo: cardNumber)
            .getDocuments() { querySnapshot, error in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                } else {
                    for document in querySnapshot!.documents {
                        document.reference.delete() { error in
                            if let error = error {
                                print("Error deleting document: \(error.localizedDescription)")
                            } else {
                                print("Document successfully deleted.")
                                cardNumbers.removeAll(where: { $0 == cardNumber })
                            }
                        }
                    }
                }
            }
    }
//    func loadImage() {
//        guard selectedImage != nil else { return }
//        // Do something with the selected image, like upload it to Firebase
//    }
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        
        // Convert the selected image to Data
        if let imageData = selectedImage.jpegData(compressionQuality: 0.5) {
            
            // Save the image data to Firebase Storage
            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child("images/\(UUID().uuidString).jpg") // set a unique filename for the image
            let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                } else {
                    // Image uploaded successfully, do something with the download URL
                    imageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error getting image URL: \(error.localizedDescription)")
                        } else if let url = url {
                            // Save the image URL to Firestore
                            let db = Firestore.firestore()
                            guard let uid = Auth.auth().currentUser?.uid else { return }
                            let userRef = db.collection("users").document(uid)
                            userRef.updateData(["profileImageURL": url.absoluteString]) { error in
                                if let error = error {
                                    print("Error updating profile image URL: \(error.localizedDescription)")
                                } else {
                                    // Profile image URL updated successfully
                                    print("Profile image URL updated successfully")
                                }
                            }
                        }
                    }
                }
            }
            
            // Observe the upload progress if needed
            uploadTask.observe(.progress) { snapshot in
                // Update upload progress if needed
                let percentComplete = Double(snapshot.progress?.completedUnitCount ?? 0) / Double(snapshot.progress?.totalUnitCount ?? 1)
                print("Upload progress: \(percentComplete * 100)%")
            }
        }
        
        // Dismiss the image picker
        isShowingImagePicker = false
    }


    func addProfileImage() {
           guard let selectedImage = selectedImage,
                 let imageData = selectedImage.jpegData(compressionQuality: 0.5) else {
               print("Error converting image to data")
               return
           }

           // Salvăm imaginea în Firebase Storage
           let storage = Storage.storage()
           let storageRef = storage.reference()
           let imageName = UUID().uuidString
           let imageRef = storageRef.child("profile_images").child("\(imageName).jpg")
           let metadata = StorageMetadata()
           metadata.contentType = "image/jpeg"
           imageRef.putData(imageData, metadata: metadata) { metadata, error in
               if let error = error {
                   print("Error uploading image: \(error.localizedDescription)")
               } else {
                   // Obținem URL-ul imaginii salvate în Firebase Storage
                   imageRef.downloadURL { url, error in
                       if let error = error {
                           print("Error getting image download URL: \(error.localizedDescription)")
                       } else if let url = url {
                           // Actualizăm URL-ul imaginii în Firestore
                           let db = Firestore.firestore()
                           guard let uid = Auth.auth().currentUser?.uid else { return }
                           db.collection("users").document(uid).updateData(["profileImageURL": url.absoluteString]) { error in
                               if let error = error {
                                   print("Error updating profile image URL: \(error.localizedDescription)")
                               } else {
                                   print("Profile image URL updated successfully.")
                               }
                           }
                       }
                   }
               }
           }
       }
    func uploadImageToFirebase(imageData: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = Storage.storage().reference()
        let imageFileName = UUID().uuidString // Generate a unique file name for the image
        let imageRef = storageRef.child("profileImages").child(imageFileName)

        imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            imageRef.downloadURL { (url, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let downloadURL = url {
                    completion(.success(downloadURL))
                } else {
                    completion(.failure(NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                }
            }
        }
    }

}

