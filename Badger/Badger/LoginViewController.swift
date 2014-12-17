import UIKit

class LoginViewController: UIViewController, GPPSignInDelegate {

    @IBOutlet weak var signInButton: GPPSignInButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        var signIn = GPPSignIn.sharedInstance()
        signIn.delegate = self
    }

    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if error != nil {
            println("Google auth error \(error) and auth object \(auth)")
        } else {
            // Take access token and auth with Firebase.
            Firebase(url: Global.FirebaseUrl).authWithOAuthProvider("google", token: auth.accessToken,
                withCompletionBlock: { error, authData in
                    if error != nil {
                        println("Firebase auth error \(error) and auth object \(authData)")
                    } else {
                        Helpers.saveAccessToken(auth)

                        // Check if the user already exists.
                        let user = User(uid: authData.uid, provider: authData.provider)
                        user.ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
                            // Add the user if they don't exist.
                            if snapshot.childrenCount == 0 {
                                if let profile = authData.providerData["cachedUserProfile"] as? [String: AnyObject] {
                                    user.firstName = profile["given_name"] as String
                                    user.lastName = profile["family_name"] as String
                                    user.email = profile["email"] as String
                                    // TODO: use the profile picture provided?
                                    // profile["picture"]
                                }

                                // Let device know we want to receive push notifications.
                                UIApplication.sharedApplication().registerForRemoteNotifications()

                                user.ref.setValue(user.toJson(), withCompletionBlock: { (error, ref) in
                                    self.presentViewController(Helpers.createRevealViewController(user.uid), animated: true, completion: nil)
                                });

                            } else {
                                // Transition to the home screen.
                                self.presentViewController(Helpers.createRevealViewController(authData.uid), animated: true, completion: nil)
                            }
                            // Start the UserStore listening to the authenticated user.
                            UserStore.sharedInstance().authorized({ _ in })
                        })
                    }
            })
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? UINavigationController {
            if let profileVC = vc.topViewController as? ProfileViewController {
                profileVC.setUid(Firebase(url: Global.FirebaseUrl).authData.uid)
            }
        }
    }
}
