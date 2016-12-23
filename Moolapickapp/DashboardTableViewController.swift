//
//  DashboardTableViewController.swift
//  Moolapickapp
//
//  Created by Apple Macintosh on 12/23/16.
//  Copyright © 2016 Apple Macintosh. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

struct postStruct {
    let userid : String!
    let savebalance : String!
    let saveid : String!
    let savedate : String!
}

class DashboardTableViewController: UITableViewController {
    
    var posts = [postStruct]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("Saving").queryOrderedByKey().observe(.childAdded, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as? NSDictionary
            let userid = snapshotValue?["userid"] as? String
            let savebalance = snapshotValue?["savebalance"] as? String
            let saveid = snapshotValue?["saveid"] as? String
            let savedate = snapshotValue?["savedate"] as? String
            
            
            self.posts.insert(postStruct(userid: userid, savebalance: savebalance, saveid: saveid, savedate: savedate), at: 0)
            self.tableView.reloadData()
            
            
            
        })
        
        
        

        post()
    }
    
    
    func post(){
        
        let userid = "User id"
        let savebalance = "Save Balance"
        let saveid = "Save id"
        let savedate = "Save Date"
        
        let post : [String : AnyObject] = ["User id" : userid as AnyObject, "Save Balance" : savebalance as AnyObject, "Save id" : saveid as AnyObject, "Save Date" : savedate as AnyObject ]
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("Saving").childByAutoId().setValue(post)
        
        
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return posts.count
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell?.textLabel?.text = posts[indexPath.row].userid
            cell?.detailTextLabel?.text = posts[indexPath.row].savebalance
            return cell!
        } else {
            let label1 = cell?.viewWithTag(1) as? UILabel
            label1?.text = posts[indexPath.row].userid
            
            let label2 = cell?.viewWithTag(2) as? UILabel
            label2?.text = posts[indexPath.row].savebalance
            
            
            let label3 = cell?.viewWithTag(3) as? UILabel
            label3?.text = posts[indexPath.row].savebalance
            
            
            let label4 = cell?.viewWithTag(4) as? UILabel
            label4?.text = posts[indexPath.row].savebalance
           
            return cell!
        }
      
        
        
    }
    
   }
    

    


