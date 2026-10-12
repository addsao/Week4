//
//  OrderItem.swift
//  FishStore
//
//  Một sản phẩm trong đơn hàng.
//  Lưu lại TÊN và GIÁ tại thời điểm mua → sau này sản phẩm đổi giá
//  hoặc bị xóa thì đơn cũ vẫn hiển thị đúng.
//
//  Trong orders.txt mỗi item được mã hoá thành:  productId|số lượng|đơn giá|tên
//  Nhiều item nối với nhau bằng dấu ;
//    "2|10|20000|Cá Neon Tetra;7|2|50000|Cây Java Fern"
//

import Foundation

struct OrderItem: Identifiable, Hashable {

    let productId: Int
    var productName: String
    var unitPrice: Double
    var quantity: Int

    var id: Int { productId }

    var subtotal: Double { unitPrice * Double(quantity) }

    init(productId: Int, productName: String, unitPrice: Double, quantity: Int) {
        self.productId = productId
        self.productName = productName
        self.unitPrice = unitPrice
        self.quantity = quantity
    }

    /// Tạo từ 1 dòng giỏ hàng lúc đặt hàng.
    init(cartItem: CartItem) {
        self.init(productId: cartItem.product.id,
                  productName: cartItem.product.name,
                  unitPrice: cartItem.product.price,
                  quantity: cartItem.quantity)
    }

    // MARK: - Mã hoá cho orders.txt

    var encoded: String {
        let safeName = productName
            .replacingOccurrences(of: "|", with: "/")
            .replacingOccurrences(of: ";", with: ",")
        return "\(productId)|\(quantity)|\(Int(unitPrice))|\(safeName)"
    }

    init?(encoded: String) {
        let parts = encoded
            .split(separator: "|", maxSplits: 3, omittingEmptySubsequences: false)
            .map(String.init)
        guard parts.count == 4,
              let productId = Int(parts[0].trimmed),
              let quantity = Int(parts[1].trimmed),
              let unitPrice = Double(parts[2].trimmed) else { return nil }
        self.init(productId: productId, productName: parts[3], unitPrice: unitPrice, quantity: quantity)
    }
}
