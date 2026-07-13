//
//  LabeledTextField.swift
//  Beaconator-SwiftUI
//
//  Created by Jeffrey Berthiaume on 07/11/26.
//  https://github.com/jeffreality/beaconator
//

import SwiftUI

struct LabeledTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField("", text: $text)
                .textFieldStyle(.roundedBorder)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
    }
}
