import Foundation

extension Int {
    var fullIMDb: String {
        var imdbID = String(self)
        while imdbID.count < 7 {
            imdbID = "0\(imdbID)"
        }
        imdbID = "tt\(imdbID)"
        return imdbID
    }
    
    func getNumEnding(fromArray array: [String]) -> String {
        guard array.count == 3 else { return "Должно быть 3 варианта в массиве" }
        let str: String
        let number = self % 100
        if number >= 11, number <= 19 {
            str = array[2]
        } else {
            let num2 = number % 10
            switch num2 {
            case 1:
                str = array[0]
            case 2, 3, 4:
                str = array[1]
            default:
                str = array[2]
            }
        }
        return str
    }
}
