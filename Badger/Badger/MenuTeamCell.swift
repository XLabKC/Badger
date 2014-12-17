import UIKit

class MenuTeamCell: BorderedCell, TeamObserver {
    private var hasAwakened = false
    private var team: Team?

    @IBOutlet weak var teamCircle: TeamCircle!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!

    deinit {
        if let team = self.team? {
            TeamStore.sharedInstance().removeObserver(self, id: team.id)
        }
    }

    override func awakeFromNib() {
        self.hasAwakened = true
        self.setBottomBorder(.Full)
        self.setBorderColor(Color.colorize(0x0C0C0C, alpha: 1))
        self.updateView()
    }

    func setTeam(team: Team) {
        self.team = team
        self.updateView()
    }

    func getTeam() -> Team? {
        return self.team
    }

    func teamUpdated(newTeam: Team) {
        self.team = newTeam
        self.updateView()
    }

    private func updateView() {
        if self.team != nil && self.hasAwakened {
            self.nameLabel.text = self.team!.name
            self.metaLabel.text = self.team!.description()
        }
    }
}
