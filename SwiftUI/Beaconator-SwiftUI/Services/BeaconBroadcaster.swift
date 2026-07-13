//
//  BeaconBroadcaster.swift
//  Beaconator-SwiftUI
//
//  Created by Jeffrey Berthiaume on 07/11/26.
//  https://github.com/jeffreality/beaconator
//

import Foundation
import Combine
import CoreBluetooth
import CoreLocation

final class BeaconBroadcaster: NSObject, ObservableObject {
    @Published private(set) var isBroadcasting = false
    @Published private(set) var isPreparing = false
    @Published private(set) var statusMessage = "Ready to broadcast."

    private var peripheralManager: CBPeripheralManager?
    private var pendingAdvertisementData: [String: Any]?
    private var pendingIdentifier: String?

    func startBroadcasting(
        identifier: String,
        uuidString: String,
        majorString: String,
        minorString: String
    ) {
        guard let uuid = UUID(uuidString: uuidString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            statusMessage = "Enter a valid UUID before broadcasting."
            return
        }

        guard let major = UInt16(majorString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            statusMessage = "Enter a major value from 0 to 65535."
            return
        }

        guard let minor = UInt16(minorString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            statusMessage = "Enter a minor value from 0 to 65535."
            return
        }

        let trimmedIdentifier = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalIdentifier = trimmedIdentifier.isEmpty ? defaultBeaconIdentifier : trimmedIdentifier

        let constraint = CLBeaconIdentityConstraint(uuid: uuid, major: major, minor: minor)
        let region = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: finalIdentifier)

        pendingAdvertisementData = region.peripheralData(withMeasuredPower: nil) as? [String: Any]
        pendingIdentifier = finalIdentifier
        isPreparing = true
        isBroadcasting = false
        statusMessage = "Preparing Bluetooth…"

        if peripheralManager == nil {
            peripheralManager = CBPeripheralManager(delegate: self, queue: .main)
        } else {
            beginAdvertisingIfReady()
        }
    }

    func stopBroadcasting() {
        peripheralManager?.stopAdvertising()
        pendingAdvertisementData = nil
        pendingIdentifier = nil
        isPreparing = false
        isBroadcasting = false
        statusMessage = "Broadcasting stopped."
    }

    private func beginAdvertisingIfReady() {
        guard isPreparing,
              let peripheralManager,
              peripheralManager.state == .poweredOn else {
            if let peripheralManager {
                updateStatus(for: peripheralManager.state)
            }
            return
        }

        guard let advertisementData = pendingAdvertisementData else {
            isPreparing = false
            statusMessage = "Unable to create beacon advertising data."
            return
        }

        peripheralManager.stopAdvertising()
        peripheralManager.startAdvertising(advertisementData)
        statusMessage = "Starting beacon broadcast…"
    }

    private func updateStatus(for state: CBManagerState) {
        switch state {
        case .poweredOn:
            statusMessage = "Bluetooth is ready."
        case .poweredOff:
            isPreparing = false
            isBroadcasting = false
            statusMessage = "Bluetooth is off. Turn it on to broadcast."
        case .unauthorized:
            isPreparing = false
            isBroadcasting = false
            statusMessage = "Bluetooth permission is required."
        case .unsupported:
            isPreparing = false
            isBroadcasting = false
            statusMessage = "BLE peripheral broadcasting is not supported on this device."
        case .resetting:
            statusMessage = "Bluetooth is resetting…"
        case .unknown:
            statusMessage = "Waiting for Bluetooth…"
        @unknown default:
            isPreparing = false
            isBroadcasting = false
            statusMessage = "Bluetooth is unavailable."
        }
    }
}

extension BeaconBroadcaster: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        updateStatus(for: peripheral.state)

        if peripheral.state == .poweredOn {
            beginAdvertisingIfReady()
        }
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error {
            isPreparing = false
            isBroadcasting = false
            statusMessage = "Unable to broadcast: \(error.localizedDescription)"
            return
        }

        isPreparing = false
        isBroadcasting = true
        statusMessage = pendingIdentifier.map { "Broadcasting \($0)." } ?? "Broadcasting beacon."
    }
}
