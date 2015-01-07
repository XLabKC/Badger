
class NotificationManager: NotificationPopupDelegate {
    private var activePopup: NotificationPopup?
    private var pendingNotifications: [RemoteNotification] = []
    //private var preparingNotifications: [[NSObject: AnyObject]] = []

    func notify(notification: [NSObject: AnyObject]) {

    }

    func notificationPopupDismissed(popup: NotificationPopup) {

    }

    private func enqueueNotification(notification: RemoteNotification) {

    }

    private func prepareNotification() {

    }
}

class RemoteNotification {
    let content: String
    let uid: String
    let timestamp = NSDate()

    init(content: String, uid: String) {
        self.content = content
        self.uid = uid
    }
}