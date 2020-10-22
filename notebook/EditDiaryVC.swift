//
//  EditDiaryVC.swift
//  notebook
//
//  Created by Rohit Saini on 22/10/20.
//

import UIKit
import SainiUtils
import RxSwift
import RxCocoa

class EditDiaryVC: UIViewController {

    @IBOutlet weak var contentTxt: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var diaryContentLbl: UILabel!
    @IBOutlet weak var titleTxt: UITextField!
    var noteIndex: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    
        // Do any additional setup after loading the view.
    }
    private func configUI(){
        diaryContentLbl.sainiAddTapGesture {
            self.contentTxt.becomeFirstResponder()
        }
        titleTxt.text = Notes.shared.notes.value[noteIndex].title
        diaryContentLbl.text = Notes.shared.notes.value[noteIndex].content
        contentTxt.text = Notes.shared.notes.value[noteIndex].content
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        saveBtn.sainiCornerRadius(radius: 20)
    }
    
    @IBAction func clickSaveBtn(_ sender: UIButton) {
        var updatedNote = Notes.shared.notes.value
        updatedNote[noteIndex].title = titleTxt.text ?? ""
        updatedNote[noteIndex].content = diaryContentLbl.text ?? ""
        Notes.shared.notes.accept(updatedNote)
        self.navigationController?.popViewController(animated: true)
    }
}

extension EditDiaryVC: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == contentTxt{
            diaryContentLbl.text = textField.text
        }
       return true
    }
}
