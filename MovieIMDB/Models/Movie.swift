//
//  Movie.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-22.
//

import Foundation

struct Movie: Decodable {
    let Title: String
    let Poster: String
    let Year: String
    
    private enum CodingKeys : String, CodingKey {
        case Title, Poster, Year
    }
}
