//
//  ViewState.swift
//  ProntoCheck
//
//  Created by usuario on 26/06/26.
//

import Foundation

enum ViewState: Equatable {
    case idle
    case loading
    case success
    case failure(String)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .failure(let message) = self { return message }
        return nil
    }
}
