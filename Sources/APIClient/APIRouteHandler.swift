//
//  APIRouteHandler.swift
//  APIClient
//
//  Created by Christoph Pageler on 15.04.20.
//


import Foundation
import NIO
import NIOFoundationCompat
import NIOHTTP1
import AsyncHTTPClient


public protocol APIRouteHandler {

    var baseURL: URL { get set }

    var eventLoop: EventLoop { get set }

    func headers() -> HTTPHeaders

    func headers(_ headers: [String: String]) -> HTTPHeaders

    func headers(token: String?) -> HTTPHeaders

    func headers(token: String?, other: [String: String]) -> HTTPHeaders

    // MARK: - Get

    func get<Body: Codable, T: Decodable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<T>

    func get<T: Decodable>(_ path: String, headers: HTTPHeaders) -> EventLoopFuture<T>

    func get<T: Decodable>(_ path: String) -> EventLoopFuture<T>

    func getData(baseURL: URL?, _ path: String) -> EventLoopFuture<Data>

    // MARK: - Post

    func post<Body: Codable, T: Decodable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<T>

    func post<T: Decodable>(_ path: String, headers: HTTPHeaders) -> EventLoopFuture<T>

    func post<Body: Codable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<Void>

    func post(_ path: String, headers: HTTPHeaders, data: Data) -> EventLoopFuture<Void>

    func post(_ path: String, headers: HTTPHeaders) -> EventLoopFuture<Void>

    // MARK: - Put

    func put<Body: Codable, T: Decodable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<T>

    func put<T: Decodable>(_ path: String, headers: HTTPHeaders) -> EventLoopFuture<T>

    func put<Body: Codable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<Void>

    func put(_ path: String, headers: HTTPHeaders, data: Data) -> EventLoopFuture<Void>

    func put(_ path: String, headers: HTTPHeaders) -> EventLoopFuture<Void>

    // MARK: - Patch

    func patch<Body: Codable, T: Decodable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<T>

    func patch<Body: Codable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<Void>

    // MARK: - Delete

    func delete<Body: Codable, T: Decodable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<T>

    func delete<Body: Codable>(_ path: String, headers: HTTPHeaders, body: Body) -> EventLoopFuture<Void>

    func delete(_ path: String, headers: HTTPHeaders) -> EventLoopFuture<Void>

}
