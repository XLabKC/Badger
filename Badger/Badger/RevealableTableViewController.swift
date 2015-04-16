import UIKit

class RevealableTableViewController: UITableViewController, RevealManagerDelegate {
    internal var shouldAddMenuButton = true
    internal var shouldAddStatusButton = true
    private var showingPurpleIcon = false
    private var statusButton: UIBarButtonItem?

    override func viewDidLoad() {
        if let nav = self.navigationController {
            if let revealVC = RevealManager.sharedInstance().revealVC {
                // Only add the menu button if there isn't already a back button.
                if self.shouldAddMenuButton {
                    if nav.viewControllers.first as? RevealableTableViewController == self {
                        var button = UIBarButtonItem(image: UIImage(named: "MenuIcon"), style: .Plain, target: revealVC, action: "revealToggle:")
                        button.tintColor = Color.colorize(0x929292, alpha: 1.0)
                        self.navigationItem.leftBarButtonItem = button
                    }
                }
                // Add the status button.
                if self.shouldAddStatusButton {
                    if let statusVC = revealVC.rightViewController as? StatusViewController {
                        self.statusButton = UIBarButtonItem(image: UIImage(named: "LogoIcon"), style: .Plain, target: revealVC, action: "rightRevealToggle:")
                        self.statusButton!.tintColor = Color.colorize(0x929292, alpha: 1.0)
                        self.navigationItem.rightBarButtonItem = self.statusButton!
                    }
                }
                if self.shouldAddMenuButton || self.shouldAddStatusButton {
                    self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
                }
            }
        }
    }

    func revealManager(manager: RevealManager, didMoveToPosition position: FrontViewPosition) {
    }

    func revealManager(manager: RevealManager, willMoveToPosition position: FrontViewPosition) {
        if self.showingPurpleIcon && position != .LeftSide {
            self.showingPurpleIcon = false
            if let button = self.statusButton {
                button.tintColor = Color.colorize(0x929292, alpha: 1.0)
            }
        } else if !self.showingPurpleIcon && position == .LeftSide {
            self.showingPurpleIcon = true
            if let button = self.statusButton {
                button.tintColor = Color.colorize(0x8E82FF, alpha: 1.0)
            }
        }
    }
}