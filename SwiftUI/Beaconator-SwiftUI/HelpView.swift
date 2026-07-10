//
//  HelpView.swift
//  Beaconator-SwiftUI
//
//  Created by Jeffrey Berthiaume on 5/24/24.
//  Updated with broadcast, detection, and QR transfer guidance.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Text("Help")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color(hex: "02b7fd"))
                        .padding(.bottom, 20)
                    Spacer()
                }

                Text("Beaconator can broadcast an iBeacon signal from one iOS device and detect matching nearby beacons from another iOS device. It is useful for demonstrating how a beacon UUID, major value, minor value, and local identifier can be used to recognize a nearby device or location.")

                Text("Important Concept")
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color(hex: "02b7fd"))

                Text("iBeacon detection is based on a target UUID. The Detect tab will only range beacons that match the UUID entered in the Detection UUID field. The scanner then reports the major and minor values from matching beacons.")

                Text("Broadcast Tab")
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color(hex: "02b7fd"))

                Text("1. Use the default identifier, net.pushplay.beacon1, or enter your own local identifier.")
                Text("2. Enter or randomize the Broadcast UUID.")
                Text("3. Use Show QR to display the UUID for a second device.")
                Text("4. Enter major and minor values from 0 to 65535.")
                Text("5. Tap Start Broadcasting to begin advertising the beacon.")

                Text("Detect Tab")
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color(hex: "02b7fd"))

                Text("1. On a second physical device, tap Scan QR in the Detect tab.")
                Text("2. Point the camera at the QR code shown on the broadcasting device.")
                Text("3. Beaconator will fill the Detection UUID automatically.")
                Text("4. Tap Start Scan.")
                Text("5. Nearby matching beacons will appear with their major value, minor value, proximity, estimated distance, and RSSI.")

                Text("Permissions")
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color(hex: "02b7fd"))

                Text("Bluetooth is required for broadcasting. Location permission is required for iBeacon detection because iBeacon ranging is exposed through Core Location. Camera permission is only used when you tap Scan QR to copy a Broadcast UUID from another device.")
            }
            .padding()
        }
        .padding()
    }
}
