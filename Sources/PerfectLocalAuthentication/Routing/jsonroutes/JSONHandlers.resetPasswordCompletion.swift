//
//  JSONHandlers.resetPasswordCompletion.swift
//  Perfect-LocalAuthentication-PostgreSQL
//
//  Created by Fatih Nayebi on 2017-12-15.
//

import PerfectHTTP
import PerfectSession
import PerfectCrypto
import PerfectSessionPostgreSQL

extension LocalAuthJSONHandlers {
    
    // POST request to finalize the password reset process
    public static func resetPasswordCompletion(data: [String: Any]) throws -> RequestHandler {
        return {
            request, response in
            if let userId = request.session?.userid, !userId.isEmpty {
                _ = try? response.setBody(json: ["msg": "Already logged in"])
                response.completed()
                return
            }
            
            guard let postBody = request.postBodyString, !postBody.isEmpty else {
                LocalAuthHandlers.error(request, response, error: "Password Reset Error: request data is incomplete", code: .badRequest)
                return
            }
            
            do {
                let postBodyJSON = try postBody.jsonDecode() as? [String: String] ?? [String: String]()
                
                guard let passResetToken = postBodyJSON["passreset"] else {
                    LocalAuthHandlers.error(request, response, error: "Account Validation Error: Please provide the token", code: .badRequest)
                    return
                }
                let acc = Account(reset: passResetToken)
                if acc.id.isEmpty {
                    LocalAuthHandlers.error(request, response, error: "Account Not Found", code: .notFound)
                    return
                } else {
                    if let p1 = request.param(name: "p1"), !(p1 as String).isEmpty,
                        let p2 = request.param(name: "p2"), !(p2 as String).isEmpty,
                        p1 == p2 {
                        acc.makePassword(p1)
                        acc.usertype = .standard
                        do {
                            try acc.save()
                            request.session?.userid = acc.id
                            _ = try response.setBody(json: ["error": "Password Reset Success", "msg": "Password reset was successful.", "userId": acc.id])
                            response.completed()
                            return
                        } catch {
                            print(error)
                        }
                    } else {
                        do {
                            _ = try response.setBody(json: ["error": "Password Reset Error", "msg": "The passwords must not be empty, and must match."])
                            response.completed()
                            return
                        } catch {
                            print(error)
                        }
                        return
                    }
                }
            } catch {
                LocalAuthHandlers.error(request, response, error: "Invalid JSON", code: .badRequest)
                return
            }
        }
    }
}
