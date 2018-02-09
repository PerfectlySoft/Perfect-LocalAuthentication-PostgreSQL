# Perfect Local Authentication (PostgreSQL) [简体中文](README.zh_CN.md)

[![Perfect logo](http://www.perfect.org/github/Perfect_GH_header_854.jpg)](http://perfect.org/get-involved.html)

[![Perfect logo](http://www.perfect.org/github/Perfect_GH_button_1_Star.jpg)](https://github.com/PerfectlySoft/Perfect)
[![Perfect logo](http://www.perfect.org/github/Perfect_GH_button_2_Git.jpg)](https://gitter.im/PerfectlySoft/Perfect)
[![Perfect logo](http://www.perfect.org/github/Perfect_GH_button_3_twit.jpg)](https://twitter.com/perfectlysoft)
[![Perfect logo](http://www.perfect.org/github/Perfect_GH_button_4_slack.jpg)](http://perfect.ly)


[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms OS X | Linux](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![License Apache](https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat)](http://perfect.org/licensing.html)
[![Twitter](https://img.shields.io/badge/Twitter-@PerfectlySoft-blue.svg?style=flat)](http://twitter.com/PerfectlySoft)
[![Join the chat at https://gitter.im/PerfectlySoft/Perfect](https://img.shields.io/badge/Gitter-Join%20Chat-brightgreen.svg)](https://gitter.im/PerfectlySoft/Perfect?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Slack Status](http://perfect.ly/badge.svg)](http://perfect.ly) [![GitHub version](https://badge.fury.io/gh/PerfectlySoft%2FPerfect-CURL.svg)](https://badge.fury.io/gh/PerfectlySoft%2FPerfect-CURL)

## Perfect Local Authentication (PostgreSQL) Library


This package provides Local Authentication libraries for projects that require locally stored and handled authentication.

Full documentation can be found at [http://www.perfect.org/docs/authentication.html](http://www.perfect.org/docs/authentication.html.html)

A template application can be found at [https://github.com/PerfectlySoft/Perfect-Local-Auth-PostgreSQL-Template](https://github.com/PerfectlySoft/Perfect-Local-Auth-PostgreSQL-Template), providing a fully functional starting point, as well as demonstrating the usage of the system.

This package builds with Swift Package Manager and is part of the [Perfect](https://github.com/PerfectlySoft/Perfect) project. It was written to be stand-alone and so does not require PerfectLib or any other components.

Ensure you have installed and activated the latest Swift 3.x tool chain.

## Adding to your project

Add this project as a dependency in your Package.swift file.

``` swift
.Package(url: "https://github.com/PerfectlySoft/Perfect-LocalAuthentication-PostgreSQL.git", majorVersion: 1)
```

To then use the LocalAuthentication module in your code:

``` swift
import LocalAuthentication
```

## Configuration

It is important to configure the following in main.swift to set up database and session configuration:

Import the required modules:

``` swift
import PerfectSession
import PerfectSessionPostgreSQL
import PerfectCrypto
import LocalAuthentication
```

Initialize PerfectCrypto:

``` swift
let _ = PerfectCrypto.isInitialized
```

Now set some defaults:

``` swift
// Used in email communications
// The Base link to your system, such as http://www.example.com/
var baseURL = ""

// Configuration of Session
SessionConfig.name = "perfectSession" // <-- change
SessionConfig.idle = 86400
SessionConfig.cookieDomain = "localhost" //<-- change
SessionConfig.IPAddressLock = false
SessionConfig.userAgentLock = false
SessionConfig.CSRF.checkState = true
SessionConfig.CORS.enabled = true
SessionConfig.cookieSameSite = .lax
```

Detailed Session configuration documentation can be dound at [https://www.perfect.org/docs/sessions.html](https://www.perfect.org/docs/sessions.html)

The database and email configurations should be set as follows (if using JSON file config):

``` swift
let opts = initializeSchema("./config/ApplicationConfiguration.json") // <-- loads base config like db and email configuration
httpPort = opts["httpPort"] as? Int ?? httpPort
baseURL = opts["baseURL"] as? String ?? baseURL
```

Otherwise, these will need to be set equivalent to this function [https://github.com/PerfectlySoft/Perfect-LocalAuthentication-PostgreSQL/blob/master/Sources/LocalAuthentication/Schema/InitializeSchema.swift](https://github.com/PerfectlySoft/Perfect-LocalAuthentication-PostgreSQL/blob/master/Sources/LocalAuthentication/Schema/InitializeSchema.swift).

Set the session driver:

``` swift
let sessionDriver = SessionPostgresDriver()
```

### Request & Response Filters

The following two session filters need to be added to your server config:

``` swift
// (where filter is a [[String: Any]] object)
filters.append(["type":"request","priority":"high","name":SessionPostgresFilter.filterAPIRequest])
filters.append(["type":"response","priority":"high","name":SessionPostgresFilter.filterAPIResponse])
```

For example, see [https://github.com/PerfectlySoft/Perfect-Local-Auth-PostgreSQL-Template/blob/master/Sources/PerfectLocalAuthPostgreSQLTemplate/configuration/Filters.swift](https://github.com/PerfectlySoft/Perfect-Local-Auth-PostgreSQL-Template/blob/master/Sources/PerfectLocalAuthPostgreSQLTemplate/configuration/Filters.swift)

### Add routes for login, register etc

The following routes can be added as needed or customized to add login, logout, register:

``` swift
// Login
routes.append(["method":"get", "uri":"/login", "handler":Handlers.login]) // simply a serving of the login GET
routes.append(["method":"post", "uri":"/login", "handler":LocalAuthWebHandlers.login])
routes.append(["method":"get", "uri":"/logout", "handler":LocalAuthWebHandlers.logout])

// Register
routes.append(["method":"get", "uri":"/register", "handler":LocalAuthWebHandlers.register])
routes.append(["method":"post", "uri":"/register", "handler":LocalAuthWebHandlers.registerPost])
routes.append(["method":"get", "uri":"/verifyAccount/{passvalidation}", "handler":LocalAuthWebHandlers.registerVerify])
routes.append(["method":"post", "uri":"/registrationCompletion", "handler":LocalAuthWebHandlers.registerCompletion])

// JSON
routes.append(["method":"get", "uri":"/api/v1/session", "handler":LocalAuthJSONHandlers.session])
routes.append(["method":"get", "uri":"/api/v1/logout", "handler":LocalAuthJSONHandlers.logout])
routes.append(["method":"post", "uri":"/api/v1/register", "handler":LocalAuthJSONHandlers.register])
routes.append(["method":"login", "uri":"/api/v1/login", "handler":LocalAuthJSONHandlers.login])
```

An example can be found at [https://github.com/PerfectlySoft/Perfect-Local-Auth-PostgreSQL-Template/blob/master/Sources/PerfectLocalAuthPostgreSQLTemplate/configuration/Routes.swift](https://github.com/PerfectlySoft/Perfect-Local-Auth-PostgreSQL-Template/blob/master/Sources/PerfectLocalAuthPostgreSQLTemplate/configuration/Routes.swift)

## Testing for authentication:

The user id can be accessed as follows:

``` swift
request.session?.userid ?? ""
```

If a user id (i.e. logged in state) is required to access a page, code such as this could be used to detect and redirect:

``` swift
let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
if !contextAuthenticated { response.redirect(path: "/login") }
```

## Further Information
For more information on the Perfect project, please visit [perfect.org](http://perfect.org).
