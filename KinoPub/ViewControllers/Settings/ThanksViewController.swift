//
//  ThanksViewController.swift
//  KinoPub
//
//  Created by Евгений Дац on 18.08.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit
//import SwiftyMarkdown

class ThanksViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usersTextView: UITextView!
    var titleText: String?
    var url: String?
    var names: String? {
        didSet {
            setup()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .kpBackground
        titleLabel.textColor = .kpLightGreen
        usersTextView.textColor = .kpOffWhite
        usersTextView.backgroundColor = .clear
        titleLabel.text = titleText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global().async {
            do {
                self.names = try String(contentsOf: URL(string: self.url!)!)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func setup() {
        DispatchQueue.main.sync {
//            let md = SwiftyMarkdown(string: names!)
//            md.body.color = UIColor.white
//            md.h1.color = UIColor.kpLightGreen
//            md.h2.color = UIColor.lightGray
//            usersTextView.attributedText = md.attributedString()
            usersTextView.text = names
        }
    }

    // MARK: - Navigation

    static func storyboardInstance() -> ThanksViewController? {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? ThanksViewController
    }

}
