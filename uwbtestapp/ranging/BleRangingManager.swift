import CoreBluetooth
import Foundation
import CoreBluetooth

// ble device uuid
// #1:  D0D32325-8F64-3C55-78C3-E83EA49923EE
// #2:  4BA22D53-3484-A062-CFE7-081DA8B61741
// #3   639BC26D-36C9-0DF1-2097-587F9D31A589
// #4   3126A363-76A7-A10E-FBD3-BC96F67AB250

class BleRangingManager: NSObject, CBCentralManagerDelegate, ObservableObject {
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
    var realPositionX: Float!
    var realPositionY: Float!
    var testDescription: String!
    var rangingResults: [Float] = [0, 0, 0, 0]
    var centralManager: CBCentralManager!
    var devices: [CBPeripheral] = [] // array to store discovered devices
    var rssi: [Double] = [] // array to store RSSI values of devices
    var distance: [Float] = [] // array to store distance values of devices
    let txPower : Float = -69.0 // calibrated RSSI value at 1 meter for your devices
    let n : Float = 3.0 // environmental factor for your devices
    private var csvResultManager: CsvResultManager = CsvResultManager()
    
    init(roomSideX: Float, roomSideY: Float, realPositionX: Float, realPositionY: Float, testDescription: String) {
        super.init()
        self.roomSideX = roomSideX
        self.roomSideY = roomSideY
        self.realPositionX = realPositionX
        self.realPositionY = realPositionY
        self.testDescription = testDescription
    }
    
    func discoverDevices() {
            // scan for all devices
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    
    public func startRanging() {
        if(centralManager == nil || centralManager.isScanning == false){
            centralManager = CBCentralManager(delegate: self, queue: nil)
            csvResultManager.startFile(technology: "BLE", rangingDescription: self.testDescription, realPositionX: self.realPositionX, realPositionY: self.realPositionY, roomSideX: self.roomSideX, roomSideY: self.roomSideY)
        }
    }
    
    public func stopRanging() {
        if(centralManager.isScanning){
            centralManager.stopScan()
            csvResultManager.saveToCSV()
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
            let distanceValue = calculateDistance(RSSI: RSSI.floatValue, txPower: txPower, n: n)
            distance.append(distanceValue)
            print("Estimote public identifier: \(peripheral.publicIdentifier), RSSI: \(RSSI), Distance: \(distanceValue) meters")
            saveResult(deviceUuid: peripheral.identifier.uuidString, range: distanceValue)
            if(isRangingComplete()){
                printRangingResults()
                calculateDevicePosition()
                csvResultManager.addRangingResult(positionX: self.positionX, positionY: self.positionY, d1: rangingResults[0], d2: rangingResults[1], d3: rangingResults[2], d4: rangingResults[3])
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

    
    func calculateDistance(RSSI: Float, txPower: Float, n: Float) -> Float {
        let ratio: Float = RSSI / txPower
        if ratio < 1.0 {
            return pow(ratio, 10)
        } else {
            return pow(10, (txPower - RSSI) / (10 * n))
        }
    }
    
    func calculateDevicePosition(){
       let devicePosition = getCoordinates(d1: rangingResults[0], d2: rangingResults[1], d3: rangingResults[2], d4: rangingResults[3], sideY: self.roomSideY, sideX: self.roomSideX)
        print("device position x: \(devicePosition.x), y: \(devicePosition.y)")
        self.positionX = devicePosition.x
        self.positionY = devicePosition.y
    }
    
    func saveResult(deviceUuid: String, range: Float) {
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
