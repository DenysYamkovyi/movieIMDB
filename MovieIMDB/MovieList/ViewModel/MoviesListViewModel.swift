//
//  MoviesListViewModel.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-22.
//

import Combine
import UIKit

protocol MoviesListViewModelUseCase {
    func fetchMovies(title: String?) -> AnyPublisher<[MovieModel], Error>
}

final class MoviesListViewModel: MoviesListViewControllerViewModel {
    @Published var movies: [MovieModel] = []
    @Published var isLoading: Bool = false
    
    private let fetchMoviesUseCase: MoviesListViewModelUseCase
    
    private var originalMoviesList: [MovieModel] = [] {
        didSet {
            movies = originalMoviesList
        }
    }
    
    let error: PassthroughSubject<Error, Never> = .init()
    
    @Passthrough var showMovieOverview: AnyPublisher<MovieModel, Never>
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    init(fetchMoviesUseCase: MoviesListViewModelUseCase) {
        self.fetchMoviesUseCase = fetchMoviesUseCase
    }

    func userDidSearch(text: String? = "") {
        guard let text, !text.isEmpty else {
            movies.removeAll()
            return
        }
        
        guard !isLoading else { return }
        isLoading = true
        
        fetchMoviesUseCase
            .fetchMovies(title: text)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoading = false
                switch result {
                case let .failure(error):
                    self?.error.send(error)
                default:
                    break
                }
            }, receiveValue: { [weak self] movies in
                self?.originalMoviesList = movies
            })
            .store(in: &cancellables)
    }
    
    func userDidSelect(_ item: MovieModel) {
        // just for presentation. Uncomment for the navigation to the overview screen
        // _showMovieOverview.subject.send(item)
    }
}


