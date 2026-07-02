
import SwiftUI

struct AdminLoginView: View {
    
    @StateObject private var viewModel = AdminLoginViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo sutil para dar profundidad
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                    
                // 🚀 UX: Cambiado VStack por ScrollView para gestionar correctamente la subida del teclado
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Encabezado Visual
                        VStack(spacing: 12) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                                .padding(.top, 30) // Un poco más de aire arriba
                            
                            Text("Acceso Administrador")
                                .font(.title2)
                                .bold()
                                .fixedSize(horizontal: false, vertical: true) // 🚀 EVITA LOS PUNTOS SUSPENSIVOS
                            
                            Text("Ingresa tus credenciales para gestionar ProntoCheck.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .fixedSize(horizontal: false, vertical: true) // 🚀 EVITA QUE SE CORTE EL SUBTÍTULO
                        }
                        .padding(.bottom, 10)
                        
                        // Contenedor de Formulario Estilizado
                        VStack(spacing: 16) {
                            // Campo Correo
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.secondary)
                                    .frame(width: 24)
                                TextField("Correo electrónico", text: $viewModel.email)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            
                            // Campo Contraseña
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.secondary)
                                    .frame(width: 24)
                                SecureField("Contraseña", text: $viewModel.password)
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                        
                        // Manejo de Errores Dinámico
                        if let error = viewModel.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(error)
                            }
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                            .transition(.opacity)
                        }
                        
                        // Botón de Acción Principal
                        Button {
                            Task {
                                await viewModel.login()
                            }
                        } label: {
                            Group {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Iniciar Sesión")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(viewModel.isLoading ? Color.blue.opacity(0.6) : Color.blue)
                            .cornerRadius(12)
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(viewModel.isLoading)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                EmpleadosView()
            }
        }
    }
}
