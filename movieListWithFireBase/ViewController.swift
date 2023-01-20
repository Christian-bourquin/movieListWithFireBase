//
//  ViewController.swift
//  movieListWithFireBase
//
//  Created by CHRISTIAN BOURQUIN on 1/17/23.
//
class movies{
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
    var Movie = [movies]()
    var selectedIndex = -1
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewOutlet.dequeueReusableCell(withIdentifier: "myCell")!
        cell.textLabel?.text = movies[indexPath.row]
       // cell.detailTextLabel?.text = "Best movies"
        return cell
    }
    
    

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
        
        ref.child("Movies").observe(.childChanged) { snapshot in
            
            var name = snapshot.value as! String
            
            for i in 0 ..< self.movies.count{
                if self.movies[i].key == snapshot.key{
                    self.movies[i] = dict["name"] as! String
                    self.tableViewOutlet.reloadData()
                    break
                }
            }
            self.tableViewOutlet.reloadData()
        }
        
        ref.child("students2").observe(.childRemoved) { snapshot in
            
            var name = snapshot.value as! String
                    for i in 0 ..< self.movies.count{
                if self.students[i].key == snapshot.key{
                    self.students.remove(at: i)
                    self.tableViewOutlet.reloadData()
                    break
                }
            }
        }
    }

    @IBAction func addMovieAction(_ sender: Any) {
        if textFieldOutlet.text != ""{
            ref.child("Movies").childByAutoId().setValue(textFieldOutlet.text)
        }
    }
    
    @IBAction func editAction(_ sender: Any) {
        movies[selectedIndex] = textFieldOutlet.text!
       
        tableViewOutlet.reloadData()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
    }
    func deleteFromFireBase(){
        ref.child("students2").child().removeValue()
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            movies[indexPath.row].deleteFromFirebase()
            movies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

