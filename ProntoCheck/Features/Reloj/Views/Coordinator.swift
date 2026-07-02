//
//  Coordinator.swift
//  ProntoCheck
//
//  Created by usuario on 01/07/26.
//

import Foundation
import UIKit

final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let parent: CameraView

    init(_ parent: CameraView) {
        self.parent = parent
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        if let image = info[.originalImage] as? UIImage {
            let imageCorregida = image.fixOrientation()
            parent.onImageCaptured(imageCorregida)
        }

        parent.dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.dismiss()
    }
}

