//
//  BannerView.swift
//  Week4.team
//
//  Created by MAY 01 on 5/10/26.
//


import SwiftUI

struct BannerView: View {
    var body: some View {
        ZStack {
            Image("banner_home")
                .resizable()
                .scaledToFill()
                .frame(height: 140)
                .clipped()
            VStack(alignment: .leading) {
                Text("ƯU ĐÃI THÁNG NÀY")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .foregroundColor(.white)
                Text("Cá khỏe - Bể đẹp")
                    .font(.title3).bold()
                Text("Không gian thư giản cho mọi nhà ♡")
                    .font(.subheadline)
            }
            .padding()
        }
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

