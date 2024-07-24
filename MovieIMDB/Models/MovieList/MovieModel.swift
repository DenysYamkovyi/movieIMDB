//
//  MovieModel.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-22.
//

import Combine
import Foundation

struct MovieModel: MovieTableViewCellViewModel, Hashable {
    let title: String
    let thumbnail: String
    let year: String
    let overview: String
    
    @HashableExcluded
    var onButtonAction: PassthroughSubject<Void, Never> = .init()
}

extension MovieModel {
    init(movie: Movie) {
        self.title = movie.title
        self.thumbnail = movie.poster
        self.year = movie.year
        self.overview = movie.poster
    }
}
