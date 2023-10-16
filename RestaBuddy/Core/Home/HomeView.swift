import SwiftUI
import CodeScanner


struct Restaurant: Identifiable {
    let id = UUID()
    let name: String
    var image: String?
    var menuItems: [String] // adăugați proprietatea `menuItems`
    
    var imageName: String {
        image ?? "default-image"
    }

    var imageDimension: CGFloat {
        140.0 // dimensiunea implicită a imaginii
    }
    
    init(name: String, image: String?, menuItems: [String]) { // adăugați proprietatea `menuItems` în inițializator
        self.name = name
        self.image = image
        self.menuItems = menuItems
    }
}




struct HomeView: View {
    @State private var showingQRScanner = false
    @State private var scannedCode: ScanResult?
    @State private var searchText = ""
    @State private var showingLogoutAlert = false

    var restaurants: [Restaurant] = [
        Restaurant(name: "Pizeria Volare", image: "volare", menuItems: ["Pizza Margherita", "Pizza Quattro Formaggi", "Spaghetti alla Carbonara", "Lasagne al Forno", "Insalata Caprese", "Tiramisù", "Gelato al Cioccolato", "Caffè Espresso", "Coca-Cola", "Fanta"]),
        Restaurant(name: "El Torito", image: "torito", menuItems: ["Tacos al Pastor", "Burritos de Carne Asada", "Fajitas de Pollo", "Quesadillas de Chorizo", "Guacamole", "Churros", "Flan", "Margarita", "Corona", "Agua Fresca"]),
        Restaurant(name: "Mosimo Bistro", image: "mosimo", menuItems: ["Bruschetta", "Caprese Salad", "Penne all'Arrabbiata", "Risotto ai Funghi Porcini", "Filetto di Manzo alla Griglia", "Tiramisù", "Panna Cotta", "Campari Spritz", "Negroni", "Acqua Panna"]),
        Restaurant(name: "Trattoria Mezalluna", image: "mezalluna", menuItems: ["Antipasto Misto", "Minestrone alla Genovese", "Ravioli al Tartufo Nero", "Pappardelle al Cinghiale", "Saltimbocca alla Romana", "Tiramisù", "Semifreddo al Torroncino", "Aperol Spritz", "Prosecco", "Acqua Minerale"]),
        Restaurant(name: "Alouette Urban Osteria", image: "alouette", menuItems: ["Charcuterie Board", "Caesar Salad", "Pappardelle Bolognese", "Ravioli di Zucca", "Beef Tenderloin", "Tiramisù", "Crème Brûlée", "Manhattan", "Bourbon Sour", "Orange Juice"])]

    var filteredRestaurants: [Restaurant] {
        if searchText.isEmpty {
            return restaurants
        } else {
            return restaurants.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    @EnvironmentObject var cart: CartItems

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search restaurants", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 16)
                    Button(action: {
                        self.showingQRScanner = true
                    }, label: {
                        Image(systemName: "qrcode")
                            .foregroundColor(.white)
                            .frame(width: 50 , height: 50)
                            .background(Color.gray)
                            .cornerRadius(10.0)
                    })
                    .padding(.trailing, 16)
                    .padding(.trailing, 16)
                }
                .padding(.top, 60)
                .navigationBarTitle("")
                .navigationBarHidden(true)
                
                ScrollView {
                    VStack {
                        ForEach(filteredRestaurants) { restaurant in
                            NavigationLink(destination: MenuView(restaurantName: restaurant.name, menuItems: restaurant.menuItems)) {
                                // ...
                                HStack {
                                    Text(restaurant.name)
                                        .foregroundColor(.black)
                                        .padding()
                                    Spacer()
                                    Image(restaurant.imageName)
                                        .resizable()
                                        .frame(width: restaurant.imageDimension, height: restaurant.imageDimension)
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(10.0)
                                        .padding(.bottom, 10)
                                }
                                .background(Color.clear)
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            
            .navigationViewStyle(StackNavigationViewStyle())
            .sheet(isPresented: $showingQRScanner, content: {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Some simulated QR code for testing") { result in
                    switch result {
                    case .success(let code):
                        self.scannedCode = code
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    self.showingQRScanner = false
                }
            })
        }
    }
}

struct MenuView: View {
    let restaurantName: String
    let menuItems: [String]
    
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var filteredMenuItems: [String] = []

    @State private var selectedMenuItem: String? = nil
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .padding()
                })
                
                Spacer()
            }
            
            Text("Meniul \(restaurantName)")
                .font(.title)
                .padding(.bottom, 20)
            
            if #available(iOS 14.0, *) {
                HStack {
                    TextField("Cauta fel de mancare", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 16)
                }
                .padding(.top, 20)
                .onChange(of: searchText) { _ in
                    filterMenuItems()
                }
            } else {
                // Fallback on earlier versions
            }
            
            List {
                ForEach(filteredMenuItems, id: \.self) { menuItem in
                    NavigationLink(destination: MenuItemDetailView(menuItem: menuItem), tag: menuItem, selection: $selectedMenuItem) {
                        Text(menuItem)
                    }
                    .onTapGesture {
                        self.selectedMenuItem = menuItem
                    }
                }
            }
            
            Spacer()
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .onAppear {
            filteredMenuItems = menuItems
        }
    }
    
    func filterMenuItems() {
        filteredMenuItems = menuItems.filter { menuItem in
            searchText.isEmpty || menuItem.localizedStandardContains(searchText)
        }
    }
}
import Foundation

struct MenuItemDetailView: View {
    @EnvironmentObject var cartItems: CartItems
    var menuItem: String
    
    // Injectăm obiectul presentationMode
    @Environment(\.presentationMode) var presentationMode
    
    @State private var quantity = 1
    
    var body: some View {
        VStack {
            Text(menuItem)
                .font(.title)
                .padding()
            
            // Adăugați poza meniului și descrierea aici
            
            // Adăugați butoanele pentru selectarea cantității aici
            HStack {
                Text("Cantitate: ")
                Button(action: {
                    if quantity > 1 {
                        quantity -= 1
                    }
                }) {
                    Image(systemName: "minus.circle")
                        .foregroundColor(.red)
                        .font(.system(size: 25))
                }
                Text("\(quantity)")
                    .padding(.horizontal, 8)
                Button(action: {
                    if quantity < 10 {
                        quantity += 1
                    }
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.red)
                        .font(.system(size: 25))
                }
            }
            .padding()
            Button(action: {
                // Adăugați produsul selectat în lista de produse din coș
                let item = CartItems.Item(name: menuItem, quantity: quantity)
                cartItems.items.append(item)

                // Închidem ecranul curent și revenim la Shopping Cart View
                self.presentationMode.wrappedValue.dismiss()
            }) {
                if #available(iOS 14.0, *) {
                    Text("Adaugă în coș")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding()
                } else {
                    // Fallback on earlier versions
                }
            }
            
            Spacer()
        }
        
        // Ascundem butonul de navigare înapoi implicit
        .navigationBarBackButtonHidden(true)
        
        // Adăugăm un buton personalizat pentru a ne întoarce la ecranul anterior
        .navigationBarItems(leading:
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            })
            {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                    .padding()
            }
        )
    }
    
    
    
}
