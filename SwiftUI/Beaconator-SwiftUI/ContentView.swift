//
//  ContentView.swift
//  Beaconator-SwiftUI
//
//  Created by Jeffrey Berthiaume on 5/24/24.
//

import SwiftUI
import CoreLocation
import CoreBluetooth

struct ContentView: View {
    @State private var isBroadcasting = false
    @State private var uuid: String = UserDefaults.standard.string(forKey: "uuid") ?? UUID().uuidString
    @State private var identifier: String = UserDefaults.standard.string(forKey: "identifier") ?? ""
    @State private var major: String = UserDefaults.standard.string(forKey: "major") ?? ""
    @State private var minor: String = UserDefaults.standard.string(forKey: "minor") ?? ""
    @State private var peripheralManager: CBPeripheralManager?
    @State private var beaconRegion: CLBeaconRegion?
    
    @State private var showingHelp = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        
                        HStack {
                            Label("Beaconator", systemImage: "antenna.radiowaves.left.and.right")
                                .font(.title)
                                .bold()
                                .foregroundColor(Color(hex: "02b7fd"))
                                .padding()
                            
                            Spacer()
                            
                            Button(action: {
                                showingHelp = true
                            }) {
                                Image(systemName: "questionmark.circle")
                                    .font(.title)
                                    .foregroundColor(Color(hex: "02b7fd"))
                                    .padding()
                            }
                        }
                        
                        TextField("Identifier", text: $identifier)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("UUID", text: $uuid)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Label("Tap the \"Randomize\" button to generate a random UDID, or enter your own:", systemImage: "info.circle")
                            .padding()
                        
                        Button(action: generateRandomUUID) {
                            Text("Randomize UUID")
                                .bold()
                                .padding()
                                .background(Color(hex: "02b7fd"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                        
                        HStack {
                            TextField("Major", text: $major)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            
                            TextField("Minor", text: $minor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                        }
                        
                        Button(action: startBroadcasting) {
                            Text(isBroadcasting ? "STOP Broadcasting" : "BROADCAST")
                                .bold()
                                .padding()
                                .background(Color(hex: "02b7fd"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                }
                .padding()
                .background(Color(hex: "eff2f9"))
                
                .sheet(isPresented: $showingHelp) {
                    HelpView()
                }
            }
        }
        .onAppear {
            setupPeripheralManager()
        }
        .onDisappear {
            stopBroadcasting()
        }
    }
    
    func generateRandomUUID() {
        uuid = UUID().uuidString
        UserDefaults.standard.set(uuid, forKey: "uuid")
    }
    
    func startBroadcasting() {
        if !isBroadcasting {
            let uuid = UUID(uuidString: self.uuid)!
            let majorValue = UInt16(self.major) ?? 0
            let minorValue = UInt16(self.minor) ?? 0
            
            beaconRegion = CLBeaconRegion(uuid: uuid, major: majorValue, minor: minorValue, identifier: "net.pushplay.test")
            
            CBPeripheralDelegate.shared.beaconData = beaconRegion?.peripheralData(withMeasuredPower: nil) as? [String: Any]
            
            peripheralManager = CBPeripheralManager(delegate: CBPeripheralDelegate(), queue: nil)
            peripheralManager?.startAdvertising(CBPeripheralDelegate.shared.beaconData)
            
            isBroadcasting = true
        } else {
            stopBroadcasting()
        }
    }
    
    func stopBroadcasting() {
        peripheralManager?.stopAdvertising()
        peripheralManager = nil
        CBPeripheralDelegate.shared.beaconData = nil
        
        isBroadcasting = false
    }
    
    func setupPeripheralManager() {
        peripheralManager = CBPeripheralManager(delegate: CBPeripheralDelegate(), queue: nil)
    }
}

class CBPeripheralDelegate: NSObject, CBPeripheralManagerDelegate {
    static let shared = CBPeripheralDelegate()
    
    public var beaconData: [String: Any]?
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            peripheral.startAdvertising(beaconData)
        case .poweredOff:
            peripheral.stopAdvertising()
        case .unsupported:
            print("Unsupported")
        default:
            break
        }
    }
}

//#Preview {
//    ContentView()
//}
