//
//  ViewController.swift
//  PlayingWithML
//
//  Created by Egor Butyrin on 29.10.2021.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, CameraMLInteractorView, CALayerDelegate {

  // Interface
  var models: [YOLODetectionResult] = []

  // Dependencies
  private var interactor: CameraMLInteractor!

  // Views
  private let previewView = PreviewView()
  private let drawLayer = CALayer()
  private let swapCamerasButton = UIButton()
  private var displayLink: CADisplayLink!

  override func viewDidLoad() {
    super.viewDidLoad()
    interactor = CameraMLInteractor()
    interactor.view = self
    drawLayer.delegate = self
    displayLink = CADisplayLink(target: self, selector: #selector(triggerDrawing))

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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    displayLink.add(to: .main, forMode: .common)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    displayLink.invalidate()
  }

  override func viewDidLayoutSubviews() {
    previewView.setNeedsLayout()
    previewView.layoutIfNeeded()
    drawLayer.frame = previewView.layer.bounds
  }

  private func setupPreviewView() {
    previewView.session = interactor.captureSession
    previewView.translatesAutoresizingMaskIntoConstraints = false
    previewView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    previewView.layer.addSublayer(drawLayer)
  }

  private func setupSwapCamerasButton() {
    swapCamerasButton.setTitle("Swap", for: .normal)
    swapCamerasButton.setTitleColor(.black, for: .normal)
    swapCamerasButton.backgroundColor = .gray
    swapCamerasButton.layer.cornerRadius = 8
    swapCamerasButton.layer.masksToBounds = true
    swapCamerasButton.widthAnchor.constraint(equalToConstant: 128).isActive = true
  }

  @objc
  func triggerDrawing() {
    drawLayer.setNeedsDisplay()
  }

  func drawRectangle(_ rect: CGRect, withLabel label: String, in ctx: CGContext) {
    // Consts
    let color = UIColor.red.cgColor
    let fontSize: CGFloat = 25
    let lineWidth: CGFloat = 5
    //

    let sourceSize = YOLODetector.Const.sampleSize
    let rect = rect.toAbsolute(withSize: sourceSize)
    let scale = CGPoint(
      x: drawLayer.frame.size.width / sourceSize.width,
      y: drawLayer.frame.size.height / sourceSize.height
      )
    let destRect = CGRect(
      x: rect.minX * scale.x,
      y: rect.minY * scale.y,
      width: rect.width * scale.x,
      height: rect.height * scale.y
    )

    ctx.setStrokeColor(color)
    ctx.stroke(destRect, width: lineWidth)

    let font = UIFont.systemFont(ofSize: fontSize)
    let attrText = NSAttributedString(string: label, attributes: [
      NSAttributedString.Key.font: font,
      NSAttributedString.Key.strokeColor: UIColor.black,
      NSAttributedString.Key.backgroundColor: UIColor.green
    ])

    let textSize = attrText.size()
    ctx.setFillColor(UIColor.red.cgColor)
    ctx.fill(CGRect(origin: destRect.origin, size: textSize))
    attrText.draw(at: destRect.origin)
  }

  // MARK: - CALayerDelegate

  func draw(_ layer: CALayer, in ctx: CGContext) {
    models.forEach {
      drawRectangle($0.box, withLabel: $0.label, in: ctx)
    }
  }

}

extension CGRect {
  func toAbsolute(withSize size: CGSize) -> CGRect {
    CGRect(
      x: minX * size.width,
      y: minY * size.height,
      width: width * size.width,
      height: height * size.height
    )
  }
}
