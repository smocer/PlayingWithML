//
//  YOLODetector.swift
//  PlayingWithML
//
//  Created by Egor Butyrin on 04.11.2021.
//

import Foundation
import CoreML
import Vision
import CoreVideo
import CoreImage

private let modelURL = Bundle.main.url(forResource: "YOLOv3", withExtension: nil)!
private let confidenceThreshold: Double = 0.7

struct YOLODetectionResult {
  let label: String
  let frame: CGRect
}

final class YOLODetector {
  static func detect(fromBuffer buffer: CVPixelBuffer) -> YOLODetectionResult? {
    let ciImage = CIImage(cvPixelBuffer: buffer)
    do {
      let yolo = YOLOv3(model: try MLModel(contentsOf: YOLOv3.urlOfModelInThisBundle))
      let result = try yolo.prediction(
        image: buffer,
        iouThreshold: nil,
        confidenceThreshold: confidenceThreshold
      )
//      print(result.coordinates)
//      print(result.confidence)
      return nil//YOLODetectionResult(label: result.featureNames.first!, frame: .zero)
    } catch {
      print(error)
      return nil
    }
  }

  static func test() {
    let model = try! VNCoreMLModel(for: MLModel(contentsOf: modelURL))
    print(model)
  }
}
