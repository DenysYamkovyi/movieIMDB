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
    private let baseURL = "https://www.omdbapi.com/"
    
    func fetchMovies(title: String) -> AnyPublisher<[MovieModel], Error> {
        var urlComps = URLComponents(string: baseURL)!
        urlComps.queryItems = [.init(name: "apikey", value: key)]
        
        if !title.isEmpty {
            let titleEncoded = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            urlComps.queryItems?.append(.init(name: "s", value: titleEncoded))
        }
        
        guard let url = urlComps.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { element -> Data in
                guard let response = element.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                
                if let error = try? JSONDecoder().decode(ErrorResponse.self, from: element.data) {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: error.error])
                }
                
                return element.data
            }
            .decode(type: MovieSearchResponse.self, decoder: JSONDecoder())
            .map { $0.search.map { MovieModel(movie: $0) } }
            .eraseToAnyPublisher()
        
        return publisher
    }

}
