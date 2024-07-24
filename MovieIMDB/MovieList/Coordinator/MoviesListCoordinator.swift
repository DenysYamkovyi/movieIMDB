//
//  MoviesListCoordinator.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-22.
//

import Combine
import UIKit

final class MoviesListCoordinator: Coordinator {
    typealias CompletionType = Void
    
    private weak var navigationController: UINavigationController?
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    @discardableResult
    func start(animated: Bool) -> CompletionPublisher {
        let useCase = FetchMoviesUseCase()
        let viewModel = MoviesListViewModel(fetchMoviesUseCase: useCase)
        let viewController = MoviesListViewController(viewModel: viewModel)
        
        viewModel.showMovieOverview
            .sink { [weak self] movie in
                self?.showMovieOverview(movie: movie)
            }
            .store(in: &cancellables)
        
        navigationController?.pushViewController(viewController, animated: animated)
        
        return .never()
    }
    
    private func showMovieOverview(movie: MovieModel) {
        let viewModel = MovieOverviewViewModel(movie: movie, imageLoader: ImageLoader())
        let viewController = MovieOverviewViewController(viewModel: viewModel)

        navigationController?.pushViewController(viewController, animated: true)
    }
}

