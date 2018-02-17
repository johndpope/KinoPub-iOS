//
//  SwitchCustomTableViewCell.swift
//  KinoPub
//
//  Created by Евгений Дац on 13.02.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit
import Eureka

open class SwitchCustomTableViewCell: Cell<Bool>, CellType {
    
    @IBOutlet public weak var switchControl: UISwitch!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var iconImageView: UIImageView!

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        let switchC = UISwitch()
//        switchControl = switchC
//        accessoryView = switchControl
//        editingAccessoryView = accessoryView
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func setup() {
        super.setup()
        selectionStyle = .none
        switchControl.addTarget(self, action: #selector(SwitchCustomTableViewCell.valueChanged), for: .valueChanged)
    }
    
    deinit {
        switchControl?.removeTarget(self, action: nil, for: .allEvents)
    }
    
    open override func update() {
        super.update()
        switchControl.isOn = row.value ?? false
        switchControl.isEnabled = !row.isDisabled
    }
    
    @objc func valueChanged() {
        row.value = switchControl?.isOn ?? false
    }
}

// MARK: SwitchRow

open class _SwitchCustomRow: Row<SwitchCustomTableViewCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<SwitchCustomTableViewCell>(nibName: "SwitchCustomTableViewCell")
    }
}

/// Boolean row that has a UISwitch as accessoryType
public final class SwitchCustomRow: _SwitchCustomRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
