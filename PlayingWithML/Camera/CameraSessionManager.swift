//
//  CameraWorker.swift
//  PlayingWithML
//
//  Created by Egor Butyrin on 29.10.2021.
//

import AVFoundation

final class CameraSessionManager {
  let captureSession: AVCaptureSession = AVCaptureSession()
  private let queue = DispatchQueue(label: "PlayingWithML.CameraSessionManagerQueue")

  init() {
    setup()
  }

  deinit {
    stopSession()
  }

  func startSession() {
    queue.async {
      if !self.captureSession.isRunning {
        self.captureSession.startRunning()
      }
    }
  }

  func stopSession() {
    if captureSession.isRunning {
      captureSession.stopRunning()
    }
  }

  private func setup() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      setupCaptureSessionAndSetIfPossible()

    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { granted in
        if granted {
          self.setupCaptureSessionAndSetIfPossible()
        }
      }

    case .denied:
      return

    case .restricted:
      return
    @unknown default:
      return
    }
  }

  private func setupCaptureSessionAndSetIfPossible() {
    guard let videoDevice = AVCaptureDevice.default(
      .builtInDualCamera,
      for: .video,
      position: .back
    )
    else { return }

    try! videoDevice.lockForConfiguration()
    defer { videoDevice.unlockForConfiguration() }

    guard let input = try? AVCaptureDeviceInput(device: videoDevice) else { return }

    captureSession.beginConfiguration()
    if captureSession.canAddInput(input) {
      captureSession.addInput(input)

    }
    captureSession.commitConfiguration()
  }
}
