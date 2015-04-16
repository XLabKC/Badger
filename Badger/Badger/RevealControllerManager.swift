
@objc protocol RevealManagerDelegate: class {
    func revealManager(manager: RevealManager, willMoveToPosition position: FrontViewPosition)
    func revealManager(manager: RevealManager, didMoveToPosition position: FrontViewPosition)
}

class RevealManager: NSObject, SWRevealViewControllerDelegate {
    // Accesses the singleton.
    class func sharedInstance() -> RevealManager {
        struct Static {
            static var instance: RevealManager?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = RevealManager()
        }
        return Static.instance!
    }

    // Use internal to make property readonly.
    private var internalRevealVC: SWRevealViewController?
    var revealVC: SWRevealViewController? {
        return self.internalRevealVC
    }

    private var internalFrontPosition = FrontViewPosition.Left
    var frontPosition: FrontViewPosition {
        return self.internalFrontPosition
    }

    // Creates the reveal view controller. This is delayed to make sure that the user is first authenticated
    // before the reveal view controller is created.
    func initialize() -> SWRevealViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let frontVC = storyboard.instantiateViewControllerWithIdentifier("ProfileNavigationViewController") as! UINavigationController

        // Set uid for profile.
        if let profileVC = frontVC.topViewController as? ProfileViewController {
            profileVC.setUid(UserStore.sharedInstance().getAuthUid())
        }

        return self.initialize(frontVC)
    }

    func initialize(vc: UIViewController) -> SWRevealViewController {
        // Return existing reveal view controller if we have already initialized.
        if let existingVC = self.internalRevealVC {
            existingVC.setFrontViewController(vc, animated: true)
            return existingVC
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuVC = storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as! UITableViewController
        let rightVC = storyboard.instantiateViewControllerWithIdentifier("StatusViewController") as! UITableViewController
        let revealVC = SWRevealViewController(rearViewController: menuVC, frontViewController: vc)
        revealVC.rightViewController = rightVC
        revealVC.draggableBorderWidth = 20
        revealVC.rearViewRevealWidth = -54
        revealVC.rightViewRevealWidth = 74
        revealVC.delegate = self

        self.internalRevealVC = revealVC
        return revealVC
    }

    func removeRevealVC() {
        self.internalRevealVC = nil
    }

    func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
        if let frontVC = self.internalRevealVC!.frontViewController as? RevealManagerDelegate {
            frontVC.revealManager(self, willMoveToPosition: position)
        } else if let navVC = self.internalRevealVC!.frontViewController as? UINavigationController {
            if let frontVC = navVC.topViewController as? RevealManagerDelegate {
                frontVC.revealManager(self, willMoveToPosition: position)
            }
        }
    }

    func revealController(revealController: SWRevealViewController!, didMoveToPosition position: FrontViewPosition) {
        self.internalFrontPosition = position
        if let frontVC = self.internalRevealVC!.frontViewController as? RevealManagerDelegate {
            frontVC.revealManager(self, didMoveToPosition: position)
        } else if let navVC = self.internalRevealVC!.frontViewController as? UINavigationController {
            if let frontVC = navVC.topViewController as? RevealManagerDelegate {
                frontVC.revealManager(self, didMoveToPosition: position)
            }
        }
    }
}
