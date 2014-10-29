import UIKit

class UserTableCell: UITableViewCell {

    @IBOutlet weak internal var label: UILabel!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setUser(user: User) {
        self.label.text = user.full_name
    }
}