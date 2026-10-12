//
//  OrderStatus.swift
//  FishStore
//
//  Trạng thái đơn hàng. Raw value tiếng Việt được ghi thẳng vào orders.txt.
//

import Foundation

enum OrderStatus: String, CaseIterable, Identifiable {

    case pending   = "Chờ xử lý"
    case preparing = "Đang chuẩn bị"
    case shipping  = "Đang giao"
    case delivered = "Đã giao"
    case cancelled = "Đã hủy"

    var id: String { rawValue }

    /// SF Symbol cho từng trạng thái.
    var iconName: String {
        switch self {
        case .pending:   return "clock.fill"
        case .preparing: return "shippingbox.fill"
        case .shipping:  return "car.fill"
        case .delivered: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }

    /// Lời nhắn hiển thị cho khách.
    var message: String {
        switch self {
        case .pending:   return "Cửa hàng đã nhận đơn và sẽ xác nhận sớm."
        case .preparing: return "Cá và sản phẩm đang được đóng gói an toàn."
        case .shipping:  return "Đơn hàng đang trên đường giao đến bạn."
        case .delivered: return "Giao hàng thành công. Cảm ơn bạn đã mua sắm!"
        case .cancelled: return "Đơn hàng đã bị hủy, số lượng đã được hoàn lại kho."
        }
    }

    /// Thứ tự trong quy trình (đơn hủy = -1).
    var step: Int {
        switch self {
        case .pending:   return 0
        case .preparing: return 1
        case .shipping:  return 2
        case .delivered: return 3
        case .cancelled: return -1
        }
    }

    /// Trạng thái kế tiếp. nil nếu đơn đã kết thúc.
    var next: OrderStatus? {
        switch self {
        case .pending:   return .preparing
        case .preparing: return .shipping
        case .shipping:  return .delivered
        case .delivered, .cancelled: return nil
        }
    }

    var isFinished: Bool { self == .delivered || self == .cancelled }

    /// Chỉ hủy được khi đơn chưa giao đi.
    var canCancel: Bool { self == .pending || self == .preparing }

    /// Các bước của thanh tiến trình.
    static let progressSteps: [OrderStatus] = [.pending, .preparing, .shipping, .delivered]
}
