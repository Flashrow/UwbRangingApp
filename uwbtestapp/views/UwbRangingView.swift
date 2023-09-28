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
    @ObservedObject var uwbManager: EstimoteUWBManagerExample
    @State var isRanging : Bool = false;
    
    init(roomSideX : Float, roomSideY : Float){
        self.roomSideX = roomSideX
        self.roomSideY = roomSideY
        uwbManager = EstimoteUWBManagerExample(roomSideX: self.roomSideX, roomSideY: self.roomSideY)
    }
    
    var body: some View {
        VStack{
            Text("Uwb Ranging")
            Button(action: isRanging ? stopUwbRanging : startUwbRanging){
                Text(isRanging ? "Stop Uwb Ranging" : "Start Uwb Ranging")
            }
            HStack{
                Text("\(uwbManager.positionX)")
                Text("\(uwbManager.positionY)")
            }
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
