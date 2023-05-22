
import SwiftUI

struct ShoppingCartView: View {
    @EnvironmentObject var cartItems: CartItems // injectăm cartItems ca un environment object

    var body: some View {
        VStack {
            Text("Shopping View")
                .font(.title)
                .padding()
            
            List(cartItems.items) { item in
                Text("\(item.name)")
            }
            
        }
        
                .onAppear {
                    // setăm lista de produse din coș cu lista de produse salvate în UserDefaults
                    let userDefaults = UserDefaults.standard
                    if let savedCartItems = userDefaults.object(forKey: "cartItems") as? [String] {
                        cartItems.items = savedCartItems.map {
                            CartItems.Item(name: $0, quantity: 1)
                        }
                    }
                }
                .onDisappear {
                    // salvăm lista de produse din coș în UserDefaults când ieșim din ecran
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(cartItems.items.map { $0.name }, forKey: "cartItems")
                }
            }
    }
    
class CartItems: ObservableObject {
    typealias Element = Item
    typealias Index = Int
    
    @Published var items: [Element] = []
    
    var startIndex: Int { items.startIndex }
    var endIndex: Int { items.endIndex }
    
    subscript(position: Int) -> Item {
        return items[position]
    }
    
    func index(after i: Int) -> Int {
        return items.index(after: i)
    }
    
    func formIndex(after i: inout Int) {
        items.formIndex(after: &i)
    }
    
    func index(before i: Int) -> Int {
        return items.index(before: i)
    }
    
    func formIndex(before i: inout Int) {
        items.formIndex(before: &i)
    }
    
    func append(_ item: Item) {
        items.append(item)
    }
    
    func remove(at index: Index) {
        items.remove(at: index)
    }
    
    struct Item: Identifiable {
        let id = UUID()
        let name: String
        let quantity: Int
    }
}

extension String: Identifiable {
    public var id: String { self }
}

