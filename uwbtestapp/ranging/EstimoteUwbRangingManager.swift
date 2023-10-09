//
//  EstimoteUwbRangingManager.swift
//  uwbtestapp
//
//  Created by Łukasz Goleniec2 on 22/08/2023.
//

import Foundation
import EstimoteUWB
import SwiftUI

class EstimoteUWBManagerExample: NSObject, ObservableObject {
    @Published var positionX : Float = 0
    @Published var positionY : Float = 0
    var roomSideX: Float! = 0
    var roomSideY: Float! = 0
    var realPositionX: Float!
    var realPositionY: Float!
    var testDescription: String!
    var deviceList: [UWBIdentifiable] = []
    var rangingResults: [Float] = [0, 0, 0, 0]
    private var uwbManager: EstimoteUWBManager?
    private var csvResultManager: CsvResultManager = CsvResultManager()
    var estimoteDevicesIds: [String] = [
        "e00d5956774a301469aa84baa271d125",
        "b4c0a40164558cbb644b8743dd33ee32",
        "6ae8d8db92d096a0ebf94d7f653f381c",
        "c4f3aa34f5ac22edacf7e0d620c41a32"]
    var isConnected: Bool = false

//  e00d5956774a301469aa84baa271d125 #1
//  b4c0a40164558cbb644b8743dd33ee32 #2
//  6ae8d8db92d096a0ebf94d7f653f381c #3
//  c4f3aa34f5ac22edacf7e0d620c41a32 #4

    init(roomSideX: Float, roomSideY: Float, realPositionX: Float, realPositionY: Float, testDescription: String) {
        super.init()
        self.roomSideX = roomSideX
        self.roomSideY = roomSideY
        self.realPositionX = realPositionX
        self.realPositionY = realPositionY
        self.testDescription = testDescription
    }

    private func setupUWB() {
        uwbManager = EstimoteUWBManager(delegate: self,
                            options: EstimoteUWBOptions(shouldHandleConnectivity: true,
                            isCameraAssisted: false)
        )
        print("start UWB ranging")
        uwbManager?.startScanning()
    }
    
    public func startScanning() {
        self.setupUWB()
        csvResultManager.startFile(technology: "UWB", rangingDescription: self.testDescription, realPositionX: self.realPositionX, realPositionY: self.realPositionY, roomSideX: self.roomSideX, roomSideY: self.roomSideY)
    }
    
    public func stopScanning(){
        uwbManager?.stopScanning()
        csvResultManager.saveToCSV()
    }
}

// REQUIRED PROTOCOL
extension EstimoteUWBManagerExample: EstimoteUWBManagerDelegate {
    func didUpdatePosition(for device: EstimoteUWBDevice) {
//        print("position updated for device: \(device.publicIdentifier), distance: \(device.distance)")
        saveResult(deviceId: device.publicIdentifier, range: device.distance)
    }

    func didDiscover(device: UWBIdentifiable, with rssi: NSNumber, from manager: EstimoteUWBManager) {
        if let uwbDevice = device as? EstimoteUWBDevice {
            DispatchQueue.main.async {
                print("device: \(uwbDevice.publicIdentifier), distance: \(uwbDevice.distance)")
            }
        }
    }
    
//     OPTIONAL PROTOCOL FOR BEACON BLE RANGING
    func didRange(for beacon: EstimoteBLEDevice) {
        print("BLE: beacon did range: \(beacon)")
    }
    
    func saveResult(deviceId: String, range: Float) {
        let index = estimoteDevicesIds.firstIndex(of: deviceId)
        if(index != nil){
            rangingResults[index!] = range
            if(isRangingComplete()){
                calculateDevicePosition()
                printRangingResults()
                csvResultManager.addRangingResult(positionX: self.positionX, positionY: self.positionY, d1: rangingResults[0], d2: rangingResults[1], d3: rangingResults[2], d4: rangingResults[3])
                clearRangingResults()
            }
        }
    }
    
    func calculateDevicePosition(){
       let devicePosition = getCoordinates(d1: rangingResults[0], d2: rangingResults[1], d3: rangingResults[2], d4: rangingResults[3], sideY: self.roomSideY, sideX: self.roomSideX)
        print("device position x: \(devicePosition.x), y: \(devicePosition.y)")
        self.positionX = devicePosition.x
        self.positionY = devicePosition.y
    }
    
    func isRangingComplete() -> Bool {
        let nextIndex = rangingResults.firstIndex(of: 0)
        return (nextIndex == nil || nextIndex! > 3)
    }
    
    func clearRangingResults(){
        rangingResults = [0, 0, 0, 0]
    }
    
    func printRangingResults(){
        for i in 0...3 {
            print("\(i) : \(rangingResults[i])")
        }
    }

}
