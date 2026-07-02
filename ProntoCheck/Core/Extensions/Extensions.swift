//
//  Extensions.swift
//  ProntoCheck
//
//  Created by usuario on 01/07/26.
//

import Foundation
import UIKit

extension UIImage {

func fixOrientation() -> UIImage {

    if imageOrientation == .up {
        return self
    }

    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)

    self.draw(in: CGRect(origin: .zero, size: self.size))

    let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    return normalizedImage ?? self
}

}
