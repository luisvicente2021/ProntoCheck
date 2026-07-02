//
//  AltaEmpleadoView.swift
//  ProntoCheck
//
//  Created by usuario on 01/07/26.
//
import SwiftUI

struct AltaEmpleadoView: View {
    @ObservedObject var viewModel: EmpleadosViewModel
    @Environment(\.dismiss) var dismiss
    let faceService = FaceRecognitionService()

    @State private var id: UUID?
    @State private var nombre = ""
    @State private var apellidoP = ""
    @State private var apellidoM = ""
    @State private var email = ""
    @State private var residencial = ""
    @State private var direccion = ""
    @State private var telCasa = ""
    @State private var telEmpresa = ""
    @State private var mostrarCamara = false
    @State private var fotoRostro: UIImage?
    @State private var faceEmbedding: [Float]?
    @State private var rostroDetectado = false
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Sección Rostro (Cabecera Visual)
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            if let foto = fotoRostro {
                                Image(uiImage: foto)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.green, lineWidth: 3))
                                    .shadow(radius: 3)
                            } else {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Button(action: { mostrarCamara = true }) {
                                Text(fotoRostro != nil ? "Cambiar foto" : "Capturar foto rostro")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(fotoRostro != nil ? .secondary : .accentColor)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear) // Hace que resalte el avatar centrado

                // MARK: - Datos Personales
                Section(header: Text("Datos Personales")) {
                    LabeledContent {
                        TextField("Requerido", text: $nombre)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("Nombre", systemImage: "person.fill")
                    }
                    
                    LabeledContent {
                        TextField("Opcional", text: $apellidoP)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("A. Paterno", systemImage: "person.text.rectangle")
                    }
                    
                    LabeledContent {
                        TextField("Opcional", text: $apellidoM)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("A. Materno", systemImage: "person.text.rectangle")
                    }
                }

                // MARK: - Contacto
                Section(header: Text("Contacto")) {
                    LabeledContent {
                        TextField("Requerido", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("Correo", systemImage: "envelope.fill")
                    }
                    
                    LabeledContent {
                        TextField("Opcional", text: $telCasa)
                            .keyboardType(.phonePad)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("Tel. Casa", systemImage: "phone.fill")
                    }
                    
                    LabeledContent {
                        TextField("Opcional", text: $telEmpresa)
                            .keyboardType(.phonePad)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("Tel. Empresa", systemImage: "building.2.crop.badge.plus")
                    }
                }

                // MARK: - Ubicación
                Section(header: Text("Ubicación")) {
                    LabeledContent {
                        TextField("Opcional", text: $residencial)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("Residencial", systemImage: "house.fill")
                    }
                    
                    LabeledContent {
                        TextField("Opcional", text: $direccion)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("Dirección", systemImage: "map.fill")
                    }
                }
                
                // MARK: - Feedback de Error
                if let error = viewModel.crudState.errorMessage {
                    Section {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                        }
                    }
                    .listRowBackground(Color.red.opacity(0.1))
                }
            }
            .navigationTitle("Nuevo Empleado")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.crudState.isLoading {
                        ProgressView()
                    } else {
                        Button("Guardar") { guardar() }
                            .bold()
                            .disabled(nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .sheet(isPresented: $mostrarCamara) {
                FaceCaptureView { image in
                    Task {
                        do {
                            if let rostro = try await faceService.detectarRostro(in: image) {
                                fotoRostro = rostro
                                let embedding = try faceService.generarEmbedding(desde: rostro)
                                faceEmbedding = embedding
                                rostroDetectado = true
                            } else {
                                rostroDetectado = false
                            }
                        } catch {
                            rostroDetectado = false
                            print("Error detectando rostro: \(error)")
                        }
                    }
                }
            }
            .onChange(of: viewModel.crudState) { _, state in
                if case .success = state { dismiss() }
            }
        }
    }

    private func guardar() {
        let rostroBase64 = fotoRostro?.jpegData(compressionQuality: 0.6)?.base64EncodedString()

        let empleado = Empleado(
            id: id ?? UUID(),
            email: email,
            nombre: nombre,
            apellidoPaterno: apellidoP.isEmpty ? nil : apellidoP,
            apellidoMaterno: apellidoM.isEmpty ? nil : apellidoM,
            residencial: residencial.isEmpty ? nil : residencial,
            direccion: direccion.isEmpty ? nil : direccion,
            telefonoCasa: telCasa.isEmpty ? nil : telCasa,
            telefonoEmpresa: telEmpresa.isEmpty ? nil : telEmpresa,
            fotoRostro: rostroBase64,
            faceEmbedding: faceEmbedding
        )
        
        viewModel.registrarEmpleado(empleado: empleado)
    }
}
