//
//  Formatters.swift
//  FishStore
//
//  Định dạng tiền Việt Nam và ngày giờ.
//

import Foundation

extension Double {

    private static let vndFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    /// 350000 → "350.000đ"
    var vnd: String {
        (Double.vndFormatter.string(from: NSNumber(value: self)) ?? "\(Int(self))") + "đ"
    }
}

extension Date {

    private static let vnFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter
    }()

    /// "12/10/2026 14:02"
    var vnString: String { Date.vnFormatter.string(from: self) }
}

extension String {

    /// Bỏ khoảng trắng đầu / cuối.
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }

    /// Chuẩn hoá để tìm kiếm: bỏ dấu, chữ thường, đ → d.
    /// "Cá Đuôi Kiếm" → "ca duoi kiem"
    var searchKey: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "vi_VN"))
            .replacingOccurrences(of: "đ", with: "d")
            .replacingOccurrences(of: "Đ", with: "d")
    }
}
