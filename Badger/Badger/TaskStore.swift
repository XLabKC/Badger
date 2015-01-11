
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
            UserStore.adjustCompletedTaskCount(task.owner, delta: -1)
        }
    }

    class func tryGetTask(owner: String, id: String, startWithActive: Bool, withBlock: Task? -> ()) {
        let firstRef = Task.createRef(owner, id: id, active: startWithActive)
        firstRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.childrenCount > 0 {
                return withBlock((Task.createFromSnapshot(snapshot) as Task))
            }
            let secondRef = Task.createRef(owner, id: id, active: !startWithActive)
            secondRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if snapshot.childrenCount > 0 {
                    return withBlock((Task.createFromSnapshot(snapshot) as Task))
                }
                withBlock(nil)
            })
        })
    }
}
