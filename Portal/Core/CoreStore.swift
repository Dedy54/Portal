//
//  Core.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 31/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation

public class CoreStore {
    
    public static let shared = CoreStore()
    private init() {}
    let baseAPIURL = "https://9ma2thw2dj.execute-api.ap-southeast-1.amazonaws.com/dev"
    let urlSession = URLSession.shared
    
    let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    func handleError(errorHandler: @escaping(_ error: Error) -> Void, error: Error) {
        DispatchQueue.main.async {
            errorHandler(error)
        }
    }
    
}
