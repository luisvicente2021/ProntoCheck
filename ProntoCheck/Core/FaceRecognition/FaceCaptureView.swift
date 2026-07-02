//
//  FaceCaptureView.swift
//  ProntoCheck
//
//  Created by usuario on 30/06/26.
//

import SwiftUI
import AVFoundation

struct FaceCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = FaceCameraManager()

    let onImageCaptured: (UIImage) -> Void

    var body: some View {
        ZStack {
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()

            FaceOvalOverlay()

            VStack {
                Spacer()

                Text("Coloca tu rostro dentro del óvalo")
                    .font(.headline)
                    .padding()
                    .background(.black.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(12)

                Button {
                    camera.capturePhoto()
                } label: {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 72, height: 72)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.3), lineWidth: 4)
                        )
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            camera.onImageCaptured = { image in
                onImageCaptured(image)
                dismiss()
            }

            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    camera.start()
                } else {
                    print("Permiso de cámara denegado")
                }
            }
        }
        .onDisappear {
            camera.stop()
        }
    }
}

struct FaceOvalOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            Ellipse()
                .frame(width: 240, height: 320)
                .blendMode(.destinationOut)

            Ellipse()
                .stroke(Color.green, lineWidth: 4)
                .frame(width: 240, height: 320)
        }
        .compositingGroup()
    }
}

//#Preview {
  //  FaceCaptureView()
//}
