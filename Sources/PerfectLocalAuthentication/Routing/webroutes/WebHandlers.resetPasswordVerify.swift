//
//  WebHandlers.resetPasswordVerify.swift
//  PerfectLocalAuthentication
//
//  Created by Alif on 8/12/18.
//

import PerfectHTTP
import PerfectSession
import PerfectCrypto
import PerfectSessionPostgreSQL

extension LocalAuthWebHandlers {
    
    /// reset verification GET
    public static func resetPasswordVerify(data: [String: Any]) throws -> RequestHandler {
        return {
            request, response in
            let t = request.session?.data["csrf"] as? String ?? ""
            if let i = request.session?.userid, !i.isEmpty { response.redirect(path: "/") }
            var context: [String : Any] = ["title": "Perfect Authentication Server"]
            
            if let r = request.urlVariables["passreset"], !(r as String).isEmpty {
                
                let acc = Account(reset: r)
                
                if acc.id.isEmpty {
                    context["msg_title"] = "Password Reset Error."
                    context["msg_body"] = ""
                    response.render(template: "views/msg", context: context)
                    return
                } else {
                    context["passreset"] = r
                    context["csrfToken"] = t
                    response.render(template: "views/resetPasswordComplete", context: context)
                }
            } else {
                context["msg_title"] = "Password Reset Error."
                context["msg_body"] = "Code not found."
                response.render(template: "views/msg", context: context)
            }
        }
    }
}
