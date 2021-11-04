//
//  ViewController.swift
//  PlayingWithML
//
//  Created by Egor Butyrin on 29.10.2021.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

  // Dependencies
  private var interactor: CameraMLInteractor!

  // Views
  private let previewView = PreviewView()
  private let swapCamerasButton = UIButton()

  override func viewDidLoad() {
    super.viewDidLoad()
    interactor = CameraMLInteractor(onDetection: onGotResult(_:))

    view.backgroundColor = .white

    let vStack = UIStackView(arrangedSubviews: [
      VSpacer(height: 16),
      previewView,
      swapCamerasButton,
      VSpacer(height: 32)
    ])
    vStack.axis = .vertical
    vStack.alignment = .center

    view.pinSubview(vStack)

    setupPreviewView()
    setupSwapCamerasButton()
  }

  private func setupPreviewView() {
    previewView.session = interactor.captureSession
    previewView.translatesAutoresizingMaskIntoConstraints = false
    previewView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
  }

  private func setupSwapCamerasButton() {
    swapCamerasButton.setTitle("Swap", for: .normal)
    swapCamerasButton.setTitleColor(.black, for: .normal)
    swapCamerasButton.backgroundColor = .gray
    swapCamerasButton.layer.cornerRadius = 8
    swapCamerasButton.layer.masksToBounds = true
    swapCamerasButton.widthAnchor.constraint(equalToConstant: 128).isActive = true
  }

  private func onGotResult(_ result: YOLODetectionResult) {

  }

}
