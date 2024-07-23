//
//  MovieModel.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-22.
//

import Foundation

struct MovieModel: MovieTableViewCellViewModel, Hashable {
    let title: String
    let thumbnail: String
    let year: String
}

extension MovieModel {
    init(movie: Movie) {
        self.title = movie.Title
        self.thumbnail = movie.Poster
        self.year = movie.Year
    }
}
