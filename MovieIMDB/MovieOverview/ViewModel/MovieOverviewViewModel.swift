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
    
    let error: PassthroughSubject<Error, Never> = .init()
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    init(movie: MovieModel) {
        self.title = movie.title
    }
}

