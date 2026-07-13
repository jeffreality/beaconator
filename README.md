# Beaconator

An open-source iOS utility for broadcasting and detecting Apple iBeacons.

Beaconator makes it easy to test apps that use iBeacon technology without needing dedicated beacon hardware. Configure a beacon, start broadcasting, then use a second iPhone to verify that it's being detected correctly.

Whether you're building an indoor navigation app, testing proximity interactions, validating hardware, or simply learning how iBeacons work, Beaconator gives you everything you need in one app.

## Features

* Broadcast fully configurable iBeacons
* Detect nearby iBeacons in real time
* Generate random UUIDs
* Share beacon configurations with QR codes
* Scan QR codes to configure another device instantly
* View RSSI, proximity, and estimated distance
* Adjustable UUID, Major, and Minor values
* Built with SwiftUI
* Completely open source

## Typical Workflow

1. Configure a beacon on one device.
2. Start broadcasting.
3. Display a QR code containing the beacon UUID.
4. Scan the QR code with a second device.
5. Begin scanning and immediately verify the broadcast.

No beacon hardware required.

## Why I Built This

Years ago I was working on an iOS app that reacted to iBeacons in different parts of our office. Testing meant carrying around several phones, each pretending to be a different beacon, and walking through the building to verify that the app entered and exited regions at the correct times.

There weren't many simple tools for this, so I wrote Beaconator.

It eventually became my most-downloaded app, and after sitting untouched for years, I decided to bring it back with a modern SwiftUI interface, built-in beacon detection, and QR code sharing to make two-device testing almost effortless.

If it saves you a few hours of debugging Bluetooth beacons, then it has done its job.

## Requirements

* iOS 18+ (or whatever your deployment target is)
* Two physical iOS devices are recommended for testing
* Bluetooth and Location permissions are required for broadcasting and ranging

## Contributing

Bug reports, feature requests, and pull requests are always welcome.