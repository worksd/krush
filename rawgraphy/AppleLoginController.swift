//
//  AppleLoginController.swift
//  rawgraphy
//
//  Created by 이동호 on 1/24/25.
//

import UIKit
import AuthenticationServices

class MyAppleLoginController: UIViewController {
    var onSuccessAppleLogin: (String) -> Void = { _ in }

    func showAppleLogin(onSuccessAppleLogin: @escaping (String) -> Void) {
        self.onSuccessAppleLogin = onSuccessAppleLogin
    
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
}

extension MyAppleLoginController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController,
                               didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName?.description
            let email = appleIDCredential.email
            let state = appleIDCredential.state

            if let authorizationCode = appleIDCredential.authorizationCode,
               let identityToken = appleIDCredential.identityToken,
               let authString = String(data: authorizationCode, encoding: .utf8),
               let tokenString = String(data: identityToken, encoding: .utf8) {
                self.onSuccessAppleLogin(tokenString)
            }
            
            print("useridentifier: \(userIdentifier)")
            print("fullName: \(fullName ?? "")")
            print("email: \(email ?? "")")
            print("state: \(state ?? "")")

        case let passwordCredential as ASPasswordCredential:
            let username = passwordCredential.user
            let password = passwordCredential.password
            print("username: \(username)")
            print("password: \(password)")

        default:
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController,
                               didCompleteWithError error: Error) {
        print("login error")
    }
}
