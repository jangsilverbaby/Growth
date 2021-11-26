//
//  FrontData.swift
//  Growth
//
//  Created by eunae on 2021/09/09.
//

import UIKit

// 프로필 리스트 화면에서 보이는 프로필 이미지와 이름 
class FrontData {
    var frontImg: UIImage // 프로필 이미지
    var name: String // 이름
    
    init(frontImg: UIImage, name: String) {
        self.frontImg = frontImg
        self.name = name
    }
}
