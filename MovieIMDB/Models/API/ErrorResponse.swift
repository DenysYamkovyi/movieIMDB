//
//  ErrorResponse.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-23.
//

import Foundation

struct ErrorResponse: Decodable {
    let response: String
    let error: String
    
    enum CodingKeys: String, CodingKey {
        case response = "Response"
        case error = "Error"
    }
}
