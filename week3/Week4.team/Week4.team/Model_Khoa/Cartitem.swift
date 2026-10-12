import Foundation

struct CartItem: Identifiable, Hashable, Codable {
    var id = UUID()
    var product: Product
    var quantity: Int = 1

    var subtotal: Double { product.price * Double(quantity) }
    var formattedSubtotal: String { subtotal.vndFormatted }

    mutating func increase() {
        if quantity < product.stock { quantity += 1 }
    }

    mutating func decrease() {
        if quantity > 1 { quantity -= 1 }
    }

    mutating func setQuantity(_ value: Int) {
        quantity = min(max(1, value), max(1, product.stock))
    }
}

extension Array where Element == CartItem {
    var totalQuantity: Int { reduce(0) { $0 + $1.quantity } }
    var totalAmount: Double { reduce(0) { $0 + $1.subtotal } }

    mutating func add(_ product: Product, quantity: Int = 1) {
        guard product.isInStock else { return }
        if let idx = firstIndex(where: { $0.product.id == product.id }) {
            self[idx].setQuantity(self[idx].quantity + quantity)
        } else {
            append(CartItem(product: product, quantity: quantity))
        }
    }

    mutating func remove(_ product: Product) {
        removeAll { $0.product.id == product.id }
    }
}

extension CartItem {
    static var sampleCart: [CartItem] {
        let items = Product.loadAll()
        return items.isEmpty ? [] : [CartItem(product: items[0], quantity: 2)]
    }
}

extension Double {
    var vndFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        let str = formatter.string(from: NSNumber(value: self)) ?? "\(Int(self))"
        return str + "đ"
    }
}
