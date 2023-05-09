//
//  BackgroundImage.swift
//  DudeWithAnApp
//
//  Created by Alejandro on 4/26/23.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct SepiaModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(Color.sepiaToneOverlay)
            .blendMode(.multiply)
    }
}
extension UIImage {
    var uiColor: UIColor {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let context = CGContext(data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo)!
        context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        let pixel = context.data!.assumingMemoryBound(to: UInt8.self)
        return UIColor(red: CGFloat(pixel[2]) / 255.0, green: CGFloat(pixel[1]) / 255.0, blue: CGFloat(pixel[0]) / 255.0, alpha: CGFloat(pixel[3]) / 255.0)
    }
}
extension Color {
    static var sepiaToneOverlay: Color {
        let sepiaToneMatrix = [
            0.272, 0.534, 0.131, 0,
            0.349, 0.686, 0.168, 0,
            0.393, 0.769, 0.189, 0,
            0,     0,     0,     1,
        ]
        
        let context = CIContext(options: nil)
        let ciFilter = CIFilter.colorMatrix()
        ciFilter.inputImage = CIImage(color: CIColor(color: .white))
        ciFilter.rVector = CIVector(values: sepiaToneMatrix[0..<4].map { CGFloat($0) }, count: 4)
        ciFilter.gVector = CIVector(values: sepiaToneMatrix[4..<8].map { CGFloat($0) }, count: 4)
        ciFilter.bVector = CIVector(values: sepiaToneMatrix[8..<12].map { CGFloat($0) }, count: 4)
        ciFilter.aVector = CIVector(values: sepiaToneMatrix[12..<16].map { CGFloat($0) }, count: 4)
        let outputImage = ciFilter.outputImage!
        
        let cgImage = context.createCGImage(outputImage, from: CGRect(x: 0, y: 0, width: 1, height: 1))
        let uiImage = UIImage(cgImage: cgImage!)
        return Color(uiImage.uiColor)
    }
}
extension Image {
    func filter(filter: ImageFilter) -> some View {
        switch filter {
        case .none:
            return self.eraseToAnyView()
        case .sepia:
            return self.modifier(SepiaModifier()).eraseToAnyView()
        case .grayscale:
            return self.modifier(GrayscaleModifier()).eraseToAnyView()
        case .blur:
            return self.modifier(BlurModifier()).eraseToAnyView()
        }
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}

struct GrayscaleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.colorMultiply(.gray)
    }
}

struct BlurModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.blur(radius: 5)
    }
}

struct BackgroundImageView: View {
    let imageName: String
    let filter: ImageFilter
    
    var body: some View {
        GeometryReader { geometry in
            let image = Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
            
            switch filter {
            case .none:
                image
            case .sepia:
                image
                    .overlay(Color.sepiaToneOverlay)
                    .blendMode(.multiply)
            case .grayscale:
                image
                    .colorMultiply(.gray)
            case .blur:
                image
                    .blur(radius: 5)
            }
        }
    }
}

