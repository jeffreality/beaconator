//
//  ContentView.swift
//  Beaconator-SwiftUI
//
//  Created by Jeffrey Berthiaume on 5/24/24.
//  Updated to broadcast and detect nearby iBeacons.
//

import SwiftUI
import CoreLocation
import CoreBluetooth
import CoreImage.CIFilterBuiltins
import UIKit
import AVFoundation
import AudioToolbox

private let defaultIdentifier = "net.pushplay.beacon1"

struct ContentView: View {
    private static func savedIdentifier() -> String {
        let savedValue = UserDefaults.standard.string(forKey: "broadcastIdentifier")
            ?? UserDefaults.standard.string(forKey: "identifier")
            ?? ""
        return savedValue.isEmpty ? defaultIdentifier : savedValue
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

    @State private var selectedTab = 0
    @State private var broadcastUUID: String = ContentView.savedBroadcastUUID()
    @State private var detectUUID: String = ContentView.savedDetectUUID()
    @State private var broadcastIdentifier: String = ContentView.savedIdentifier()
    @State private var major: String = UserDefaults.standard.string(forKey: "major") ?? "1"
    @State private var minor: String = UserDefaults.standard.string(forKey: "minor") ?? "1"

    @State private var showingHelp = false
    @State private var showingQRCode = false
    @State private var showingQRScanner = false
    @State private var qrCopyStatus = ""
    @State private var detectPasteStatus = ""
    @State private var qrScanStatus = ""

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        broadcastExplanation
                        broadcastForm
                        broadcastControls
                    }
                    .padding()
                }
                .background(Color(hex: "eff2f9").ignoresSafeArea())
                .tabItem {
                    Label("Broadcast", systemImage: "dot.radiowaves.left.and.right")
                }
                .tag(0)

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        detectExplanation
                        detectForm
                        detectedBeaconsSection
                    }
                    .padding()
                }
                .background(Color(hex: "eff2f9").ignoresSafeArea())
                .tabItem {
                    Label("Detect", systemImage: "location.magnifyingglass")
                }
                .tag(1)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingHelp) {
                HelpView()
            }
            .sheet(isPresented: $showingQRCode) {
                qrCodeSheet
            }
            .sheet(isPresented: $showingQRScanner) {
                qrScannerSheet
            }
        }
        .onAppear {
            saveDefaults()
        }
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

    private var header: some View {
        HStack {
            Label("Beaconator", systemImage: "antenna.radiowaves.left.and.right")
                .font(.title)
                .bold()
                .foregroundColor(Color(hex: "02b7fd"))

            Spacer()

            Button(action: { showingHelp = true }) {
                Image(systemName: "questionmark.circle")
                    .font(.title)
                    .foregroundColor(Color(hex: "02b7fd"))
                    .accessibilityLabel("Help")
            }
        }
        .padding(.top)
    }

    private var broadcastExplanation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Broadcast")
                .font(.title2)
                .bold()

            Text("Use this device as the beacon. Generate or enter a UUID, optionally show it as a QR code for a second device, then start broadcasting. The identifier is a local label for this beacon region; the UUID, major, and minor values are the broadcast identity.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .cardStyle()
    }

    private var detectExplanation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Detect")
                .font(.title2)
                .bold()

            Text("Use this tab on a second device. iBeacon detection needs a target UUID, so scan the QR code from the broadcasting device or enter the UUID manually. Matching beacons will appear below with their major, minor, proximity, estimated distance, and RSSI.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .cardStyle()
    }

    private var broadcastForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            LabeledTextField(
                title: "Identifier",
                text: $broadcastIdentifier,
                keyboardType: .default,
                autocapitalization: .none
            )

            LabeledTextField(
                title: "Broadcast UUID",
                text: $broadcastUUID,
                keyboardType: .default,
                autocapitalization: .none
            )

            HStack(spacing: 10) {
                Button(action: generateRandomBroadcastUUID) {
                    Label("Randomize", systemImage: "shuffle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: showQRCode) {
                    Label("Show QR", systemImage: "qrcode")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(!isValidUUID(broadcastUUID))
            }

            Button(action: copyBroadcastUUID) {
                Label("Copy UUID", systemImage: "doc.on.doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            HStack(alignment: .top, spacing: 12) {
                LabeledTextField(
                    title: "Major",
                    text: $major,
                    keyboardType: .numberPad,
                    autocapitalization: .none
                )

                LabeledTextField(
                    title: "Minor",
                    text: $minor,
                    keyboardType: .numberPad,
                    autocapitalization: .none
                )
            }
        }
        .cardStyle()
    }

    private var detectForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            LabeledTextField(
                title: "Detection UUID",
                text: $detectUUID,
                keyboardType: .default,
                autocapitalization: .none
            )

            HStack(spacing: 10) {
                Button(action: useBroadcastUUIDForDetection) {
                    Label("My UUID", systemImage: "arrow.down.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button(action: scanQRCodeForDetection) {
                    Label("Scan QR", systemImage: "camera.viewfinder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }

            Button(action: pasteDetectionUUID) {
                Label("Paste UUID", systemImage: "doc.on.clipboard")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            if !detectPasteStatus.isEmpty {
                Text(detectPasteStatus)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            if !qrScanStatus.isEmpty {
                Text(qrScanStatus)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .cardStyle()
    }

    private var broadcastControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: toggleBroadcasting) {
                Label(
                    broadcaster.isBroadcasting ? "Stop Broadcasting" : "Start Broadcasting",
                    systemImage: broadcaster.isBroadcasting ? "stop.circle.fill" : "dot.radiowaves.left.and.right"
                )
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(broadcaster.isBroadcasting ? Color.red : Color(hex: "02b7fd"))
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            Text(broadcaster.statusMessage)
                .font(.footnote)
                .foregroundColor(.secondary)
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
                .disabled(!scanner.isScanning && !isValidUUID(detectUUID))
            }

            Text(scanner.statusMessage)
                .font(.footnote)
                .foregroundColor(.secondary)

            if scanner.detectedBeacons.isEmpty {
                Text("No matching beacons detected yet. Start scanning on this device while another physical device broadcasts the same UUID.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
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

    private var qrCodeSheet: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 18) {
                Text("Scan this QR code with the second device to copy the broadcast UUID into the Detect tab.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                QRCodeView(text: trimmedBroadcastUUID)
                    .frame(width: 260, height: 260)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(18)

                Text(trimmedBroadcastUUID)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .textSelection(.enabled)
                    .padding(.horizontal)

                Button(action: copyBroadcastUUIDFromSheet) {
                    Label("Copy UUID", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                if !qrCopyStatus.isEmpty {
                    Text(qrCopyStatus)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitle("Broadcast UUID", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") { showingQRCode = false })
        }
    }

    private var qrScannerSheet: some View {
        NavigationView {
            UUIDQRScannerView { scannedValue in
                handleScannedQRCode(scannedValue)
            }
            .navigationBarTitle("Scan Broadcast UUID", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") { showingQRScanner = false })
        }
    }

    private var trimmedBroadcastUUID: String {
        broadcastUUID.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func generateRandomBroadcastUUID() {
        broadcastUUID = UUID().uuidString
        detectUUID = broadcastUUID
        qrCopyStatus = ""
        saveDefaults()
    }

    private func showQRCode() {
        qrCopyStatus = ""
        showingQRCode = true
    }

    private func copyBroadcastUUID() {
        UIPasteboard.general.string = trimmedBroadcastUUID
    }

    private func copyBroadcastUUIDFromSheet() {
        UIPasteboard.general.string = trimmedBroadcastUUID
        qrCopyStatus = "UUID copied."
    }

    private func useBroadcastUUIDForDetection() {
        detectUUID = trimmedBroadcastUUID
        detectPasteStatus = "Detection UUID set to the current broadcast UUID."
    }

    private func scanQRCodeForDetection() {
        qrScanStatus = ""
        detectPasteStatus = ""
        showingQRScanner = true
    }

    private func handleScannedQRCode(_ value: String) {
        let scannedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)

        if isValidUUID(scannedValue) {
            detectUUID = scannedValue
            qrScanStatus = "UUID scanned."
            showingQRScanner = false
        } else {
            qrScanStatus = "That QR code does not contain a valid UUID."
        }
    }

    private func pasteDetectionUUID() {
        guard let pastedValue = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines), !pastedValue.isEmpty else {
            detectPasteStatus = "Clipboard is empty."
            return
        }

        if isValidUUID(pastedValue) {
            detectUUID = pastedValue
            detectPasteStatus = "UUID pasted."
        } else {
            detectPasteStatus = "Clipboard does not contain a valid UUID."
        }
    }

    private func toggleBroadcasting() {
        if broadcaster.isBroadcasting {
            broadcaster.stopBroadcasting()
        } else {
            broadcaster.startBroadcasting(
                identifier: broadcastIdentifier.isEmpty ? defaultIdentifier : broadcastIdentifier,
                uuidString: broadcastUUID,
                majorString: major,
                minorString: minor
            )
        }
    }

    private func toggleScanning() {
        if scanner.isScanning {
            scanner.stopScanning()
        } else {
            scanner.startScanning(uuidString: detectUUID)
        }
    }

    private func saveDefaults() {
        UserDefaults.standard.set(broadcastIdentifier, forKey: "broadcastIdentifier")
        UserDefaults.standard.set(broadcastUUID, forKey: "broadcastUUID")
        UserDefaults.standard.set(detectUUID, forKey: "detectUUID")
        UserDefaults.standard.set(major, forKey: "major")
        UserDefaults.standard.set(minor, forKey: "minor")

        // Keep the old keys populated so older builds of the app still have usable defaults.
        UserDefaults.standard.set(broadcastIdentifier, forKey: "identifier")
        UserDefaults.standard.set(broadcastUUID, forKey: "uuid")
    }

    private func isValidUUID(_ value: String) -> Bool {
        UUID(uuidString: value.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
    }
}

private struct LabeledTextField: View {
    let title: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let autocapitalization: UITextAutocapitalizationType

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            TextField("", text: $text)
                .textFieldStyle(.roundedBorder)
                .keyboardType(keyboardType)
                .autocapitalization(autocapitalization)
                .disableAutocorrection(true)
        }
    }
}

private struct QRCodeView: View {
    let text: String

    private static let context = CIContext()

    var body: some View {
        if let image = makeQRCodeImage(from: text) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                Text("Unable to create QR code")
                    .font(.footnote)
            }
            .foregroundColor(.secondary)
        }
    }

    private func makeQRCodeImage(from text: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }

        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))

        guard let cgImage = QRCodeView.context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}


private struct UUIDQRScannerView: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let viewController = QRScannerViewController()
        viewController.onCodeScanned = onCodeScanned
        return viewController
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) { }
}

private final class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeScanned: ((String) -> Void)?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let messageLabel = UILabel()
    private var didScanCode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureMessageLabel()
        configureScanner()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
        messageLabel.frame = CGRect(
            x: 16,
            y: view.safeAreaInsets.top + 16,
            width: view.bounds.width - 32,
            height: 76
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startCaptureSessionIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    private func configureMessageLabel() {
        messageLabel.text = "Point this device at the Broadcast UUID QR code."
        messageLabel.textColor = .white
        messageLabel.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 2
        messageLabel.layer.cornerRadius = 12
        messageLabel.clipsToBounds = true
        view.addSubview(messageLabel)
    }

    private func configureScanner() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCaptureSession()
                    } else {
                        self?.showCameraPermissionMessage()
                    }
                }
            }
        case .denied, .restricted:
            showCameraPermissionMessage()
        @unknown default:
            showCameraPermissionMessage()
        }
    }

    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            messageLabel.text = "This device does not have an available camera."
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)

            guard captureSession.canAddInput(videoInput) else {
                messageLabel.text = "Unable to use the camera for QR scanning."
                return
            }

            captureSession.addInput(videoInput)
        } catch {
            messageLabel.text = "Unable to use the camera: \(error.localizedDescription)"
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        guard captureSession.canAddOutput(metadataOutput) else {
            messageLabel.text = "Unable to read QR codes from the camera."
            return
        }

        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
        view.setNeedsLayout()
        startCaptureSessionIfNeeded()
    }

    private func startCaptureSessionIfNeeded() {
        guard !captureSession.isRunning,
              !captureSession.inputs.isEmpty,
              !captureSession.outputs.isEmpty else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    private func showCameraPermissionMessage() {
        messageLabel.text = "Camera permission is required to scan the Broadcast UUID QR code."
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !didScanCode,
              let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadataObject.type == .qr,
              let scannedValue = metadataObject.stringValue else {
            return
        }

        didScanCode = true
        captureSession.stopRunning()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        onCodeScanned?(scannedValue)
    }
}

