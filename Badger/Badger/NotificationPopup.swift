import UIKit

@objc protocol NotificationPopupDelegate {
    func notificationPopupDismissed(popup: NotificationPopup)
    func notificationPopupSelected(popup: NotificationPopup)
}

class NotificationPopup: UIView {

    class func createFromNib() -> NotificationPopup {
        let nibs = UINib(nibName: "NotificationPopup", bundle: nil).instantiateWithOwner(nil, options: nil)
        return nibs.first as NotificationPopup
    }

    private var notification: RemoteNotification?
    private var isDismissing = false

    @IBOutlet weak var profileCircle: ProfileCircle!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    weak var delegate: NotificationPopupDelegate?

    override func awakeFromNib() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap")
        self.addGestureRecognizer(tapGesture)
    }

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
        self.notification = notification
        self.profileCircle.setUid(notification.uid)
        self.contentLabel.text = notification.content

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm"
        self.dateLabel.text = dateFormatter.stringFromDate(notification.timestamp)
    }

    func getNotification() -> RemoteNotification? {
        return self.notification
    }

    func startTimer() {
        NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "dismiss:", userInfo: nil, repeats: false)
    }

    func handleTap() {
        if self.isDismissing {
            return
        }
        self.isDismissing = true
        if let delegate = self.delegate? {
            delegate.notificationPopupSelected(self)
        }
    }
}