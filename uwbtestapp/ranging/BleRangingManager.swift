import CoreBluetooth
import Foundation
import CoreBluetooth

// ble device uuid
// #1:  D0D32325-8F64-3C55-78C3-E83EA49923EE
// #2:  4BA22D53-3484-A062-CFE7-081DA8B61741
// #3   639BC26D-36C9-0DF1-2097-587F9D31A589
// #4   3126A363-76A7-A10E-FBD3-BC96F67AB250

class BleRangingManager: NSObject, CBCentralManagerDelegate {
    let estimoteUuids = [
        "D0D32325-8F64-3C55-78C3-E83EA49923EE",
        "4BA22D53-3484-A062-CFE7-081DA8B61741",
        "639BC26D-36C9-0DF1-2097-587F9D31A589",
        "3126A363-76A7-A10E-FBD3-BC96F67AB250",
    ]
    @Published var positionX : Float = 0
    @Published var positionY : Float = 0
    var roomSideX: Float! = 0
    var roomSideY: Float! = 0
    var rangingResults: [Double] = [0, 0, 0, 0]
    var centralManager: CBCentralManager!
    var devices: [CBPeripheral] = [] // array to store discovered devices
    var rssi: [Double] = [] // array to store RSSI values of devices
    var distance: [Double] = [] // array to store distance values of devices
    let txPower = -69.0 // calibrated RSSI value at 1 meter for your devices
    let n = 3.0 // environmental factor for your devices
    
    init(roomSideX: Float, roomSideY: Float) {
        super.init()
        self.roomSideX = roomSideX
        self.roomSideY = roomSideY
    }
    
    func discoverDevices() {
            // scan for all devices
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    
    public func startRanging() {
        if(centralManager.isScanning == false){
        centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    public func stopRanging() {
        if(centralManager.isScanning){
        centralManager.stopScan()
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is on")
            // start discovering devices when bluetooth is on
            discoverDevices()
        case .poweredOff:
            print("Bluetooth is off")
        default:
            print("Bluetooth state is unknown")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(estimoteUuids.contains(peripheral.publicIdentifier)){
            rssi.append(RSSI.doubleValue)
            let distanceValue = calculateDistance(RSSI: RSSI.doubleValue, txPower: txPower, n: n)
            distance.append(distanceValue)
            print("Estimote public identifier: \(peripheral.publicIdentifier ?? "Unknown"), RSSI: \(RSSI), Distance: \(distanceValue) meters")
            saveResult(deviceUuid: peripheral.identifier.uuidString, range: distanceValue)
            if(isRangingComplete()){
                printRangingResults()
                clearRangingResults()
                discoverDevices()
            }
        }
    }
    
    func peripheral (_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(peripheral)
        if let e = error {
            print("Błąd podczas aktualizacji wartości charakterystyki: \(e)")
            return
        }
        guard let data = characteristic.value else {
            print("Brak wartości charakterystyki")
            return
        }
        print(data)
    }

    
    func calculateDistance(RSSI: Double, txPower: Double, n: Double) -> Double {
        let ratio = RSSI / txPower
        if ratio < 1.0 {
            return pow(ratio, 10)
        } else {
            return pow(10, (txPower - RSSI) / (10 * n))
        }
    }
    
    func saveResult(deviceUuid: String, range: Double) {
        let index = estimoteUuids.firstIndex(of: deviceUuid)
        if(index != nil){
            rangingResults[index!] = range
        }
    }
    
    func isRangingComplete() -> Bool {
        let nextIndex = rangingResults.firstIndex(of: 0)
        return (nextIndex == nil || nextIndex! > 3)
    }
    
    func clearRangingResults(){
        rangingResults = [0, 0, 0, 0]
    }
    
    func printRangingResults(){
        print("BLE ranging result:")
        for i in 0...3 {
            print("\(i) : \(rangingResults[i])")
        }
        print("")
    }
}
