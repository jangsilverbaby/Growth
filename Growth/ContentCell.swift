//
//  ContentCell.swift
//  Growth
//
//  Created by eunae on 2021/11/09.
//

import UIKit
import CoreData

class ContentCell: UITableViewCell {
    @IBOutlet weak var regdate: UILabel! // 등록 날짜
    @IBOutlet weak var contents: UILabel! // 게시글
    @IBOutlet weak var contentImage: UIImageView! // 게시 이미지
    @IBOutlet weak var setting: UIButton! // 설정 버튼
}
