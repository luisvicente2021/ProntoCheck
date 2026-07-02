//
//  RelojView.swift
//  ProntoCheck
//
//  Created by usuario on 26/06/26.
//

import SwiftUI

struct RelojView: View {

    @StateObject private var relojVM = RelojViewModel()
    @State private var mostrarCamara = false
    @State private var mostrarLoginAdmin = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemGroupedBackground),
                    Color.blue.opacity(0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerView
                    cameraCard
                    statusCards
                    empleadoCard
                    actionButton
                    messageCard
                }
                .padding([.horizontal, .bottom])
            }
            .navigationTitle("ProntoCheck")
            .navigationBarTitleDisplayMode(.inline)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    mostrarLoginAdmin = true
                } label: {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .task {
            await relojVM.iniciar()
        }
        .sheet(isPresented: $mostrarCamara) {
            FaceCaptureView { image in
                Task {
                    await relojVM.validarRostro(image)
                }
            }
        }
        .sheet(isPresented: $mostrarLoginAdmin) {
            AdminLoginView()
        }
        .onDisappear {
            relojVM.detenerReloj()
        }
    }

    private var headerView: some View {
        VStack(spacing: 4) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 55, height: 55)

            Text(relojVM.horaActual)
                .font(.system(size: 38, weight: .bold, design: .rounded))

            Text(relojVM.fechaActual)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, -30)
    }

    private var cameraCard: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.black)
                    .frame(height: 280)

                VStack(spacing: 14) {
                    Image(systemName: "faceid")
                        .font(.system(size: 74))
                        .foregroundColor(.white)

                    Text(relojVM.estadoEscaner)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(statusColor)
                        .foregroundColor(.white)
                        .cornerRadius(20)

                    Button {
                        mostrarCamara = true
                    } label: {
                        Label("Escanear rostro", systemImage: "camera.fill")
                            .font(.headline)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                }
            }
        }
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }

    private var statusCards: some View {
        HStack(spacing: 14) {
            StatusMiniCard(
                title: "Rostro",
                value: relojVM.faceOK ? "OK" : "Pendiente",
                icon: "faceid",
                isOK: relojVM.faceOK
            )

            StatusMiniCard(
                title: "Ubicación",
                value: relojVM.gpsOK ? "OK" : "Pendiente",
                icon: "location.fill",
                isOK: relojVM.gpsOK
            )
        }
    }

    private var empleadoCard: some View {
        VStack(spacing: 10) {
            Text("Empleado detectado")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(relojVM.empleadoDetectado?.nombreCompleto ?? "Sin detectar")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(relojVM.empleadoDetectado == nil ? .secondary : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
    }

    private var actionButton: some View {
        Button {
            Task {
                await relojVM.registrarAsistencia()
            }
        } label: {
            Label(
                relojVM.tipoDisponible == "entrada" ? "Registrar entrada" : "Registrar salida",
                systemImage: relojVM.tipoDisponible == "entrada" ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
            )
            .font(.title3)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(actionColor)
            .foregroundColor(.white)
            .cornerRadius(20)
            .opacity(relojVM.faceOK && relojVM.gpsOK ? 1 : 0.45)
        }
        .disabled(!(relojVM.faceOK && relojVM.gpsOK))
    }

    private var messageCard: some View {
        Text(relojVM.mensaje)
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }

    private var actionColor: Color {
        guard relojVM.faceOK && relojVM.gpsOK else { return .gray }
        return relojVM.tipoDisponible == "entrada" ? .green : .red
    }

    private var statusColor: Color {
        switch relojVM.estadoEscaner {
        case "ROSTRO OK":
            return .green
        case "NO AUTORIZADO", "ERROR", "NO DETECTADO":
            return .red
        default:
            return .orange
        }
    }
}

// MARK: - Componente Reutilizable (Faltaba añadirlo abajo)
struct StatusMiniCard: View {
    let title: String
    let value: String
    let icon: String
    let isOK: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isOK ? .green : .gray)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.headline)
                    .foregroundColor(isOK ? .green : .gray)
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.06), radius: 5, y: 2)
    }
}
