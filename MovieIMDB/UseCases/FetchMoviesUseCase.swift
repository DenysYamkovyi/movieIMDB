//
//  FetchMoviesUseCase.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-22.
//

import Combine
import Foundation

struct FetchMoviesUseCase: MoviesListViewModelUseCase {
    private let key = "ed3bad6"
    private let baseURL = "https://www.omdbapi.com/?apikey="
    
    func fetchMovies(title: String? = "") -> AnyPublisher<[MovieModel], Error> {
        guard let title = title?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)\(key)&t=\(title)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { element -> Data in
                guard let response = element.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: Movie.self, decoder: JSONDecoder())
            .map { [MovieModel.init(movie: $0)] }
            .eraseToAnyPublisher()
        
        return publisher
    }
}

