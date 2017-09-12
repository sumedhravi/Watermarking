//
//  SelectedImageViewController.swift
//  ImageCollection
//
//  Created by Sumedh Ravi on 08/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit

class SelectedImageViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collection: UICollectionView!
    var sample: [UIImage] = []
    //let newBackButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector (proceed))

    

    override func viewDidLoad() {
        super.viewDidLoad()
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.barTintColor = UIColor.black
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture))
        self.collection.addGestureRecognizer(longPressGesture)
        self.collection.dataSource = self
        self.collection.delegate = self
        let layout = self.collection.collectionViewLayout as? UICollectionViewFlowLayout
        let defaultSize = (UIScreen.main.bounds.width / 4) - (2)
        let newBackButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector (proceed))

        self.navigationItem.rightBarButtonItem = newBackButton
        navigationItem.title = "Selected Images"
        layout?.itemSize = CGSize(width: defaultSize, height: defaultSize)
        layout?.minimumInteritemSpacing = 1
        layout?.minimumLineSpacing = 1
        layout?.invalidateLayout()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sample.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let view = cell.viewWithTag(1) as? UIImageView
        view?.image = sample[indexPath.item]
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let temp = sample[sourceIndexPath.item]
//        sample[sourceIndexPath.item] = sample[destinationIndexPath.item]
//        sample[destinationIndexPath.item]=temp
        if sourceIndexPath.item<destinationIndexPath.item{
            let temp = sample[sourceIndexPath.item]
            for i in sourceIndexPath.item...destinationIndexPath.item-1{
                sample[i] = sample[i+1]
            }
                sample[destinationIndexPath.item] = temp
        }
        else{
            let temp = sample[sourceIndexPath.item]
            for i in (destinationIndexPath.item+1...sourceIndexPath.item).reversed(){
                sample[i] = sample[i-1]
            }
            sample[destinationIndexPath.item] = temp

        }
        collection.reloadData()
    }

    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collection.indexPathForItem(at: gesture.location(in: self.collection)) else {
                break
            }
            collection.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            collection.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            collection.endInteractiveMovement()
        default:
            collection.cancelInteractiveMovement()
        }
        collection.reloadData()
    }
    
    func proceed(){
               
        let newController = self.storyboard?.instantiateViewController(withIdentifier: "conversionVC") as! ConversionViewController
        newController.userImages = self.sample
        navigationController?.pushViewController(newController, animated: true)

    }
}
