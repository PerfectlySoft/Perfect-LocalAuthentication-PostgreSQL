//
//  JSONHandler.resetPassword.swift
//  PerfectLocalAuthentication
//
//  Created by Fatih Nayebi on 2017-12-15.
//

import PerfectHTTP
import PerfectSession
import PerfectCrypto
import PerfectSessionPostgreSQL

extension LocalAuthJSONHandlers {
    
    /// POST request to reset user password
    public static func resetPassword(data: [String: Any]) throws -> RequestHandler {
        return {
            request, response in
            
            guard let postBody = request.postBodyString, !postBody.isEmpty else {
                LocalAuthHandlers.error(request, response, error: "Password Reset Error: Please provide the email address", code: .badRequest)
                return
            }
            
            do {
                let postBodyJSON = try postBody.jsonDecode() as? [String: String] ?? [String: String]()
                if let email = postBodyJSON["email"], !email.isEmpty {
                    let err = Account.resetPassword(email, baseURL: AuthenticationVariables.baseURL)
                    if err != .noError {
                        LocalAuthHandlers.error(request, response, error: "Password Reset Error: \(err)", code: .badRequest)
                        return
                    } else {
                        _ = try response.setBody(json: ["error": "Password reset success", "msg": "Check your email for an email from us. It contains instructions to reset your password!"])
                        response.completed()
                        return
                    }
                } else {
                    LocalAuthHandlers.error(request, response, error: "Please supply a valid email address", code: .badRequest)
                    return
                }
            } catch {
                LocalAuthHandlers.error(request, response, error: "Invalid JSON", code: .badRequest)
                return
            }
        }
    }
}
