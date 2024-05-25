//
//  HelpView.swift
//  Beaconator-SwiftUI
//
//  Created by Jeffrey Berthiaume on 5/24/24.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                
                HStack {
                    Spacer()
                    Text("Help")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color(hex: "02b7fd"))
                        .padding(.bottom, 20)
                    Spacer()
                }
                
                Text("Beaconator is an application that allows you to broadcast a Bluetooth Low Energy (BLE) beacon signal using your iOS device. This guide will help you understand the features of the app and how to use them effectively.")
                
                Text("Features")
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color(hex: "02b7fd"))
                
                Text("1. **Generate Random UUID**")
                    .bold()
                Text("Tap the \"Randomize\" button to generate a random UUID. This UUID will be used as part of the beacon signal you broadcast.")
                
                Text("2. **Custom UUID, Major, and Minor Values**")
                    .bold()
                Text("You can manually enter your own UUID, Major, and Minor values if you prefer. These values uniquely identify your beacon signal.")
                
                Text("3. **Start and Stop Broadcasting**")
                    .bold()
                Text("Tap the \"BROADCAST\" button to start broadcasting the beacon signal. Once broadcasting, the button will change to \"STOP Broadcasting\". Tap it again to stop broadcasting.")
                
                Text("How to Use Beaconator")
                    .font(.title3)
                    .bold()
                
                Text("1. **Enter Identifier**")
                Text("In the text field labeled \"Identifier\", enter a unique identifier for your beacon. This is a label that helps you recognize your beacon signal.")
                
                Text("2. **Generate or Enter UUID**")
                Text("Tap the \"Randomize UUID\" button to generate a random UUID or enter your own UUID in the \"UUID\" text field.")
                
                Text("3. **Enter Major and Minor Values**")
                Text("Enter values for Major and Minor in their respective text fields. These values help further identify your beacon signal.")
                
                Text("4. **Start Broadcasting**")
                Text("Tap the \"BROADCAST\" button to start broadcasting your beacon signal. Ensure that your device's Bluetooth is turned on.")
                
                Text("5. **Stop Broadcasting**")
                Text("To stop broadcasting, tap the \"STOP Broadcasting\" button.")
                
                Text("Additional Information")
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color(hex: "02b7fd"))
                
                Text("Ensure that Bluetooth is enabled on your device to use the broadcasting feature. If Bluetooth is turned off or unsupported on your device, the app will notify you.")
                
                Spacer()
            }
            .padding()
        }
        .padding()
    }
}
