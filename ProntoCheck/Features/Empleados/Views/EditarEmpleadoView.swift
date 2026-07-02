//
//  EditarEmpleadoView.swift
//  ProntoCheck
//
//  Created by usuario on 01/07/26.
//

import SwiftUI

struct EditarEmpleadoView: View {
    let empleado: Empleado
    @ObservedObject var viewModel: EmpleadosViewModel
    @Environment(\.dismiss) var dismiss

    @State private var nombre: String
    @State private var apellidoP: String
    @State private var apellidoM: String
    @State private var residencial: String
    @State private var direccion: String
    @State private var telCasa: String
    @State private var telEmpresa: String

    init(empleado: Empleado, viewModel: EmpleadosViewModel) {
        self.empleado = empleado
        self.viewModel = viewModel
        _nombre = State(initialValue: empleado.nombre)
        _apellidoP = State(initialValue: empleado.apellidoPaterno ?? "")
        _apellidoM = State(initialValue: empleado.apellidoMaterno ?? "")
        _residencial = State(initialValue: empleado.residencial ?? "")
        _direccion = State(initialValue: empleado.direccion ?? "")
        _telCasa = State(initialValue: empleado.telefonoCasa ?? "")
        _telEmpresa = State(initialValue: empleado.telefonoEmpresa ?? "")
    }

    var body: some View {
        Form {
            // MARK: - Cabecera Visual (Avatar y Datos Lectura)
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        // Trata de cargar la foto real, si no, usa el icono
                        if let fotoBase64 = empleado.fotoRostro,
                           let uiImage = UIImage(base64String: fotoBase64) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .foregroundStyle(.tint)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(nombre) \(apellidoP)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text(empleado.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.clear)

            // MARK: - Datos Personales
            Section(header: Text("Datos Personales")) {
                LabeledContent {
                    TextField("Requerido", text: $nombre)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled() // UX: Deshabilitar autocorrector en nombres
                } label: {
                    Label("Nombre", systemImage: "person.fill")
                }
                
                LabeledContent {
                    TextField("Opcional", text: $apellidoP)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled()
                } label: {
                    Label("A. Paterno", systemImage: "person.text.rectangle")
                }
                
                LabeledContent {
                    TextField("Opcional", text: $apellidoM)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled()
                } label: {
                    Label("A. Materno", systemImage: "person.text.rectangle")
                }
            }

            // MARK: - Contacto
            Section(header: Text("Contacto")) {
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
                        .autocorrectionDisabled()
                } label: {
                    Label("Residencial", systemImage: "house.fill")
                }
                
                LabeledContent {
                    TextField("Opcional", text: $direccion)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled()
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
        .navigationTitle("Editar Empleado")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // UX: Añadir botón de cancelar explícito
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") { dismiss() }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.crudState.isLoading {
                    ProgressView()
                } else {
                    Button("Guardar") { guardar() }
                        .bold()
                        // Validación simple: nombre no vacío
                        .disabled(nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onChange(of: viewModel.crudState) { _, state in
            if case .success = state { dismiss() }
        }
    }

    private func guardar() {
        // ... (Tu lógica de guardado existente permanece igual)
    }
}

// MARK: - Ayudante para cargar Imagen Base64
// Puedes mover esto a un archivo de utilidades separado
extension UIImage {
    convenience init?(base64String: String) {
        guard let iconData = Data(base64Encoded: base64String) else { return nil }
        self.init(data: iconData)
    }
}
