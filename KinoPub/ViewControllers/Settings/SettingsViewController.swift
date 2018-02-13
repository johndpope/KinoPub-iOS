import UIKit
import Eureka
import SwiftyUserDefaults
import InteractiveSideMenu
import LKAlertController

class SetViewController: FormViewController, SideMenuItemContent {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .kpBackground
        tableView.separatorStyle = .none
        title = "Настройки"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .always
            let attributes = [NSAttributedStringKey.foregroundColor : UIColor.kpOffWhite]
            navigationController?.navigationBar.largeTitleTextAttributes = attributes
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "Kinopub (Menu)")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(showMenu))
        
        tableView.tintColor = .kpGreyishBrown
        
        SwitchRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = .kpOffWhite
            cell.switchControl.onTintColor = .kpMarigold
            cell.switchControl.tintColor = .kpGreyishBrown
        }
        
        PushRow<Int>.defaultCellUpdate = { cell, row in
            cell.tintColor = .kpGreyishBrown
            cell.setDisclosure(toColor: .kpGreyishBrown)
            cell.textLabel?.textColor = .kpOffWhite
            cell.detailTextLabel?.textColor = .kpGreyishTwo
            let _ = row.onPresent({ (_, to) in
                to.enableDeselection = false
                let _ = to.view
                let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                backgroundView.backgroundColor = .kpBackground
                to.tableView?.backgroundView = backgroundView
                to.tableView.separatorColor = .kpOffWhiteSeparator
                to.tableView.tintColor = .kpMarigold
                to.form.last?.header = nil
                to.selectableRowCellUpdate = { cell, row in
                    cell.tintColor = .kpMarigold
                    cell.backgroundColor = .clear
                    cell.textLabel?.textColor = .kpOffWhite
                }
            })
        }
        
        AlertRow<String>.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = .kpOffWhite
            cell.detailTextLabel?.textColor = .kpGreyishTwo
            let _ = row.onPresent({ (_, to) in
                to.cancelTitle = "Отмена"
                to.view.tintColor = .kpBlack
            })
        }
        
        TextRow.defaultCellUpdate = { cell, row in
            cell.detailTextLabel?.textColor = .kpGreyishTwo
            cell.textLabel?.textColor = .kpOffWhite
            cell.tintColor = UIColor.kpMarigold
            cell.textField.textColor = .kpGreyishTwo
        }
        
        ButtonRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = .kpOffWhite
            cell.setDisclosure(toColor: .kpGreyishBrown)
        }
        
        form +++ Section("ОБЩЕЕ")
            
            <<< PushRow<Int>() {
                $0.title = "Стартовый экран"
                $0.selectorTitle = "Стартовый экран"
                $0.options = Array(0 ..< Config.MenuItems.all.count)
                $0.value = Defaults[.menuItem]
                $0.displayValueFor = { test in
                    if let _test = test {
                        return Config.MenuItems.all[_test].name
                    }
                    return "Oops"
                }
                }.onChange({ (row) in
                    guard let value = row.value else { return }
                    Defaults[.menuItem] = value
                })
            
            <<< SwitchRow() {
                $0.title = "Обратная сортировка сезонов"
                $0.value = Defaults[.canSortSeasons]
                }.onChange({ (row) in
                    Defaults[.canSortSeasons] = row.value!
                })
            
            <<< SwitchRow() {
                $0.title = "Обратная сортировка эпизодов"
                $0.value = Defaults[.canSortEpisodes]
                }.onChange({ (row) in
                    Defaults[.canSortEpisodes] = row.value!
                })
            
            +++ Section("ВНЕШНИЙ ВИД")
            <<< ButtonRow() { (row: ButtonRow) in
                row.title = "Разделы меню"
                row.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback(builder: {
                    return MenuSectionViewController.storyboardInstance()
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
            
            <<< SwitchRow() {
                $0.title = "Рейтинг на постере"
                $0.value = Defaults[.showRatringInPoster]
                }.onChange({ (row) in
                    Defaults[.showRatringInPoster] = row.value!
                })
            
            +++ Section("ВОСПРОИЗВЕДЕНИЕ")
            <<< AlertRow<String>() {
                $0.title = "Тип потока"
                $0.selectorTitle = "Рекомендуем HLS4"
                $0.options = ["hls4", "http", "hls"]
                $0.value = Defaults[.streamType]
                $0.displayValueFor = { test in
                    if let _test = test {
                        switch _test {
                        case "hls4": return "HLS4 (Адаптивный)"
                        case "http": return "HTTP (Выбор качества)"
                        case "hls": return "HLS (Выбор качества)"
                        default: return ""
                        }
                    }
                    return ""
                }
                }.onChange({ (row) in
                    Defaults[.streamType] = row.value!
                })
            
            <<< SwitchRow() {
                $0.title = "Логирование просмотров"
                $0.value = Defaults[.logViews]
                }.onChange({ (row) in
                    Defaults[.logViews] = row.value!
                })
            
            <<< SwitchRow("Custom") {
                $0.title = "Кастомный плеер"
                $0.value = Defaults[.isCustomPlayer]
                }.onChange({ (row) in
                    Defaults[.isCustomPlayer] = row.value!
                })
            
            +++ Section(header: "КАСТОМНЫЙ ПЛЕЕР", footer: "Данные настройки применимы только для кастомного плеера.") {
                $0.hidden = .function(["Custom"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "Custom")
                    return row.value ?? false == false
                })
            }
            <<< SwitchRow() {
                $0.title = "Перемотка свайпом"
                $0.value = Defaults[.canSlideProgress]
                }.onChange({ (row) in
                    Defaults[.canSlideProgress] = row.value!
                })
            
            <<< AlertRow<String>() {
                $0.title = "Левый слайд"
                $0.selectorTitle = "Выберите действие"
                $0.options = ["none", "volume", "brightness"]
                $0.value = Defaults[.leftSlideTrigger]
                $0.displayValueFor = { test in
                    if let _test = test {
                        switch _test {
                        case "none": return "Отключено"
                        case "volume": return "Громкость"
                        case "brightness": return "Яркость"
                        default: return ""
                        }
                    }
                    return ""
                }
                }.onChange({ (row) in
                    Defaults[.leftSlideTrigger] = row.value!
                })
            
            <<< AlertRow<String>() {
                $0.title = "Правый слайд"
                $0.selectorTitle = "Выберите действие"
                $0.options = ["none", "volume", "brightness"]
                $0.value = Defaults[.rightSlideTrigger]
                $0.displayValueFor = { test in
                    if let _test = test {
                        switch _test {
                        case "none": return "Отключено"
                        case "volume": return "Громкость"
                        case "brightness": return "Яркость"
                        default: return ""
                        }
                    }
                    return ""
                }
                }.onChange({ (row) in
                    Defaults[.rightSlideTrigger] = row.value!
                })
        
            +++ Section("ДОПОЛНИТЕЛЬНО")
            
            <<< TextRow() {
                $0.title = "Имя клиента"
                $0.value = Defaults[.clientTitle]
                }.onChange({ (row) in
                    Defaults[.clientTitle] = row.value ?? "iPhone"
                })
            
//            +++ Section(footer: "(c) 2017 Evgeny Dats http://dats.xyz")
            <<< ButtonRow() { (row: ButtonRow) in
                row.title = "Список изменений"
                row.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback(builder: {
                    let thanksVC = ThanksViewController.storyboardInstance()
                    thanksVC?.title = row.title
                    thanksVC?.url = "https://raw.githubusercontent.com/hintoz/KinoPub-iOS/master/CHANGELOG.md"
                    thanksVC?.titleText = ""
                    return thanksVC!
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
            
            <<< ButtonRow() { (row: ButtonRow) in
                row.title = "Благодарности"
                row.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback(builder: {
                    let thanksVC = ThanksViewController.storyboardInstance()
                    thanksVC?.title = row.title
                    thanksVC?.url = "http://dats.xyz/thanks.txt"
                    thanksVC?.titleText = "Огромная благодарность за поддержку"
                    return thanksVC!
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
            
            <<< ButtonRow() { (row: ButtonRow) in
                row.title = "О приложении"
                row.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback(builder: {
                    let thanksVC = AboutViewController.storyboardInstance()
                    thanksVC?.title = row.title
                    return thanksVC!
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
            
            +++ Section()
            <<< ButtonRow("Support") { (row: ButtonRow) -> Void in
                row.title = "Поддержка приложения"
            }.onCellSelection({ [weak self] (cell, row) in
                self?.openTelegramChat()
            }).cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .kpGreyishTwo
                cell.textLabel?.borderWidth = 1
                cell.textLabel?.borderColor = .kpGreyishBrown
                cell.textLabel?.cornerRadius = 6
            })
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = .kpGreyishBrown
            view.textLabel?.font = UIFont(name: "UniSansSemiBold", size: 12)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openTelegramChat() {
        let url = URL(string: "https://t.me/kinopubappios")!
        UIApplication.shared.open(url: url)
    }
    
    // MARK: - Navigation
    @objc func showMenu() {
        if let navigationViewController = self.navigationController as? SideMenuItemContent {
            navigationViewController.showSideMenu()
        }
    }
    
}
