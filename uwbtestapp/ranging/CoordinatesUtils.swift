//
//  CoordinatesUtils.swift
//  uwbtestapp
//
//  Created by Łukasz Goleniec2 on 27/08/2023.
//

import Foundation

private func calculateTriangleField(a : Float, b: Float, c: Float) -> Float {
    let avg = (a+b+c)/2
    let avgA = (((a+b+c)/2)-a)
    let avgB = (((a+b+c)/2)-b)
    let avgC = (((a+b+c)/2)-c)
    let product = avg * avgA * avgB * avgC
    return sqrt(product)
}

private func calculateTriangleHeight(heightRelatedSide: Float, d1: Float, d2: Float) -> Float {
    var _d1 = d1
    var _d2 = d2
    if(d1 + d2 < heightRelatedSide) {
        _d1 = d1 + (heightRelatedSide - (d1+d2))/2
        _d2 = d2 + (heightRelatedSide - (d1+d2))/2
    }
    let triangleField = calculateTriangleField(a: heightRelatedSide, b: _d1, c: _d2)
    return (2 * triangleField)/heightRelatedSide
}

private func calculateAveragePosition(height1: Float, height2: Float, alterHeight1: Float, alterHeight2: Float, sideLength: Float ) -> Float {
    let accuracy: Float = 0.01
    var nonZeros : Float = 0
    if (height1 > accuracy) {
        nonZeros += 1
    }
    if (height2 > accuracy) {
        nonZeros += 1
    }
    if (alterHeight1 > accuracy) {
        nonZeros += 1
    }
    if (alterHeight2 > accuracy) {
        nonZeros += 1
    }
    return (height1 + (sideLength - height2) + alterHeight1 + alterHeight2)/Float(nonZeros)
}

func pythagoreanHeight(b: Float, c: Float) -> Float {
    return sqrt(c*c - b*b);
}

func getCoordinates(d1: Float, d2: Float, d3: Float, d4: Float, sideY: Float, sideX: Float) -> DevicePosition {
    let leftSideTriangleHeight = calculateTriangleHeight(heightRelatedSide: sideY, d1: d1, d2: d2)
    let rightSideTriangleHeight = calculateTriangleHeight(heightRelatedSide: sideY, d1: d4, d2: d3)
    let bottomSideTriangleHeight = calculateTriangleHeight(heightRelatedSide: sideX, d1: d1, d2: d4)
    let topSideTriangleHeight = calculateTriangleHeight(heightRelatedSide: sideX, d1: d2, d2: d3)
    
    let YalterHeight1 = leftSideTriangleHeight != 0 ? pythagoreanHeight(b: leftSideTriangleHeight, c: d1) : (d1 + (sideY - (d1+d2))/2)
    let YalterHeight2 = rightSideTriangleHeight != 0 ? pythagoreanHeight(b: rightSideTriangleHeight, c: d4) : (d4 + (sideY - (d4+d3))/2)
    let XalterHeight1 = bottomSideTriangleHeight != 0 ? pythagoreanHeight(b: bottomSideTriangleHeight, c: d1) : (d1 + (sideX - (d1+d4))/2)
    let XalterHeight2 = topSideTriangleHeight != 0 ? pythagoreanHeight(b: topSideTriangleHeight, c: d2) : (d2 + (sideX - (d2+d3))/2)
    let x: Float = calculateAveragePosition(height1: leftSideTriangleHeight, height2: rightSideTriangleHeight, alterHeight1: XalterHeight1, alterHeight2: XalterHeight2, sideLength: sideX)
    let y: Float = calculateAveragePosition(height1: bottomSideTriangleHeight, height2: topSideTriangleHeight, alterHeight1: YalterHeight1, alterHeight2: YalterHeight2, sideLength: sideY)
    return DevicePosition(_x: x, _y: y)
}
