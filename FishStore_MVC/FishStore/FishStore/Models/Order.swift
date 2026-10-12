//
//  Order.swift
//  FishStore
//
//  Đơn hàng – lưu trong orders.txt
//
//  Định dạng 1 dòng:
//    id, "tên khách", "SĐT", "địa chỉ", thời gian (giây từ 1970), "trạng thái",
//    phí ship, "danh sách item", "ghi chú"
//  Ví dụ:
//    1, "Nguyễn Văn An", "0901234567", "Phường Trấn Biên, Đồng Nai", 1791599400,
//    "Chờ xử lý", 30000, "2|10|20000|Cá Neon Tetra", "Gọi trước khi giao"
//

import Foundation

struct Order: Identifiable, Hashable {

    let id: Int
    var customerName: String
    var phoneNumber: String
    var shippingAddress: String
    var orderDate: Date
    var status: OrderStatus
    var shippingFee: Double
    var items: [OrderItem]
    var note: String

    // MARK: - Quy định phí ship

    static let defaultShippingFee: Double = 30_000
    static let freeShippingThreshold: Double = 500_000

    /// Miễn phí ship cho đơn từ 500.000đ.
    static func shippingFee(for subtotal: Double) -> Double {
        if subtotal <= 0 { return 0 }
        return subtotal >= freeShippingThreshold ? 0 : defaultShippingFee
    }

    init(id: Int,
         customerName: String,
         phoneNumber: String,
         shippingAddress: String,
         orderDate: Date = Date(),
         status: OrderStatus = .pending,
         shippingFee: Double,
         items: [OrderItem],
         note: String = "") {
        self.id = id
        self.customerName = customerName
        self.phoneNumber = phoneNumber
        self.shippingAddress = shippingAddress
        self.orderDate = orderDate
        self.status = status
        self.shippingFee = shippingFee
        self.items = items
        self.note = note
    }

    // MARK: - Đọc / ghi txt

    init?(line: String) {
        let f = TxtFormat.splitFields(line)
        guard f.count >= 8,
              let id = Int(f[0]),
              let timestamp = Double(f[4]),
              let status = OrderStatus(rawValue: f[5]),
              let fee = Double(f[6]) else {
            print("⚠️ orders.txt – bỏ qua dòng sai định dạng: \(line)")
            return nil
        }
        let items = f[7]
            .split(separator: ";")
            .compactMap { OrderItem(encoded: String($0)) }

        self.init(id: id,
                  customerName: f[1],
                  phoneNumber: f[2],
                  shippingAddress: f[3],
                  orderDate: Date(timeIntervalSince1970: timestamp),
                  status: status,
                  shippingFee: fee,
                  items: items,
                  note: f.count > 8 ? f[8] : "")
    }

    var txtLine: String {
        let itemsText = items.map(\.encoded).joined(separator: ";")
        return [
            "\(id)",
            TxtFormat.quote(customerName),
            TxtFormat.quote(phoneNumber),
            TxtFormat.quote(shippingAddress),
            "\(Int(orderDate.timeIntervalSince1970))",
            TxtFormat.quote(status.rawValue),
            "\(Int(shippingFee))",
            TxtFormat.quote(itemsText),
            TxtFormat.quote(note)
        ].joined(separator: ", ")
    }

    // MARK: - Tính tiền & hiển thị

    var subtotal: Double { items.reduce(0) { $0 + $1.subtotal } }

    var total: Double { subtotal + shippingFee }

    var totalQuantity: Int { items.reduce(0) { $0 + $1.quantity } }

    /// Mã đơn: DH0001
    var code: String { String(format: "DH%04ld", id) }

    /// "Cá Neon Tetra và 1 sản phẩm khác"
    var itemsSummary: String {
        guard let first = items.first else { return "Không có sản phẩm" }
        return items.count > 1
            ? "\(first.productName) và \(items.count - 1) sản phẩm khác"
            : first.productName
    }
}
