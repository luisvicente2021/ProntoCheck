//
//  NetworkServiceProtocol.swift
//  ProntoCheck
//
//  Created by usuario on 26/06/26.
//
import Foundation

protocol NetworkServiceProtocol {
    
    func request <T:Decodable> (
        endpoint: Endpoint
    ) async throws -> T
}
