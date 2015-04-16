@objc protocol DataEntity: class {
    func getKey() -> String
    static func createFromSnapshot(snapshot: FDataSnapshot) -> DataEntity
}
