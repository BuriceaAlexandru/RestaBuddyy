

import SwiftUI
import Firebase
import FirebaseAuth

struct ContentView: View {
    @State var isLoggedIn = false
    @Environment(\.presentationMode) var mode
    @StateObject var cartItems = CartItems()
    @StateObject var cart = CartItems()

    
    

    var body: some View {
        
        ZStack {
            if isLoggedIn {
                VStack {
                    TabView(selection: $selectedIndex) {
                        HomeView()
                            .environmentObject(cart)
                            .onTapGesture {
                                self.selectedIndex = 0
                            }
                            .tabItem {
                                Image(systemName: "house")
                            }.tag(0)

                        ShoppingCartView()
                            .environmentObject(cartItems) // injectăm cartItems ca un environment object
                            .onTapGesture {
                                self.selectedIndex = 1
                            }
                            .tabItem {
                                Image(systemName: "cart")
                            }.tag(1)

                        OrdersView()
                            .onTapGesture {
                                self.selectedIndex = 2
                            }
                            .tabItem {
                                Image(systemName: "list.bullet.rectangle")
                            }.tag(2)
                        if #available(iOS 14.0, *) {
                            ProfileView()
                                .onTapGesture {
                                    self.selectedIndex = 3
                                }
                                .tabItem {
                                    Image(systemName: "person")
                                }.tag(3)
                        }
                    }
                }
                .onAppear() {
                    // Verificăm starea de autentificare a utilizatorului
                    let user = Auth.auth().currentUser
                    if user != nil {
                        self.isLoggedIn = true
                    }
                }
            } else {
                VStack {
                    Text("Welcome to my app!")
                    LoginView(isLoggedIn: $isLoggedIn)
                }
            }
        }
        .onAppear() {
            // Inițializăm Firebase
           
        }
    }

    @State private var selectedIndex = 0
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State var user = ""
    @State var pass = ""
    @State var showRegister = false
    @State var showResetPasswordView = false // Added this state variable
    @State var errorMessage = ""
    
    func signIn() {
        Auth.auth().signIn(withEmail: user, password: pass) { (result, error) in
            if error != nil {
                // handle error
                print(error!.localizedDescription)
            } else {
                isLoggedIn = true
            }
        }
    }
    
    var body : some View{
        VStack{
            HStack{
                Spacer()
                Image("shape")
            }
            VStack{
                Image("logo")
                Text("RestaBuddy")
                    .font(.body).fontWeight(.heavy).bold()
                
            }
            .offset(y: -122)
            .padding(.bottom,-132)
            
            VStack(spacing: 20){
                Text("Hello").font(.title).fontWeight(.bold)
                Text("Sign Into Your Account").fontWeight(.bold)
                Spacer()
                CustomTF(value: self.$user, isemail: true)
                CustomTF(value: self.$pass, isemail: false)
                HStack{
                    Spacer()
                    Button(action: {
                        self.showResetPasswordView = true // Set showResetPasswordView to true when tapped
                    }) {
                        Text("Forgot Password ?").foregroundColor(Color.black.opacity(2))
                    }
                }
                Button(action: {
                    self.signIn()
                }) {
                    Text("Login")
                        .frame(width: UIScreen.main.bounds.width - 100)
                        .padding(.vertical)
                        .foregroundColor(.white)
                }
                .background(Color("Color1"))
                .clipShape(Capsule())
                
                
                Text("Or Login Using Social Media").fontWeight(.bold)
                SocialMedia()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(5)
            .padding()
            
            HStack{
                Text("Don't Have an Account ?")
                Button(action: {
                    self.showRegister = true
                }) {
                    Text("Register Now").foregroundColor(Color("Color1"))
                }.sheet(isPresented: self.$showRegister) {
                    Register(showRegister: self.$showRegister)
                }
            }
            
            Spacer(minLength: (80))
            
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color("Color").edgesIgnoringSafeArea(.all))
        .sheet(isPresented: self.$showResetPasswordView) { // Show ResetPasswordView when showResetPasswordView is true
            ResetPasswordView(showResetPasswordView: self.$showResetPasswordView)
        }
    }
}




struct Register: View {
    @Binding var showRegister: Bool
    @State var user = ""
    @State var pass = ""
    @State var repass = ""
    @State var agree = false
    @State var showError = false
    
    func createAccount() {
        Auth.auth().createUser(withEmail: user, password: pass) { (result, error) in
            if error != nil {
                // handle error
                print(error!.localizedDescription)
            } else {
                self.showRegister = false
            }
        }
    }
    
