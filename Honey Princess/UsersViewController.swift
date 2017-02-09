//
//  UsersViewController.swift
//  Honey Princess
//
//  Created by Bryan Ye on 27/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class UsersViewController: UIViewController {
    
    //MARK: - Properties
    var users = [User]()
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        prepareDZNEmptyDataSet()
    }
    
    
    //MARK: - Preparations
    func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .honeyPrincessGold()
        DatabaseHelper.Instance.fetchUsersDelegate = self
        DatabaseHelper.Instance.getSingleUsers()
    }
    
    func prepareDZNEmptyDataSet() {
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
}

extension UsersViewController: FetchUsers {
    func dataReceived(users: [User]) {
        print(users)
        self.users = users
        
        tableView.reloadData()
    }
}

extension UsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selfId = AuthHelper.Instance.idForCurrentUser()
        let partner = users[indexPath.row]
        let partnerId = partner.firebaseId
        DatabaseHelper.Instance.saveCouple(user1id: selfId, user2id: partnerId)
        dismiss(animated: true, completion: nil)
    }
}

extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = "\(user.name): \(user.email)"
        cell?.textLabel?.textColor = .white
        cell?.backgroundColor = .clear
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
}

extension UsersViewController: DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "Icon-98")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var titleFont: String?
        
        if openSansExists() {
            titleFont = "OpenSans"
        } else {
            titleFont = "HelveticaNeue"
        }
        
        let attributes: [String: Any] = [
            NSFontAttributeName: UIFont(name: titleFont ?? "HelveticaNeue", size: 18)!,
            NSForegroundColorAttributeName: UIColor.white
        ]
        
        let titleText = "Sorry"
        
        let title = NSAttributedString(string: titleText, attributes: attributes)
        return title
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let descriptionText = "There are currently no single people to match with"
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        
        var descriptionFont: String?
        
        if openSansExists() {
            descriptionFont = "OpenSans"
        } else {
            descriptionFont = "HelveticaNeue"
        }
        
        let attributes: [String: Any] = [
            NSFontAttributeName: UIFont(name: descriptionFont ?? "HelveticaNeue", size: 14)!,
            NSForegroundColorAttributeName: UIColor.white,
            NSParagraphStyleAttributeName: paragraph
        ]
        
        let description = NSAttributedString(string: descriptionText, attributes: attributes)
        
        return description
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.honeyPrincessGold()
    }
    
}

extension UsersViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
}

