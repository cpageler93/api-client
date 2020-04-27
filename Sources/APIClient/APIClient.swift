//
//  APIClient.swift
//  APIClient
//
//  Created by Christoph Pageler on 15.04.20.
//


import Foundation
import NIO
import AsyncHTTPClient


open class APIClient {

    public var handler: APIRouteHandler

    private let httpClient: HTTPClient

    public init(handler: APIRouteHandler, httpClient: HTTPClient) {
        self.handler = handler
        self.httpClient = httpClient
    }

    public init(httpClient: HTTPClient, eventLoop: EventLoop, baseURL: URL) {
        self.handler = DefaultAPIRouteHandler(httpClient: httpClient, eventLoop: eventLoop, baseURL: baseURL)
        self.httpClient = httpClient
    }

    public init(eventLoopGroupProvider: HTTPClient.EventLoopGroupProvider = .createNew, baseURL: URL) {
        let httpClient = HTTPClient(eventLoopGroupProvider: eventLoopGroupProvider)

        self.handler = DefaultAPIRouteHandler(httpClient: httpClient,
                                              eventLoop: httpClient.eventLoopGroup.next(),
                                              baseURL: baseURL)
        self.httpClient = httpClient
    }

    /// Hop to a new eventloop to execute requests on.
    /// - Parameter eventLoop: The eventloop to execute requests on.
    public func hopped(to eventLoop: EventLoop) -> APIClient {
        handler.eventLoop = eventLoop
        return self
    }

    deinit {
        try? httpClient.syncShutdown()
    }

}
