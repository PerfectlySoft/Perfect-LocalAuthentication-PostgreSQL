//
//  AccessToken.swift
//  Perfect-OAuth2-Server
//
//  Created by Jonathan Guthrie on 2017-02-06.
//
//

import StORM
import PostgresStORM
import Foundation
import SwiftRandom
import SwiftMoment

public class AccessToken: PostgresStORM {
	public var accesstoken		= ""
	public var refreshtoken		= ""
	public var userid			= ""
	public var clientid			= ""
	public var expires			= 0
	public var scope			= ""

	var _rand = URandom()

	public static func setup(_ str: String = "") {
		do {
			let obj = AccessToken()
			try obj.setup(str)

			// Migrations
			let _ = try obj.sql("ALTER TABLE accesstoken ADD COLUMN clientid text", params: [])

		} catch {
			// nothing
		}
	}


	public override init(){}

	// no clientid
	public init(userid u: String, expiration: Int, scope s: [String] = [String]()) {
		accesstoken = _rand.secureToken
		refreshtoken = _rand.secureToken
		userid = u
		expires = Int(moment().epoch()) + (expiration * 1000)
		scope = s.isEmpty ? "" : s.joined(separator: " ")
	}

	// with clientid
	public init(userid u: String, clientid c: String, expiration: Int, scope s: [String] = [String]()) {
		accesstoken = _rand.secureToken
		refreshtoken = _rand.secureToken
		clientid = c
		userid = u
		expires = Int(moment().epoch()) + (expiration * 1000)
		scope = s.isEmpty ? "" : s.joined(separator: " ")
	}

	public func isCurrent() -> Bool {
		if Int(moment().epoch()) > expires { return false }
		return true
	}

	override public func to(_ this: StORMRow) {
		accesstoken     = this.data["accesstoken"] as? String	?? ""
		refreshtoken	= this.data["refreshtoken"] as? String	?? ""
		userid			= this.data["userid"] as? String		?? ""
		clientid		= this.data["clientid"] as? String		?? ""
		expires			= this.data["expires"] as? Int			?? 0
		scope			= this.data["scope"] as? String			?? ""
	}

	public func rows() -> [AccessToken] {
		var rows = [AccessToken]()
		for i in 0..<self.results.rows.count {
			let row = AccessToken()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

}


