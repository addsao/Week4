//
//  ProductCategory.swift
//  Week4.team
//
//  Created by MAY 05 on 5/10/26.
//

import Foundation

struct ProductCategory: Identifiable, Hashable, Codable {
    let id: Int
    var name: String
    var iconName: String
    var systemIconName: String
    var subtitles: [String]
    var backgroundHex: String
    var isProductCategory: Bool
    
    var subtitleText: String {
        subtitles.joined(separator: "\n")
    }
}

extension ProductCategory {
    
    init?(fromCSVLine line: String) {
        let clean = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return nil }
        
        let cols = clean
            .replacingOccurrences(of: "\"", with: "")
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        guard cols.count >= 7, let id = Int(cols[0]) else { return nil }
        
        self.id = id
        self.name = cols[1]
        self.iconName = cols[2]
        self.systemIconName = cols[3]
        self.subtitles = cols[4].components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
        self.backgroundHex = cols[5]
        self.isProductCategory = (cols[6].lowercased() == "true")
    }
    

    static func loadAll() -> [ProductCategory] {
        guard let url = Bundle.main.url(forResource: "categories", withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        
        return text
            .components(separatedBy: .newlines)
            .compactMap { ProductCategory(fromCSVLine: $0) }
    }
}
