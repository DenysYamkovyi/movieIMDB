//
//  FetchMoviesUseCaseMock.swift
//  MovieIMDBTests
//
//  Created by macbook pro on 2024-07-22.
//

import Combine
import XCTest
@testable import MovieIMDB

final class MockMoviesListViewModelUseCase: MoviesListViewModelUseCase {
    var fetchMoviesResult: Result<[MovieModel], Error>?
    
    func fetchMovies(title: String) -> AnyPublisher<[MovieModel], Error> {
        if let result = fetchMoviesResult {
            return result.publisher.eraseToAnyPublisher()
        } else {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        }
    }
}
