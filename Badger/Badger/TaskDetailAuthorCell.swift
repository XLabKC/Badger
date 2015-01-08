import UIKit

class TaskDetailAuthorCell: BorderedCell {

    private var hasAwakened = false
    private var task: Task?
    private var author: User?
    private var team: Team?
    private var authorObserver: FirebaseObserver<User>?
    private var teamObserver: FirebaseObserver<Team>?


    @IBOutlet weak var profileCircle: ProfileCircle!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!

    deinit {
        self.dispose()
    }

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }


    func setTask(task: Task) {
        if let oldTask = self.task? {
            if oldTask.id == task.id && self.authorObserver != nil && self.teamObserver != nil {
                return self.updateView()
            } else {
                self.dispose()
            }
        }
        self.task = task

        // Start watching the author.
        let authorRef = User.createRef(task.author)
        self.authorObserver = FirebaseObserver<User>(query: authorRef, withBlock: { author in
            self.author = author
            self.updateView()
        })

        // Start watching the team.
        let teamRef = Team.createRef(task.team)
        self.teamObserver = FirebaseObserver<Team>(query: teamRef, withBlock: { team in
            self.team = team
            self.updateView()
        })

        self.updateView()
    }

    private func updateView() {
        if self.hasAwakened {
            if let task = self.task? {
                self.metaLabel.text = task.createdAtString
                self.profileCircle.setUid(task.author)
                if let author = self.author? {
                    self.nameLabel.text = author.fullName
                }
                if let team = self.team? {
                    self.teamLabel.text = team.name
                }
            }
        }
    }

    private func dispose() {
        if let observer = self.authorObserver? {
            observer.dispose()
        }
        if let observer = self.teamObserver? {
            observer.dispose()
        }
        self.authorObserver = nil
        self.teamObserver = nil
    }
}