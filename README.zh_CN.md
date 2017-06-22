# Perfect Local Authentication (PostgreSQL)

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

基于PostgreSQL数据库为驱动的服务器端用户身份验证函数库

## 参考实例

请参考如下链接的模板应用程序：[https://github.com/PerfectlySoft/Perfect-Local-Auth-PostgreSQL-Template](https://github.com/PerfectlySoft/Perfect-Local-Auth-PostgreSQL-Template)，内容为完整的函数使用方法展示。

## 添加组件

欲使用本函数库，请选择如下适当的模块并追加到您项目的Package.swift文件中去。

``` swift
.Package(url: "https://github.com/PerfectlySoft/Perfect-LocalAuthentication-PostgreSQL.git", majorVersion: 1)
```
## 模块配置

具体使用之前，请务必做好模块配置工作（以下例子假设您使用main.swift作为程序入口）。首先导入函数库：

``` swift
import PerfectSession
import PerfectSessionPostgreSQL
import PerfectCrypto
import LocalAuthentication
```

然后请初始化 PerfectCrypto 加密函数库：

``` swift
let _ = PerfectCrypto.isInitialized
```

设置默认选项：

``` swift
// 以下配置在电子邮件系统中会用上。
// 请设置链接到您自己系统主页的基本地址，比如 http://www.example.com/
var baseURL = ""

// 配置会话过程
SessionConfig.name = "perfectSession" // <-- 请自行设定名称
SessionConfig.idle = 86400
SessionConfig.cookieDomain = "localhost" //<-- 请自行设定主机名
SessionConfig.IPAddressLock = false
SessionConfig.userAgentLock = false
SessionConfig.CSRF.checkState = true
SessionConfig.CORS.enabled = true
SessionConfig.cookieSameSite = .lax
```

详细的会话过程文档请参考 [https://www.perfect.org/docs/sessions_zh_CN.html](https://www.perfect.org/docs/sessions_zh_CN.html)

数据库和电邮配置方法参考如下（假设您使用JSON进行配置）：

``` swift
let opts = initializeSchema("./config/ApplicationConfiguration.json") // <-- 该JSON文件包含数据库和邮件配置信息
httpPort = opts["httpPort"] as? Int ?? httpPort
baseURL = opts["baseURL"] as? String ?? baseURL
```

否则，请使用下列函数完成等价的配置：

* PostgreSQL: [https://github.com/PerfectlySoft/Perfect-LocalAuthentication-PostgreSQL/blob/master/Sources/LocalAuthentication/Schema/InitializeSchema.swift](https://github.com/PerfectlySoft/Perfect-LocalAuthentication-PostgreSQL/blob/master/Sources/LocalAuthentication/Schema/InitializeSchema.swift)

### 设置会话数据库驱动

``` swift
let sessionDriver = SessionPostgresDriver()
```

### 设置请求/响应过滤器

下列两个会话过滤器需要追加到您服务器的配置中：

``` swift
// (where filter is a [[String: Any]] object)
filters.append(["type":"request","priority":"high","name":SessionPostgresFilter.filterAPIRequest])
filters.append(["type":"response","priority":"high","name":SessionPostgresFilter.filterAPIResponse])
```

关于过滤器的使用，请参考范例： [https://github.com/PerfectlySoft/Perfect-Local-Auth-PostgreSQL-Template/blob/master/Sources/PerfectLocalAuthPostgreSQLTemplate/configuration/Filters.swift](https://github.com/PerfectlySoft/Perfect-Local-Auth-PostgreSQL-Template/blob/master/Sources/PerfectLocalAuthPostgreSQLTemplate/configuration/Filters.swift)

### 追加注册及登录函数

请将下列函数句柄追加到服务器路由，用于实现注册、登录和注销命令。

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

详细例子可以参考这里： [https://github.com/PerfectlySoft/Perfect-Local-Auth-PostgreSQL-Template/blob/master/Sources/PerfectLocalAuthPostgreSQLTemplate/configuration/Routes.swift](https://github.com/PerfectlySoft/Perfect-Local-Auth-PostgreSQL-Template/blob/master/Sources/PerfectLocalAuthPostgreSQLTemplate/configuration/Routes.swift)

## 测试验证模块是否工作

如果配置成功，您可以通过下列方式获取用户身份编号：

``` swift
request.session?.userid ?? ""
```

如果在具体页面实现中需要用户处于登录状态，您可以用下列代码测试用户是否登录；如果没有登录则自动调用登录过程：

``` swift
let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
if !contextAuthenticated { response.redirect(path: "/login") }
```


### 问题报告、内容贡献和客户支持

我们目前正在过渡到使用JIRA来处理所有源代码资源合并申请、修复漏洞以及其它有关问题。因此，GitHub 的“issues”问题报告功能已经被禁用了。

如果您发现了问题，或者希望为改进本文提供意见和建议，[请在这里指出](http://jira.perfect.org:8080/servicedesk/customer/portal/1).

在您开始之前，请参阅[目前待解决的问题清单](http://jira.perfect.org:8080/projects/ISS/issues).

## 更多信息
关于本项目更多内容，请参考[perfect.org](http://perfect.org).

## 扫一扫 Perfect 官网微信号
<p align=center><img src="https://raw.githubusercontent.com/PerfectExamples/Perfect-Cloudinary-ImageUploader-Demo/master/qr.png"></p>