    var body : some View{
        ZStack(alignment: .topLeading) {
            VStack{
                HStack{
                    Spacer()
                    Image("shape")
                }
                VStack{
                    Image("logo")
                    Text("RestaBuddy")
                        .font(.body).fontWeight(.heavy).bold()
                }.offset(y: -122)
                    .padding(.bottom,-132)
                VStack(spacing: 20){
                    Text("Hello").font(.title).fontWeight(.bold)
                    Text("Create Your Account").fontWeight(.bold)
                    CustomTF(value: self.$user, isemail: true)
                    CustomTF(value: self.$pass, isemail: false)
                    CustomTF(value: self.$repass, isemail: false,reenter: true)
                    HStack{
                        Button(action: {
                            self.agree.toggle()
                        }) {
                            ZStack{
                                Circle().fill(Color.black.opacity(0.05)).frame(width: 20, height: 20)
                                if self.agree{
                                    Image("check").resizable().frame(width: 10, height: 10)
                                        .foregroundColor(Color("Color1"))
                                }
                            }
                        }
                        Text("I Read And Agree The Terms And Conditions").font(.caption)
                            .foregroundColor(Color.black.opacity(2))
                        Spacer()
                    }
                    if self.showError {
                        Text("Please agree to the terms and conditions")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                    Button(action: {
                        if !self.agree {
                            self.showError = true
                        } else {
                            self.createAccount()
                        }
                    }) {
                        Text("Register Now")
                            .frame(width: UIScreen.main.bounds.width - 100)
                            .padding(.vertical)
                            .foregroundColor(.white)
                    }.background(Color("Color1"))
                        .clipShape(Capsule())
                    Text("Or Register Using Social Media").fontWeight(.bold)
                    SocialMedia()
                }.padding()
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding()
                Spacer(minLength: 0)
            }.edgesIgnoringSafeArea(.top)
                .background(Color("Color").edgesIgnoringSafeArea(.all))
            Button(action: {
                // self.show.toggle()
            }) {
                Image(systemName: "arrow.left").resizable().frame(width: 18, height: 15).foregroundColor(.black)
            }.padding()
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}


struct SocialMedia: View {
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View{
        
        HStack(spacing: 40){
            
            Button(action: {
                let fbURL = URL(string: "https://www.facebook.com/login")!
                if UIApplication.shared.canOpenURL(fbURL) {
                    UIApplication.shared.open(fbURL)
                } else {
                    showAlert = true
                    alertMessage = "Unable to open Facebook"
                }
            }) {
                Image("fb").renderingMode(.original)
            }
            
            Button(action: {
                let twitterURL = URL(string: "https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwj9wPzdyP_9AhXSrYsKHY82BwcQjBB6BAgQEAE&url=https%3A%2F%2Ftwitter.com%2Flogin%3Flang%3Den&usg=AOvVaw0AMmJgcv8ZiZA73A_ttoE9")!
                if UIApplication.shared.canOpenURL(twitterURL) {
                    UIApplication.shared.open(twitterURL)
                } else {
                    showAlert = true
                    alertMessage = "Unable to open Twitter"
                }
            }) {
                Image("twitter").renderingMode(.original)
            }
            
            Button(action: {
                let googleURL = URL(string: "https://accounts.google.com/InteractiveLogin/signinchooser?elo=1&flowEntry=ServiceLogin&flowName=GlifWebSignIn&ifkv=AQMjQ7RwrvCVrxS0tmRickV5xe8e3FBvNMh4cmQvRaBtNtu1eATy0rmHrD09NNxAITNBijBp3yCZ")!
                if UIApplication.shared.canOpenURL(googleURL) {
                    UIApplication.shared.open(googleURL)
                } else {
                    showAlert = true
                    alertMessage = "Unable to open Google"
                }
            }) {
                Image("google").renderingMode(.original)
            }
            
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}


struct ResetPasswordView: View {
    @Binding var showResetPasswordView: Bool
    @State var email: String = ""
    
    var body: some View {
        VStack {
            Text("Reset Password")
                .font(.title)
                .bold()
                .padding()
            
            TextField("Enter email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: {
                Auth.auth().sendPasswordReset(withEmail: self.email) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Password reset email sent")
                        self.showResetPasswordView = false
                    }
                }
            }) {
                Text("Send Password Reset Email")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("Color1"))
                    .cornerRadius(10)
            }
            .padding(.top, 30)
            
            Spacer()
            
            Button(action: {
                self.showResetPasswordView = false
            }) {
                Text("Dismiss")
                    .foregroundColor(.red)
            }
            .padding(.top, 30)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}




struct CustomTF : View {
    
    @Binding var value : String
    var isemail = false
    var reenter = false
    
    @State private var isSecureTextEntry = true
    
    var body : some View{
        
        VStack(spacing: 8){
            
            HStack{
                
                Text(self.isemail ? "Email ID" : self.reenter ? "Re-Enter" : "Password").foregroundColor(Color.gray.opacity(2))
                
                
                Spacer()
            }
            
            HStack{
                
                if self.isemail{
                    TextField("", text: self.$value)
                }
                else{
                    ZStack(alignment: .trailing){
                        if isSecureTextEntry {
                            SecureField("", text: self.$value)
                        } else {
                            TextField("", text: self.$value)
                        }
                        
                        Button(action: {
                            self.isSecureTextEntry.toggle()
                        }) {
                            Image(systemName: self.isSecureTextEntry ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(Color.secondary)
                        }
                    }
                    .foregroundColor(self.value.count >= 8 && self.value.rangeOfCharacter(from: .uppercaseLetters) != nil ? .black : .red)
                    .disableAutocorrection(true)
                }
                
                
                
            }
            
            Divider()
        }
    }
}


