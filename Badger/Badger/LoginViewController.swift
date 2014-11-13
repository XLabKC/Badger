import UIKit

class LoginViewController: UIViewController, GPPSignInDelegate {

    @IBOutlet weak var signInButton: GPPSignInButton!

    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if error != nil {
            println("Google auth error \(error) and auth object \(auth)")
        } else {
            // Take access token and auth with Firebase.
            let ref = Firebase(url: Global.FirebaseUrl)
            ref.authWithOAuthProvider("google", token: auth.accessToken,
                withCompletionBlock: { error, authData in
                    if error != nil {
                        println("Firebase auth error \(error) and auth object \(authData)")
                    } else {
                        // Check if the user already exists.
                        let uidRef = ref.childByAppendingPath("users").childByAppendingPath(authData.uid)
                        uidRef.observeSingleEventOfType(.Value, withBlock: { snapshot in

                            // Add the user if they don't exist.
                            if snapshot.childrenCount == 0 {
                                let newUser = [
                                    "provider": authData.provider,
                                    "email": authData.providerData["email"] as? NSString as? String,
                                    "status": "green",
                                    "first_name": authData.providerData["cachedUserProfile"]?["given_name"] as? NSString as? String,
                                    "last_name": authData.providerData["cachedUserProfile"]?["family_name"] as? NSString as? String,
                                    "green_profile_image": authData.providerData["cachedUserProfile"]?["picture"] as? NSString as? String,
                                    "yellow_profile_image": authData.providerData["cachedUserProfile"]?["picture"] as? NSString as? String,
                                    "red_profile_image": authData.providerData["cachedUserProfile"]?["picture"] as? NSString as? String
                                ]
                                uidRef.setValue(newUser)
                            }

                            // Transition to the home screen.
                            self.performSegueWithIdentifier("SHOW_HOME", sender: self)
                        })
                        Global.AuthData = authData
                    }
            })
        }
    }
}
