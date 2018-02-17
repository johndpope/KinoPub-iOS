import UIKit
import Eureka

class MenuSectionViewController: FormViewController {
    
    var hiddenMenuItems = Config.shared.hiddenMenusService.getHiddenMenuItems()

    override func viewDidLoad() {
        super.viewDidLoad()

        configView()
        configTableView()
    }

    func configView() {
        tableView.backgroundColor = .kpBackground
        tableView.separatorColor = .kpOffWhiteSeparator
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        title = "Разделы меню"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .always
            let attributes = [NSAttributedStringKey.foregroundColor : UIColor.kpOffWhite]
            navigationController?.navigationBar.largeTitleTextAttributes = attributes
        }
        
        tableView.tintColor = .kpGreyishBrown
    }
    
    func configTableView() {
        SwitchCustomRow.defaultCellUpdate = { cell, row in
            cell.titleLabel?.textColor = .kpOffWhite
            cell.switchControl.onTintColor = .kpMarigold
            cell.switchControl.tintColor = .kpGreyishBrown
        }
        
        form +++
        Section(footer: "Здесь можно убрать разделы, которые вам не хочется видеть в боковом меню приложения.\nИзменения вступят в силу поле перезапуска приложения.")
        for item in MenuItems.configurableMenuItems {
            form.last! <<< SwitchCustomRow() {
                $0.value = !hiddenMenuItems.contains(item)
                }.onChange({ (row) in
                    if row.value! {
                        self.hiddenMenuItems.remove(at: self.hiddenMenuItems.index(of: item)!)
                    } else {
                        self.hiddenMenuItems.append(item)
                    }
                    Config.shared.hiddenMenusService.saveConfigMenu(self.hiddenMenuItems)
                }).cellSetup({ (cell, row) in
                    cell.iconImageView.image = UIImage(named: item.icon)
                    cell.titleLabel.text = item.name
                })
            }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = .kpGreyishBrown
        }
    }
    
    // MARK: - Navigation
    static func storyboardInstance() -> MenuSectionViewController {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! MenuSectionViewController
    }
}
