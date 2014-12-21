@objc protocol DataEntity: class {
    func getKey() -> String
    class func createFromSnapshot(snapshot: FDataSnapshot) -> DataEntity
}
