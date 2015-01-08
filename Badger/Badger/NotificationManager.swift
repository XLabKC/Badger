import UIKit


class NotificationManager: NotificationPopupDelegate {
    private let AnimationDuration: NSTimeInterval = 0.5

    private var activePopup: NotificationPopup?
    private var pendingNotifications: [RemoteNotification] = []
    private var showingNotification = false

    init() {

    }

    func notify(notification: [NSObject: AnyObject]) {
        if let type = notification["type"] as? String {
            switch type {
            case "new_task":
                return self.createNewTaskNote(notification)
            case "new_status":
                return self.createNewStatusNote(notification)
            default:
                println("Unknown notification type: \(type)")
            }
        }
    }

    func notificationPopupDismissed(popup: NotificationPopup) {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        let window = delegate.window!

        UIView.animateWithDuration(self.AnimationDuration, animations: { _ in
            popup.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 72.0)
        },
        completion: { completed in
            popup.removeFromSuperview()
            // Show the next notification if any.
            if !self.pendingNotifications.isEmpty {
                let note = self.pendingNotifications.removeAtIndex(0)
                self.show(note)
            }
        })
    }

    private func show(notification: RemoteNotification) {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        let window = delegate.window!
        let popup = NotificationPopup.createFromNib()
        popup.delegate = self
        popup.setNotification(notification)
        popup.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 72.0)
        window.addSubview(popup)

        UIView.animateWithDuration(self.AnimationDuration, animations: { _ in
            let y = window.frame.height - popup.frame.height
            popup.frame = CGRect(x: 0, y: y, width: window.frame.width, height: 72.0)
        },
        completion: { completed in
            popup.startTimer()
        })

        self.activePopup = popup
    }

    private func enqueueNotification(notification: RemoteNotification) {
        if self.showingNotification {
            self.pendingNotifications.append(notification)
        } else {
            self.show(notification)
        }
    }

    private func createNewTaskNote(notification: [NSObject: AnyObject]) {
        let uid = UserStore.sharedInstance().getAuthUid()
        let authorUid = notification["author"] as String
        let taskId = notification["task"] as String
        User.createRef(authorUid).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot != nil {
                let author = User.createFromSnapshot(snapshot) as User
                let taskRef = Task.createRef(uid, id: taskId, active: true)
                taskRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if snapshot != nil {
                        let task = Task.createFromSnapshot(snapshot) as Task
                        let content = "New Task: \(task.title)"
                        let note = RemoteNotification(type: "new_task", content: content, uid: authorUid)
                        self.enqueueNotification(note)
                    }
                })
            }
        })
    }

    private func createNewStatusNote(notification: [NSObject: AnyObject]) {
        let uid = notification["uid"] as String
        User.createRef(uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot != nil {
                let user = User.createFromSnapshot(snapshot) as User
                let content = "\(user.fullName) is now \(user.statusText.lowercaseString)."
                let note = RemoteNotification(type: "new_status", content: content, uid: uid)
                self.enqueueNotification(note)
            }
        })
    }
}

class RemoteNotification {
    let type: String
    let content: String
    let uid: String
    let timestamp = NSDate()

    init(type: String, content: String, uid: String) {
        self.type = type
        self.content = content
        self.uid = uid
    }
}