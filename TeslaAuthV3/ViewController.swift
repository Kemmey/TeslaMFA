//
//  ViewController.swift
//  TeslaAuthV3
//
//  Created by Kim Hansen on 02/11/2020.
//

import UIKit
import OAuthSwift

class ViewController: UIViewController {
    
    @IBAction func authenticate(_ sender: Any) {
        authenticateV3()
    }
    
    @IBAction func getData(_ sender: Any) {
        getData()
    }
    
    @IBAction func renew(_ sender: Any) {
        renew()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    var oauthswift = OAuth2Swift(
        consumerKey: "ownerapi",
        consumerSecret: kTeslaSecret,
        authorizeUrl: "https://auth.tesla.com/oauth2/v3/authorize",
        accessTokenUrl: "https://auth.tesla.com/oauth2/v3/token",
        responseType: "code"
    )
    
    private func verifier(forKey key: String) -> String {
        let verifier = key.data(using: .utf8)!.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
        return verifier
    }
    
    private func challenge(forVerifier verifier: String) -> String {
        let hash = verifier.sha256
        let challenge = hash.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
        return challenge
    }
    
    
    var credential: OAuthSwiftCredential?
    
    func authenticateV3() {
        let codeVerifier = self.verifier(forKey: kTeslaClientID)
        let codeChallenge = self.challenge(forVerifier: codeVerifier)
        
        let internalController = WebViewController()
        //        internalController.callbackURL = "https://auth.tesla.com/void/callback"
        //        internalController.callingViewController = self
        oauthswift.authorizeURLHandler = internalController
        //        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
        let state = generateState(withLength: 20)
        
        oauthswift.authorize(withCallbackURL: "https://auth.tesla.com/void/callback", scope: "openid email offline_access", state: state, codeChallenge: codeChallenge, codeChallengeMethod: "S256", codeVerifier: codeVerifier) { result in
            switch result {
            case .success(let (credential, _, _)):
                print(credential.oauthToken)
                self.credential = credential
                //self.getData(token: credential.oauthToken)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func renew() {
        let refreshToken = credential?.oauthRefreshToken ?? ""
        //{
            var parameters = OAuthSwift.Parameters()
            parameters["scope"] = "openid email offline_access"
            oauthswift.renewAccessToken(withRefreshToken: refreshToken, parameters: parameters) { (result) in
                switch result {
                case .success(let (credential, _, _)):
                    print(credential.oauthToken)
                case .failure(let error):
                    print(error)
                }
            }
        //}
    }
    
    func getData() {
        oauthswift.startAuthorizedRequest("https://owner-api.teslamotors.com/api/1/vehicles", method: .GET, parameters: OAuthSwift.Parameters()) { (result) in
            print(result)
        }
    }
    
    func getData(token: String) {
        // Create URL
        let url = URL(string: "https://owner-api.teslamotors.com/api/1/vehicles")
        guard let requestUrl = url else { fatalError() }

        // Create URL Request
        var request = URLRequest(url: requestUrl)

        // Specify HTTP Method to use
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Send HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }
            
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
            }
            
        }
        task.resume()    }
    
}

