import UIKit

class StatusCell: UITableViewCell {
    private var hasAwakened = false
    private var user: User?

    @IBOutlet weak var profileCircle: ProfileCircle!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    func getUser() -> User? {
        return self.user
    }

    func setUser(user: User) {
        self.user = user
        self.updateView()
    }

    private func updateView() {
        if self.user != nil && self.hasAwakened {
            self.profileCircle.setUid(self.user!.uid)
        }
    }
}
