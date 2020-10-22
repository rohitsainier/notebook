//
//  DiaryVC.swift
//  notebook
//
//  Created by Rohit Saini on 21/10/20.
//

import UIKit
import RxSwift
import RxCocoa
import SainiUtils
class DiaryVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var diaryVM: DiaryViewModel = DiaryViewModel()
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
    }
    
    private func configUI(){
        setupTableRxObserver()
        diaryVM.delegate = self
        tableView.register(UINib(nibName: "DiaryCell", bundle: nil), forCellReuseIdentifier: "DiaryCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        diaryVM.notes()
    }
    
    private func setupTableRxObserver(){
        
        Notes.shared.notes.asObservable()
            .subscribe(onNext: { [unowned self] notes in
                if let savedNotes = UserDefaults.standard.get(UserListModel.self, forKey: "Notes"){
                    if Notes.shared.notes.value.count == 0{
                        Notes.shared.notes.accept(savedNotes)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - Table View DataSource and Delegate Methods
extension DiaryVC: UITableViewDataSource, UITableViewDelegate {
    
    // numberOfSections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Notes.shared.notes.value.count
    }
    
    // estimatedHeightForRowAt
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else {
                return UITableViewCell()
            }
        cell.diaryTitleLbl.text = Notes.shared.notes.value[indexPath.row].title
        cell.desLbl.text = Notes.shared.notes.value[indexPath.row].content
        cell.timeAgoLbl.text = Notes.shared.notes.value[indexPath.row].date.UTCToLocal(incomingFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outGoingFormat: "MM-d-yyyy, hh:mm a")
        cell.editBtn.tag = indexPath.row
        cell.deleteBtn.tag = indexPath.row
        cell.editBtn.addTarget(self, action: #selector(editNote(sender:)), for: .touchUpInside)
        cell.deleteBtn.addTarget(self, action: #selector(deleteNote(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func editNote(sender: UIButton){
        let vc: EditDiaryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditDiaryVC") as! EditDiaryVC
        vc.noteIndex = sender.tag
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func deleteNote(sender: UIButton){
        let updatedNotesArr = Notes.shared.notes.value.filter({$0.id != Notes.shared.notes.value[sender.tag].id})
        Notes.shared.notes.accept(updatedNotesArr)
    }
    
}


extension DiaryVC: DiaryDelegate{
    func didReceivedNotes(response: UserListModel) {
        Notes.shared.notes.accept(response)
        UserDefaults.standard.set(encodable: response, forKey: "Notes")
    }
}
