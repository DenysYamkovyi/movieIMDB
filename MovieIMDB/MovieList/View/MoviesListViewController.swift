//
//  MoviesListViewController.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-22.
//

import Combine
import UIKit

protocol MoviesListViewControllerViewModel: ObservableObject {
    associatedtype Movie: MovieTableViewCellViewModel, Hashable
    
    var movies: [Movie] { get }
    var isLoading: Bool { get }
    
    var error: PassthroughSubject<Error, Never> { get }

    func userDidSearch(text: String?)
    func userDidSelect(_ item: Movie)
}

final class MoviesListViewController<ViewModel>: ViewController, UITableViewDelegate, UISearchResultsUpdating where ViewModel: MoviesListViewControllerViewModel  {
    
    private typealias DataSource = UITableViewDiffableDataSource<Section, Row>
    
    private enum Section: Hashable {
        case movies
    }
    
    private enum Row: Hashable {
        case movie(ViewModel.Movie)
    }
    
    private let viewModel: ViewModel
    private let tableView: UITableView = .init()
    private var activityIndicatorView: UIActivityIndicatorView?
    
    private var dataSource: DataSource?
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("We don't use storyboards")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDataSource()
        setupSubviews()
        setupSearchController()
        bindToViewModel()
        updateView()
        
        viewModel.userDidSearch(text: "")
    }
    
    private func setupSubviews() {
        view.addSubview(tableView)
        tableView.bindFrameToSuperviewBounds()
        tableView.delegate = self
    }
    
    private func setupSearchController() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Type to search"
        navigationItem.searchController = search
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
    
    private func updateView() {
        updateActivityIndicatorIfNeeded()
        updateDataSource()
    }
    
    private func updateActivityIndicatorIfNeeded() {
        if viewModel.isLoading,
           activityIndicatorView == nil {
            let activity = UIActivityIndicatorView(style: .large)
            activity.translatesAutoresizingMaskIntoConstraints = false
            activity.startAnimating()
            view.addSubview(activity)
            
            activity.bindToCenter()
            
            activityIndicatorView = activity
        } else if activityIndicatorView != nil {
            activityIndicatorView?.stopAnimating()
            activityIndicatorView?.removeFromSuperview()
            activityIndicatorView = nil
        }
    }
    
    private func handleError(_ error: Error) {
        let alertViewController = UIAlertController(
            title: error.localizedDescription,
            message: nil,
            preferredStyle: .alert
        )
        
        present(alertViewController, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.userDidSearch(text: searchController.searchBar.text)
    }
    
    // MARK: - Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let row = dataSource?.itemIdentifier(for: indexPath) {
            switch row {
            case let .movie(item):
                viewModel.userDidSelect(item)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Layout
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let row = dataSource?.itemIdentifier(for: indexPath) {
            switch row {
            case .movie(_):
                return 100
            }
        }
        return UITableView.automaticDimension
    }
}

// MARK: - Data Source
private extension MoviesListViewController {
    func setupDataSource() {
        tableView.register(MovieTableViewCellView.self, forCellReuseIdentifier: MovieTableViewCellView.reuseIdentifier)
        
        let dataSource = UITableViewDiffableDataSource<Section, Row>(tableView: tableView) { tableView, indexPath, row in
            switch row {
            case let .movie(item):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCellView.reuseIdentifier) as? MovieTableViewCellView else { fatalError("Unexpected cell type") }
                cell.configure(with: item)
                return cell
            }
        }
        
        self.dataSource = dataSource
    }
    
    func updateDataSource() {
        guard var snapshot = dataSource?.snapshot() else { return }
        defer { dataSource?.apply(snapshot, animatingDifferences: true) }
        
        snapshot.deleteAllItems()
        
        guard !viewModel.isLoading else { return }
        
        snapshot.appendSections([.movies])
        snapshot.appendItems(viewModel.movies.map(Row.movie))
    }
}

