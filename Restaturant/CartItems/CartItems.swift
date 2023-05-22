//import Foundation
//
//class CartItems: ObservableObject {
//    typealias Element = Item
//    typealias Index = Int
//    
//    @Published var items: [Element] = []
//    
//    var startIndex: Int { items.startIndex }
//    var endIndex: Int { items.endIndex }
//    
//    subscript(position: Int) -> Item {
//        return items[position]
//    }
//    
//    func index(after i: Int) -> Int {
//        return items.index(after: i)
//    }
//    
//    func formIndex(after i: inout Int) {
//        items.formIndex(after: &i)
//    }
//    
//    func index(before i: Int) -> Int {
//        return items.index(before: i)
//    }
//    
//    func formIndex(before i: inout Int) {
//        items.formIndex(before: &i)
//    }
//    
//    func append(_ item: Item) {
//        items.append(item)
//    }
//    
//    func remove(at index: Index) {
//        items.remove(at: index)
//    }
//    
//    struct Item: Identifiable {
//        let id = UUID()
//        let name: String
//        let quantity: Int
//    }
//}
//
//extension String: Identifiable {
//    public var id: String { self }
//}
//
