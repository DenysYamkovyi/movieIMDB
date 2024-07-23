//
//  MockImageLoaderService.swift
//  MovieIMDBTests
//
//  Created by macbook pro on 2024-07-22.
//

import Combine
import UIKit
@testable import MovieIMDB

class MockImageLoaderService: ImageLoaderService {
    var result: Result<UIImage, Error>?
    
    func loadImage(path: String) -> AnyPublisher<UIImage, Error> {
        if let result = result {
            return result.publisher.eraseToAnyPublisher()
        } else {
            return Fail(error: NSError(domain: "", code: -1, userInfo: nil))
                .eraseToAnyPublisher()
        }
    }
}
