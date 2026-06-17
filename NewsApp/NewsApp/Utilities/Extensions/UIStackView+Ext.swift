//
//  UIStackView+Ext.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 17.06.2026.
//
import Foundation
import UIKit

extension UIStackView {
    func addArrangedSubviews(_ subviews: UIView...) {
        for subview in subviews {
            addArrangedSubview(subview)
        }
    }
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
}
