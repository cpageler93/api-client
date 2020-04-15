//
//  TestGitHubClient.swift
//  APIClientTests
//
//  Created by Christoph Pageler on 15.04.20.
//


import Foundation
import NIO
import NIOHTTP1
import APIClient


class TestGitHubClient: APIClient {

    public var user: UserRoutes!

    init() {
        super.init(baseURL: URL(string: "https://api.github.com")!)
        user = UserRoutes(apiHandler: self.handler)
    }

}


struct UserRoutes {

    let apiHandler: APIRouteHandler

    func repositories(owner: String) -> EventLoopFuture<[Repository]> {
        return apiHandler.get("/users/\(owner)/repos", headers: apiHandler.githubHeader())
    }

}


struct Repository: Codable {

    var id: Int
    var name: String?
    var fullName: String?

}


private extension APIRouteHandler {

    func githubHeader() -> HTTPHeaders {
        return headers(["User-Agent": "Swift GitHub Client"])
    }

}
