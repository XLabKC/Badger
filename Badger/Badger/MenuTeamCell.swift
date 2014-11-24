import UIKit

class MenuTeamCell: UITableViewCell {
    private var hasAwakened = false

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    func setTeam(team: Team) {

    }

    private func updateView() {
    }
}
