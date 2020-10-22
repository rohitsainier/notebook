//
//  Notes.swift
//  notebook
//
//  Created by Rohit Saini on 22/10/20.
//

import Foundation
import RxSwift
import RxCocoa

class Notes {
    static let shared = Notes()
    let notes: BehaviorRelay<[UserListModelElement]> = BehaviorRelay(value: [])
}
