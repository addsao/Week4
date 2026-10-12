//
//  TxtStorage.swift
//  FishStore
//
//  Lớp đọc / ghi file .txt (thuộc tầng MODEL – nơi lưu trữ dữ liệu).
//
//  - File gốc nằm trong Bundle của app (chỉ đọc được).
//  - Lần đầu chạy, file được copy sang thư mục Documents của app.
//  - Từ đó mọi thao tác đọc / ghi đều làm trên bản trong Documents.
//

import Foundation

final class TxtStorage: @unchecked Sendable {

    // MARK: - Tên các file dữ liệu

    static let categoryFile = "category.txt"
    static let productFile  = "fish.txt"
    static let orderFile    = "orders.txt"

    static let shared = TxtStorage()

    private let fileManager = FileManager.default
    private let directory: URL

    /// `directory` mặc định là thư mục Documents của app.
    init(directory: URL? = nil) {
        self.directory = directory
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    // MARK: - Đường dẫn

    func url(for fileName: String) -> URL {
        directory.appendingPathComponent(fileName)
    }

    /// Đảm bảo file đã có trong Documents (copy từ Bundle nếu chưa có).
    private func prepare(_ fileName: String) {
        let destination = url(for: fileName)
        guard !fileManager.fileExists(atPath: destination.path) else { return }

        if let source = bundleURL(for: fileName) {
            try? fileManager.copyItem(at: source, to: destination)
        } else {
            fileManager.createFile(atPath: destination.path, contents: Data())
        }
    }

    private func bundleURL(for fileName: String) -> URL? {
        let name = (fileName as NSString).deletingPathExtension
        let ext  = (fileName as NSString).pathExtension
        return Bundle.main.url(forResource: name, withExtension: ext)
    }

    // MARK: - Đọc

    /// Đọc file → mảng các dòng (bỏ dòng trống và dòng chú thích bắt đầu bằng #).
    func readLines(_ fileName: String) -> [String] {
        prepare(fileName)
        guard var content = try? String(contentsOf: url(for: fileName), encoding: .utf8) else {
            return []
        }
        // Bỏ ký tự BOM nếu file được lưu bằng Notepad
        if content.hasPrefix("\u{FEFF}") { content.removeFirst() }

        return content
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !$0.hasPrefix("#") }
    }

    // MARK: - Ghi

    /// Ghi đè toàn bộ file bằng danh sách dòng mới.
    func writeLines(_ lines: [String], to fileName: String) throws {
        let text = lines.joined(separator: "\n") + (lines.isEmpty ? "" : "\n")
        try text.write(to: url(for: fileName), atomically: true, encoding: .utf8)
    }

    /// Thêm 1 dòng vào cuối file.
    func appendLine(_ line: String, to fileName: String) throws {
        prepare(fileName)
        let fileURL = url(for: fileName)
        var content = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
        if !content.isEmpty && !content.hasSuffix("\n") { content += "\n" }
        content += line + "\n"
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    /// Xóa bản trong Documents và copy lại bản gốc từ Bundle.
    func resetToDefault(_ fileName: String) {
        try? fileManager.removeItem(at: url(for: fileName))
        prepare(fileName)
    }
}

// MARK: - Định dạng 1 dòng txt

/// Mỗi dòng có dạng:  1, "Cá bảy màu", 1, 10000, 45
/// Chuỗi đặt trong dấu nháy kép, số để trần, ngăn cách bằng dấu phẩy.
enum TxtFormat {

    /// Tách 1 dòng thành các cột.
    /// Dấu phẩy nằm TRONG "..." không bị tách:
    ///   1, "Cá đẹp, dễ nuôi", 2   →   ["1", "Cá đẹp, dễ nuôi", "2"]
    static func splitFields(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false

        for character in line {
            if character == "\"" {
                inQuotes.toggle()
            } else if character == "," && !inQuotes {
                fields.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
            } else {
                current.append(character)
            }
        }
        fields.append(current.trimmingCharacters(in: .whitespaces))
        return fields
    }

    /// Bọc chuỗi trong dấu nháy kép.
    /// Dấu " và xuống dòng bên trong được thay thế để không làm hỏng file.
    static func quote(_ text: String) -> String {
        let clean = text
            .replacingOccurrences(of: "\"", with: "'")
            .replacingOccurrences(of: "\r", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
        return "\"\(clean)\""
    }
}
