import UIKit

class UserTableCell: UITableViewCell {

    var statusHandle: UInt
    var statusRef: Firebase?

    @IBOutlet weak internal var label: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    required init(coder aDecoder: NSCoder) {
        self.statusHandle = 0
        super.init(coder: aDecoder)
    }

    func setUser(user: User) {
        if let statusRef = self.statusRef? {
            statusRef.removeObserverWithHandle(statusHandle)
        }

        self.label.text = user.full_name
        self.setStatus(user.status)
        if let uidRef = user.uidRef {
            self.statusRef = uidRef.childByAppendingPath("status")
            self.statusHandle = statusRef!.observeEventType(.Value, withBlock: { (snapshot) in
                self.setStatus(snapshot.value as String)
            })
        }
    }

    private func setStatus(status:String) {
        self.statusLabel.text = status
        self.statusLabel.textColor = statusToColor(status)
    }

    private func statusToColor(status:String) -> UIColor {
        switch status {
            case "red":
                return UIColor.redColor()
            case "yellow":
                return UIColor.yellowColor()
            default:
                return UIColor.greenColor()
        }
    }
}