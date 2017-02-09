//
//  UsersViewController.swift
//  Honey Princess
//
//  Created by Bryan Ye on 27/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController {
    
    //MARK: - Properties
    var users = [User]()
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
    }
    
    
    //MARK: - Preparations
    func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .honeyPrincessGold()
        DatabaseHelper.Instance.fetchUsersDelegate = self
        DatabaseHelper.Instance.getSingleUsers()
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
