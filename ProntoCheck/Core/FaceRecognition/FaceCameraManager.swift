//
//  FaceCameraManager.swift
//  ProntoCheck
//
//  Created by usuario on 30/06/26.
//

import Foundation
import UIKit
import AVFoundation
import Vision

final class FaceCameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {

    let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var ultimoRostroDetectado = Date.distantPast
    private var yaCapturo = false
    private let output = AVCapturePhotoOutput()

    var onImageCaptured: ((UIImage) -> Void)?

    override init() {
        super.init()
        configure()
    }

    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else {
            print("No se encontró cámara frontal")
            session.commitConfiguration()
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)

            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                print("No se pudo agregar input de cámara")
            }

            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frames"))
            }

            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            if let connection = output.connection(with: .video) {
                connection.videoOrientation = .portrait
                connection.isVideoMirrored = true
            }

        } catch {
            print("Error configurando cámara:", error)
        }
        session.commitConfiguration()
    }

    func start() {
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stop() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            print("Error tomando foto:", error)
            return
        }

        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }

        let fixed = image.fixOrientation()
        DispatchQueue.main.async {
            self.onImageCaptured?(fixed)
        }
    }
}


extension FaceCameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard !yaCapturo,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let request = VNDetectFaceRectanglesRequest { [weak self] request, _ in
            guard let self else { return }

            let faces = request.results as? [VNFaceObservation] ?? []

            if let face = faces.first, self.rostroEstaCentrado(face) {
                let ahora = Date()

                if ahora.timeIntervalSince(self.ultimoRostroDetectado) > 1.0 {
                    self.yaCapturo = true
                    DispatchQueue.main.async {
                        self.capturePhoto()
                    }
                }
            } else {
                self.ultimoRostroDetectado = Date()
            }
        }

        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .leftMirrored
        )

        try? handler.perform([request])
    }

    private func rostroEstaCentrado(_ face: VNFaceObservation) -> Bool {
        let box = face.boundingBox

        let estaCentrado =
            box.midX > 0.32 &&
            box.midX < 0.68 &&
            box.midY > 0.25 &&
            box.midY < 0.75

        let tamañoCorrecto =
            box.width > 0.25 &&
            box.width < 0.60 &&
            box.height > 0.25 &&
            box.height < 0.70

        return estaCentrado && tamañoCorrecto
    }
}
