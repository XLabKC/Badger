import UIKit

class TaskEditTitleCell: BorderedCell {
    private var hasAwakened = false
    private var task: Task?

    @IBOutlet weak var titleTextField: UITextField!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    func setTask(task: Task) {
        self.task = task
        if self.hasAwakened {
            self.updateView()
        }
    }

    func getTitle() -> String {
        return self.titleTextField.text
    }

    private func updateView() {
        if let task = self.task? {
            self.titleTextField.text = task.title
        }
    }
}