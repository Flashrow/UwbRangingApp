//
//  BleRangingView.swift
//  uwbtestapp
//
//  Created by Łukasz Goleniec2 on 23/09/2023.
//

import Foundation
import SwiftUI
struct BleRangingView :View{
    var roomSideX : Float!
    var roomSideY : Float!
    var bleManager: BleRangingManager!
    @State var isRanging : Bool = false
    
    init(roomSideX : Float, roomSideY : Float) {
        self.roomSideY = roomSideY
        self.roomSideX = roomSideX
        self.bleManager = BleRangingManager(roomSideX: self.roomSideX, roomSideY: self.roomSideY)
    }
    
    var body: some View {
        Text("BLE Ranging")
        Button(action: isRanging ? stopBleRanging : startBleRanging){
            Text(isRanging ? "Stop BLE Ranging" : "Start BLE Ranging")
        }
        HStack{
            Text("\(bleManager.positionX)")
            Text("\(bleManager.positionY)")
        }
        Spacer()
    }
    func startBleRanging() {
        isRanging = true
        self.bleManager.startRanging()
    }
    
    func stopBleRanging() {
        isRanging = false
        self.bleManager.stopRanging()
    }
}
