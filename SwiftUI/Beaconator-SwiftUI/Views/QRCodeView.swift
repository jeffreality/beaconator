//
//  QRCodeView.swift
//  Beaconator-SwiftUI
//
//  Created by Jeffrey Berthiaume on 07/11/26.
//  https://github.com/jeffreality/beaconator
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let text: String

    private static let context = CIContext()

    var body: some View {
        if let image = makeQRCodeImage(from: text) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                Text("Unable to create QR code")
                    .font(.footnote)
            }
            .foregroundStyle(.secondary)
        }
    }

    private func makeQRCodeImage(from text: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))

        guard let cgImage = Self.context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
