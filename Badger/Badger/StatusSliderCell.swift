import UIKit

class StatusSliderCell: BorderedCell, StatusSliderDelegate {
    private var user: User?
    private var currentStatus = UserStatus.Unknown
    private var hasAwakened = false
    private var timer: NSTimer?

    @IBOutlet weak var slider: StatusSlider!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    func setUser(user: User) {
        self.user = user
        self.currentStatus = user.status
        self.updateView()
    }

    func sliderChangedStatus(slider: StatusSlider, newStatus: UserStatus) {
        self.currentStatus = newStatus
        var oldStatus = UserStatus.Free.rawValue

        if let user = self.user? {
            oldStatus = user.status.rawValue
            user.ref.childByAppendingPath("status").setValue(newStatus.rawValue as String!)
        }
        if let timer = self.timer? {
            oldStatus = timer.userInfo as String
            timer.invalidate()
        }
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "setForPush:", userInfo: oldStatus, repeats: false)
    }

    func setForPush(timer: NSTimer) {
        self.timer = nil
        let oldStatus = timer.userInfo as String
        if self.currentStatus.rawValue != oldStatus {
            let uid = UserStore.sharedInstance().getAuthUid()
            let ref = Firebase(url: Global.FirebaseStatusUpdatedUrl).childByAppendingPath(uid)
            ref.setValue(self.currentStatus.rawValue)
        }
    }

    private func updateView() {
        if self.hasAwakened {
            if let user = self.user? {
                self.slider.setStatus(user.status, animated: false)
                self.slider.delegate = self
            }
        }
    }
}
