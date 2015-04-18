import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var notificationManager = NotificationManager()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        UINavigationBar.appearance().backgroundColor = UIColor.whiteColor()
        UINavigationBar.appearance().barStyle = UIBarStyle.Default
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = Color.colorize(0x929292, alpha: 1.0)

        // Set the font of all bar buttons to be Open Sans.
        var attributes: [NSObject: AnyObject] = [:]
        attributes[NSFontAttributeName] = UIFont(name: "OpenSans", size: 17.0)
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, forState: .Normal)

        let setCallbacks: () -> () = {
            UserStore.sharedInstance().unauthorizedBlock = self.loggedOut
            UserStore.sharedInstance().authorizedBlock = nil
        }

        UserStore.sharedInstance().unauthorizedBlock = {
            setCallbacks()
            self.navigateToLogin()
        }
        UserStore.sharedInstance().authorizedBlock = {
            setCallbacks()
            self.navigateToFirstView(launchOptions)
        }
        UserStore.sharedInstance().initialize()
        return true
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

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
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

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if application.applicationState == .Active {
            // Application was already in foreground.
            self.notificationManager.notify(userInfo)
        } else {
            // Application was in the background.
            if let revealVC = RevealManager.sharedInstance().revealVC {
                if let vc = NotificationManager.createViewControllerFromNotification(userInfo) {
                    revealVC.setFrontViewController(vc, animated: true)
                }
            }
        }
    }

    private func loggedOut() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! UIViewController
        vc.view.alpha = 0

        RevealManager.sharedInstance().removeRevealVC()
//        UIApplication.sharedApplication().keyWindow?.rootViewController = vc
        self.window?.rootViewController = vc

        UIView.animateWithDuration(0.5, animations: { () -> Void in
            vc.view.alpha = 1
        })
    }

    private func navigateToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! UIViewController
        self.navigateToViewController(vc)
    }

    private func navigateToFirstView(launchOptions: [NSObject: AnyObject]?) {
        // For some reason, it's possible to get to this point but for the UserStore to not actually
        // have valid auth data. Make sure we catch these cases and redirect to login.
        if !UserStore.sharedInstance().hasValidAuth() {
            self.navigateToLogin()
        }

        if let options = launchOptions {
            if let note = options[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
                if let vc = NotificationManager.createViewControllerFromNotification(note) {
                    UserStore.sharedInstance().waitForUser({ _ in
                        let reveal = RevealManager.sharedInstance().initialize(vc)
                        self.navigateToViewController(reveal)
                    })
                    return
                }
            }
        }
        UserStore.sharedInstance().waitForUser({ _ in
            let vc = RevealManager.sharedInstance().initialize()
            self.navigateToViewController(vc)
        })
    }

    private func navigateToViewController(viewController: UIViewController) {
        if let root = self.window?.rootViewController {
            if root.isViewLoaded() {
                root.presentViewController(viewController, animated: true, completion: nil)
                return
            }
        }
        self.window?.rootViewController = viewController
    }
}

