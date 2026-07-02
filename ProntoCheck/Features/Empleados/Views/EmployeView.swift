//
//  EmployeView.swift
//  ProntoCheck
//
//  Created by usuario on 26/06/26.
//

import SwiftUI

struct EmpleadosView: View {
    @StateObject private var viewModel = EmpleadosViewModel()
    @State private var showAltaEmpleado = false
    @State private var showRelojView = false
    @State private var textoBusqueda = "" // UX: Soporte para búsqueda

    // Computed property para filtrar localmente si es necesario
    var empleadosFiltrados: [Empleado] {
        if textoBusqueda.isEmpty {
            return viewModel.empleados
        } else {
            return viewModel.empleados.filter {
                $0.nombreCompleto.localizedCaseInsensitiveContains(textoBusqueda) ||
                ($0.email.localizedCaseInsensitiveContains(textoBusqueda))
            }
        }
    }

    var body: some View {
        Group {
            switch viewModel.listState {
            case .loading where viewModel.empleados.isEmpty:
                ProgressView("Cargando empleados...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tint(.accentColor)

            case .failure(let msg):
                ContentUnavailableView(
                    "Error al cargar",
                    systemImage: "exclamationmark.triangle.fill",
                    description: Text(msg)
                )

            case .success where viewModel.empleados.isEmpty:
                ContentUnavailableView(
                    "Sin empleados",
                    systemImage: "person.2.slash.fill",
                    description: Text("Agrega al primer empleado usando el botón + superior.")
                )

            default:
                List {
                    ForEach(empleadosFiltrados) { empleado in
                        NavigationLink(destination: EditarEmpleadoView(empleado: empleado, viewModel: viewModel)) {
                            EmpleadoRowView(empleado: empleado)
                        }
                        // UI: Acciones rápidas al deslizar
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                // Lógica para dar de baja o eliminar si es necesario
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                        .onAppear {
                            if empleado.id == viewModel.empleados.last?.id {
                                viewModel.cargarPagina()
                            }
                        }
                    }
                    
                    if viewModel.listState.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.insetGrouped) // UI: El estilo agrupado se ve más limpio y corporativo
            }
        }
        .navigationTitle("Gestión de Personal")
        .navigationBarTitleDisplayMode(.large) // UI: Título grande nativo para pantallas principales
        .searchable(text: $textoBusqueda, prompt: "Buscar empleado...") // UX: Barra de búsqueda nativa
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showAltaEmpleado = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3) // Destaca sutilmente el botón principal de acción
                }
            }
        }
        .sheet(isPresented: $showAltaEmpleado) {
            AltaEmpleadoView(viewModel: viewModel)
        }
        .sheet(isPresented: $showRelojView) {
            RelojView()
        }
        .onAppear {
            if viewModel.empleados.isEmpty {
                viewModel.cargarPagina(reiniciar: true)
            }
        }
        .refreshable {
            viewModel.cargarPagina(reiniciar: true)
        }
    }
}

// MARK: - Row Rediseñada
struct EmpleadoRowView: View {
    let empleado: Empleado

    var body: some View {
        HStack(spacing: 16) {
            // Avatar Inteligente (Foto real o iniciales con gradiente)
            if let fotoBase64 = empleado.fotoRostro,
               let uiImage = UIImage(contentsOfFile: fotoBase64) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.separator), lineWidth: 0.5))
            } else {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(empleado.iniciales)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    )
            }

            // Datos del Empleado
            VStack(alignment: .leading, spacing: 4) {
                Text(empleado.nombreCompleto)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 6) {
                    // Badge de Estado Activo/Inactivo
                    Circle()
                        .fill(empleado.activo ?? true ? Color.green : Color.secondary)
                        .frame(width: 8, height: 8)
                    
                    Text(empleado.email)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
