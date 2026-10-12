//
//  SearchBarView.swift
//  FishStore
//
//  Ô tìm kiếm – tìm không cần gõ dấu ("ca neon" vẫn ra "Cá Neon").
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var placeholder = "Tìm cá, cây thủy sinh, phụ kiện..."

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.primary)

            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 14).fill(AppTheme.card))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .padding(.horizontal)
    }
}
