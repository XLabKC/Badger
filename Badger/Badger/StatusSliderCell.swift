import UIKit

class StatusSliderCell: BorderedCell, StatusSliderDelegate {
    private var ref: Firebase?
    private var user: User?
    private var hasAwakened = false

    @IBOutlet weak var slider: StatusSlider!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    func setUser(user: User) {
        self.user = user
        self.updateView()
    }

    func sliderChangedStatus(slider: StatusSlider, newStatus: UserStatus) {
        if let ref = self.ref? {
            ref.childByAppendingPath("status").setValue(newStatus.rawValue as String!)
        }
    }

    func updateView() {
        if self.hasAwakened {
            if let user = self.user? {
                self.slider.setStatus(user.status, animated: false)
                self.slider.delegate = self
                self.ref = user.ref
                if self.ref == nil {
                    self.ref = Firebase(url: Global.FirebaseUsersUrl).childByAppendingPath(user.uid)
                }
            }
        }
    }
}
