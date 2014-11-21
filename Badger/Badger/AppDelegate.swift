import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GPPSignInDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Try and use last sessions access token if it's still valid.
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("access_token") as? String {
            if let expiration = NSUserDefaults.standardUserDefaults().objectForKey("access_token_expiration")
                as? NSDate {
                    if expiration.compare(NSDate()) == .OrderedDescending {
                        self.window?.rootViewController = self.createRevealViewController(Firebase(url: Global.FirebaseUrl).authData.uid)
                        return true
                    }
            }
        }

        // Set up options for signing in.
        var signIn = GPPSignIn.sharedInstance()
        signIn.shouldFetchGooglePlusUser = true
        signIn.shouldFetchGoogleUserEmail = true
        signIn.clientID = Global.GoogleClientId
        signIn.scopes = [kGTLAuthScopePlusLogin]
        signIn.delegate = self
        signIn.attemptSSO = true

        // Try and silently authenticate the user.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if (!signIn.trySilentAuthentication()) {
            let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as UIViewController
            self.window?.rootViewController = vc
        }

        return true
    }

    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if error != nil {
            println("Google auth error \(error) and auth object \(auth)")
        } else {
            let ref = Firebase(url: Global.FirebaseUrl)
            ref.authWithOAuthProvider("google", token: auth.accessToken, withCompletionBlock: { error, authData in
                if error != nil {
                    println("Firebase auth error \(error) and auth object \(authData)")
                } else {
                    Helpers.saveAccessToken(auth)
                    self.window?.rootViewController?.presentViewController(self.createRevealViewController(authData.uid), animated: true, completion: nil)
                }
            })
        }
    }

    private func createRevealViewController(uid: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuVC = storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as UITableViewController
        let frontVC = storyboard.instantiateViewControllerWithIdentifier("ProfileNavigationViewController") as UINavigationController
        let revealVC = SWRevealViewController(rearViewController: menuVC, frontViewController: frontVC)
        revealVC.draggableBorderWidth = 20
        revealVC.rearViewRevealWidth = -54

        // Set uid for profile.
        if let profileVC = frontVC.topViewController as? ProfileViewController {
            profileVC.setUid(uid)
        }
        return revealVC
    }

    func application(application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

            // Convert NSData into a hex string.
            var bytes = [UInt8](count: deviceToken.length, repeatedValue: 0x0)
            deviceToken.getBytes(&bytes, length:deviceToken.length)
            var hexBits = "" as String
            for value in bytes {
                hexBits += NSString(format: "%2X", value) as String
            }
            let hexDeviceToken = hexBits.stringByReplacingOccurrencesOfString("\u{0020}", withString: "0", options: NSStringCompareOptions.CaseInsensitiveSearch)

            // Save device token.
            let device = [
                "platform": "ios",
                "token": hexDeviceToken
            ]
            let ref = Firebase(url: Global.FirebaseUsersUrl)
            ref.childByAppendingPath(ref.authData.uid).childByAppendingPath("device").setValue(device)
    }

    func application(application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: NSError) {
            println("Failed to register for remote notifications")
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        return GPPURLHandler.handleURL(url, sourceApplication: sourceApplication, annotation: annotation);
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

