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

    func notificationPopupSelected(popup: NotificationPopup) {
        if let notification = popup.getNotification()? {
            if let revealVC = RevealManager.sharedInstance().revealVC? {
                if let vc = NotificationManager.createViewControllerFromNotification(notification.raw)? {
                    revealVC.setFrontViewController(vc, animated: true)
                }
            }
        }
        self.notificationPopupDismissed(popup)
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
                TaskStore.tryGetTask(uid, id: taskId, startWithActive: true, withBlock: { maybeTask in
                    if let task = maybeTask? {
                        let content = "New Task: \(task.title)"
                        let note = RemoteNotification(type: "new_task", content: content, uid: authorUid, raw: notification)
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
                let note = RemoteNotification(type: "new_status", content: content, uid: uid, raw: notification)
                self.enqueueNotification(note)
            }
        })
    }

    class func createProfileViewController(uid: String) -> UINavigationController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nav = storyboard.instantiateViewControllerWithIdentifier("ProfileNavigationViewController") as UINavigationController
        if let profileVC = nav.topViewController as? ProfileViewController {
            profileVC.setUid(uid)
        }
        return nav
    }

    class func createViewControllerFromNotification(notification: [NSObject: AnyObject]) -> UIViewController? {
        if let type = notification["type"] as? String {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            switch type {
            case "new_task":
                if let taskId = notification["task"] as? String {
                    let owner = UserStore.sharedInstance().getAuthUid()
                    let nav = NotificationManager.createProfileViewController(owner)
                    let taskDetail = storyboard.instantiateViewControllerWithIdentifier("TaskDetailViewController") as TaskDetailViewController
                    taskDetail.setTask(owner, id: taskId, active: true)
                    nav.pushViewController(taskDetail, animated: false)
                    return nav
                }
                break
            case "new_status":
                if let uid = notification["uid"] as? String {
                    return NotificationManager.createProfileViewController(uid)
                }
            default:
                break
            }
        }
        return nil
    }
}

class RemoteNotification {
    let type: String
    let content: String
    let uid: String
    let timestamp = NSDate()
    let raw: [NSObject: AnyObject]

    init(type: String, content: String, uid: String, raw: [NSObject: AnyObject]) {
        self.type = type
        self.content = content
        self.uid = uid
        self.raw = raw
    }
}