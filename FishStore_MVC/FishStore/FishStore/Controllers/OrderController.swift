//
//  OrderController.swift
//  FishStore
//
//  CONTROLLER quản lý đơn hàng – đọc / ghi orders.txt.
//
//  Đặt hàng:  kiểm tra thông tin → kiểm tra tồn kho → ghi orders.txt
//             → trừ kho trong fish.txt → xóa giỏ hàng.
//  Hủy đơn:   đổi trạng thái → ghi orders.txt → hoàn kho.
//

import Foundation
import Combine

final class OrderController: ObservableObject {

    @Published private(set) var orders: [Order] = []
    @Published var errorMessage: String?

    private let storage: TxtStorage

    init(storage: TxtStorage = .shared) {
        self.storage = storage
        load()
    }

    func load() {
        orders = storage
            .readLines(TxtStorage.orderFile)
            .compactMap(Order.init(line:))
    }

    // MARK: - Truy vấn

    /// Lọc theo trạng thái (nil = tất cả), đơn mới nhất lên đầu.
    func orders(status: OrderStatus?) -> [Order] {
        orders
            .filter { status == nil || $0.status == status }
            .sorted { $0.orderDate > $1.orderDate }
    }

    func order(id: Int) -> Order? {
        orders.first { $0.id == id }
    }

    func count(status: OrderStatus) -> Int {
        orders.filter { $0.status == status }.count
    }

    /// Doanh thu từ các đơn đã giao.
    var revenue: Double {
        orders.filter { $0.status == .delivered }.reduce(0) { $0 + $1.total }
    }

    private var nextOrderId: Int {
        (orders.map(\.id).max() ?? 0) + 1
    }

    // MARK: - Kiểm tra thông tin khách

    func validateCustomer(name: String, phone: String, address: String) -> String? {
        if name.trimmed.isEmpty { return "Vui lòng nhập họ tên người nhận." }

        let digits = phone.filter(\.isNumber)
        if digits.count != 10 || !digits.hasPrefix("0") || digits.count != phone.trimmed.count {
            return "Số điện thoại phải gồm 10 chữ số và bắt đầu bằng 0."
        }
        if address.trimmed.isEmpty { return "Vui lòng nhập địa chỉ giao hàng." }
        return nil
    }

    // MARK: - Đặt hàng

    /// Trả về đơn vừa tạo, hoặc nil nếu lỗi (xem `errorMessage`).
    @discardableResult
    func placeOrder(cart: CartController,
                    productController: ProductController,
                    customerName: String,
                    phone: String,
                    address: String,
                    note: String) -> Order? {
        errorMessage = nil

        guard !cart.isEmpty else {
            errorMessage = "Giỏ hàng đang trống."
            return nil
        }
        if let error = validateCustomer(name: customerName, phone: phone, address: address) {
            errorMessage = error
            return nil
        }

        // Kiểm tra lại tồn kho mới nhất (có thể đã thay đổi sau khi bỏ vào giỏ)
        for item in cart.items {
            guard let product = productController.product(id: item.product.id) else {
                errorMessage = "\(item.product.name) không còn được bán."
                return nil
            }
            if product.stock < item.quantity {
                errorMessage = "\(product.name) chỉ còn \(product.stock) sản phẩm."
                return nil
            }
        }

        let items = cart.items.map(OrderItem.init(cartItem:))
        let subtotal = items.reduce(0) { $0 + $1.subtotal }
        let order = Order(id: nextOrderId,
                          customerName: customerName.trimmed,
                          phoneNumber: phone.trimmed,
                          shippingAddress: address.trimmed,
                          orderDate: Date(),
                          status: .pending,
                          shippingFee: Order.shippingFee(for: subtotal),
                          items: items,
                          note: note.trimmed)

        do {
            try storage.appendLine(order.txtLine, to: TxtStorage.orderFile)
        } catch {
            errorMessage = "Không ghi được orders.txt: \(error.localizedDescription)"
            return nil
        }
        orders.append(order)

        // Trừ kho
        var changes: [Int: Int] = [:]
        for item in items { changes[item.productId, default: 0] -= item.quantity }
        productController.applyStockChanges(changes)

        cart.clear()
        return order
    }

    // MARK: - Đổi trạng thái

    /// Chuyển sang bước tiếp theo (dành cho chủ cửa hàng).
    @discardableResult
    func advanceStatus(_ order: Order) -> Bool {
        guard let index = orders.firstIndex(where: { $0.id == order.id }),
              let next = orders[index].status.next else { return false }
        let old = orders[index].status
        orders[index].status = next
        if saveOrders() { return true }
        orders[index].status = old
        return false
    }

    /// Hủy đơn và hoàn lại tồn kho.
    @discardableResult
    func cancel(_ order: Order, productController: ProductController) -> Bool {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return false }
        guard orders[index].status.canCancel else {
            errorMessage = "Đơn đã giao đi, không thể hủy."
            return false
        }
        let old = orders[index].status
        orders[index].status = .cancelled
        guard saveOrders() else {
            orders[index].status = old
            return false
        }

        var changes: [Int: Int] = [:]
        for item in orders[index].items { changes[item.productId, default: 0] += item.quantity }
        productController.applyStockChanges(changes)
        return true
    }

    private func saveOrders() -> Bool {
        let sorted = orders.sorted { $0.id < $1.id }
        do {
            try storage.writeLines(sorted.map(\.txtLine), to: TxtStorage.orderFile)
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Không ghi được orders.txt: \(error.localizedDescription)"
            return false
        }
    }
}
