import Foundation


final class MenuStore {
    private let queue = DispatchQueue(label: "MenuStore.Queue")
    private var menus: [GoodsCategory: [MenuItemDTO]] = [:]
    
    func setMenus(by menu: GoodsCategory, menus: [MenuItemDTO]) {
        queue.sync {
            self.menus[menu] = menus
        }
    }
    
    func getMenus(by menu: GoodsCategory) -> [MenuItemDTO] {
        queue.sync {
            return menus[menu, default: []]
        }
    }
}