private struct DetectedBeaconRow: View {
    let beacon: DetectedBeacon

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(beacon.proximityDescription)
                    .font(.headline)

                Spacer()

                Text("RSSI \(beacon.rssi)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(beacon.uuid.uuidString)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            HStack {
                Text("Major: \(beacon.major)")
                Text("Minor: \(beacon.minor)")
                Spacer()
                Text(beacon.accuracyDescription)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white.opacity(0.85))
        .cornerRadius(10)
    }
}

private struct DetectedBeacon: Identifiable {
    let uuid: UUID
    let major: Int
    let minor: Int
    let proximity: CLProximity
    let accuracy: CLLocationAccuracy
    let rssi: Int

    var id: String {
        "\(uuid.uuidString)-\(major)-\(minor)"
    }

    var proximityDescription: String {
        switch proximity {
        case .immediate:
            return "Immediate"
        case .near:
            return "Near"
        case .far:
            return "Far"
        case .unknown:
            fallthrough
        @unknown default:
            return "Unknown"
        }
    }

    var accuracyDescription: String {
        guard accuracy >= 0 else { return "Distance unknown" }
        return String(format: "~%.2f m", accuracy)
    }
}

private final class BeaconBroadcaster: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    @Published var isBroadcasting = false
    @Published var statusMessage = "Ready to broadcast."

    private var peripheralManager: CBPeripheralManager?
    private var beaconData: [String: Any]?

    func startBroadcasting(identifier: String, uuidString: String, majorString: String, minorString: String) {
        guard let uuid = UUID(uuidString: uuidString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            statusMessage = "Enter a valid UUID before broadcasting."
            return
        }

        guard let majorValue = UInt16(majorString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            statusMessage = "Enter a major value from 0 to 65535."
            return
        }

        guard let minorValue = UInt16(minorString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            statusMessage = "Enter a minor value from 0 to 65535."
            return
        }

        let sanitizedIdentifier = identifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? defaultIdentifier
            : identifier.trimmingCharacters(in: .whitespacesAndNewlines)

        let identityConstraint = CLBeaconIdentityConstraint(
            uuid: uuid,
            major: CLBeaconMajorValue(majorValue),
            minor: CLBeaconMinorValue(minorValue)
        )

        let beaconRegion = CLBeaconRegion(
            beaconIdentityConstraint: identityConstraint,
            identifier: sanitizedIdentifier
        )

        beaconData = beaconRegion.peripheralData(withMeasuredPower: nil) as? [String: Any]

        if peripheralManager == nil {
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        }

        isBroadcasting = true
        statusMessage = "Preparing to broadcast \(sanitizedIdentifier)."
        startAdvertisingIfPossible()
    }

    func stopBroadcasting() {
        peripheralManager?.stopAdvertising()
        beaconData = nil
        isBroadcasting = false
        statusMessage = "Broadcasting stopped."
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        startAdvertisingIfPossible()
    }

    private func startAdvertisingIfPossible() {
        guard isBroadcasting else { return }
        guard let peripheralManager = peripheralManager else { return }

        switch peripheralManager.state {
        case .poweredOn:
            peripheralManager.stopAdvertising()
            peripheralManager.startAdvertising(beaconData)
            statusMessage = "Broadcasting beacon."
        case .poweredOff:
            statusMessage = "Bluetooth is off. Turn on Bluetooth to broadcast."
        case .unsupported:
            statusMessage = "This device does not support BLE peripheral broadcasting."
        case .unauthorized:
            statusMessage = "Bluetooth permission is required to broadcast."
        case .resetting:
            statusMessage = "Bluetooth is resetting."
        case .unknown:
            fallthrough
        @unknown default:
            statusMessage = "Waiting for Bluetooth to become available."
        }
    }
}

