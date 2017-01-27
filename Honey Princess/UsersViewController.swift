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
        DatabaseHelper.Instance.delegate = self
        DatabaseHelper.Instance.getUsers()
    }
    
    
    
    
}

extension UsersViewController: FetchData {
    func dataReceived(users: [User]) {
        self.users = users
        
        tableView.reloadData()
    }
}

extension UsersViewController: UITableViewDelegate {
    
}

extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = user.name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
}
