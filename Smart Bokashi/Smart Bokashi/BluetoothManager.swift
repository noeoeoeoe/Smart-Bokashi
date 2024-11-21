import SwiftUI
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var temperaturePeripheral: CBPeripheral?
    @Published var temperature: String = "N/A"
    @Published var humidity: String = "N/A"

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState: \(central.state.rawValue)")
        if central.state == .poweredOn {
            print("Bluetooth is powered on. Starting scan...")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth is not available.")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered peripheral: \(peripheral.name ?? "Unknown")")
        if peripheral.name == "HMSoft" {
            temperaturePeripheral = peripheral
            temperaturePeripheral?.delegate = self
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
            print("Connecting to peripheral: \(peripheral.name ?? "Unknown")")
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral.name ?? "Unknown")")
        peripheral.discoverServices(nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                print("Discovered service: \(service.uuid)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        } else if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Discovered characteristic: \(characteristic.uuid)")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        } else if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating value for characteristic: \(error.localizedDescription)")
            return
        }

        if let data = characteristic.value {
            print("Received data: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
            let (temperatureValue, humidityValue) = parseSensorData(data)
            print("Parsed temperature data: \(temperatureValue)")
            print("Parsed humidity data: \(humidityValue)")
            DispatchQueue.main.async {
                self.temperature = temperatureValue
                self.humidity = humidityValue
            }
        } else {
            print("No data received")
        }
    }

    private func parseSensorData(_ data: Data) -> (String, String) {
        if let dataString = String(data: data, encoding: .utf8) {
            let components = dataString.split(separator: ",")
            if components.count == 2 {
                let temperatureValue = String(components[0])
                let humidityValue = String(components[1])
                return (temperatureValue, humidityValue)
            }
        }
        return ("N/A", "N/A")
    }
}

@main
struct MultiTabApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject var bluetoothManager = BluetoothManager()

    var body: some View {
        VStack {
            if bluetoothManager.temperature != "N/A" && bluetoothManager.humidity != "N/A" {
                Text("Température: \(bluetoothManager.temperature)°C")
                    .padding()
                Text("Humidité: \(bluetoothManager.humidity)%")
                    .padding()
            } else {
                ProgressView()
                    .padding()
            }
        }
        .onAppear {
            // La configuration initiale de BluetoothManager s'effectue automatiquement
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
