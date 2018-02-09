//
//  Application.swift
//  Perfect-OAuth2-Server
//
//  Created by Jonathan Guthrie on 2017-02-06.
//
//

import StORM
import PostgresStORM

public class Application: PostgresStORM {
	public var id				= ""
	public var name				= ""
	public var clientid			= ""
	public var clientsecret		= ""
	public var redirecturls		= [String]()

	public static func setup(_ str: String = "") {
		do {
			let obj = Application()
			try obj.setup(str)
			let _ = try obj.sql("ALTER TABLE application ADD COLUMN redirecturls text", params: [])
		} catch {
			// nothing
		}
	}

	public func makeID() {
		id = AccessToken.generate()
	}

	override public func to(_ this: StORMRow) {
		id					= this.data["id"] as? String			?? ""
		name				= this.data["name"] as? String			?? ""
		clientid			= this.data["clientid"] as? String		?? ""
		clientsecret		= this.data["clientsecret"] as? String	?? ""
		redirecturls		= toArrayString(this.data["redirecturls"] as? String ?? "")
	}

	public func rows() -> [Application] {
		var rows = [Application]()
		for i in 0..<self.results.rows.count {
			let row = Application()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}
}

