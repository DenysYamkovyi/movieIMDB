//
//  MovieOverviewViewModel.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-23.
//

import Combine
import Foundation
import UIKit

final class MovieOverviewViewModel: MovieOverviewViewControllerViewModel {
    private(set) var title: String
    @Published private(set) var image: UIImage? = nil
    private(set) var overview: String
    
    private let imageLoader: ImageLoaderService
    
    let error: PassthroughSubject<Error, Never> = .init()
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    init(movie: MovieModel, imageLoader: ImageLoaderService) {
        self.title = movie.title
        self.overview = movie.overview
        self.imageLoader = imageLoader
        
        self.loadImage(path: movie.thumbnail)
    }
    
    private func loadImage(path: String) {
        
        imageLoader.loadImage(path: path)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case let .failure(error):
                    self.error.send(error)
                default:
                    break
                }
            }, receiveValue: { [weak self] image in
                self?.image = image
            })
            .store(in: &cancellables)
    }
}

