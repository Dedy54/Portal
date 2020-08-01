//
//  GenerateTokenService.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 31/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation

public enum GenerateTokenError: Error {
    case apiError
    case invalidURL
    case invalidEndpoint
    case invalidResponse
    case noData
    case serializationError
}

extension CoreStore : GenerateTokenStore {
    
    func postGenerateToken(from endpoint: Endpoint, page: Int, params: [String : String]?, successHandler: @escaping (GenerateTokenResponse) -> Void, errorHandler: @escaping (Error) -> Void) {
        print("\(baseAPIURL)/\(endpoint.rawValue)")
        guard let urlComponents = URLComponents(string: "\(baseAPIURL)/\(endpoint.rawValue)") else {
            errorHandler(GenerateTokenError.invalidEndpoint)
            return
        }
        
        guard let url = urlComponents.url else {
            errorHandler(GenerateTokenError.invalidEndpoint)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params ?? [], options: []) else {
            return
        }
        request.httpBody = httpBody

        urlSession.dataTask(with: request) { (data, response, error) in
            if error != nil {
                self.handleError(errorHandler: errorHandler, error: GenerateTokenError.apiError)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                self.handleError(errorHandler: errorHandler, error: GenerateTokenError.invalidResponse)
                return
            }
            
            guard let data = data else {
                self.handleError(errorHandler: errorHandler, error: GenerateTokenError.noData)
                return
            }
            
            do {
                print(data)
                let response = try self.jsonDecoder.decode(GenerateTokenResponse.self, from: data)
                DispatchQueue.main.async {
                    successHandler(response)
                }
            } catch {
                self.handleError(errorHandler: errorHandler, error: GenerateTokenError.serializationError)
            }
        }.resume()
        
    }
    
    
    
}
