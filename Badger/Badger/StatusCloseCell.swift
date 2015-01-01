import UIKit

class StatusCloseCell: BorderedCell {

    @IBAction func closeButtonPressed(sender: AnyObject) {
        let manager = RevealManager.sharedInstance()
        if manager.frontPosition == .LeftSide {
            manager.revealVC!.rightRevealToggle(sender)
        }
    }
}
