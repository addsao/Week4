//
//  BannerView.swift
//  FishStore
//
//  Banner khuyến mãi. Nếu Assets có ảnh "banner_home" thì dùng làm nền.
//

import SwiftUI
import UIKit

struct BannerView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("ƯU ĐÃI THÁNG NÀY")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(AppTheme.primary))

                    Text("Cá khỏe – Bể đẹp")
                        .font(.title2.bold())

                    Text("Không gian thư giãn cho mọi nhà ♡")
                        .font(.subheadline)
                        .opacity(0.9)
                }

                Spacer(minLength: 8)

                VStack(spacing: 0) {
                    Text("Giảm đến")
                        .font(.caption2.bold())
                    Text("30%")
                        .font(.title2.bold())
                }
                .frame(width: 76, height: 76)
                .background(Circle().fill(AppTheme.accent))
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            }

            HStack(spacing: 8) {
                feature(icon: "shippingbox.fill", text: "Giao nhanh")
                feature(icon: "checkmark.shield.fill", text: "Đóng gói an toàn")
                feature(icon: "leaf.fill", text: "Tư vấn miễn phí")
            }
        }
        .foregroundStyle(.white)
        .padding(16)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    @ViewBuilder
    private var background: some View {
        if let image = UIImage(named: "banner_home") {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.3))
        } else {
            LinearGradient(
                colors: [Color(red: 0.00, green: 0.50, blue: 0.75),
                         Color(red: 0.10, green: 0.70, blue: 0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func feature(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .font(.caption2.weight(.semibold))
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.white.opacity(0.2)))
    }
}
