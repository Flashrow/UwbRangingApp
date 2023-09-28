//
//  CsvResultManager.swift
//  uwbtestapp
//
//  Created by Łukasz Goleniec2 on 27/09/2023.
//

import Foundation
import UIKit
class CsvResultManager {
    var csvResultString : String = ""
    var technology : String?
    var rangingTitle : String?
    var rangingDescription : String?
    var realPositionX : Float?
    var realPositionY : Float?
    var roomSideX : Float?
    var roomSideY : Float?
    
    func startFile(technology: String, rangingTitle: String, rangingDescription: String, realPositionX: Float, realPositionY: Float, roomSideX: Float, roomSideY: Float) {
        self.technology = technology
        self.rangingTitle = rangingTitle
        self.rangingDescription = rangingDescription
        self.realPositionX = realPositionX
        self.realPositionY = realPositionY
        self.roomSideX = roomSideX
        self.roomSideY = roomSideY
        
        csvResultString = "technologia:;\(technology);tytul:;\(rangingTitle);opis:;\(rangingDescription);czas;\(NSDate());pozycja telefonu X[m]:;\(realPositionX);pozycja telefonu Y[m]:;\(realPositionY);ściana x[m]:;\(roomSideX);sciana y[m]:;\(roomSideY)\n\n"
        csvResultString += "X;Y;dystans 1;dystans 2;dystans 3;dystans 4;roznica x; roznica y;roznica\n"
    }
    
    func addRangingResult(positionX: Float, positionY: Float, d1: Float, d2: Float, d3: Float, d4: Float){
        let differenceX = abs(positionX - (self.realPositionX ?? 0))
        let differenceY = abs(positionY - (self.realPositionY ?? 0))
        let difference = sqrt(pow(positionX - (self.realPositionX ?? 0),2)+pow(positionY-(self.realPositionY ?? 0),2))
        csvResultString+="\(positionX);\(positionY);\(d1);\(d2);\(d3);\(d4);\(differenceX);\(differenceY);\(difference)\n"
    }
    
    func saveToCSV() {
        let fileManager = FileManager.default
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy-HH-mm"
        let dateString = dateFormatter.string(from: Date())
        let fileName = "\(self.technology ?? "")_ranging_\(dateString).csv"
      
        let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
            
            do {
                try csvResultString.write(to: fileURL, atomically: true, encoding: .utf8)
                print("File saved successfully at \(fileURL)")
            } catch {
                print("Error while saving file:", error.localizedDescription)
            }
    }

}
