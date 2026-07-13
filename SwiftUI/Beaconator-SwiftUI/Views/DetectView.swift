//
//  DetectView.swift
//  Beaconator-SwiftUI
//
//  Created by Jeffrey Berthiaume on 07/11/26.
//  https://github.com/jeffreality/beaconator
//

import SwiftUI
import UIKit

struct DetectView: View {
    @ObservedObject var scanner: BeaconScanner

    @Binding var detectionUUID: String
    let broadcastUUID: String
    @Binding var showingHelp: Bool

    @State private var showingQRScanner = false
    @State private var statusMessage = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                BeaconatorHeader(showingHelp: $showingHelp)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Detect")
                        .font(.title2.bold())

                    Text("Use this tab on a second device. iBeacon ranging needs a target UUID, so scan the QR code from the broadcasting device or enter the UUID manually. Matching beacons appear below with major, minor, proximity, estimated distance, and RSSI.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .cardStyle()

                detectionForm
                detectedBeaconsSection
            }
            .padding()
        }
        .background(Color(hex: "eff2f9").ignoresSafeArea())
        .sheet(isPresented: $showingQRScanner) {
            qrScannerSheet
        }
    }

    private var detectionForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            LabeledTextField(title: "Detection UUID", text: $detectionUUID)

            HStack(spacing: 10) {
                Button(action: matchBroadcast) {
                    Label("Match Broadcast", systemImage: "arrow.down.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    statusMessage = ""
                    showingQRScanner = true
                } label: {
                    Label("Scan QR", systemImage: "camera.viewfinder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }

            Button(action: pasteUUID) {
                Label("Paste UUID", systemImage: "doc.on.clipboard")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .cardStyle()
    }

    private var detectedBeaconsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Detected Beacons", systemImage: "location.magnifyingglass")
                    .font(.headline)

                Spacer()

                Button(scanner.isScanning ? "Stop Scan" : "Start Scan") {
                    toggleScanning()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!scanner.isScanning && !isValidDetectionUUID)
            }

            Text(scanner.statusMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)

            if scanner.detectedBeacons.isEmpty {
                Text("No matching beacons detected yet. Start scanning on this device while another physical device broadcasts the same UUID.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                ForEach(scanner.detectedBeacons) { beacon in
                    DetectedBeaconRow(beacon: beacon)
                }

                Button(action: scanner.clearDetectedBeacons) {
                    Label("Clear Results", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .cardStyle()
    }

    private var qrScannerSheet: some View {
        NavigationStack {
            QRScannerView { scannedValue in
                handleScannedQRCode(scannedValue)
            }
            .navigationTitle("Scan Broadcast UUID")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingQRScanner = false }
                }
            }
        }
    }

    private var isValidDetectionUUID: Bool {
        UUID(uuidString: detectionUUID.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
    }

    private func matchBroadcast() {
        detectionUUID = broadcastUUID.trimmingCharacters(in: .whitespacesAndNewlines)
        statusMessage = "Detection UUID now matches the Broadcast tab."
    }

    private func pasteUUID() {
        guard let value = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            statusMessage = "Clipboard is empty."
            return
        }

        guard UUID(uuidString: value) != nil else {
            statusMessage = "Clipboard does not contain a valid UUID."
            return
        }

        detectionUUID = value
        statusMessage = "UUID pasted."
    }

    private func handleScannedQRCode(_ value: String) {
        let scannedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard UUID(uuidString: scannedValue) != nil else {
            statusMessage = "That QR code does not contain a valid UUID."
            return
        }

        detectionUUID = scannedValue
        statusMessage = "UUID scanned."
        showingQRScanner = false
    }

    private func toggleScanning() {
        if scanner.isScanning {
            scanner.stopScanning()
        } else {
            scanner.startScanning(uuidString: detectionUUID)
        }
    }
}
