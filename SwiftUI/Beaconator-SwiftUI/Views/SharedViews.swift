//
//  SharedViews.swift
//  Beaconator-SwiftUI
//
//  Created by Jeffrey Berthiaume on 07/11/26.
//  https://github.com/jeffreality/beaconator
//

import SwiftUI

struct BeaconatorHeader: View {
    @Binding var showingHelp: Bool

    var body: some View {
        HStack {
            Label("Beaconator", systemImage: "antenna.radiowaves.left.and.right")
                .font(.title.bold())
                .foregroundStyle(Color(hex: "02b7fd"))

            Spacer()

            Button {
                showingHelp = true
            } label: {
                Image(systemName: "questionmark.circle")
                    .font(.title)
                    .foregroundStyle(Color(hex: "02b7fd"))
            }
            .accessibilityLabel("Help")
        }
        .padding(.top)
    }
}

extension View {
    func cardStyle() -> some View {
        padding()
            .background(Color.white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
