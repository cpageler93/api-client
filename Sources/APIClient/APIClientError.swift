//
//  APIClientError.swift
//  APIClient
//
//  Created by Christoph Pageler on 15.04.20.
//

import Foundation


public enum APIClientError: Swift.Error {

    case httpError(UInt)
    case noBodyError(UInt)
    case couldNotReadBody
    case parsing
    case unknown

}
