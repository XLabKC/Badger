import UIKit

@objc protocol NotificationPopupDelegate {
    func notificationPopupDismissed(popup: NotificationPopup)
}

class NotificationPopup: UIView {

    class func createFromNib() -> NotificationPopup {
        let nibs = UINib(nibName: "NotificationPopup", bundle: nil).instantiateWithOwner(nil, options: nil)
        return nibs.first as NotificationPopup
    }

    private var isDismissing = false

    @IBOutlet weak var profileCircle: ProfileCircle!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    weak var delegate: NotificationPopupDelegate?

    @IBAction func dismiss(sender: AnyObject) {
        if self.isDismissing {
            return
        }
        self.isDismissing = true
        if let delegate = self.delegate? {
            delegate.notificationPopupDismissed(self)
        }
    }

    func setNotification(notification: RemoteNotification) {
        self.profileCircle.setUid(notification.uid)
        self.contentLabel.text = notification.content

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm"
        self.dateLabel.text = dateFormatter.stringFromDate(notification.timestamp)
    }

    func startTimer() {
        NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "dismiss:", userInfo: nil, repeats: false)
    }
}