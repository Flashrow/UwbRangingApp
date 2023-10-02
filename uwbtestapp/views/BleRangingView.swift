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
    var realPositionX : Float!
    var realPositionY : Float!
    var testDescription: String!
    var bleManager: BleRangingManager!
    @State var isRanging : Bool = false
    
    init(roomSideX : Float, roomSideY : Float, realPositionX : Float, realPositionY : Float, testDescription : String) {
        self.roomSideY = roomSideY
        self.roomSideX = roomSideX
        self.realPositionY = realPositionY
        self.realPositionX = realPositionX
        self.testDescription = testDescription
        self.bleManager = BleRangingManager(roomSideX: self.roomSideX, roomSideY: self.roomSideY, realPositionX: realPositionX, realPositionY: realPositionY, testDescription: testDescription)
    }
    
    var body: some View {
        Text("BLE Ranging")
        Button(action: isRanging ? stopBleRanging : startBleRanging){
            Text(isRanging ? "Stop BLE Ranging" : "Start BLE Ranging")
        }
        Spacer().frame(height: 40)
        Text("\(self.testDescription)")
        VStack{
            Text("Ranging position:")
            HStack{
                Text("X: \(bleManager.positionX)")
                Text("Y: \(bleManager.positionY)")
            }
        }.padding()
        VStack{
            Text("Real position:")
            HStack{
                Text("X: \(self.realPositionX)")
                Text("Y: \(self.realPositionY)")
            }
        }.padding()
        VStack{
            Text("Difference:")
            HStack{
                Text("X: \(abs(bleManager.positionX - self.realPositionX))")
                Text("Y: \(abs(bleManager.positionX - self.realPositionY))")
            }
        }.padding()
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
