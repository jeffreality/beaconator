//
//  DetectedBeacon.swift
//  Beaconator-SwiftUI
//
//  Created by Jeffrey Berthiaume on 07/11/26.
//  https://github.com/jeffreality/beaconator
//

import SwiftUI
import CoreLocation

struct DetectedBeacon: Identifiable {
    let uuid: UUID
    let major: Int
    let minor: Int
    let proximity: CLProximity
    let accuracy: CLLocationAccuracy
    let rssi: Int

    init(beacon: CLBeacon) {
        uuid = beacon.uuid
        major = beacon.major.intValue
        minor = beacon.minor.intValue
        proximity = beacon.proximity
        accuracy = beacon.accuracy
        rssi = beacon.rssi
    }

    var id: String { "\(uuid.uuidString)-\(major)-\(minor)" }

    var proximityDescription: String {
        switch proximity {
        case .immediate: return "Immediate"
        case .near: return "Near"
        case .far: return "Far"
        case .unknown: return "Unknown"
        @unknown default: return "Unknown"
        }
    }

    var accuracyDescription: String {
        guard accuracy >= 0 else { return "Distance unknown" }
        return String(format: "~%.2f m", accuracy)
    }
}

struct DetectedBeaconRow: View {
    let beacon: DetectedBeacon

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(beacon.proximityDescription)
                    .font(.headline)

                Spacer()

                Text("RSSI \(beacon.rssi)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(beacon.uuid.uuidString)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            HStack {
                Text("Major: \(beacon.major)")
                Text("Minor: \(beacon.minor)")
                Spacer()
                Text(beacon.accuracyDescription)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
