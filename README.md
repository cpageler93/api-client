# APIClient

![Swift](https://img.shields.io/badge/Swift-5.2-orange.svg?style=flat)
![Xcode](https://img.shields.io/badge/Xcode-11-blue.svg?style=flat)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/cpageler93/api-client/blob/master/LICENSE)
[![Twitter: @cpageler93](https://img.shields.io/badge/contact-@cpageler93-blue.svg?style=flat)](https://twitter.com/cpageler93)

`APIClient` is an easy to use HTTP Client for Swift.

## Usage Example (GitHub)


### Call your APIs like this

```swift
let githubClient = TestGitHubClient()
let repos = try githubClient.user.repositories(owner: "cpageler93").wait()
```

### GitHub API Client (simplified)

```swift
import Foundation
import NIO
import NIOHTTP1
import APIClient


// Define your clients routes

class TestGitHubClient: APIClient {

    public var user: UserRoutes!

    init() {
        super.init(baseURL: URL(string: "https://api.github.com")!)
        user = UserRoutes(apiHandler: self.handler)
    }

}

// Define single routes

struct UserRoutes {

    let apiHandler: APIRouteHandler

    func repositories(owner: String) -> EventLoopFuture<[Repository]> {
        return apiHandler.get("/users/\(owner)/repos", headers: apiHandler.githubHeader())
    }

}


// Codable DTOs

struct Repository: Codable {

    var id: Int
    var name: String?
    var fullName: String?

}


// Header Helper

private extension APIRouteHandler {

    func githubHeader() -> HTTPHeaders {
        return headers(["User-Agent": "Swift GitHub Client"])
    }

}

```

## Need Help?

Please [submit an issue](https://github.com/cpageler93/api-client/issues) on GitHub or contact me via Mail or Twitter.

## License

This project is licensed under the terms of the MIT license. See the [LICENSE](LICENSE) file.