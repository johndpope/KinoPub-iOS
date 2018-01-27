
extension Set {
    public var toString: String {
        var value = ""
        for item in self {
            if value != "" {
                value += ","
            }
            value += item.hashValue.string
        }
        return value
    }
}
