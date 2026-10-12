//
//  CommonViews.swift
//  FishStore
//
//  Các view nhỏ dùng lại ở nhiều màn hình.
//

import SwiftUI
import UIKit

// MARK: - Ảnh sản phẩm

/// Hiện ảnh trong Assets nếu có, nếu không thì hiện SF Symbol của danh mục.
struct ProductImageView: View {
    let imageName: String
    var fallbackSymbol: String = "fish.fill"
    var tint: Color = AppTheme.primary
    var symbolSize: CGFloat = 36

    var body: some View {
        tint.opacity(0.12)
            .overlay {
                if let uiImage = loadImage() {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: fallbackSymbol)
                        .font(.system(size: symbolSize))
                        .foregroundStyle(tint)
                }
            }
            .clipped()
    }

    private func loadImage() -> UIImage? {
        imageName.isEmpty ? nil : UIImage(named: imageName)
    }
}

// MARK: - Màn hình trống

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.primary.opacity(0.6))
            Text(title)
                .font(.title3.bold())
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.primary)
                    .padding(.top, 4)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Nút icon có badge số

struct BadgeIconButton: View {
    let systemName: String
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title3)
                .foregroundStyle(AppTheme.primary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(AppTheme.card))
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                .overlay(alignment: .topTrailing) {
                    if count > 0 {
                        Text("\(min(count, 99))")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(4)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(Circle().fill(Color.red))
                            .offset(x: 4, y: -4)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Nhãn trạng thái đơn

struct StatusBadge: View {
    let status: OrderStatus

    var body: some View {
        Label(status.rawValue, systemImage: status.iconName)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(status.color)
            .background(Capsule().fill(status.color.opacity(0.15)))
    }
}

// MARK: - Chip lọc

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .foregroundStyle(isSelected ? Color.white : AppTheme.primary)
                .background(Capsule().fill(isSelected ? AppTheme.primary : AppTheme.primary.opacity(0.1)))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Dòng tổng tiền

struct SummaryRow: View {
    let title: String
    let value: String
    var isEmphasized = false
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(isEmphasized ? Color.primary : Color.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(valueColor)
        }
        .font(isEmphasized ? .headline : .subheadline)
    }
}

// MARK: - Bộ chọn số lượng

struct QuantityStepper: View {
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        HStack(spacing: 14) {
            Button {
                value = max(range.lowerBound, value - 1)
            } label: {
                Image(systemName: "minus")
                    .frame(width: 32, height: 32)
            }
            .disabled(value <= range.lowerBound)

            Text("\(value)")
                .font(.headline)
                .frame(minWidth: 28)

            Button {
                value = min(range.upperBound, value + 1)
            } label: {
                Image(systemName: "plus")
                    .frame(width: 32, height: 32)
            }
            .disabled(value >= range.upperBound)
        }
        .font(.headline)
        .foregroundStyle(AppTheme.primary)
        .padding(.horizontal, 6)
        .background(Capsule().stroke(AppTheme.primary.opacity(0.3)))
        .onChange(of: range.upperBound) { newUpper in
            if value > newUpper { value = newUpper }
        }
    }
}

// MARK: - Toast

struct ToastView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color.black.opacity(0.8)))
            .padding(.horizontal, 24)
    }
}

// MARK: - Ô thống kê

struct StatTile: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.1)))
    }
}

// MARK: - Điều hướng dùng chung

extension View {
    /// Đăng ký các màn hình đích cho NavigationStack (gọi trong mỗi tab).
    func appDestinations() -> some View {
        self
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(productId: product.id)
            }
            .navigationDestination(for: ProductCategory.self) { category in
                ProductListView(category: category)
            }
            .navigationDestination(for: Order.self) { order in
                OrderDetailView(orderId: order.id)
            }
    }
}
