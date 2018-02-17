import Foundation

class HiddenMenusService {
    
    init() {
        
    }
    
    func saveConfigMenu(_ menu: [MenuItems]) {
        Storage.store(menu, to: .documents, as: MenuItems.jsonFileForHiddenMenuItems)
    }
    
    func loadConfigMenu() -> [MenuItems] {
        if !Storage.fileExists(MenuItems.jsonFileForHiddenMenuItems, in: .documents) {
            saveConfigMenu(MenuItems.hiddenMenuItemsDefault)
        }
        var configMenu = MenuItems.configurableMenuItems
        let json = Storage.retrieve(MenuItems.jsonFileForHiddenMenuItems, from: .documents, as: [MenuItems].self)
        configMenu = configMenu.filter { !json.contains($0) }
        return configMenu
    }
    
    func getHiddenMenuItems() -> [MenuItems] {
        return Storage.retrieve(MenuItems.jsonFileForHiddenMenuItems, from: .documents, as: [MenuItems].self)
    }
}
