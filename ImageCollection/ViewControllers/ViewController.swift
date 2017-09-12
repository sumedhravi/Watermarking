//
//  ViewController.swift
//  ImageCollection
//
//  Created by Sumedh Ravi on 07/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit
import Photos


class ViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    var userImages : [UIImage] = []
    @IBOutlet weak var collectionView: UICollectionView!
//    let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(YourViewController.back(sender:)))
//    self.navigationItem.leftBarButtonItem = newBackButton
    
    @IBAction func doneButton(_ sender: Any) {
        let indexPathsSelected = self.collectionView.indexPathsForSelectedItems
        guard (!(indexPathsSelected?.isEmpty)!) else{
            let alert = UIAlertController(title: "ERROR",message: "No Images Selected",preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
                (alertAction: UIAlertAction!) in
                alert.dismiss(animated: true, completion:nil) }))
            return
        }
        var selectedImages : [UIImage]=[]
        for path in indexPathsSelected!{
            selectedImages.append(userImages[path.item])
        }
        
        let newController = self.storyboard?.instantiateViewController(withIdentifier: "selectedVC") as! SelectedImageViewController
        newController.sample = selectedImages
        navigationController?.pushViewController(newController, animated: true)

    
    }

        
    override func viewDidLoad() {
        super.viewDidLoad()
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.barTintColor = UIColor.magenta
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        self.collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collectionViewCell")
        
        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let defaultSize = (UIScreen.main.bounds.width / 4) - (2)
        navigationItem.title = "Home Page"
        layout?.itemSize = CGSize(width: defaultSize, height: defaultSize)
        layout?.minimumInteritemSpacing = 1
        layout?.minimumLineSpacing = 1
        layout?.invalidateLayout()

        getImages()
        getImages()
        getImages()
        getImages()
        getImages()
        getImages()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        cell.cellImage.image = userImages[indexPath.item]
        if cell.isSelected{
            cell.selectionImage.backgroundColor = UIColor.green
        }
        else{
            cell.selectionImage.backgroundColor = UIColor.clear
        }
        return cell
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let height = self.view.frame.size.height;
//        let width  = self.view.frame.size.width;
//        return CGSize(width: width/2.5, height: height/3)
//    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)as! CollectionViewCell
        cell.selectionImage.backgroundColor = UIColor.green
        //cell.isSelected = true
        //collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)as! CollectionViewCell
        cell.selectionImage.backgroundColor = UIColor.clear
        //cell.isSelected = false
        //collectionView.reloadData()
    }

    
    func getImages(){
    
        let imageManagerObject = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        let fetchResults = PHAsset.fetchAssets(with: .image, options: nil)
        if(fetchResults.count>0){
            for i in 0...(fetchResults.count-1){
                imageManagerObject.requestImage(for: fetchResults.object(at: i), targetSize:CGSize(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height*0.3) , contentMode: .aspectFill , options: requestOptions, resultHandler: {image, error in self.userImages.append(image!)
            })
        
        
        }
    }
    else{
        //self.collectionView.reloadData()
    }
    return
}
}
