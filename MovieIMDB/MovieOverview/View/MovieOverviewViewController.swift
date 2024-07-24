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
    var overview: String { get }
    
    var error: PassthroughSubject<Error, Never> { get }
}

final class MovieOverviewViewController<ViewModel>: ViewController where ViewModel: MovieOverviewViewControllerViewModel {
    
    private let viewModel: ViewModel
    
    private let titleLabel = UILabel()
    private let posterImageView = UIImageView()
    private let overviewLabel = UILabel()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bindToViewModel()
        updateView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        
        scrollView.bindFrameToSuperviewBounds()
        
        let contentStackView = UIStackView()
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.alignment = .center
        contentStackView.distribution = .equalSpacing
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(posterImageView)
        contentStackView.addArrangedSubview(overviewLabel)
        
        // Movie Title Label
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textAlignment = .center
        
        
        // Movie Poster Image View
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.clipsToBounds = true
        
        
        NSLayoutConstraint.activate([
            posterImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Movie Overview Label
        overviewLabel.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            overviewLabel.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: -20)
        ])
    }
    
    private func bindToViewModel() {
        viewModel
            .objectDidChange(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateView() }
            .store(in: &cancellables)
        
        viewModel
            .error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.handleError($0) }
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: Error) {
        let alertViewController = UIAlertController(
            title: error.localizedDescription,
            message: nil,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertViewController.addAction(okAction)
        
        present(alertViewController, animated: true)
    }
    
    private func updateView() {
        titleLabel.text = viewModel.title
        posterImageView.image = viewModel.image
        overviewLabel.text = viewModel.overview
    }
}
