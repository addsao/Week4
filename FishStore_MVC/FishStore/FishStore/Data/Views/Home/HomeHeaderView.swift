//
//  HomeHeaderView.swift
//  FishStore
//
//  Phần đầu trang: logo, tên cửa hàng, nút thông báo, nút giỏ hàng.
//

import SwiftUI

struct HomeHeaderView: View {
    var storeName: String = AppTheme.storeName
    var subtitle: String = AppTheme.slogan
    let cartCount: Int
    let notificationCount: Int
    let onNotificationTap: () -> Void
    let onCartTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ProductImageView(imageName: "logo", fallbackSymbol: "fish.fill", symbolSize: 26)
                .frame(width: 52, height: 52)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(storeName)
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.primary)
                HStack(spacing: 4) {
                    Text(subtitle)
                    Image(systemName: "heart")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 4)

            BadgeIconButton(systemName: "bell.fill", count: notificationCount, action: onNotificationTap)
            BadgeIconButton(systemName: "cart.fill", count: cartCount, action: onCartTap)
        }
        .padding(.horizontal)
    }
}

// MARK: - Dòng địa chỉ giao hàng

struct LocationRowView: View {
    let address: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "mappin.circle.fill")
                .foregroundStyle(AppTheme.primary)
            Text("Giao đến:")
                .foregroundStyle(.secondary)
            Text(address)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 14).fill(AppTheme.card))
        .padding(.horizontal)
    }
}
