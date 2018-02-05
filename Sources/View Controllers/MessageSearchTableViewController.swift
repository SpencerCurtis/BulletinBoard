//
//  MessageSearchTableViewController.swift
//  BulletinBoard
//
//  Created by Spencer Curtis on 2/5/18.
//  Copyright © 2018 Open Reel Software. All rights reserved.
//

import UIKit

class MessageSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadViews),
                                               name: MessagesController.DidFinishSearchNotification,
                                               object: nil)
    }
    
    @objc func reloadViews() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let email = searchBar.text else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        MessagesController.shared.fetchMessagesFromUserWith(email: email)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessagesController.shared.searchedUserMessages.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        
        let message = MessagesController.shared.searchedUserMessages[indexPath.row]
        
        cell.textLabel?.text = message.messageText
        cell.detailTextLabel?.text = dateFormatter.string(from: message.date)
        
        return cell
    }
}

