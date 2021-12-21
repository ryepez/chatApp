//
//  ListOfPeopleViewController.swift
//  chatDare
//
//  Created by Ramon Yepez on 12/19/21.
//

import UIKit
import Firebase
import FirebaseStorageUI



class ListOfPeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference!
    var chatID = String()
    var listOfPeople: [UserOnList] = []
    var lista: [UserOnList] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
   
        configureDB(chatID: chatID) { dic in
            for user in dic.keys {
                
                let llaves = user as String

                self.getProfile(userData: llaves) { userOnlist in
                    self.lista.append(userOnlist)
                    self.tableView.reloadData()
                }
                
            }
        }
                
        self.tableView.rowHeight = (view.frame.height/10)
        self.tableView.separatorStyle = .none
    }
    
    
    
    func configureDB(chatID: String, completion: @escaping ([String:Any]) -> Void) {
        //getting a reference to the db
        
        
        ref = Database.database().reference()
        
        ref.child("members").child(chatID).getData { error, dataShap in
            
            if error != nil {
                completion([:])
            } else {
                
                let values = dataShap.value as! [String:Any]
                completion(values)
                           
                           }
            
        }
           
        
    }
    
    func getProfile(userData: String, completion: @escaping (UserOnList) -> Void) {
        
       // var arrayOfValues: [UserOnList] = []

        
        ref.child("usersInfo").child(userData).getData { error, dataShapy in
            
            let values = dataShapy.value as! [String: Any]
            
            let userInfo = UserOnList(userName: values["userName"] as! String, profileURL: values["profileFotoURL"] as! String)
            
            completion(userInfo)
        }
        
        
    }
 
    deinit {
        //this is to remove the lisenser so we do not run of memory after this class get deinit
      //  Auth.auth().removeStateDidChangeListener(_authHandle)
        
            print("deinit \(self)")
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section:Int) -> String?
    {
    
      return "Chat Participants"
   }
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return lista.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
         let person = lista[indexPath.row]

         let cell =
         tableView.dequeueReusableCell(withIdentifier: "OnListTableViewCell", for: indexPath) as! OnListTableViewCell
         
         
         cell.userName.text = person.userName
         
         let gsReference = Storage.storage().reference(forURL:  person.profileURL)

         cell.userPhoto.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
         cell.userPhoto.sd_setImage(with: gsReference, placeholderImage: UIImage(systemName: "person.fill"))
         cell.userPhoto.sd_imageTransition = .fade

         
         //setting the round image
     cell.imageStack.layer.cornerRadius = cell.imageStack.bounds.height / 2
     cell.imageStack.layer.borderWidth = 3.5
         cell.imageStack.layer.borderColor = UIColor.white.cgColor
     cell.imageStack.clipsToBounds = true
         
         return cell
     }
    
    @IBAction func dimiss(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)

    }
    
}
