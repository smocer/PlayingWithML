//
//  CameraMLInteractor.swift
//  PlayingWithML
//
//  Created by Egor Butyrin on 04.11.2021.
//

import Foundation
import AVFoundation
import CoreImage
import Accelerate

protocol CameraMLInteractorView: AnyObject {
  var models: [YOLODetectionResult] { get set }
}

final class CameraMLInteractor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

  weak var view: CameraMLInteractorView?
  var captureSession: AVCaptureSession { sessionManager.captureSession }

  private let sessionManager = CameraSessionManager()
  private let detector = YOLODetector()
  private let frameProcessingQueue = DispatchQueue(label: "PlayingWithML.FrameProcessingQueue")

  override init() {
    super.init()

    let dataOutput = AVCaptureVideoDataOutput()
    let formatSupportedByYOLO = kCVPixelFormatType_32BGRA
    if dataOutput.availableVideoPixelFormatTypes.contains(formatSupportedByYOLO) {
      dataOutput.videoSettings = [
        String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA
      ]
    }

    dataOutput.connection(with: .video)

    if captureSession.canAddOutput(dataOutput) {
      captureSession.addOutput(dataOutput)
    }
    dataOutput.setSampleBufferDelegate(self, queue: frameProcessingQueue)

    sessionManager.startSession()
  }

  deinit {
    sessionManager.stopSession()
  }

  // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    if let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
      if let resizedPixelBuffer = resizePixelBuffer(
        buffer,
        width: Int(YOLODetector.Const.sampleSize.width),
        height: Int(YOLODetector.Const.sampleSize.width)
      ) {
        detector.detect(fromBuffer: resizedPixelBuffer) { [weak self] results in
          DispatchQueue.main.async {
            self?.view?.models = results
          }
        }
      }
    }
  }
}

private func fit(cvImg: CVPixelBuffer, toSize: (w: Int, h: Int)) -> CVPixelBuffer {
  let sourceWidth = CVPixelBufferGetWidth(cvImg)
  let sourceHeight = CVPixelBufferGetHeight(cvImg)
  let rowBytes = CVPixelBufferGetBytesPerRow(cvImg)
  CVPixelBufferLockBaseAddress(cvImg, CVPixelBufferLockFlags.readOnly)
  let ptr = CVPixelBufferGetBaseAddress(cvImg)

  defer {
    CVPixelBufferUnlockBaseAddress(cvImg, CVPixelBufferLockFlags.readOnly)
  }

  var vImageSource = vImage_Buffer(
    data: ptr,
    height: UInt(sourceHeight),
    width: UInt(sourceWidth),
    rowBytes: rowBytes
  )

  defer {
//    vImageSource.free()
  }

  let bytesPerPixel = rowBytes / sourceWidth

  let scale = min(CGFloat(toSize.w) / CGFloat(sourceWidth), CGFloat(toSize.h) / CGFloat(sourceHeight))
  var outWidth = Int(CGFloat(sourceWidth) * scale)
  var outHeight = Int(CGFloat(sourceHeight) * scale)
  let deltaW = toSize.w - outWidth
  let deltaH = toSize.h - outHeight
  if abs(deltaW) < abs(deltaH) {
    outWidth += deltaW
  } else {
    outHeight += deltaH
  }

  let outBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: outWidth * outHeight * bytesPerPixel)
  defer {
    outBuffer.deallocate()
  }

  var vImageResult = vImage_Buffer(
    data: outBuffer,
    height: UInt(outHeight),
    width: UInt(outWidth),
    rowBytes: outWidth * bytesPerPixel
  )

  let error = vImageScale_ARGB8888(
    &vImageSource,
    &vImageResult,
    nil,
    numericCast(kvImageHighQualityResampling)
  )

  guard error == kvImageNoError else { fatalError("vImage failed to scale CVPixelBuffer") }

  let options = [
    kCVPixelBufferWidthKey: outWidth,
    kCVPixelBufferHeightKey: outHeight
  ] as CFDictionary

  var retVal: CVPixelBuffer?

  let status = CVPixelBufferCreateWithBytes(
    kCFAllocatorDefault,
    outWidth,
    outHeight,
    kCVPixelFormatType_32BGRA,
    outBuffer,
    bytesPerPixel * outWidth,
    nil,
    nil,
    options,
    &retVal
  )

  print(status)

  var cgFormat = vImage_CGImageFormat(
    bitsPerComponent: 8,
    bitsPerPixel: bytesPerPixel / 8,
    colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
    bitmapInfo: [.byteOrder32Little]
  )

  let cvFormat = vImageCVImageFormat.make(buffer: retVal!)

  vImageBuffer_CopyToCVPixelBuffer(
    &vImageResult,
    &cgFormat!,
    retVal!,
    cvFormat,
    nil,
    UInt32(kvImageNoFlags)
  )

  return retVal!
}
