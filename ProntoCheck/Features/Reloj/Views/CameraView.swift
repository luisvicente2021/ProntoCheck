//
//  CameraView.swift
//  ProntoCheck
//
//  Created by usuario on 29/06/26.
//

import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    var onImageCaptured: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = .front
        picker.allowsEditing = false
        picker.cameraCaptureMode = .photo
        picker.cameraFlashMode = .off
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
