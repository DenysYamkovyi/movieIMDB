//
//  MoviesListViewModelTests.swift
//  MovieIMDBTests
//
//  Created by macbook pro on 2024-07-22.
//

import XCTest
import Combine
@testable import MovieIMDB

final class MoviesListViewModelTests: XCTestCase {
    private var viewModel: MoviesListViewModel!
    private var mockUseCase: MockMoviesListViewModelUseCase!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockUseCase = MockMoviesListViewModelUseCase()
        viewModel = MoviesListViewModel(fetchMoviesUseCase: mockUseCase)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockUseCase = nil
        cancellables = nil
        super.tearDown()
    }

    func testUserDidSearchSuccess() {
        // Arrange
        let movies = [MovieModel(title: "Movie 1", thumbnail: "", year: "2024", overview: "Test overview"),
                      MovieModel(title: "Movie 2", thumbnail: "", year: "2024", overview: "Test overview")]
        mockUseCase.fetchMoviesResult = .success(movies)
        let expectation = self.expectation(description: "Movies fetched")
        
        // Act
        viewModel.$movies
            .dropFirst()
            .sink { movies in
                XCTAssertEqual(movies.count, 2)
                XCTAssertEqual(movies.first?.title, "Movie 1")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.userDidSearch(text: "Movie")
        
        // Assert
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testUserDidSearchFailure() {
        // Arrange
        let error = URLError(.badServerResponse)
        mockUseCase.fetchMoviesResult = .failure(error)
        let expectation = self.expectation(description: "Error received")
        
        // Act
        viewModel.error
            .sink { receivedError in
                XCTAssertEqual((receivedError as? URLError)?.code, error.code)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.userDidSearch(text: "Movie")
        
        // Assert
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testUserDidSelect() {
        // Arrange
        let movie = MovieModel(title: "Selected Movie", thumbnail: "", year: "2024", overview: "Test overview")
        let expectation = self.expectation(description: "Movie selected")
        
        // Act
        viewModel.showMovieOverview
            .sink { selectedMovie in
                XCTAssertEqual(selectedMovie.title, movie.title)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.userDidSelect(movie)
        
        // Assert
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
