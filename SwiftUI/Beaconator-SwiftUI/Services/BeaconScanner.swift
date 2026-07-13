//
//  BeaconScanner.swift
//  Beaconator-SwiftUI
//
//  Created by Jeffrey Berthiaume on 07/11/26.
//  https://github.com/jeffreality/beaconator
//

import Foundation
import Combine
import CoreLocation

final class BeaconScanner: NSObject, ObservableObject {
    @Published private(set) var isScanning = false
    @Published private(set) var detectedBeacons: [DetectedBeacon] = []
    @Published private(set) var statusMessage = "Ready to scan for matching beacons."

    private let locationManager = CLLocationManager()
    private var activeConstraint: CLBeaconIdentityConstraint?
    private var pendingUUID: UUID?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func startScanning(uuidString: String) {
        guard let uuid = UUID(uuidString: uuidString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            statusMessage = "Enter a valid detection UUID before scanning."
            return
        }

        let authorizationStatus = locationManager.authorizationStatus
        guard authorizationStatus != .denied && authorizationStatus != .restricted else {
            statusMessage = "Location permission is required to detect iBeacons."
            return
        }

        if authorizationStatus == .notDetermined {
            pendingUUID = uuid
            statusMessage = "Requesting location permission for beacon detection."
            locationManager.requestWhenInUseAuthorization()
            return
        }

        let constraint = CLBeaconIdentityConstraint(uuid: uuid)
        activeConstraint = constraint
        detectedBeacons = []
        locationManager.startRangingBeacons(satisfying: constraint)
        isScanning = true
        statusMessage = "Scanning for beacons matching this UUID."
    }

    func stopScanning() {
        if let activeConstraint {
            locationManager.stopRangingBeacons(satisfying: activeConstraint)
        }

        activeConstraint = nil
        pendingUUID = nil
        isScanning = false
        statusMessage = "Scanning stopped."
    }

    func clearDetectedBeacons() {
        detectedBeacons = []
    }
}

extension BeaconScanner: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            if let pendingUUID {
                self.pendingUUID = nil
                startScanning(uuidString: pendingUUID.uuidString)
            }
        case .denied, .restricted:
            isScanning = false
            statusMessage = "Location permission is required to detect iBeacons."
        case .notDetermined:
            break
        @unknown default:
            statusMessage = "Unknown location authorization state."
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didRange beacons: [CLBeacon],
        satisfying beaconConstraint: CLBeaconIdentityConstraint
    ) {
        detectedBeacons = beacons.map(DetectedBeacon.init)
            .sorted { lhs, rhs in
                let lhsDistance = lhs.accuracy < 0 ? .greatestFiniteMagnitude : lhs.accuracy
                let rhsDistance = rhs.accuracy < 0 ? .greatestFiniteMagnitude : rhs.accuracy
                return lhsDistance < rhsDistance
            }

        statusMessage = detectedBeacons.isEmpty
            ? "Scanning, but no matching beacons are in range yet."
            : "Found \(detectedBeacons.count) matching beacon\(detectedBeacons.count == 1 ? "" : "s")."
    }

    func locationManager(
        _ manager: CLLocationManager,
        rangingBeaconsDidFailFor beaconConstraint: CLBeaconIdentityConstraint,
        withError error: Error
    ) {
        statusMessage = "Beacon scan failed: \(error.localizedDescription)"
        isScanning = false
    }
}
