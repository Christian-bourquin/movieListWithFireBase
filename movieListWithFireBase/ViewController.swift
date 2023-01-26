//
//  ViewController.swift
//  movieListWithFireBase
//
//  Created by CHRISTIAN BOURQUIN on 1/17/23.
//
class Movies{
    var name: String
    var rating: Double
    var ref = Database.database().reference()
    var key = ""
    init(name: String, rating: Double) {
        self.name = name
        self.rating = rating
    }
    init(dict: [String: Any]) {
        if let n = dict["name"] as? String{
            name = n
        }
        else{
            name = ""
        }
        if let a = dict["rating"] as? Double{
            rating = a
        }
        else {
            rating = 0
        }
    }
    func saveToFireBase(){
        var dict = ["name":name,"rating":rating] as [String: Any]
        key = ref.child("Movies").childByAutoId().key ?? ""
        ref.child("Movies").child(key).setValue(dict)
        
    }
    func deleteFromFirebase (){
        ref.child("Movies").child(key).removeValue()
    }
    func updateFirebase(){
        let dict = ["name": name,"rating": rating] as! [String: Any]
        ref.child("Movies").child(key).updateChildValues(dict)
        
    }
}



import UIKit
import FirebaseCore
import FirebaseDatabase
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var ref: DatabaseReference!
    //var names = [String]()
    var Movie = [Movies]()
    var selectedIndex = -1
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Movie.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewOutlet.dequeueReusableCell(withIdentifier: "myCell")!
        cell.textLabel?.text = Movie[indexPath.row].name
        cell.detailTextLabel?.text = String(Movie[indexPath.row].rating)
        return cell
    }
    
    

    @IBOutlet weak var textFieldOutlet: UITextField!
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    @IBOutlet weak var ratingFieldOutlet: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //next two lines very very important
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
      //  ref.child("Movies").childByAutoId().setValue("harry potter")
        ref.child("Movies").observe(.childAdded) { snapshot in
            
            var dict = snapshot.value as! [String: Any]
            var stews = Movies(dict: dict)
            stews.key = snapshot.key
            self.Movie.append(stews)
            self.tableViewOutlet.reloadData()
            
        }
        
        ref.child("Movies").observe(.childChanged) { snapshot in
            
            var dict = snapshot.value as! [String: Any]
            
            for i in 0 ..< self.Movie.count{
                if self.Movie[i].key == snapshot.key{
                    self.Movie[i].name = dict["name"] as! String
                    self.Movie[i].rating = dict["rating"] as! Double
                    self.tableViewOutlet.reloadData()
                    break
                }
            }
            self.tableViewOutlet.reloadData()
        }
        
        ref.child("students2").observe(.childRemoved) { snapshot in
            
            var dict = snapshot.value as! [String: Any]
            for i in 0 ..< self.Movie.count{
                if self.Movie[i].key == snapshot.key{
                    self.Movie.remove(at: i)
                    self.tableViewOutlet.reloadData()
                    break
                }
            }
        }
    }

    @IBAction func addMovieAction(_ sender: Any) {
        let name = textFieldOutlet.text!
        let rating = Double(ratingFieldOutlet.text!)!
        var stew = Movies(name: name, rating: rating)
        stew.saveToFireBase()
    }
    
    @IBAction func editAction(_ sender: Any) {
        Movie[selectedIndex].name = textFieldOutlet.text!
        Movie[selectedIndex].rating = Double(ratingFieldOutlet.text!)!
        Movie[selectedIndex].updateFirebase()
        tableViewOutlet.reloadData()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            Movie[indexPath.row].deleteFromFirebase()
            Movie.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

