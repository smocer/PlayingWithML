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
import Accelerate
import UIKit

struct YOLODetectionResult {
  let label: String
  let box: CGRect
}

struct Prediction {
  let classIndex: Int
  let score: CGFloat
  let rect: CGRect
}

final class YOLODetector {
  enum Const {
    static let confidenceThreshold: VNConfidence = 0.7
    static let sampleSize = CGSize(width: 416, height: 416)
  }

  typealias Completion = ([YOLODetectionResult]) -> Void

  private let vnModel = try! VNCoreMLModel(for: MLModel(contentsOf: YOLOv3.urlOfModelInThisBundle))

  func detect(fromBuffer buffer: CVPixelBuffer, completion: @escaping Completion) {
    do {
      let request = VNCoreMLRequest(model: vnModel) { [weak self] request, error in
        guard
          let self = self,
          let results = request.results
        else { return }

        completion(self.processResults(results))
      }
      let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: UIDevice.current.propertyOrientation, options: [:])
      try handler.perform([request])
    } catch {
      print(error)
    }
  }

  private func processResults(_ results: [VNObservation]) -> [YOLODetectionResult] {
    return results
      .filter { $0.confidence > Const.confidenceThreshold }
      .compactMap {
        guard let observation = $0 as? VNRecognizedObjectObservation
        else { return nil }

        let box = observation.boundingBox
        guard let label = observation.labels.first,
              label.confidence > Const.confidenceThreshold
        else { return nil }

        return YOLODetectionResult(label: label.identifier, box: box)
      }
  }

  // https://habr.com/ru/post/460869/
}

extension UIDevice {
  var propertyOrientation: CGImagePropertyOrientation {
    let exifOrientation: CGImagePropertyOrientation

    switch orientation {
    case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
        exifOrientation = .left
    case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
        exifOrientation = .upMirrored
    case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
        exifOrientation = .down
    case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
        exifOrientation = .up
    default:
        exifOrientation = .up
    }

    return exifOrientation
  }
}
