import UIKit

class MenuSettingsCell: BorderedCell {
    private var hasAwakened = false
    private var user: User?

    @IBOutlet weak var emailButton: UIButton!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
        self.setTopBorder(.Full)
        self.setBottomBorder(.Full)
        self.setBorderColor(Color.colorize(0x0C0C0C, alpha: 1))
    }

    func setUser(user: User) {
        self.user = user
        self.updateView()
    }

    private func updateView() {
        if self.user != nil && self.hasAwakened {
            self.emailButton.setTitle(self.user!.email, forState: .Normal)
        }
    }
}
