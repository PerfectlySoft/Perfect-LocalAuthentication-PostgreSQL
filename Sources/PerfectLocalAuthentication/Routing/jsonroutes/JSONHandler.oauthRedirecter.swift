//
//  JSONHandler.oauthRedirecter.swift
//  LocalAuthentication
//
//  Created by Jonathan Guthrie on 2017-07-14.
//

import PerfectHTTP

extension LocalAuthJSONHandlers {

	/// Helps with OAuth2 redirection for iOS apps
	public static func oAuthRedirecter(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			var str = [String]()
			for param in request.params() {
				str.append("\(param.0)=\(param.1)")
			}

			let provider = request.urlVariables["provider"] ?? ""


//			print("REDIRECTING TO: \(LocalAuthConfig.OAuthAppNameScheme)/\(provider)?\(str.joined(separator: "&"))")
			//			print("REDIRECTING TO: oauth-swift://oauth-callback/facebook?\(str.joined(separator: "&"))")
			response.status = .movedPermanently
			//			response.setHeader(.location, value: "oauth-swift://oauth-callback/facebook?\(str.joined(separator: "&"))")
			response.setHeader(.location, value: "\(LocalAuthConfig.OAuthAppNameScheme)/\(provider)?\(str.joined(separator: "&"))")
			response.completed()
		}
	}
}

