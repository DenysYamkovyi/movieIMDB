//
//  MoviesListViewModel.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-22.
//

import Combine
import UIKit

protocol MoviesListViewModelUseCase {
    func fetchMovies(title: String) -> AnyPublisher<[MovieModel], Error>
}

final class MoviesListViewModel: MoviesListViewControllerViewModel {
    @Published var movies: [MovieModel] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String? = nil
    
    private let fetchMoviesUseCase: MoviesListViewModelUseCase
    
    private var lastSearch: String?
    
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

    func userDidSearch(text: String) {
        guard !isLoading, text.count > 2, lastSearch != text else { return }
        isLoading = true
        
        lastSearch = text
        showError = false
        errorMessage = nil
        
        fetchMoviesUseCase
            .fetchMovies(title: text)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoading = false
                switch result {
                case let .failure(error):
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                    self?.error.send(error)
                default:
                    break
                }
            }, receiveValue: { [weak self] movies in
                guard let self else { return }
                self.originalMoviesList = movies
                movies.forEach { model in
                    model.onButtonAction.sink { [weak self] _ in self?.userDidTapMoreFor(model) }
                        .store(in: &self.cancellables)
                }
            })
            .store(in: &cancellables)
    }
    
    func userDidSelect(_ item: MovieModel) {
         _showMovieOverview.subject.send(item)
    }
    
    private func userDidTapMoreFor(_ model: MovieModel) {
        print("BUTTON ACTION")
    }
}


