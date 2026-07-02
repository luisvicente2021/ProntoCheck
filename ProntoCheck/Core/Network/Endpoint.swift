//
//  Endpoint.swift
//  ProntoCheck
//
//  Created by usuario on 26/06/26.
//

import Foundation


protocol Endpoint {
    var basePath: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var body:  Data? { get }
}



enum EmpleadosEndpoint: Endpoint {
   
    case obtenerTodos(limit: Int, offset: Int)
    case obtenerPorId(String)
    case crear(CrearEmpleadoRequest)
    case actualizar(id: String, body: Data)
    case puntoAcceso
  
    
    var basePath: String {
        "/rest/v1/"
    }
    
    var path: String {
        switch self {
            
        case let .obtenerTodos(limit, offset):
            return "empleados?select=*&limit=\(limit)&offset=\(offset)"
            
        case let .obtenerPorId(id):
            return "empleados?id=eq.\(id)&select=*"
            
        case .crear:
            return "empleados"
            
        case let .actualizar(id, _):
            return "empleados?id=eq.\(id)"
        case .puntoAcceso:
            return "puntos_acceso?select=*"
       
        }
    }
        
        var method: HTTPMethod {
            switch self {
            case .obtenerTodos, .obtenerPorId:
                return .get
                
            case .crear:
                return .post
                
            case .actualizar:
                return .patch
            case .puntoAcceso:
                return .get
          
            }
        }
        
        var body: Data? {
            switch self {
            case .obtenerTodos,
                    .obtenerPorId:
                return nil
                
            case .crear(let crearEmpleadoRequest):
                return try? JSONEncoder().encode(crearEmpleadoRequest)
                
            case let .actualizar(_, data):
                return data
            case .puntoAcceso:
                return nil
           
            }
        }
}



enum PostEndpoint: Endpoint {
 
    
    
    case getAttendances
    case createAttendances(RegistrarAsistenciaRequest)
    case createemploye(CrearEmpleadoRequest)
    case ultimaAsistencia(UUID)
    
    var basePath: String {
        "/rest/v1/"
    }
    
    var path: String {
        switch self {
        case .getAttendances:
            return  "/asistencia"
        case .createAttendances(_):
            return "asistencia"
            
        case .createemploye(_):
            return "/empleados"
        case .ultimaAsistencia(let empleadoId):
            return "asistencia?empleado_id=eq.\(empleadoId.uuidString)&select=*&order=fecha_hora.desc&limit=1"
        }
    }
    
    var method: HTTPMethod {
        switch self {
            
        case .getAttendances:
            return .get
        case .createAttendances(_):
            return .post
        case .createemploye(_):
              return  .post
        case .ultimaAsistencia(_):
            return .get
        }
    }
    
    var body: Data? {
        switch self {
            
        case .getAttendances:
            return  nil
            
        case .createAttendances(let request):
            return try?  JSONEncoder().encode(request)
            
        case .createemploye(let request):
            return try? JSONEncoder().encode(request)
        case .ultimaAsistencia(_):
            return nil
        }
    }
}


enum AuthEndpoint: Endpoint {
    case login(LoginRequest)

    var basePath: String { "/auth/v1/" }

    var path: String {
        switch self {
        case .login:
            return "token?grant_type=password"
        }
    }

    var method: HTTPMethod { .post }

    var body: Data? {
        switch self {
        case .login(let request):
            return try? JSONEncoder().encode(request)
        }
    }
}
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    
}
