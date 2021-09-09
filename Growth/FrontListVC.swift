//
//  FrontListVC.swift
//  Growth
//
//  Created by eunae on 2021/09/09.
//

import UIKit

// UICollectionViewDataSource : 컬렉션 뷰의 셀은 총 몇 개?
// UICollectionViewDelegate : 컬렉션 뷰를 어떻게 보여줄 것인가?
class FrontVC: UIViewController {
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    let frontList: [FrontData] = [
        FrontData(frontImg: UIImage(named: "pet.JPG")!, name: "먼지"),
        FrontData(frontImg: UIImage(named: "plants.HEIC")!, name: "오이"),
        FrontData(frontImg: UIImage(named: "food.HEIC")!, name: "오늘의 음식"),
        FrontData(frontImg: UIImage(named: "sky.HEIC")!, name: "오늘의 하늘"),
        FrontData(frontImg: UIImage(named: "study.PNG")!, name: "공부 기록"),
        FrontData(frontImg: UIImage(named: "question.JPG")!, name: "하루에 한 문제"),
        FrontData(frontImg: UIImage(named: "phrase.JPG")!, name: "하루에 한 글귀"),
        FrontData(frontImg: UIImage(named: "ootd.JPG")!, name: "OOTD"),
        FrontData(frontImg: UIImage(named: "diary.HEIC")!, name: "나의 일기")
    ]
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
    }

}

extension FrontVC: UICollectionViewDataSource, UICollectionViewDelegate {
    // 컬렉션 뷰에 총 몇개의 벳울 표시할 것인가
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return frontList.count
    }
    
    // 해당 cell에 무슨 셀을 표시할 지 결정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = frontList[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "frontCell", for: indexPath) as! FrontCell
        
        cell.frontImgView.image = item.frontImg
        cell.frontImgView.contentMode = .scaleAspectFill
        cell.nameLabel.text = item.name
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.frame.width
            let height = collectionView.frame.height
            
            let itemsPerRow: CGFloat = 2
            let widthPadding = sectionInsets.left * (itemsPerRow + 1)
            let itemsPerColumn: CGFloat = 3
            let heightPadding = sectionInsets.top * (itemsPerColumn + 1)
            
            let cellWidth = (width - widthPadding) / itemsPerRow
            let cellHeight = (height - heightPadding) / itemsPerColumn
        
            return CGSize(width: cellWidth, height: cellHeight)
        }
    
    func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            insetForSectionAt section: Int) -> UIEdgeInsets {
          return sectionInsets
        }
        
    func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
        
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    
}
