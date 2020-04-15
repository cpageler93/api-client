//
//  TestGitHubClientTests.swift
//  APIClientTests
//
//  Created by Christoph Pageler on 15.04.20.
//


import XCTest


class TestGitHubClientTests: XCTestCase {

    func testGetUserRepositories() throws {
        let githubClient = TestGitHubClient()
        let repos = try githubClient.user.repositories(owner: "cpageler93").wait()
        XCTAssertGreaterThan(repos.count, 10)
    }

}
