//
//  PreviewView.swift
//  PlayingWithML
//
//  Created by Egor Butyrin on 29.10.2021.
//

import UIKit
import AVFoundation

final class PreviewView: UIView {
  private var previewLayer: AVCaptureVideoPreviewLayer {
    layer as! AVCaptureVideoPreviewLayer
  }

  var session: AVCaptureSession? {
    get {
      previewLayer.session
    }
    set {
      previewLayer.session = newValue
      setNeedsLayout()
    }
  }

  var videoGravity: AVLayerVideoGravity {
    get {
      previewLayer.videoGravity
    }
    set {
      previewLayer.videoGravity = newValue
    }
  }

  override class var layerClass: AnyClass {
    AVCaptureVideoPreviewLayer.self
  }
}
