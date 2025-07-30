//
//  NotesTableViewController.swift
//  NotesApp
//
//  Created by Abdelrahman Zain on 28/07/2025.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController {
    
    var currentAlertAction: UIAlertAction?
    let context = PersistentContainer.shared.viewContext
    
    var unpinnedNotes = [Note]()
    var pinnedNotes = [Note]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "NotesTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NoteCell")
        
        load()
    }
    
    //MARK: - Add New Note
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Note" , message: "", preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Enter Note name"
            alertTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { UIAlertAction in
            
            let text = alert.textFields?.first?.text ?? ""
            //            let newCategory = Category(context: self.context)
            //            newCategory.name = text
            //            //            print("User typed: \(text)")
            let newNote = Note(context: self.context)
            newNote.title = text
            newNote.isPinned = false
            newNote.createdAt = Date()
            
            self.unpinnedNotes.append(newNote)
            self.save()
        }
        action.isEnabled = false
        
        self.currentAlertAction = action
        
        alert.addAction(action)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        currentAlertAction?.isEnabled = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    //MARK: - Data Manipulation Methods

    func save(reload: Bool = true) {
        do {
            try context.save()
        } catch {
            print("Error saving new category: \(error.localizedDescription)")
        }
        if reload {
            tableView.reloadData()
        }
    }
    
    
    func load(with predicate: NSCompoundPredicate? = nil) {
        
        let request : NSFetchRequest<Note> = Note.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        let pinnedPredicate = NSPredicate(format: "isPinned == true")
        let unpinnedPredicate = NSPredicate(format: "isPinned == false")
        if let searchPredicate = predicate {
            request.predicate = searchPredicate
            do {
                self.unpinnedNotes = try context.fetch(request)
            } catch {
                print("Error fetching data from context \(error)")
            }
        }
        
        else {
            request.predicate = pinnedPredicate
            do {
                self.pinnedNotes = try context.fetch(request)
            } catch {
                print("Error fetching data from context \(error)")
            }
            request.predicate = unpinnedPredicate

            do {
                self.unpinnedNotes = try context.fetch(request)
            } catch {
                print("Error fetching data from context \(error)")
            }
        }
        
        tableView.reloadData()
    }
    
    
    func noteForIndex(at indexPath: IndexPath) -> Note {
        if pinnedNotes.isEmpty {
            return unpinnedNotes[indexPath.row]
        } else {
            return indexPath.section == 0 ? pinnedNotes[indexPath.row] : unpinnedNotes[indexPath.row]
        }
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return pinnedNotes.isEmpty ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 && !pinnedNotes.isEmpty ? pinnedNotes.count : unpinnedNotes.count
    }

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Pinned Notes" : "Notes"
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
         let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NotesTableViewCell

         let note = noteForIndex(at: indexPath)
         cell.titleLabel.text = note.title
         cell.createdAtLabel.text = note.createdAt?.formatted()
         
     
     return cell
     }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
//    
//    func noteForIndex(at indexPath: IndexPath) -> Note {
//        if pinnedNotes.isEmpty {
//            return unpinnedNotes[indexPath.row]
//        } else {
//            return indexPath.section == 0 ? pinnedNotes[indexPath.row] : unpinnedNotes[indexPath.row]
//        }
//    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! NotesViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            if pinnedNotes.isEmpty {
                destinationVC.selectedNote = unpinnedNotes[indexPath.row]
            } else {
                if indexPath.section == 0 {
                    destinationVC.selectedNote = pinnedNotes[indexPath.row]
                } else {
                    destinationVC.selectedNote = unpinnedNotes[indexPath.row]
                }
            }
        }
    }*/
}

// MARK: - Search Bar

extension NotesTableViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
        
            let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            let contentPredicate = NSPredicate(format: "content CONTAINS[cd] %@", searchBar.text!)
            let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])

            load(with: predicate)
        } else{
            load()
        }
        
    }
}

