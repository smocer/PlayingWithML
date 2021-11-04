//
//  Layout.swift
//  PlayingWithML
//
//  Created by Egor Butyrin on 29.10.2021.
//

import UIKit

final class VSpacer: UIView {
  init(height: CGFloat) {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    heightAnchor.constraint(equalToConstant: height).isActive = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension UIView {
  func pinSubview(_ subview: UIView) {
    translatesAutoresizingMaskIntoConstraints = false
    subview.translatesAutoresizingMaskIntoConstraints = false
    addSubview(subview)
    NSLayoutConstraint.activate([
      subview.topAnchor.constraint(equalTo: topAnchor),
      subview.leftAnchor.constraint(equalTo: leftAnchor),
      subview.bottomAnchor.constraint(equalTo: bottomAnchor),
      subview.rightAnchor.constraint(equalTo: rightAnchor),
    ])
  }
}

extension UILayoutGuide {
  func pinSubview(_ subview: UIView) {
    subview.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      subview.topAnchor.constraint(equalTo: topAnchor),
      subview.leftAnchor.constraint(equalTo: leftAnchor),
      subview.bottomAnchor.constraint(equalTo: bottomAnchor),
      subview.rightAnchor.constraint(equalTo: rightAnchor),
    ])
  }
}
