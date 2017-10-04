import PackageDescription

let package = Package(
    name: "Perfect-LocalAuthentication-PostgreSQL",
    targets: [
		Target(
			name: "PerfectLocalAuthentication",
			dependencies: []
		)
		],
    dependencies: [
		.Package(url: "https://github.com/iamjono/JSONConfig.git", majorVersion: 3),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", majorVersion: 3),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-SMTP", majorVersion: 3),
		.Package(url: "https://github.com/SwiftORM/Postgres-StORM.git", majorVersion: 3),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Session-PostgreSQL.git", majorVersion: 3),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", majorVersion: 3),
		]

)
