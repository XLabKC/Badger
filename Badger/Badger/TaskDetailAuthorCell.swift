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
    }


    func setTask(task: Task) {
        self.task = task
        self.updateView()
    }

    private func updateView() {
        if self.hasAwakened {
            if let task = self.task? {
                UserStore.sharedInstance().getUser(task.author, withBlock: { user in
                    self.profileCircle.setUid(user.uid)
                    self.nameLabel.text = user.fullName
                    self.metaLabel.text = task.createdAtString
                })
                TeamStore.sharedInstance().getTeam(task.team, withBlock: { team in
                    self.teamLabel.text = team.name
                })
            }
        }
    }
}