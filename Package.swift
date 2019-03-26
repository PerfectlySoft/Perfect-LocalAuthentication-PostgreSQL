// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Perfect-LocalAuthentication-PostgreSQL",
	products: [
		.library(name: "Perfect-LocalAuthentication-PostgreSQL", targets: ["Perfect-LocalAuthentication-PostgreSQL"])
	],
    dependencies: [
		.package(url: "https://github.com/iamjono/JSONConfig.git", from: "3.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", from: "3.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-SMTP.git", from: "3.0.0"),
		.package(url: "https://github.com/SwiftORM/Postgres-StORM.git", from: "3.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-Session-PostgreSQL.git", from: "3.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", from: "3.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-HTTP.git", from: "3.0.0"),
	],
	targets: [
		.target(name: "Perfect-LocalAuthentication-", dependencies: [
			"JSONConfig",
			"PerfectRequestLogger",
			"PerfectSMTP",
			"PostgresStORM",
			"PerfectSessionPostgreSQL",
			"PerfectMustache",
			"PerfectHTTP"
			])
	]
)
