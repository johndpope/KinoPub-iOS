import Foundation

class MergeDownloads {
    private let plistPath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/NTDownload.plist"
    private let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    init() {
//        if UserDefaults.standard.object(forKey: "mergedDownloads") == nil {
//            mergeBuild33()
//            UserDefaults.standard.set(true, forKey: "mergedDownloads")
//        }
    }
    
    func merge() {
        let newJsonArray = NSMutableArray()
        guard let jsonArray = NSArray(contentsOfFile: plistPath) else {
            return
        }
        for jsonItem in jsonArray {
            let newJsonItem = NSMutableDictionary()
            guard let item = jsonItem as? NSDictionary else { return }
            if (item["fileName"] as? String) != nil { return }
            guard let name = item["name"] as? String, let urlString = item["url"] as? String else { return }
            let nameToSave = name.replacingOccurrences(of: "/ ", with: "") + ".mp4"
            let fromFile = documentUrl.appendingPathComponent(urlString.lastPathComponent)
            let toFile = documentUrl.appendingPathComponent(nameToSave)
            do {
                try FileManager.default.moveItem(at: fromFile, to: toFile)
            } catch {
                print("Ooops! Something went wrong: \(error.localizedDescription)")
            }
            newJsonItem["fileImage"] = item["fileImage"]
            newJsonItem["fileName"] = nameToSave
            newJsonItem["fileSize.size"] = item["fileTotalSize"]
            newJsonItem["fileSize.unit"] = item["fileTotalUnit"]
            newJsonItem["fileURL"] = item["url"]
            if item["isFinished"] as! Bool {
                newJsonItem["statusCode"] = 2 as NSNumber
            }
            newJsonArray.add(newJsonItem)
        }
        newJsonArray.write(toFile: plistPath, atomically: true)
    }
}
