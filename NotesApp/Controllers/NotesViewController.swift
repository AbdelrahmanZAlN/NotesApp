//
//  ViewController.swift
//  NotesApp
//
//  Created by Abdelrahman Zain on 28/07/2025.
//

import UIKit

class NotesViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var noteTitle : String?
    var selectedNote : Note?
    let context = PersistentContainer.shared.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.textView.becomeFirstResponder()
        }
        let title = selectedNote?.title
        let attributedText = NSMutableAttributedString(
            string: "\(title!) \n",
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.label
            ]
        )
        if let content = selectedNote?.content {
            
            let contentText = NSAttributedString(
                string: content,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 16),
//                    .foregroundColor: UIColor.secondaryLabel
                ]
            )
            
            attributedText.append(contentText)
            textView.attributedText = attributedText
        } else {
            let contentText = NSAttributedString(
                string: "",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.secondaryLabel
                ]
            )
            
            attributedText.append(contentText)
        }
        
        textView.attributedText = attributedText

        // Do any additional setup after loading the view.
    }
    
    func applySmartFormatting() {
        let fullText = textView.text ?? ""
        let lines = fullText.components(separatedBy: "\n")
        
        let titleFont = UIFont.boldSystemFont(ofSize: 22)
        let contentFont = UIFont.systemFont(ofSize: 16)
        
        let attributed = NSMutableAttributedString()
        
        if let titleLine = lines.first {
            let titleAttr = NSAttributedString(string: titleLine + "\n", attributes: [
                .font: titleFont
            ])
            attributed.append(titleAttr)
        }
        
        if lines.count > 1 {
            let contentLines = lines.dropFirst().joined(separator: "\n")
            let contentAttr = NSAttributedString(string: contentLines, attributes: [
                .font: contentFont
            ])
            attributed.append(contentAttr)
        }
        
        let selectedRange = textView.selectedRange
        textView.attributedText = attributed
        textView.selectedRange = selectedRange
    }

    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        let fullText = textView.text ?? ""
        let lines = fullText.components(separatedBy: "\n")
        let title = lines.first ?? ""
        let content = lines.dropFirst().joined(separator: "\n")
        
        selectedNote?.title = title
        selectedNote?.content = content
        save()
        navigationController?.popViewController(animated: true)
    }
    //MARK: - Data Manipulation Methods

    func save() {
        do {
            try context.save()
        } catch {
            print("Error saving new category: \(error.localizedDescription)")
        }
        
    }
}

// MARK: - TextView Delegate

extension NotesViewController : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            applySmartFormatting()
        }
        return true
    }

    
    
    func textViewDidChange(_ textView: UITextView) {
        let fullText = textView.text ?? ""
        let lines = fullText.components(separatedBy: "\n")
        let title = lines.first ?? ""
        let content = lines.dropFirst().joined(separator: "\n")
        
        selectedNote?.title = title
        selectedNote?.content = content
        save()
        print("Saved")
    }
}
