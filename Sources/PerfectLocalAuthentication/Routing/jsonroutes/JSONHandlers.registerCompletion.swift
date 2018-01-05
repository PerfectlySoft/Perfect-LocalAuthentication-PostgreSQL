//
//  JSONHandlers.registerCompletion.swift
//  Perfect-LocalAuthentication-PostgreSQL
//
//  Created by Fatih Nayebi on 2017-12-15.
//

import PerfectHTTP
import PerfectSession
import PerfectCrypto
import PerfectSessionPostgreSQL

extension LocalAuthJSONHandlers {
    
    // POST request to finalize the registration process
    public static func registerCompletion(data: [String: Any]) throws -> RequestHandler {
        return {
            request, response in
            
            if let userId = request.session?.userid, !userId.isEmpty {
                _ = try? response.setBody(json: ["msg": "Already logged in"])
                response.completed()
                return
            }
            
            guard let postBody = request.postBodyString, !postBody.isEmpty else {
                LocalAuthHandlers.error(request, response, error: "Registration Verification Error: request data is incomplete", code: .badRequest)
                return
            }
            
            do {
                let postBodyJSON = try postBody.jsonDecode() as? [String: String] ?? [String: String]()
                
                guard let passValidation = postBodyJSON["passvalidation"] else {
                    LocalAuthHandlers.error(request, response, error: "Account Validation Error: Please provide the token", code: .badRequest)
                    return
                }
                
                let acc = Account(validation: passValidation)
                if acc.id.isEmpty {
                    LocalAuthHandlers.error(request, response, error: "Account Not Found", code: .notFound)
                    return
                } else {
                    if let p1 = postBodyJSON["p1"], !p1.isEmpty,
                        let p2 = postBodyJSON["p2"], !p2.isEmpty,
                        p1 == p2 {
                        acc.makePassword(p1)
                        acc.usertype = .standard
                        do {
                            try acc.save()
                            request.session?.userid = acc.id
                            _ = try response.setBody(json: ["error": "Account Validation Success", "msg": "Account Validated and Completed.", "userId": acc.id])
                            response.completed()
                            return
                        } catch {
                            print(error)
                        }
                    } else {
                        do {
                            _ = try response.setBody(json: ["error": "Account Validation Error", "msg": "The passwords must not be empty, and must match."])
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

