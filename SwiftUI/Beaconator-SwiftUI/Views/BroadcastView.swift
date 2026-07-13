//
//  BroadcastView.swift
//  Beaconator-SwiftUI
//
//  Created by Jeffrey Berthiaume on 07/11/26.
//  https://github.com/jeffreality/beaconator
//

import SwiftUI
import UIKit

struct BroadcastView: View {
    @ObservedObject var broadcaster: BeaconBroadcaster

    @Binding var identifier: String
    @Binding var uuid: String
    @Binding var major: String
    @Binding var minor: String
    @Binding var showingHelp: Bool

    @State private var showingQRCode = false
    @State private var copyStatus = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                BeaconatorHeader(showingHelp: $showingHelp)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Broadcast")
                        .font(.title2.bold())

                    Text("Use this device as the beacon. Generate or enter a UUID, optionally show it as a QR code for a second device, then start broadcasting. The identifier is a local label; the UUID, major, and minor values form the beacon identity.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .cardStyle()

                broadcastForm
                broadcastControls
            }
            .padding()
        }
        .background(Color(hex: "eff2f9").ignoresSafeArea())
        .sheet(isPresented: $showingQRCode) {
            qrCodeSheet
        }
    }

    private var broadcastForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            LabeledTextField(title: "Identifier", text: $identifier)
            LabeledTextField(title: "Broadcast UUID", text: $uuid)

            HStack(spacing: 10) {
                Button(action: generateRandomUUID) {
                    Label("Randomize", systemImage: "shuffle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    copyStatus = ""
                    showingQRCode = true
                } label: {
                    Label("Show QR", systemImage: "qrcode")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(!isValidUUID)
            }

            Button(action: copyUUID) {
                Label("Copy UUID", systemImage: "doc.on.doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(!isValidUUID)

            HStack(alignment: .top, spacing: 12) {
                LabeledTextField(title: "Major", text: $major, keyboardType: .numberPad)
                LabeledTextField(title: "Minor", text: $minor, keyboardType: .numberPad)
            }
        }
        .cardStyle()
    }

    private var broadcastControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: toggleBroadcasting) {
                Label(buttonTitle, systemImage: buttonIcon)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(buttonColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Text(broadcaster.statusMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }

    private var qrCodeSheet: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Text("Scan this QR code with the second device to copy the broadcast UUID into its Detect tab.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                QRCodeView(text: trimmedUUID)
                    .frame(width: 260, height: 260)
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                Text(trimmedUUID)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .textSelection(.enabled)

                Button(action: copyUUIDFromSheet) {
                    Label("Copy UUID", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                if !copyStatus.isEmpty {
                    Text(copyStatus)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Broadcast UUID")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showingQRCode = false }
                }
            }
        }
    }

    private var trimmedUUID: String {
        uuid.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isValidUUID: Bool {
        UUID(uuidString: trimmedUUID) != nil
    }

    private var isActive: Bool {
        broadcaster.isBroadcasting || broadcaster.isPreparing
    }

    private var buttonTitle: String {
        isActive ? "Stop Broadcasting" : "Start Broadcasting"
    }

    private var buttonIcon: String {
        isActive ? "stop.circle.fill" : "dot.radiowaves.left.and.right"
    }

    private var buttonColor: Color {
        isActive ? .red : Color(hex: "02b7fd")
    }

    private func generateRandomUUID() {
        uuid = UUID().uuidString
        copyStatus = ""
    }

    private func copyUUID() {
        UIPasteboard.general.string = trimmedUUID
    }

    private func copyUUIDFromSheet() {
        UIPasteboard.general.string = trimmedUUID
        copyStatus = "UUID copied."
    }

    private func toggleBroadcasting() {
        if isActive {
            broadcaster.stopBroadcasting()
        } else {
            broadcaster.startBroadcasting(
                identifier: identifier,
                uuidString: uuid,
                majorString: major,
                minorString: minor
            )
        }
    }
}
