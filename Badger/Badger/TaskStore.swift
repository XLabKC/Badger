
class TaskStore {

    class func deleteTask(task: Task) {
        task.ref.removeAllObservers()
        task.ref.removeValue()

        // Update counts.
        if task.active {
            let combinedId = Task.combineId(task.owner, id: task.id)
            UserStore.adjustActiveTaskCount(task.owner, delta: -1)
            TeamStore.removeActiveTask(task.team, combinedId: combinedId)
        } else {
            UserStore.adjustActiveTaskCount(task.owner, delta: -1)
        }
    }
}
