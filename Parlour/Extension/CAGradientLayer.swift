//
//  CAGradientLayer.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/23.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import Foundation
import UIKit

//Gradient Color setting parameters

extension CAGradientLayer {

    class func primaryGradient(on view: UIView) -> UIImage? {

        let gradient = CAGradientLayer()
        let flareRed = UIColor(displayP3Red: 3.0/255.0, green: 63.0/255.0, blue: 122.0/255.0, alpha: 1.0)
        let flareOrange = UIColor(displayP3Red: 4.0/255.0, green: 107.0/255.0, blue: 149.0/255.0, alpha: 1.0)

        var bounds = view.bounds

        bounds.size.height += UIApplication.shared.statusBarFrame.size.height
        gradient.frame = bounds
        gradient.colors = [flareRed.cgColor, flareOrange.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        return gradient.createGradientImage(on: view)

    }

    private func createGradientImage(on view: UIView) -> UIImage? {

        var gradientImage: UIImage?
        UIGraphicsBeginImageContext(view.frame.size)

        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }

        UIGraphicsEndImageContext()
        return gradientImage

    }

    class func darkGrayGradation(on view: UIView) -> UIImage? {

        let gradient = CAGradientLayer()
        let flareRed = UIColor(displayP3Red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        let flareOrange = UIColor(displayP3Red: 67.0/255.0, green: 67.0/255.0, blue: 67.0/255.0, alpha: 1.0)

        var bounds = view.bounds

        bounds.size.height += UIApplication.shared.statusBarFrame.size.height
        gradient.frame = bounds
        gradient.colors = [flareRed.cgColor, flareOrange.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        return gradient.createGradientImage(on: view)

    }
}
