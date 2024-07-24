//
//  MovieTableViewCellView.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-22.
//

import UIKit
import Combine

protocol MovieTableViewCellViewModel {
    var title: String { get }
    var thumbnail: String { get }
    var year: String { get }
    
    var onButtonAction: PassthroughSubject<Void, Never> { get }
}

class MovieTableViewCellView: UITableViewCell {
    static let reuseIdentifier = "MovieTableViewCellView"
    
    private var cancellables = Set<AnyCancellable>()
    
    // Subviews
    private let movieImageView = UIImageView()
    private let titleLabel = UILabel()
    private let yearLabel = UILabel()
    private let moreButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupViews() {
        contentView.addSubview(movieImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(yearLabel)
        contentView.addSubview(moreButton)
        
        setupMovieImageView()
        setupTitleLabel()
        setupYearLabel()
        setupMoreButton()
    }
    
    private func setupMovieImageView() {
        movieImageView.translatesAutoresizingMaskIntoConstraints = false
        movieImageView.contentMode = .scaleAspectFit
        movieImageView.clipsToBounds = true

        NSLayoutConstraint.activate([
            movieImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            movieImageView.heightAnchor.constraint(equalTo: movieImageView.widthAnchor, multiplier: 1.5),
            movieImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: 8)
        ])
    }
    
    private func setupYearLabel() {
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.font = UIFont.systemFont(ofSize: 12)
        yearLabel.textColor = .gray
   
        contentView.addSubview(yearLabel)

        NSLayoutConstraint.activate([
            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            yearLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 8),
            yearLabel.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: 8),
            yearLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupMoreButton() {
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.setTitle("More", for: .normal)
        moreButton.setTitleColor(.black, for: .normal)
        moreButton.backgroundColor = .lightGray

        contentView.addSubview(moreButton)
        
        NSLayoutConstraint.activate([
            moreButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            moreButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
        ])
    }
}

extension MovieTableViewCellView: Configurable {
    func configure(with viewModel: MovieTableViewCellViewModel) {
        cancellables.removeAll()
        
        moreButton.removeAction(identifiedBy: .init("tap"), for: .touchUpInside)
        moreButton.addAction(.init(identifier: .init("tap"), handler: { action in
            viewModel.onButtonAction.send(())
        }), for: .touchUpInside)
        
        titleLabel.text = viewModel.title
        yearLabel.text = viewModel.year
        
        ImageLoader().loadImage(path: viewModel.thumbnail)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                // Handle completion if needed
            }, receiveValue: { [weak self] image in
                self?.movieImageView.image = image
            })
            .store(in: &cancellables)
    }
}
