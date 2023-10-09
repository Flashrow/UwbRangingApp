//
//  UwbRangingView.swift
//  uwbtestapp
//
//  Created by Łukasz Goleniec2 on 22/09/2023.
//

import Foundation
import SwiftUI
struct UwbRangingView :View{
    var roomSideX : Float!
    var roomSideY : Float!
    var realPositionX : Float!
    var realPositionY : Float!
    var testDescription : String!
    @ObservedObject var uwbManager: EstimoteUWBManagerExample
    @State var isRanging : Bool = false;
    
    init(roomSideX : Float, roomSideY : Float, realPositionX : Float, realPositionY : Float, testDescription : String){
        self.roomSideX = roomSideX
        self.roomSideY = roomSideY
        self.realPositionY = realPositionY
        self.realPositionX = realPositionX
        self.testDescription = testDescription
        uwbManager = EstimoteUWBManagerExample(roomSideX: self.roomSideX, roomSideY: self.roomSideY, realPositionX: realPositionX, realPositionY: realPositionY, testDescription: testDescription)
    }
    
    var body: some View {
        VStack{
            Text("Uwb Ranging")
            Button(action: isRanging ? stopUwbRanging : startUwbRanging){
                Text(isRanging ? "Stop Uwb Ranging" : "Start Uwb Ranging")
            }
            Spacer().frame(height: 40)
            Text("\(self.testDescription)")
            VStack{
                Text("Ranging position:")
                HStack{
                    Text("X: \(uwbManager.positionX)")
                    Text("Y: \(uwbManager.positionY)")
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
                    Text("X: \(abs(uwbManager.positionX - self.realPositionX))")
                    Text("Y: \(abs(uwbManager.positionY - self.realPositionY))")
                }
            }.padding()
            Spacer()
        }
    }
    
    func startUwbRanging(){
        isRanging = true
        self.uwbManager.startScanning()
    }
    
    func stopUwbRanging(){
        isRanging = false
        self.uwbManager.stopScanning()
    }
}
