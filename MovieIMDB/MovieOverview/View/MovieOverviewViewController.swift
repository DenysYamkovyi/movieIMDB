//
//  MovieOverviewViewController.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-23.
//

import Combine
import UIKit

protocol MovieOverviewViewControllerViewModel: ObservableObject {
    var title: String { get }
    var image: UIImage? { get }
    
    var error: PassthroughSubject<Error, Never> { get }
}

final class MovieOverviewViewController<ViewModel>: ViewController where ViewModel: MovieOverviewViewControllerViewModel {
    private let viewModel: ViewModel
    
    private let titleLabel = UILabel()
    private let posterImageView = UIImageView()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
