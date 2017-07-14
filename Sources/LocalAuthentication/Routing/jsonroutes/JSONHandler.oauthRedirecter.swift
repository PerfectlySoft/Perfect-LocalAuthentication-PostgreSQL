//
//  JSONHandler.oauthRedirecter.swift
//  LocalAuthentication
//
//  Created by Jonathan Guthrie on 2017-07-14.
//

import PerfectHTTP
import PerfectHTTPServer


extension LocalAuthJSONHandlers {

	/// Helps with OAuth2 redirection for iOS apps
	public static func oAuthRedirecter(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			var str = [String]()
			for param in request.params() {
				str.append("\(param.0)=\(param.1)")
			}
			response.status = .movedPermanently
			response.setHeader(.location, value: "\(LocalAuthConfig.OAuthAppNameScheme)?\(str.joined(separator: "&"))")
			response.completed()
		}
	}
}