private final class BeaconScanner: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var isScanning = false
    @Published var detectedBeacons: [DetectedBeacon] = []
    @Published var statusMessage = "Ready to scan for matching beacons."

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

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        switch status {
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

    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        detectedBeacons = beacons.map { beacon in
            DetectedBeacon(
                uuid: beacon.uuid,
                major: beacon.major.intValue,
                minor: beacon.minor.intValue,
                proximity: beacon.proximity,
                accuracy: beacon.accuracy,
                rssi: beacon.rssi
            )
        }
        .sorted { lhs, rhs in
            let lhsAccuracy = lhs.accuracy < 0 ? Double.greatestFiniteMagnitude : lhs.accuracy
            let rhsAccuracy = rhs.accuracy < 0 ? Double.greatestFiniteMagnitude : rhs.accuracy
            return lhsAccuracy < rhsAccuracy
        }

        statusMessage = detectedBeacons.isEmpty
            ? "Scanning, but no matching beacons are in range yet."
            : "Found \(detectedBeacons.count) matching beacon\(detectedBeacons.count == 1 ? "" : "s")."
    }

    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor beaconConstraint: CLBeaconIdentityConstraint, withError error: Error) {
        statusMessage = "Beacon scan failed: \(error.localizedDescription)"
        isScanning = false
    }
}

private extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(14)
    }
}

//#Preview {
//    ContentView()
//}
