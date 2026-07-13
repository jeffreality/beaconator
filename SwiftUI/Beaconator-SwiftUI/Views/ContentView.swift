//
//  ContentView.swift
//  Beaconator-SwiftUI
//
//  Created by Jeffrey Berthiaume on 07/11/26.
//  https://github.com/jeffreality/beaconator
//

import SwiftUI

let defaultBeaconIdentifier = "net.pushplay.beacon1"

struct ContentView: View {
    private static func savedIdentifier() -> String {
        let savedValue = UserDefaults.standard.string(forKey: "broadcastIdentifier")
            ?? UserDefaults.standard.string(forKey: "identifier")
            ?? ""
        return savedValue.isEmpty ? defaultBeaconIdentifier : savedValue
    }

    private static func savedBroadcastUUID() -> String {
        UserDefaults.standard.string(forKey: "broadcastUUID")
            ?? UserDefaults.standard.string(forKey: "uuid")
            ?? UUID().uuidString
    }

    private static func savedDetectUUID() -> String {
        UserDefaults.standard.string(forKey: "detectUUID")
            ?? UserDefaults.standard.string(forKey: "broadcastUUID")
            ?? UserDefaults.standard.string(forKey: "uuid")
            ?? UUID().uuidString
    }

    @StateObject private var broadcaster = BeaconBroadcaster()
    @StateObject private var scanner = BeaconScanner()

    @State private var broadcastUUID = ContentView.savedBroadcastUUID()
    @State private var detectUUID = ContentView.savedDetectUUID()
    @State private var broadcastIdentifier = ContentView.savedIdentifier()
    @State private var major = UserDefaults.standard.string(forKey: "major") ?? "1"
    @State private var minor = UserDefaults.standard.string(forKey: "minor") ?? "1"
    @State private var showingHelp = false

    var body: some View {
        NavigationStack {
            TabView {
                BroadcastView(
                    broadcaster: broadcaster,
                    identifier: $broadcastIdentifier,
                    uuid: $broadcastUUID,
                    major: $major,
                    minor: $minor,
                    showingHelp: $showingHelp
                )
                .tabItem {
                    Label("Broadcast", systemImage: "dot.radiowaves.left.and.right")
                }

                DetectView(
                    scanner: scanner,
                    detectionUUID: $detectUUID,
                    broadcastUUID: broadcastUUID,
                    showingHelp: $showingHelp
                )
                .tabItem {
                    Label("Detect", systemImage: "location.magnifyingglass")
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingHelp) {
                HelpView()
            }
        }
        .onAppear(perform: saveDefaults)
        .onDisappear {
            broadcaster.stopBroadcasting()
            scanner.stopScanning()
        }
        .onChange(of: broadcastIdentifier) { _ in saveDefaults() }
        .onChange(of: broadcastUUID) { _ in saveDefaults() }
        .onChange(of: detectUUID) { _ in saveDefaults() }
        .onChange(of: major) { _ in saveDefaults() }
        .onChange(of: minor) { _ in saveDefaults() }
    }

    private func saveDefaults() {
        UserDefaults.standard.set(broadcastIdentifier, forKey: "broadcastIdentifier")
        UserDefaults.standard.set(broadcastUUID, forKey: "broadcastUUID")
        UserDefaults.standard.set(detectUUID, forKey: "detectUUID")
        UserDefaults.standard.set(major, forKey: "major")
        UserDefaults.standard.set(minor, forKey: "minor")

        // Preserve compatibility with older Beaconator versions.
        UserDefaults.standard.set(broadcastIdentifier, forKey: "identifier")
        UserDefaults.standard.set(broadcastUUID, forKey: "uuid")
    }
}
