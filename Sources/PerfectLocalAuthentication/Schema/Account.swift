//
//  Account.swift
//  Perfect-OAuth2-Server
//
//  Created by Jonathan Guthrie on 2017-02-06.
//
//

import StORM
import PostgresStORM
import SwiftRandom
import PerfectSMTP

public class Account: PostgresStORM {
	public var id			  = ""
	public var username		  = ""
	public var password		  = ""
	public var email		  = ""
	public var usertype: AccountType = .provisional
	public var source		  = "local"	// local, facebook, etc
	public var remoteid		  = ""		// if oauth then the sourceid is stored here
	public var passvalidation = ""
    public var passreset      = ""

	public var detail		  = [String:Any]()

	let _r = URandom()

	public static func setup(_ str: String = "") {
		do {
			let obj = Account()
			try obj.setup(str)

			// Account migrations:
			// 1.3.1->1.4
			let _ = try? obj.sql("ALTER TABLE account ADD COLUMN source text;", params: [])
			let _ = try? obj.sql("ALTER TABLE account ADD COLUMN remoteid text;", params: [])
            let _ = try? obj.sql("ALTER TABLE account ADD COLUMN passreset text;", params: [])

		} catch {
			// nothing
		}
	}

	override public func to(_ this: StORMRow) {
		id              = this.data["id"] as? String				?? ""
		username		= this.data["username"] as? String			?? ""
		password        = this.data["password"] as? String			?? ""
		email           = this.data["email"] as? String				?? ""
		usertype        = AccountType.from((this.data["usertype"] as? String)!)
		source          = this.data["source"] as? String			?? "local"
		remoteid        = this.data["remoteid"] as? String			?? ""
		passvalidation	= this.data["passvalidation"] as? String	?? ""
        passreset       = this.data["passreset"] as? String         ?? ""

		if let detailObj = this.data["detail"] {
			self.detail = detailObj as? [String:Any] ?? [String:Any]()
		}
	}

	public func rows() -> [Account] {
		var rows = [Account]()
		for i in 0..<self.results.rows.count {
			let row = Account()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

	public override init() {
		super.init()
	}

	public init(
		_ i: String = "",
		_ u: String,
		_ p: String = "",
		_ e: String,
		_ ut: AccountType = .provisional,
		_ s: String = "local",
		_ rid: String = ""
		) {
		super.init()
		id = i
		username = u
		password = p
		email = e
		usertype = ut
		passvalidation = _r.secureToken
        passreset = _r.secureToken
		source = s
		remoteid = rid
	}

	public init(validation: String) {
		super.init()
		try? find(["passvalidation": validation])
	}
    
    public init(reset: String) {
        super.init()
        try? find(["passreset": reset])
    }

	public func makeID() {
		id = _r.secureToken
	}

	public func makePassword(_ p1: String) {
		if let digestBytes = p1.digest(.sha256),
			let hexBytes = digestBytes.encode(.hex),
			let hexBytesStr = String(validatingUTF8: hexBytes) {
			password = hexBytesStr
		}
	}

	public func isUnique() throws {
		// checks for email address already existing
		let this = Account()
		//		let thisUsername = Account()
		do {
			try this.find(["email":email])
			if this.results.cursorData.totalRecords > 0 {
				//				print("failing unique test")
				throw OAuth2ServerError.invalidEmail
			}
		} catch {
			//			print(error)
			throw OAuth2ServerError.invalidEmail
		}
	}

	// Register User
	public static func register(_ u: String, _ e: String, _ ut: AccountType = .provisional, baseURL: String) -> OAuth2ServerError {
		let r = URandom()
		let acc = Account(r.secureToken, u, "", e, ut)
		do {
			try acc.isUnique()
			//			print("passed unique test")
			try acc.create()
		} catch {
			print(error)
			return .registerError
		}

		var h = "<p>Welcome to your new account</p>"
		h += "<p>To get started with your new account, please <a href=\"\(baseURL)/verifyAccount/\(acc.passvalidation)\">click here</a></p>"
		h += "<p>If the link does not work copy and paste the following link into your browser:<br>\(baseURL)/verifyAccount/\(acc.passvalidation)</p>"

		var t = "Welcome to your new account\n"
		t += "To get started with your new account, please click here: \(baseURL)/verifyAccount/\(acc.passvalidation)"


		Utility.sendMail(name: u, address: e, subject: "Welcome to your account", html: h, text: t)

		return .noError
	}
    
    /// Reset Password
    /// - Parameter e: email address
    /// - Parameter baseURL: base url to create the reset pass url
    public static func resetPassword(_ e: String, baseURL: String) -> OAuth2ServerError {
        let r = URandom()
        let acc = Account()
        do {
            try acc.find(["email": e])
            acc.passreset = r.secureToken
            acc.email = e
            try acc.save()
        } catch {
            print(error)
            return .invalidEmail
        }
        
        var h = "<p>Forgotten password reset</p>"
        h += "<p>You requested a new password <a href=\"\(baseURL)/verifyPassReset/\(acc.passreset)\">click here</a></p>"
        h += "<p>If the link does not work copy and paste the following link into your browser:<br>\(baseURL)/resetPassword/\(acc.passreset)</p>"
        
        var t = "Forgotten password reset\n"
        t += "You requested a new password, please click here: \(baseURL)/verifyPassReset/\(acc.passreset)"
        
        Utility.sendMail(name: "", address: e, subject: "Password reset request", html: h, text: t)
        
        return .noError
    }

	// Register User
	public static func login(_ u: String, _ p: String) throws -> Account {
		if let digestBytes = p.digest(.sha256),
			let hexBytes = digestBytes.encode(.hex),
			let hexBytesStr = String(validatingUTF8: hexBytes) {

			let acc = Account()
			let criteria = ["username":u,"password":hexBytesStr]
			do {
				try acc.find(criteria)
				if acc.usertype == .provisional {
					throw OAuth2ServerError.loginError
				}
				return acc
			} catch {
				print(error)
				throw OAuth2ServerError.loginError
			}
		} else {
			throw OAuth2ServerError.loginError
		}
	}

	public static func listUsers() -> [[String: Any]] {
		var users = [[String: Any]]()
		let t = Account()
		let cursor = StORMCursor(limit: 9999999,offset: 0)
		try? t.select(
			columns: [],
			whereclause: "true",
			params: [],
			orderby: ["username"],
			cursor: cursor
		)


		for row in t.rows() {
			var r = [String: Any]()
			r["id"] = row.id
			r["username"] = row.username
			r["email"] = row.email
			r["usertype"] = row.usertype
			r["detail"] = row.detail
			r["source"] = row.source
			r["remoteid"] = row.remoteid
			users.append(r)
		}
		return users
	}

	public func isAdmin() -> Bool {
		switch usertype {
		case .admin, .admin1, .admin2, .admin3:
			return true
		default:
			return false
		}
	}
}

public enum AccountType {
	case provisional, standard, inactive, admin, admin1, admin2, admin3

	public static func from(_ str: String) -> AccountType {
		switch str {
		case "admin":
			return .admin
		case "admin1":
			return .admin1
		case "admin2":
			return .admin2
		case "admin3":
			return .admin3
		case "standard":
			return .standard
		case "inactive":
			return .inactive
		default:
			return .provisional
		}
	}
}

