//
//  ContentCollectionViewController.swift
//  KinoPub
//
//  Created by hintoz on 06.03.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit

class ContentCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        if let collectionView = self.collectionView {
            collectionView.contentInset = UIEdgeInsets(top: 8.0, left: 7.0, bottom: 8.0, right: 7.0)

            collectionView.register(UINib(nibName: String(describing: ItemCollectionViewCell.self), bundle: Bundle.main),
                                          forCellWithReuseIdentifier: String(describing: ItemCollectionViewCell.self))
            collectionView.register(UINib(nibName:String(describing:LoadingItemCollectionViewCell.self), bundle: Bundle.main),
                                          forCellWithReuseIdentifier: LoadingItemCollectionViewCell.reuseIdentifier)
        }
    }
/*
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            let width = self.collectionView!.bounds.width / 5.5
            let height = width * 1.66
            flowLayout.itemSize = CGSize(width: width, height: height)
        } else {
            let width = self.collectionView!.bounds.width / 3.5
            let height = width * 1.66
            flowLayout.itemSize = CGSize(width: width, height: height)
        }
        
        flowLayout.invalidateLayout()
    }
 */

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateCollectionViewLayout(with: size)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    private func updateCollectionViewLayout(with size: CGSize) {
//        let itemSizeForPortraitMode = CGSize(width: self.collectionView!.bounds.width / 3.5, height: self.collectionView!.bounds.width / 3.5 * 1.66)
//        let itemSizeForLandscapeMode = CGSize(width: self.collectionView!.bounds.width / 4.5, height: self.collectionView!.bounds.width / 4.5 * 1.66)
        if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.itemSize = (size.width < size.height) ? itemSizeForPortraitMode : itemSizeForLandscapeMode
            layout.invalidateLayout()
        }
    }

}
