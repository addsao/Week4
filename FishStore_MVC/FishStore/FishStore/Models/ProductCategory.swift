//
//  ProductCategory.swift
//  FishStore
//
//  Danh mục sản phẩm – đọc từ category.txt
//
//  Định dạng 1 dòng:   id, "tên danh mục"
//  Ví dụ:              1, "Cá cảnh"
//

import Foundation

struct ProductCategory: Identifiable, Hashable {

    let id: Int
    var name: String

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    // MARK: - Đọc / ghi txt

    /// Tạo danh mục từ 1 dòng txt. Trả về nil nếu dòng sai định dạng.
    init?(line: String) {
        let fields = TxtFormat.splitFields(line)
        guard fields.count >= 2,
              let id = Int(fields[0]),
              !fields[1].isEmpty else { return nil }
        self.init(id: id, name: fields[1])
    }

    /// Chuyển ngược thành 1 dòng txt.
    var txtLine: String {
        "\(id), \(TxtFormat.quote(name))"
    }

    // MARK: - Hiển thị

    /// SF Symbol đại diện cho danh mục (dùng khi chưa có ảnh trong Assets).
    var iconName: String {
        switch id {
        case 1:  return "fish.fill"
        case 2:  return "leaf.fill"
        case 3:  return "cube.transparent"
        case 4:  return "mountain.2.fill"
        case 5:  return "fan.fill"
        case 6:  return "takeoutbag.and.cup.and.straw.fill"
        case 7:  return "cross.case.fill"
        case 8:  return "drop.fill"
        default: return "square.grid.2x2.fill"
        }
    }
}
