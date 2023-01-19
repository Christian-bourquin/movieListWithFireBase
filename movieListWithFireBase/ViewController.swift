//
//  ViewController.swift
//  movieListWithFireBase
//
//  Created by CHRISTIAN BOURQUIN on 1/17/23.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var movies = [String]()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewOutlet.dequeueReusableCell(withIdentifier: "myCell")!
        cell.textLabel?.text = movies[indexPath.row]
       // cell.detailTextLabel?.text = "Best movies"
        return cell
    }
    
    var ref: DatabaseReference!

    @IBOutlet weak var textFieldOutlet: UITextField!
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //next two lines very very important
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
      //  ref.child("Movies").childByAutoId().setValue("harry potter")
        ref.child("Movies").observe(.childAdded) { snapshot in
            var name = snapshot.value as! String
            self.movies.append(name)
            self.tableViewOutlet.reloadData()
            print("hello")
        }
    }

    @IBAction func addMovieAction(_ sender: Any) {
        if textFieldOutlet.text != ""{
            ref.child("Movies").childByAutoId().setValue(textFieldOutlet.text)
        }
    }
    
}

