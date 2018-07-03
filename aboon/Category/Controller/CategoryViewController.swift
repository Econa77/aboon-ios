//
//  CategoryViewController.swift
//  aboon
//
//  Created by 原口和音 on 2018/06/23.
//  Copyright © 2018 aboon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CategoryViewController: UIViewController {
    
    var model: CategoryCollectionModel!
    var categoryCollectionView: CategoryCollectionView?
    
    func categoriesDidLoad() {
        categoryCollectionView = (self.view as! CategoryView).initializeCollectionView(numberOfCells: model.categories.count)
        categoryCollectionView?.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCell")
        categoryCollectionView?.delegate = self
    }
    
    func imagesDidLoad() {
        dLog("images loaded")
        categoryCollectionView?.dataSource = model
        (self.view as! CategoryView).appendCollectionView()
        (self.view as! CategoryView).stopActivityIndicator()
        (self.view as! CategoryView).setNeedsLayout()
    }
    
    override func loadView() {
        let categoryView = CategoryView()
        self.view = categoryView

        model = CategoryCollectionModel()
        _ = model.fetchCategories()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { (data) in
                    self.model.categories.append(data)
                    
                    dLog("CATEGORIES FETCHING")
                    
                    _ = self.model.fetchCategoryImage(imagePath: data["imagePath"] as! String)
                        .observeOn(MainScheduler.instance)
                        .subscribe(
                            onNext: {(image, path) in
                                self.model.categoryImages.updateValue(image, forKey: path)
                                self.model.imageCount.accept(self.model.imageCount.value + 1)
                        }, onError: { (error) in
                            dLog("Error Loading Image: \(error)")
                        })
            },
                onError: { (error) in
                    dLog("Error Loading: \(error)")
            },
                onCompleted: {
                    self.categoriesDidLoad()
                    _ = self.model.imageCount
                        .subscribe(onNext: { (count) in
                            if count == self.model.categories.count {
                                self.imagesDidLoad()
                                dLog("IMAGES LOADED")
                                dLog(self.model.categoryImages)
                            }
                        })
            })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.configureBarItems(title: "カテゴリー", navigationController: navigationController as! NavigationController)
        (self.view as! CategoryView).setFrame(tabBar: (tabBarController?.tabBar)!, navBar: navigationController?.navigationBar as! NavigationBar)
        (self.view as! CategoryView).appendActivityIndicator()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}

extension CategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let couponListViewController = CouponListViewController(withTitle: model.categories[indexPath.row]["categoryName"] as! String)
        couponListViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(couponListViewController, animated: true)
    }
}

