//
//  JSONHandler.me.swift
//  LocalAuthentication
//
//  Created by Jonathan Guthrie on 2017-07-06.
//

import PerfectHTTP
import PerfectSession
import PerfectCrypto
import PerfectSessionPostgreSQL


extension LocalAuthJSONHandlers {

	// GET request for current user info
	public static func me(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			if let i = request.session?.userid, !i.isEmpty {
				let acc = Account()
				do {
					try acc.get(i)
					_ = try? response.setBody(json: [
						"userid":acc.id,
						"username":acc.username,
						"email":acc.email,
                        "details":acc.detail,
						"usertype":"\(acc.usertype)"
						])
					response.completed()
					return
				} catch {
					LocalAuthHandlers.error(request, response, error: "AccountError", code: .badRequest)
					return
				}
			} else {
				LocalAuthHandlers.error(request, response, error: "NotLoggedIn", code: .badRequest)
				return
			}
		}
	}

}
