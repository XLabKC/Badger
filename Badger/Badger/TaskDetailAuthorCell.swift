import UIKit

class TaskDetailAuthorCell: BorderedCell {
    private var hasAwakened = false
    private var task: Task?

    @IBOutlet weak var profileCircle: ProfileCircle!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
        self.setTopBorder(.Full)
        self.setBottomBorder(.Full)
        self.setBorderColor(Color.colorize(0xE0E0E0, alpha: 1))
    }


    func setTask(task: Task) {
        self.task = task
        if self.hasAwakened {
            self.updateView()
        }
    }

    private func updateView() {
        if let task = self.task? {
            UserStore.sharedInstance().getUser(task.author, withBlock: { user in
                self.profileCircle.setUser(user)
                self.nameLabel.text = user.fullName
                self.teamLabel.text = "Unknown" // TODO: figure out best way to get team name
                self.metaLabel.text = "Unknown" // TODO: display date
            })
        }
    }
}