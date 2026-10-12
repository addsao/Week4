//
//  Product.swift
//  Week4.team
//
//  Created by MAY 05 on 5/10/26.
//

import Foundation


struct Product: Identifiable, Hashable, Codable {
    let id: Int
    var name: String
    var categoryId: Int
    var price: Double
    var stock: Int
    var description: String
    var imageName: String
    var unit: String
    var isFeatured: Bool
    var rating: Double
    
    init(
        id: Int,
        name: String,
        categoryId: Int,
        price: Double,
        stock: Int,
        description: String,
        imageName: String,
        unit: String = "cái",
        isFeatured: Bool = false,
        rating: Double = 5.0
    ) {
        self.id = id
        self.name = name
        self.categoryId = categoryId
        self.price = max(0, price)
        self.stock = max(0, stock)
        self.description = description
        self.imageName = imageName
        self.unit = unit
        self.isFeatured = isFeatured
        self.rating = rating
    }
    
    var isInStock: Bool { stock > 0 }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        let numStr = formatter.string(from: NSNumber(value: price)) ?? "\(Int(price))"
        return numStr + "đ"
    }
    
    func matches(keyword: String) -> Bool {
        let key = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        if key.isEmpty { return true }
        let opts: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        return name.range(of: key, options: opts) != nil || description.range(of: key, options: opts) != nil
    }
}

extension Product {
    
    // Parse 1 dòng: 1, "Cá bảy màu", 1, 10000, 45, "Cá guppy...", "guppy"
    init?(fromCSVLine line: String) {
        let clean = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return nil }
        
        let cols = clean
            .replacingOccurrences(of: "\"", with: "")
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        guard cols.count >= 7,
              let id = Int(cols[0]),
              let catId = Int(cols[2]),
              let price = Double(cols[3]),
              let stock = Int(cols[4]) else {
            return nil
        }
        
        self.id = id
        self.name = cols[1]
        self.categoryId = catId
        self.price = price
        self.stock = stock
        self.description = cols[5]
        self.imageName = "fish\(id)" // Gán tự động theo fish1, fish2...
        self.unit = (catId == 1 ? "con" : (catId == 2 ? "cây" : "cái"))
        self.isFeatured = stock > 20
        self.rating = 4.8
    }
    
    // Đọc từ file fish.txt
    static func loadAll(from fileName: String = "fish") -> [Product] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        
        return text
            .components(separatedBy: .newlines)
            .compactMap { Product(fromCSVLine: $0) }
    }
}
