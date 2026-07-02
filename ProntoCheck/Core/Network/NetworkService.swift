//
//  NetworkService.swift
//  ProntoCheck
//
//  Created by usuario on 26/06/26.
// GET https://tu-proyecto.supabase.co/rest/v1/empleados

import Foundation

final class NetworkService: NetworkServiceProtocol {
    
    private let baseURL =  "https://lzncujcdpsopktlctrci.supabase.co" //"https://jsonplaceholder.typicode.com"
    
    private let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx6bmN1amNkcHNvcGt0bGN0cmNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3MjEyNjMsImV4cCI6MjA5MDI5NzI2M30.rrrll0GVVSR79mOocZxq48kcFIXkdh5XeJ7djEQRv_Q"
  
    func request<T>(endpoint: Endpoint) async throws -> T where T : Decodable {
        
        
        
        guard let url = URL(string: baseURL + endpoint.basePath + endpoint.path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(anonKey, forHTTPHeaderField: "apikey")
                request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
                request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        request.httpBody = endpoint.body
        
        let (data, response) =
        try await URLSession.shared.data(for: request)
        
        if let http = response as? HTTPURLResponse {
            print("STATUS CODE:", http.statusCode)
        }

        print("BODY:", String(data: data, encoding: .utf8) ?? "Sin body")
        print("URL:", url.absoluteString)
        print("METHOD:", request.httpMethod ?? "")
        print("BODY SENT:", String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        return try  JSONDecoder().decode(T.self, from: data)
        
        
    }
    
    
    
}



enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case encodingError
}
