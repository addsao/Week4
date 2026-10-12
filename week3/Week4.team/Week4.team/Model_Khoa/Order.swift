//
//  Order.swift
//  Week4.team
//
//  Created by MAY 05 on 5/10/26.
//

import Foundation

struct Order: Identifiable, Hashable, Codable {
    let id: UUID
    var customerName: String
    var phoneNumber: String
    var shippingAddress: String
    var items: [CartItem]
    var orderDate: Date
    var status: OrderStatus
    var shippingFee: Double
    var note: String

    static let defaultShippingFee: Double = 30_000
    static let freeShippingThreshold: Double = 500_000

    init(
        id: UUID = UUID(),
        customerName: String,
        phoneNumber: String = "",
        shippingAddress: String = "",
        items: [CartItem],
        orderDate: Date = Date(),
        status: OrderStatus = .pending,
        shippingFee: Double? = nil,
        note: String = ""
    ) {
        self.id = id
        self.customerName = customerName
        self.phoneNumber = phoneNumber
        self.shippingAddress = shippingAddress
        self.items = items
        self.orderDate = orderDate
        self.status = status
        self.note = note
        self.shippingFee = shippingFee ?? Order.calculateShippingFee(for: items.totalAmount)
    }

    init(from cart: [CartItem], customerName: String, phoneNumber: String, shippingAddress: String, note: String = "") {
        self.init(
            customerName: customerName,
            phoneNumber: phoneNumber,
            shippingAddress: shippingAddress,
            items: cart,
            note: note
        )
    }

    static func calculateShippingFee(for subtotal: Double) -> Double {
        subtotal >= freeShippingThreshold ? 0 : defaultShippingFee
    }

    var subtotal: Double { items.totalAmount }
    var totalAmount: Double { subtotal + shippingFee }
    var totalQuantity: Int { items.totalQuantity }
    var isFreeShipping: Bool { shippingFee == 0 }
    var formattedSubtotal: String { subtotal.vndFormatted }
    var formattedShippingFee: String { isFreeShipping ? "Miễn phí" : shippingFee.vndFormatted }
    var formattedTotal: String { totalAmount.vndFormatted }

    var orderCode: String {
        "DH-" + id.uuidString.prefix(6).uppercased()
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter
    }()

    var formattedDate: String {
        Order.dateFormatter.string(from: orderDate)
    }

    var itemsSummary: String {
        guard let first = items.first else { return "Không có sản phẩm" }
        let others = items.count - 1
        return others > 0
            ? "\(first.product.name) và \(others) sản phẩm khác"
            : first.product.name
    }

    var isValid: Bool {
        !customerName.trimmingCharacters(in: .whitespaces).isEmpty
            && !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty
            && !shippingAddress.trimmingCharacters(in: .whitespaces).isEmpty
            && !items.isEmpty
    }

    @discardableResult
    mutating func advanceStatus() -> Bool {
        guard let next = status.next else { return false }
        status = next
        return true
    }

    @discardableResult
    mutating func cancel() -> Bool {
        guard status.canCancel else { return false }
        status = .cancelled
        return true
    }
}

// MARK: - Quản lý danh sách Orders
extension Array where Element == Order {
    func filtered(by status: OrderStatus?) -> [Order] {
        guard let status else { return self }
        return filter { $0.status == status }
    }

    var sortedByNewest: [Order] {
        sorted { $0.orderDate > $1.orderDate }
    }

    var totalRevenue: Double {
        filter { $0.status == .delivered }.reduce(0) { $0 + $1.totalAmount }
    }
}

// MARK: - Dữ liệu mẫu (Sample Orders)
extension Order {
    static var sampleOrders: [Order] {
        let products = Product.loadAll()
        guard !products.isEmpty else { return [] }

        var list: [Order] = []

        // Đơn 1
        list.append(Order(
            customerName: "Nguyễn Văn An",
            phoneNumber: "0901234567",
            shippingAddress: "Phường Trấn Biên, Thành phố Đồng Nai",
            items: [CartItem(product: products[0], quantity: 10)],
            orderDate: Date().addingTimeInterval(-2 * 3600),
            status: .pending,
            note: "Gọi trước khi giao"
        ))

        // Đơn 2
        if products.count > 2 {
            list.append(Order(
                customerName: "Trần Thị Bình",
                phoneNumber: "0912345678",
                shippingAddress: "Phường Bến Thành, TP. Hồ Chí Minh",
                items: [CartItem(product: products[1], quantity: 1)],
                orderDate: Date().addingTimeInterval(-26 * 3600),
                status: .shipping
            ))
        }

        // Đơn 3
        if products.count > 4 {
            list.append(Order(
                customerName: "Lê Minh Châu",
                phoneNumber: "0987654321",
                shippingAddress: "Phường Thủ Dầu Một, TP. Hồ Chí Minh",
                items: [CartItem(product: products[2], quantity: 5)],
                orderDate: Date().addingTimeInterval(-3 * 24 * 3600),
                status: .delivered
            ))
        }

        return list
    }

    static var preview: Order {
        sampleOrders.first ?? Order(
            customerName: "Khách lẻ",
            items: []
        )
    }
}
