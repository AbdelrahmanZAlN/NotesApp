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
    var notes = [Note]()
    var unpinnedNotes = [Note]()
    var pinnedNotes = [Note]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "NotesTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NoteCell")
        
        load()
    }
    override func viewWillAppear(_ animated: Bool) {
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
            newNote.content = "Content"
            self.notes.append(newNote)
            self.save()
            self.reloadNotes()
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
    func load(with searchPredicate: NSCompoundPredicate? = nil) {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        if let predicate = searchPredicate {
            request.predicate = predicate
        }

        do {
            notes = try context.fetch(request)
            reloadNotes()
        } catch {
            print("Error fetching notes: \(error)")
        }
    }
    
    func noteForIndex(at indexPath: IndexPath) -> Note {
        if pinnedNotes.isEmpty {
            return unpinnedNotes[indexPath.row]
        } else {
            return indexPath.section == 0 ? pinnedNotes[indexPath.row] : unpinnedNotes[indexPath.row]
        }
    }

    func reloadNotes(reloadTable : Bool = true) {
        self.pinnedNotes = notes.filter { $0.isPinned }
        self.unpinnedNotes = notes.filter { !$0.isPinned }
        if reloadTable {
            tableView.reloadData()
        }
    }
    
    /*
    func load(with searchPredicate: NSCompoundPredicate? = nil) {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

        if let searchPredicate = searchPredicate {
            // Combine search with isPinned == true
            let pinnedFilter = NSCompoundPredicate(andPredicateWithSubpredicates: [
                searchPredicate,
                NSPredicate(format: "isPinned == true")
            ])
            request.predicate = pinnedFilter
            do {
                pinnedNotes = try context.fetch(request)
            } catch {
                print("Error fetching pinned notes: \(error)")
            }

            // Combine search with isPinned == false
            let unpinnedFilter = NSCompoundPredicate(andPredicateWithSubpredicates: [
                searchPredicate,
                NSPredicate(format: "isPinned == false")
            ])
            request.predicate = unpinnedFilter
            do {
                unpinnedNotes = try context.fetch(request)
            } catch {
                print("Error fetching unpinned notes: \(error)")
            }
        } else {
            // No predicate, regular fetch
            request.predicate = NSPredicate(format: "isPinned == true")
            do {
                pinnedNotes = try context.fetch(request)
            } catch {
                print("Error fetching pinned notes: \(error)")
            }

            request.predicate = NSPredicate(format: "isPinned == false")
            do {
                unpinnedNotes = try context.fetch(request)
            } catch {
                print("Error fetching unpinned notes: \(error)")
            }
        }

        tableView.reloadData()
    }
*/
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return pinnedNotes.isEmpty ? 1 : 2
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
        if pinnedNotes.isEmpty {
            return "Notes"
        } else {
            if section == 0 {
                return "Pinned"
            } else {
                return unpinnedNotes.isEmpty ? nil : "Notes"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if pinnedNotes.isEmpty {
            return unpinnedNotes.count
        } else {
            return section == 0 ? pinnedNotes.count : unpinnedNotes.count
        }
    }
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
         let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NotesTableViewCell

         let note = noteForIndex(at: indexPath)
         cell.titleLabel.text = note.title
         
         let date = note.createdAt
         
         //if date == Calendar.isDateInToday(self) {}
         if Calendar.current.isDateInToday(date!) {
             let timeFormatter = DateFormatter()
             timeFormatter.dateFormat = "h:mm a"
             cell.createdAtLabel.text = timeFormatter.string(from: date!)
         }else {
             cell.createdAtLabel.text = date?.formatted()
         }
         
         cell.contentLabel.text = note.content ?? "No Additional Details"
         
     
     return cell
     }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToNote", sender: self)
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

    // MARK: - Swipe Actions
    
    /*
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let note = self.noteForIndex(at: indexPath)
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            
            // 1. Remove from context
            self.context.delete(note)
            
            // 2. Remove from master notes array
            if let index = self.notes.firstIndex(of: note) {
                self.notes.remove(at: index)
            }

            // 3. Remove from pinned/unpinned
            if indexPath.section == 0 && !self.pinnedNotes.isEmpty {
                self.pinnedNotes.remove(at: indexPath.row)
            } else {
                self.unpinnedNotes.remove(at: indexPath.row)
            }

            // 4. Begin animation
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()

//             5. If any section became empty, reload full table to update sections
            if self.pinnedNotes.isEmpty || self.unpinnedNotes.isEmpty {
                tableView.reloadData()
            }

            // 6. Save
            self.save(reload: false)
            
            completionHandler(true)
        }

        deleteAction.image = UIImage(systemName: "trash")
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }

   */
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            
            let noteToDelete = self.noteForIndex(at: indexPath)
            
            self.context.delete(noteToDelete)
            
            guard let index = self.notes.firstIndex(of: noteToDelete) else {
                fatalError("Note not found")
            }
            //tableView.beginUpdates()

            self.notes.remove(at: index)
            self.reloadNotes()
            self.save(reload: false)
            completionHandler(true)
            //tableView.endUpdates()
            
        }

        deleteAction.image = UIImage(systemName: "trash.fill")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let note = self.noteForIndex(at: indexPath)
        let pinAction = UIContextualAction(style: .normal, title: "Pin") { action, view, completionHandler in
            note.isPinned.toggle()
            
            self.reloadNotes()
            self.save(reload: false)
            completionHandler(true)
        }

        pinAction.backgroundColor = .systemYellow
        pinAction.image = UIImage(systemName: note.isPinned ? "pin.slash.fill" : "pin.fill")

        let shareAction = UIContextualAction(style: .normal, title: "Share") { _, _, completionHandler in
                
                let title = note.title ?? ""
                let content = note.content ?? ""
                
                let textToShare = "\(title)\n\n\(content)"
                let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
                
                // iPad compatibility
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = tableView.cellForRow(at: indexPath)
                }

                self.present(activityVC, animated: true)
                
                completionHandler(true)
            }
            shareAction.image = UIImage(systemName: "square.and.arrow.up")
            shareAction.backgroundColor = .systemBlue
            
        
        
        let configuration = UISwipeActionsConfiguration(actions: [pinAction, shareAction])
//        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! NotesViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedNote = noteForIndex(at: indexPath)
            
        }
    }
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
