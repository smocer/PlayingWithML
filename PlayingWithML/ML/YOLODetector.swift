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

private let modelURL = Bundle.main.url(forResource: "YOLOv3", withExtension: nil)!
private let confidenceThreshold: VNConfidence = 0.7

struct YOLODetectionResult {
  let label: String
  let frame: CGRect
}

struct Prediction {
  let classIndex: Int
  let score: CGFloat
  let rect: CGRect
}

final class YOLODetector {
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
      let handler = VNImageRequestHandler(cvPixelBuffer: buffer, options: [:])
      try handler.perform([request])
    } catch {
      print(error)
    }
  }

  private func processResults(_ results: [VNObservation]) -> [YOLODetectionResult] {
    return results
      .filter { $0.confidence > confidenceThreshold }
      .compactMap {
        guard let observation = $0 as? VNRecognizedObjectObservation
        else { return nil }

        let box = observation.boundingBox
        guard let label = observation.labels.first,
              label.confidence > confidenceThreshold
        else { return nil }

        return YOLODetectionResult(label: label.identifier, frame: box)
      }
  }

  // https://habr.com/ru/post/460869/
}
