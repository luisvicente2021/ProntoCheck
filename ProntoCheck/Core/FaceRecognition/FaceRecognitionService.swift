//
//  FaceRecognitionService.swift
//  ProntoCheck
//
//  Created by usuario on 29/06/26.
//
import Foundation
import UIKit
import Vision
import CoreML

final class FaceRecognitionService {
    
    private let model: Facenet6
    
    init() {
        self.model = try! Facenet6(configuration: MLModelConfiguration())
    }
    
    func detectarRostro(in image: UIImage) async throws -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectFaceRectanglesRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let face = (request.results as? [VNFaceObservation])?.first else {
                    continuation.resume(returning: nil)
                    return
                }

                let width = CGFloat(cgImage.width)
                let height = CGFloat(cgImage.height)

                var rect = CGRect(
                    x: face.boundingBox.minX * width,
                    y: (1 - face.boundingBox.maxY) * height,
                    width: face.boundingBox.width * width,
                    height: face.boundingBox.height * height
                )

                let marginX = rect.width * 0.30
                let marginY = rect.height * 0.40

                rect = rect.insetBy(dx: -marginX, dy: -marginY)

                let safeRect = rect.intersection(
                    CGRect(x: 0, y: 0, width: width, height: height)
                )

                guard let cropped = cgImage.cropping(to: safeRect) else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: UIImage(cgImage: cropped))
            }

            do {
                try VNImageRequestHandler(cgImage: cgImage).perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func generarEmbedding(desde rostro: UIImage) throws -> [Float] {
        guard let inputArray = rostro.toMLMultiArray160x160() else {
            throw NSError(domain: "FaceRecognition", code: 1)
        }
        
        let input = Facenet6Input(input: inputArray)
        let output = try model.prediction(input: input)
        
        return output.embeddings.toFloatArray()
    }
    
    func distanciaEuclidiana(_ a: [Float], _ b: [Float]) -> Float {
        sqrt(zip(a, b).map { pow($0 - $1, 2) }.reduce(0, +))
    }
}

extension UIImage {
    
    func toMLMultiArray160x160() -> MLMultiArray? {
        guard let resized = self.resize(to: CGSize(width: 160, height: 160)),
              let cgImage = resized.cgImage else {
            return nil
        }
        
        let width = 160
        let height = 160
        let channels = 3
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var rawData = [UInt8](repeating: 0, count: width * height * 4)
        
        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var values: [Float] = []
        values.reserveCapacity(width * height * channels)
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * 4
                
                values.append(Float(rawData[pixelIndex]))
                values.append(Float(rawData[pixelIndex + 1]))
                values.append(Float(rawData[pixelIndex + 2]))
            }
        }
        
        let mean = values.reduce(0, +) / Float(values.count)
        
        let variance = values
            .map { pow($0 - mean, 2) }
            .reduce(0, +) / Float(values.count)
        
        let std = sqrt(variance)
        let stdAdj = max(std, 1.0 / sqrt(Float(values.count)))
        
        guard let array = try? MLMultiArray(
            shape: [1, 160, 160, 3],
            dataType: .float32
        ) else {
            return nil
        }
        
        var index = 0
        
        for y in 0..<height {
            for x in 0..<width {
                for c in 0..<channels {
                    let normalized = (values[index] - mean) / stdAdj
                    array[[0, y as NSNumber, x as NSNumber, c as NSNumber]] = NSNumber(value: normalized)
                    index += 1
                }
            }
        }
        
        return array
    }
    
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized
    }
}

extension MLMultiArray {
    func toFloatArray() -> [Float] {
        var result: [Float] = []
        result.reserveCapacity(self.count)
        
        for i in 0..<self.count {
            result.append(self[i].floatValue)
        }
        
        return result
    }
}
