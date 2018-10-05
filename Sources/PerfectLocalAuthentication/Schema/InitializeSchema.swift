//
//  InitializeSchema.swift
//  Perfect-OAuth2-Server
//
//  Created by Jonathan Guthrie on 2017-02-06.
//
//
import PerfectLib
import StORM
import PostgresStORM
import JSONConfig
import PerfectSessionPostgreSQL

public func initializeSchema(_ fname: String = "./config/ApplicationConfiguration.json") -> [String:Any] {
	var opts = [String:Any]()

    guard let config = JSONConfig(name: fname), let dict =  config.getValues() else {
        print("⚠️ Unable to get Configuration or data at path \(fname)")
        setFallbackOpts()
        return opts
    }

    opts["httpPort"] = dict["httpport"] as! Int
    opts["baseURL"] = dict["baseURL"] as? String ?? ""
    setOpts(config: dict)

    performSetup()

	return opts
}

/**
 initializeSchema takes a dictionary using tme keys names as ApplicationConfiguration.json
 */
public func initializeSchema(_ dict: [String: Any]) -> [String:Any] {
    var opts = [String:Any]()
    opts["httpPort"] = dict["httpport"] as! Int
    opts["baseURL"] = dict["baseURL"] as? String ?? ""
    setOpts(config: dict)

    performSetup()

    return opts
}


fileprivate func performSetup(){
//    StORMdebug = true
    // Account
    PostgresConnector.quiet = true
    Account.setup()
    PostgresConnector.quiet = false
}


//
fileprivate func setFallbackOpts(){
    PostgresConnector.host        = "localhost"
    PostgresConnector.username    = "perfect"
    PostgresConnector.password    = "perfect"
    PostgresConnector.database    = "perfect_testing"
    PostgresConnector.port        = 5432
}

public func setOpts(config dict: [String: Any]) {
    // StORM Connector Config
    PostgresConnector.host        = dict["postgreshost"] as? String ?? ""
    PostgresConnector.username    = dict["postgresuser"] as? String ?? ""
    PostgresConnector.password    = dict["postgrespwd"] as? String ?? ""
    PostgresConnector.database    = dict["postgresdbname"] as? String ?? ""
    PostgresConnector.port        = dict["postgresport"] as? Int ?? 0

    // Outbound email config
    SMTPConfig.mailserver         = dict["mailserver"] as? String ?? ""
    SMTPConfig.mailuser              = dict["mailuser"] as? String ?? ""
    SMTPConfig.mailpass              = dict["mailpass"] as? String ?? ""
    SMTPConfig.mailfromaddress    = dict["mailfromaddress"] as? String ?? ""
    SMTPConfig.mailfromname        = dict["mailfromname"] as? String ?? ""

    AuthenticationVariables.baseURL = dict["baseURL"] as? String ?? ""

    // session driver config
    PostgresSessionConnector.host = PostgresConnector.host
    PostgresSessionConnector.port = PostgresConnector.port
    PostgresSessionConnector.username = PostgresConnector.username
    PostgresSessionConnector.password = PostgresConnector.password
    PostgresSessionConnector.database = PostgresConnector.database
    PostgresSessionConnector.table = "sessions"
}

