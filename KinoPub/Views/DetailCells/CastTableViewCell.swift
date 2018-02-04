import UIKit

class CastTableViewCell: UITableViewCell {

    static let reuseIdentifier = "CastTableViewCell"
    
    var actors = [String]()
    var directors = [String]()

    @IBOutlet weak var actorsTitleLabel: UILabel!
    @IBOutlet weak var directorsTitleLabel: UILabel!

    @IBOutlet weak var directorStackView: UIStackView!
    @IBOutlet weak var actorsStackView: UIStackView!
    
    @IBOutlet weak var directorCollectionView: UICollectionView! {
        didSet {
            directorCollectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
    }
    @IBOutlet weak var actorCollectionView: UICollectionView! {
        didSet {
            actorCollectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
    }
    @IBOutlet weak var directorCollectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var actorCellectionHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.clear
        configureLabels()

        directorCollectionView.register(UINib(nibName: String(describing: ActorCollectionViewCell.self), bundle: Bundle.main),
                                        forCellWithReuseIdentifier: String(describing: ActorCollectionViewCell.self))
        actorCollectionView.register(UINib(nibName: String(describing: ActorCollectionViewCell.self), bundle: Bundle.main),
                                        forCellWithReuseIdentifier: String(describing: ActorCollectionViewCell.self))
        directorCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapDirector(_:))))
        actorCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapActor(_:))))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(with actors: String?, directors: String?) {
        configure(directors: directors)
        directorCollectionView.reloadData()
        configure(actors: actors)
        actorCollectionView.reloadData()
    }

    func configure(actors: String?) {
        guard actors != "" else {
//            actorsTitleLabel.isHidden = true
//            actorCellectionHeightConstraint.constant = 0
            actorsStackView.isHidden = true
            return
        }

        if let actors = actors?.components(separatedBy: ", ") {
            self.actors = actors
            if actors.count > 3 {
                actorCellectionHeightConstraint.constant = 170
            }
        }
    }

    func configure(directors: String?) {
        guard directors != "" else {
//            directorsTitleLabel.isHidden = true
//            directorCollectionHeightConstraint.constant = 0
            directorStackView.isHidden = true
            return
        }

        if let directors = directors?.components(separatedBy: ", ") {
            self.directors = directors
        }
    }

    func configureLabels() {
        actorsTitleLabel.textColor = .kpGreyishBrown
        directorsTitleLabel.textColor = .kpGreyishBrown
    }
    
    @objc func tapDirector(_ sender: UITapGestureRecognizer) {
        if let indexPath = self.directorCollectionView.indexPathForItem(at: sender.location(in: self.directorCollectionView)) {
            let parameters = ["director" : directors[indexPath.row]]
            showItemVC(withParameters: parameters)
        }
    }
    
    @objc func tapActor(_ sender: UITapGestureRecognizer) {
        if let indexPath = self.actorCollectionView.indexPathForItem(at: sender.location(in: self.actorCollectionView)) {
            let parameters = ["actor" : actors[indexPath.row]]
            showItemVC(withParameters: parameters)
        }
    }
    
    func showItemVC(withParameters parameters: [String : String]) {
        if let itemVC = ActorCollectionViewController.storyboardInstance() {
            itemVC.viewModel.parameters = parameters
            itemVC.title = parameters["director"] ?? parameters["actor"]
            parentViewController?.navigationController?.pushViewController(itemVC, animated: true)
        }
    }
}

extension CastTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.directorCollectionView {
            return directors.count
        }
        return actors.count

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == directorCollectionView {
            let cell = directorCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ActorCollectionViewCell.self), for: indexPath) as! ActorCollectionViewCell
            cell.configure(with: directors[indexPath.row])
            return cell
        } else {
            let cell = actorCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ActorCollectionViewCell.self), for: indexPath) as! ActorCollectionViewCell
            cell.configure(with: actors[indexPath.row])
            return cell
        }
    }
}

extension CastTableViewCell: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
//        let screenwith  = ScreenSize.SCREEN_WIDTH
//        let colum:Float = 2.0, spacing:Float = 8.0;
//        let value = floorf((Float(screenwith) - (colum - 1) * spacing) / colum)
//        let cellHeight = screenwith*0.48
//        let cellWidth = CGFloat(value + (value / 1.3 ))
        
        
//        return  CGSize(width: 320, height: 50)
//    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return 0
    }

}
