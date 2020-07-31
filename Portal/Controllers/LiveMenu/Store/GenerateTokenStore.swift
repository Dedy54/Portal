//
//  LiveMenuStore.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 31/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation

public enum Endpoint: String, CaseIterable, CustomStringConvertible {
    case generateagoratoken = "generateagoratoken"
    
    public var description: String {
        switch self {
        case .generateagoratoken: return "generateagoratoken"
        }
    }
}

public struct GenerateTokenResponse: Codable {
    public let success: Bool
    public let token: String?
    public let channelName: String?
    public let uid: UInt?
}

protocol GenerateTokenStore {
    func postGenerateToken(from endpoint: Endpoint, page: Int, params: [String: String]?,
                     successHandler: @escaping (_ response: GenerateTokenResponse) -> Void, errorHandler: @escaping(_ error: Error) -> Void)
}
