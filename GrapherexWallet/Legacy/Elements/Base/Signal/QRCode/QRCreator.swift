//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import Foundation

final class QRCreator {
    static func createQr(qrString: String?, size: CGFloat) -> UIImage? {
        guard qrString != nil else {
            Logger.error("qrString is nil")
            return nil }
        
        guard let qrData = qrString?.data(using: String.Encoding.ascii) else {
            Logger.error("qrData from qrString is nil")
            return nil }
        
        return createQr(qrData: qrData, size: size)
    }
    
    static func createQr(qrData: Data?, size: CGFloat) -> UIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            Logger.error("filter is not found")
            return nil }
        
        filter.setDefaults()
        filter.setValue(qrData, forKey: "inputMessage")
        
        
        guard let ciImage = filter.outputImage else {
            Logger.error("outputImage is nil")
            return nil }
        
        let scaleXX = size / ciImage.extent.size.width
        let scaleYY = size / ciImage.extent.size.height
        
        let transform = CGAffineTransform(scaleX: scaleXX, y: scaleYY)
        let transformedCiImage = ciImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(transformedCiImage, from: transformedCiImage.extent) else {
            Logger.error("cgImage is nil")
            return nil }
        let qrImage = UIImage(cgImage: cgImage)
        
        return qrImage
    }
}
