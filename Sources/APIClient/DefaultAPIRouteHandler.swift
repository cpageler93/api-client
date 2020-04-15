//
//  DefaultAPIRouteHandler.swift
//  APIClient
//
//  Created by Christoph Pageler on 15.04.20.
//


import Foundation
import NIO
import NIOFoundationCompat
import NIOHTTP1
import AsyncHTTPClient


open class DefaultAPIRouteHandler: APIRouteHandler {

    public var baseURL: URL
    public var eventLoop: EventLoop

    private let client: HTTPClient
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(httpClient: HTTPClient, eventLoop: EventLoop, baseURL: URL) {
        self.client = httpClient
        self.eventLoop = eventLoop
        self.baseURL = baseURL

        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }

    public func headers() -> HTTPHeaders {
        return HTTPHeaders(dictionaryLiteral:
            ("Content-Type", "application/json")
        )
    }

    public func headers(_ headers: [String : String]) -> HTTPHeaders {
        var defaultHeaders = self.headers()

        for (key, value) in headers {
            defaultHeaders.replaceOrAdd(name: key, value: value)
        }

        return defaultHeaders
    }

    public func headers(token: String?) -> HTTPHeaders {
        return headers(token: token, other: [:])
    }

    public func headers(token: String?, other: [String: String]) -> HTTPHeaders {
        var headers = other
        if let token = token {
            headers["Authorization"] = "Bearer \(token)"
        }
        return self.headers(headers)
    }

    // MARK: - Make Requests

    internal func submit<T: Decodable>(request: HTTPClient.Request) -> EventLoopFuture<T> {
        return client.execute(request: request).flatMapThrowing { response in
            guard var body = response.body else {
                throw APIClientError.noBodyError(response.status.code)
            }

            guard let responseBody = body.readBytes(length: body.readableBytes) else {
                throw APIClientError.couldNotReadBody
            }

            guard response.status.code < 400 else {
                throw APIClientError.httpError(response.status.code)
            }

            do {
                return try self.decoder.decode(T.self, from: Data(responseBody))
            } catch(let error) {
                print(error)
                throw APIClientError.parsing
            }
        }
    }

    internal func submit(request: HTTPClient.Request) -> EventLoopFuture<Void> {
        return client.execute(request: request).flatMapThrowing { response in
            guard response.status.code < 400 else {
                throw APIClientError.httpError(response.status.code)
            }

            return
        }
    }

    internal func makeRequest<Body: Codable, T: Decodable>(_ path: String,
                                                           method: HTTPMethod,
                                                           headers: HTTPHeaders,
                                                           body: Body) -> EventLoopFuture<T> {
        do {
            return try makeRequest(path, method: method, headers: headers, data: encoder.encode(body))
        } catch {
            return client.eventLoopGroup.next().makeFailedFuture(error)
        }
    }

    internal func makeRequest<T: Decodable>(_ path: String,
                                            method: HTTPMethod,
                                            headers: HTTPHeaders,
                                            data: Data) -> EventLoopFuture<T> {
        do {
            let request = try HTTPClient.Request(url: URL(string: baseURL.absoluteString + path)!,
                                                 method: method,
                                                 headers: headers,
                                                 body: HTTPClient.Body.data(data))
            return submit(request: request)
        } catch {
            return client.eventLoopGroup.next().makeFailedFuture(error)
        }
    }

    internal func makeRequest(_ path: String,
                              method: HTTPMethod,
                              headers: HTTPHeaders,
                              data: Data) -> EventLoopFuture<Void> {
        do {
            let request = try HTTPClient.Request(url: URL(string: baseURL.absoluteString + path)!,
                                                 method: method,
                                                 headers: headers,
                                                 body: HTTPClient.Body.data(data))
            return submit(request: request)
        } catch {
            return client.eventLoopGroup.next().makeFailedFuture(error)
        }
    }

    internal func makeRequest<T: Decodable>(_ path: String,
                                            method: HTTPMethod,
                                            headers: HTTPHeaders) -> EventLoopFuture<T> {
        do {
            let request = try HTTPClient.Request(url: URL(string: baseURL.absoluteString + path)!,
                                                 method: method,
                                                 headers: headers)
            return submit(request: request)
        } catch {
            return client.eventLoopGroup.next().makeFailedFuture(error)
        }
    }

