import UIKit

class LoginViewController: UIViewController, GPPSignInDelegate {

    @IBOutlet weak var signInButton: GPPSignInButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        var signIn = GPPSignIn.sharedInstance()
        signIn.shouldFetchGooglePlusUser = true
        signIn.shouldFetchGoogleUserEmail = true
        signIn.clientID = ApiKeys.getGoogleClientId()
        signIn.scopes = []
        signIn.attemptSSO = true
        signIn.delegate = self
        signIn.trySilentAuthentication()
    }

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
                        self.redirectToProfile(authData)
                    }
            })
        }
    }

    private func redirectToProfile(authData: FAuthData!) {
        let presentInitial = { () -> () in
            // Let device know we want to receive push notifications.
            let iOS8 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)
            if iOS8 {
                // Register for push in iOS 8.
                let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound, categories: nil)
                UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                UIApplication.sharedApplication().registerForRemoteNotifications()
            } else {
                // Register for push in iOS 7.
                UIApplication.sharedApplication().registerForRemoteNotificationTypes(.Badge | .Sound | .Alert)
            }

            // Transition to the home screen.
            UserStore.sharedInstance().waitForUser({ user in
                let vc = RevealManager.sharedInstance().initialize()
                self.presentViewController(vc, animated: true, completion: nil)
            })
        }

        // Check if the user already exists.
        let user = User(uid: authData.uid, provider: authData.provider)
        user.ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            // Add the user if they don't exist.
            if snapshot.childrenCount == 0 {
                if let profile = authData.providerData["cachedUserProfile"] as? [String: AnyObject] {
                    user.firstName = profile["given_name"] as! String
                    user.lastName = profile["family_name"] as! String
                    user.email = profile["email"] as! String
                    // TODO: use the profile picture provided?
                    // profile["picture"]
                }

                user.ref.setValue(user.toJson(), withCompletionBlock: { (error, ref) in
                    presentInitial()
                });
            } else {
                presentInitial()
            }
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? UINavigationController {
            if let profileVC = vc.topViewController as? ProfileViewController {
                profileVC.setUid(Firebase(url: Global.FirebaseUrl).authData.uid)
            }
        }
    }
}
