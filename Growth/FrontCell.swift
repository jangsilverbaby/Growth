//
//  FrontCell.swift
//  Growth
//
//  Created by eunae on 2021/09/09.
//

import UIKit

class FrontCell: UICollectionViewCell {
    @IBOutlet weak var frontImgView: UIImageView! // 프로필 이미지 뷰
    @IBOutlet weak var nameLabel: UILabel! // 이름 라벨
    @IBOutlet weak var editBtn: UIButton! // 수정 버튼
    @IBOutlet weak var contentAddBtn: UIButton! // 게시물 추가 버튼

    var cornerRadius: CGFloat = 5.0
    
    // 인터페이스 빌더에서 뷰가 만들어졌을때 호출
    // 객체가 초기화(인스턴스화)된 후 호출
    override func awakeFromNib() {
        super.awakeFromNib()

        // 셀을 둥글게 만들기
        self.layer.cornerRadius = cornerRadius
    }
}