    internal func makeRequest<Body: Codable>(_ path: String,
                                             method: HTTPMethod,
                                             headers: HTTPHeaders,
                                             body: Body) -> EventLoopFuture<Void> {
        do {
            let request = try HTTPClient.Request(url: URL(string: baseURL.absoluteString + path)!,
                                                 method: method,
                                                 headers: headers,
                                                 body: HTTPClient.Body.data(encoder.encode(body)))
            return submit(request: request)
        } catch {
            return client.eventLoopGroup.next().makeFailedFuture(error)
        }
    }

    internal func makeRequest(_ path: String, method: HTTPMethod, headers: HTTPHeaders) -> EventLoopFuture<Void> {
        do {
            let request = try HTTPClient.Request(url: URL(string: baseURL.absoluteString + path)!,
                                                 method: method,
                                                 headers: headers)
            return submit(request: request)
        } catch {
            return client.eventLoopGroup.next().makeFailedFuture(error)
        }
    }

    // MARK: - Get

    public func get<Body: Codable, T: Decodable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<T> {
        return makeRequest(path, method: .GET, headers: headers, body: body)
    }

    public func get<T: Decodable>(_ path: String, headers: HTTPHeaders) -> EventLoopFuture<T> {
        return makeRequest(path, method: .GET, headers: headers)
    }

    public func get<T: Decodable>(_ path: String) -> EventLoopFuture<T> {
        return makeRequest(path, method: .GET, headers: HTTPHeaders())
    }

    public func getData(baseURL: URL?, _ path: String) -> EventLoopFuture<Data> {
        do {
            let baseURL = baseURL ?? self.baseURL
            let request = try HTTPClient.Request(url: URL(string: baseURL.absoluteString + path)!, method: .GET)
            return client.execute(request: request).flatMapThrowing { response in
                guard response.status.code < 400 else {
                    throw APIClientError.httpError(response.status.code)
                }

                guard var body = response.body else {
                    throw APIClientError.noBodyError(response.status.code)
                }

                guard let response = body.readBytes(length: body.readableBytes) else {
                    throw APIClientError.couldNotReadBody
                }

                return Data(response)
            }
        } catch {
            return client.eventLoopGroup.next().makeFailedFuture(error)
        }
    }

    // MARK: - Post

    public func post<Body: Codable, T: Decodable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<T> {
        return makeRequest(path, method: .POST, headers: headers, body: body)
    }

    public func post<T: Decodable>(_ path: String, headers: HTTPHeaders) -> EventLoopFuture<T> {
        return makeRequest(path, method: .POST, headers: headers)
    }

    public func post<Body: Codable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<Void> {
        return makeRequest(path, method: .POST, headers: headers, body: body)
    }

    public func post(_ path: String, headers: HTTPHeaders, data: Data) -> EventLoopFuture<Void> {
        return makeRequest(path, method: .POST, headers: headers, data: data)
    }

    public func post(_ path: String, headers: HTTPHeaders) -> EventLoopFuture<Void> {
        return makeRequest(path, method: .POST, headers: headers)
    }

    // MARK: - Put

    public func put<Body: Codable, T: Decodable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<T> {
        return makeRequest(path, method: .PUT, headers: headers, body: body)
    }

    public func put<T: Decodable>(_ path: String, headers: HTTPHeaders) -> EventLoopFuture<T> {
        return makeRequest(path, method: .PUT, headers: headers)
    }

    public func put<Body: Codable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<Void> {
        return makeRequest(path, method: .PUT, headers: headers, body: body)
    }

    public func put(_ path: String, headers: HTTPHeaders, data: Data) -> EventLoopFuture<Void> {
        return makeRequest(path, method: .PUT, headers: headers, data: data)
    }

    public func put(_ path: String, headers: HTTPHeaders) -> EventLoopFuture<Void> {
        return makeRequest(path, method: .PUT, headers: headers)
    }

    // MARK: - Patch

    public func patch<Body: Codable, T: Decodable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<T> {
        return makeRequest(path, method: .PATCH, headers: headers, body: body)
    }

    public func patch<Body: Codable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<Void> {
        return makeRequest(path, method: .PATCH, headers: headers, body: body)
    }

    // MARK: - Delete

    public func delete<Body: Codable, T: Decodable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<T> {
        return makeRequest(path, method: .DELETE, headers: headers, body: body)
    }

    public func delete<Body: Codable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<Void> {
        return makeRequest(path, method: .DELETE, headers: headers, body: body)
    }

    public func delete(_ path: String, headers: HTTPHeaders) -> EventLoopFuture<Void> {
        return makeRequest(path, method: .DELETE, headers: headers)
    }

}
