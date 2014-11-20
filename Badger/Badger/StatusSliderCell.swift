import UIKit

class StatusSliderCell: UITableViewCell, StatusSliderDelegate {
    private var ref: Firebase?

    @IBOutlet weak var slider: StatusSlider!

    func setUser(user: User) {
        self.slider.setStatus(user.status, animated: false)
        self.slider.delegate = self
        self.ref = user.ref
        if self.ref == nil {
            self.ref = Firebase(url: Global.FirebaseUsersUrl).childByAppendingPath(user.uid)
        }
    }

    func sliderChangedStatus(slider: StatusSlider, newStatus: UserStatus) {
        if let ref = self.ref? {
            ref.childByAppendingPath("status").setValue(newStatus.rawValue as String!)
        }
    }
}
