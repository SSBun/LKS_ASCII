//
//  main.swift
//  LKS_ASCII
//
//  Created by caishilin on 2022/10/24.
//

import AppKit
import Foundation
import QuartzCore

// MARK: - BZParticle

struct BZParticle {
    let gray: CGFloat
    let point: CGPoint
}

func parse(image: NSImage) -> [BZParticle] {
    var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
    guard let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil) else {
        return []
    }
    let imageW = imageRef.width
    let imageH = imageRef.height
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * imageW
    let rawData: UnsafeMutableRawPointer = calloc(imageH * imageW * bytesPerPixel, MemoryLayout.size(ofValue: CChar()))
    let bitsPerComponent = 8
    let context = CGContext(
        data: rawData,
        width: imageW,
        height: imageH,
        bitsPerComponent: bitsPerComponent,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: CGImageByteOrderInfo.order32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
    )
    context?.draw(
        imageRef,
        in: CGRect(x: 0, y: 0, width: imageW, height: imageH)
    )
    
    var result = [BZParticle]()
    let bufferData = UnsafeRawBufferPointer(start: rawData, count: imageH * imageW * bytesPerPixel)
    
    for y in stride(from: 0, to: imageH, by: 1) {
        for x in stride(from: 0, to: imageW, by: 1) {
            let byteIndex = bytesPerRow * y + bytesPerPixel * x
            let red = CGFloat(bufferData[byteIndex]) / 255.0
            let green = CGFloat(bufferData[byteIndex + 1]) / 255.0
            let blue = CGFloat(bufferData[byteIndex + 2]) / 255.0
            let alpha = CGFloat(bufferData[byteIndex + 3]) / 255.0
            let color = NSColor(red: red, green: green, blue: blue, alpha: alpha)
            let point = CGPoint(x: x, y: y)
            let particle = BZParticle(gray: color.brightnessComponent, point: point)
            result.append(particle)
        }
    }
    free(rawData)
    return result
}

if let image = NSImage(contentsOfFile: "/Users/caishilin/Desktop/test/LKS_ASCII/LKS_ASCII/0.png") {
    let elements = parse(image: image)
    var currentLine = 0
    var currentStr = ""
    for element in elements {
        let line = Int(element.point.y)
        if line != currentLine {
            currentLine = line
            print(currentStr)
            currentStr = ""
        }
        switch element.gray {
        case 0..<(0.25):
            currentStr += "面"
        case (0.25)..<(0.5):
            currentStr += "全"
        case (0.5)..<(0.75):
            currentStr += "付"
        default:
            currentStr += "交"
        }
    }
}
