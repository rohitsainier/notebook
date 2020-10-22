//
//  DiaryViewModel.swift
//  notebook
//
//  Created by Rohit Saini on 22/10/20.
//

import Foundation
import SainiUtils


// MARK: - UserListModelElement
struct UserListModelElement: Codable {
    var id, title, content, date: String
}

typealias UserListModel = [UserListModelElement]


protocol DiaryDelegate{
    func didReceivedNotes(response: UserListModel)
}

struct DiaryViewModel {
    var delegate: DiaryDelegate?
    
    func notes(){
        GCD.Diary.notes.async {
            APIManager.sharedInstance.I_AM_COOL_GET(params: [String : Any](), api: API.Diary.notes, Loader: false, isMultipart: false) { (response) in
                if response != nil{                             //if response is not empty
                    do {
                        let success = try JSONDecoder().decode(UserListModel.self, from: response!) // decode the response into success model
                        self.delegate?.didReceivedNotes(response: success)
                    }
                    catch let err {
                        log.error("ERROR OCCURED WHILE DECODING: \(Log.stats()) \(err)")/
                    }
                }
            }
        }
    }
}
