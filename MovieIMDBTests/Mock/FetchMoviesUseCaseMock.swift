//
//  FetchMoviesUseCaseMock.swift
//  MovieIMDBTests
//
//  Created by macbook pro on 2024-07-22.
//

import Combine
@testable import MovieIMDB

class FetchMoviesUseCaseMock: MoviesListViewModelUseCase {
    
    var result: Result<[MovieModel], Error>?
    
    func fetchMovies(title: String?) -> AnyPublisher<[MovieModel], Error> {
        return Future { promise in
            if let result = self.result {
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }
}

