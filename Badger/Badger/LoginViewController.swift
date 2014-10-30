import UIKit

class LoginViewController: UIViewController, GPPSignInDelegate {

    @IBOutlet weak var signInButton: GPPSignInButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        var signIn = GPPSignIn.sharedInstance()
        signIn.shouldFetchGooglePlusUser = true
        signIn.shouldFetchGoogleUserEmail = true
        signIn.clientID = Global.GoogleClientId
        signIn.scopes = [kGTLAuthScopePlusLogin];
        signIn.delegate = self;

        signIn.trySilentAuthentication()
    }

    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if error != nil {
            println("Google auth error \(error) and auth object \(auth)")
        } else {
            let ref = Firebase(url: Global.FirebaseUrl)
            ref.authWithOAuthProvider("google", token: auth.accessToken,
                withCompletionBlock: { error, authData in
                    if error != nil {
                        println("Firebase auth error \(error) and auth object \(authData)")
                    } else {
                        let uidRef = ref.childByAppendingPath("users").childByAppendingPath(authData.uid)
                        uidRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
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
                            Global.AuthData = authData

                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewControllerWithIdentifier("PrimaryNavigation") as UIViewController as UINavigationController
                            self.presentViewController(vc, animated: true, completion: nil)
                        })
                    }
            })
        }
    }

}
