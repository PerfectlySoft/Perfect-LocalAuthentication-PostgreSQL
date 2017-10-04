//
//  JSONHandlers.login.swift
//  Perfect-OAuth2-Server
//
//  Created by Jonathan Guthrie on 2017-04-26.
//
//

import PerfectHTTP
import PerfectSession
import PerfectCrypto
import PerfectSessionPostgreSQL


extension LocalAuthJSONHandlers {
	
	// POST request for login form
	public static func login(data: [String:Any]) throws -> RequestHandler {
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
						"usertype":"\(acc.usertype)",
						"error":"Login Success",
						"msg":"Already logged in"
						])
					response.completed()
					return
				} catch {
					LocalAuthHandlers.error(request, response, error: "Login Failure", code: .badRequest)
					return
				}
			}


			if let postBody = request.postBodyString, !postBody.isEmpty {
				do {
					let postBodyJSON = try postBody.jsonDecode() as? [String: String] ?? [String: String]()
					if let u = postBodyJSON["username"], !u.isEmpty,
						let p = postBodyJSON["password"], !p.isEmpty {

						do{
							let acc = try Account.login(u, p)
							request.session?.userid = acc.id
							_ = try response.setBody(json: [
								"userid":acc.id,
								"username":acc.username,
								"email":acc.email,
								"usertype":"\(acc.usertype)",
								"error":"Login Success"
								])
							response.completed()
							return
						} catch {
							LocalAuthHandlers.error(request, response, error: "Login Failure", code: .badRequest)
							return
						}
					} else {
						LocalAuthHandlers.error(request, response, error: "Please supply a username and password", code: .badRequest)
						return
					}
				} catch {
					LocalAuthHandlers.error(request, response, error: "Invalid JSON", code: .badRequest)
					return
				}
			} else {
				LocalAuthHandlers.error(request, response, error: "Login Error: Insufficient Data", code: .badRequest)
				return
			}
		}
	}
	

}
