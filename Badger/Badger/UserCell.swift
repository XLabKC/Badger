import UIKit

class UserCell: BorderedCell {
    private var hasAwakened = false
    private var user: User?
    private var observer: FirebaseObserver<User>?

    @IBOutlet weak var profileCircle: ProfileCircle!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    deinit {
        self.dispose()
    }

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    func setUid(uid: String) {
        if let user = self.user? {
            if user.uid == uid {
                // Already setup.
                return
            } else {
                self.dispose()
            }
        }
        let ref = User.createRef(uid)
        self.observer = FirebaseObserver<User>(query: ref, withBlock: { user in
            self.user = user
            self.updateView()
        })
    }

    private func updateView() {
        if self.hasAwakened {
            if let user = self.user? {
                self.nameLabel.text = user.fullName
                self.statusLabel.text = Helpers.statusToText(user, status: user.status)
                self.statusLabel.textColor = Helpers.statusToColor(user.status)
                self.profileCircle.setUid(user.uid)
            } else {
                self.statusLabel.text = ""
                self.nameLabel.text = "Loading..."
            }
        }
    }

    private func dispose() {
        if let observer = self.observer? {
            observer.dispose()
        }
    }
}