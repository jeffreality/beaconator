//
//  HelpView.swift
//  Beaconator-SwiftUI
//
//  Created by Jeffrey Berthiaume on 5/24/24.
//  Updated for the modern Beaconator release.
//  https://github.com/jeffreality/beaconator
//

import SwiftUI

struct HelpView: View {
    private let accentColor = Color(hex: "02b7fd")

    private let githubURL = URL(string: "https://github.com/jeffreality/beaconator")!

    private let articleURL = URL(
        string: "https://jeffreality.medium.com/broadcasting-and-detecting-ibeacons-in-swift-6-4e1c44890620?sk=de854c0cf28593f8f32cda94269c1582"
    )!

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                
                learnMoreCard

                Text("Beaconator turns your iPhone into an iBeacon testing tool. Use one device to broadcast a beacon signal and another to detect it, making it easier to build, debug, and demonstrate apps that use Apple’s iBeacon technology.")
                
                articleCard

                sectionTitle("Typical Workflow")

                numberedStep(1, "Open the Broadcast tab on one physical iOS device.")
                numberedStep(2, "Choose a UUID, along with Major and Minor values, then tap Start Broadcasting.")
                numberedStep(3, "Show the UUID as a QR code.")
                numberedStep(4, "On a second device, open the Detect tab and scan the QR code.")
                numberedStep(5, "Start scanning to verify the beacon’s UUID, Major, Minor, RSSI, proximity, and estimated distance.")

                sectionTitle("Broadcast Tab")

                Text("Use the default identifier, net.pushplay.beacon1, or enter your own local identifier. You can type a UUID or generate a new one, choose Major and Minor values from 0 to 65535, and then begin broadcasting.")

                Text("The QR code contains the broadcast UUID, so a second device can be configured without manually typing a long value.")

                sectionTitle("Detect Tab")

                Text("iBeacon ranging is based on a target UUID. Beaconator only displays nearby beacons that match the UUID entered in the Detection UUID field.")

                Text("Tap Scan QR to copy the UUID from another device, then tap Start Scan. Matching beacons will appear with their Major and Minor values, RSSI, proximity, and estimated distance.")

                sectionTitle("Permissions")

                Text("Bluetooth is required for broadcasting. Location permission is required for iBeacon detection because Apple exposes beacon ranging through Core Location. Camera permission is only used when you tap Scan QR.")

                sectionTitle("About Beaconator")

                Text("Beaconator started as a small utility I built while developing apps that reacted to iBeacons around an office. It eventually became my most-downloaded App Store app and my most popular open-source repository.")

                Text("I brought it back with a modern SwiftUI interface, built-in beacon detection, QR sharing, and cleaner Swift 6 code. I hope it saves you a little time—or at least one afternoon of typing UUIDs into two different phones.")
            }
            .padding()
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Beaconator Help")
                .font(.largeTitle)
                .bold()
                .foregroundColor(accentColor)

            Text("Broadcast. Detect. Verify.")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 4)
    }

    private var learnMoreCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Explore the Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                .font(.title3)
                .bold()
                .foregroundColor(accentColor)

            Text("Beaconator is completely open source. Browse the SwiftUI interface, Core Bluetooth broadcaster, Core Location scanner, and QR workflow—or use the project as a starting point for your own app.")

            Link(destination: githubURL) {
                Label("Open Beaconator on GitHub", systemImage: "arrow.up.right.square")
                    .fontWeight(.semibold)
            }
        }
        .helpCardStyle()
    }

    private var articleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Read the Swift 6 Tutorial", systemImage: "doc.text")
                .font(.title3)
                .bold()
                .foregroundColor(accentColor)

            Text("The companion article explains how iBeacon broadcasting and detection work, with small Swift 6 examples you can adapt for your own projects.")

            Link(destination: articleURL) {
                Label(
                    "Broadcasting and Detecting iBeacons in Swift 6",
                    systemImage: "arrow.up.right.square"
                )
                .fontWeight(.semibold)
            }
        }
        .helpCardStyle()
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .bold()
            .foregroundColor(accentColor)
            .padding(.top, 4)
    }

    private func numberedStep(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .bold()
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(accentColor)
                .clipShape(Circle())

            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private extension View {
    func helpCardStyle() -> some View {
        self
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.quaternary, lineWidth: 1)
            }
    }
}

#Preview {
    NavigationStack {
        HelpView()
    }
}
