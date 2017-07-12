//
//  SendProposalQuestionView.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/26/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import Contacts

class SendProposalQuestionView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    //Class vars
    var questionLabel: UILabel?
    var button1: UIButton?
    var button2: UIButton?
    var button3: UIButton?
    var contactsTableView: UITableView?
        //Contacts vars COPY
    fileprivate var addressBookStore: CNContactStore!
    var contacts: [CNContact]?
    var contactIDs: [NSString]?
    var contactPhoneNumbers = [NSString]()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addViews()
        
        //COPY FOR CONTACTS
        addressBookStore = CNContactStore()
        retrieveContactsWithStore(store: addressBookStore)
        
        //        self.layer.borderColor = UIColor.green.cgColor
        //        self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 133)
        
        button1?.sizeToFit()
        button1?.frame.size.height = 30
        button1?.frame.size.width += 20
        button1?.frame.origin.x = (bounds.size.width - (button1?.frame.width)!) / 2
        button1?.frame.origin.y = 80
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2
        
        button2?.sizeToFit()
        button2?.frame.size.height = 30
        button2?.frame.size.width += 20
        button2?.frame.origin.x = (bounds.size.width - (button2?.frame.width)!) / 2
        button2?.frame.origin.y = 510
        button2?.layer.cornerRadius = (button2?.frame.height)! / 2
        
        button3?.sizeToFit()
        button3?.frame.size.height = 30
        button3?.frame.size.width += 20
        button3?.frame.origin.x = (bounds.size.width - (button3?.frame.width)!) / 2
        button3?.frame.origin.y = 560
        button3?.layer.cornerRadius = (button3?.frame.height)! / 2
        
        contactsTableView?.frame = CGRect(x: (bounds.size.width - 300) / 2, y: 200, width: 300, height: 286)
        
        if contacts != nil && contacts?.count != 0 {
            button2?.isHidden = false
//            button1?.frame.origin.y = CGFloat(60 * contacts!.count + 180)
        }
        
    }
    
    
    func addViews() {        
        setUpTable()
        
        //Question label
        questionLabel = UILabel(frame: CGRect.zero)
        questionLabel?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel?.numberOfLines = 0
        questionLabel?.textAlignment = .center
        questionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        questionLabel?.textColor = UIColor.white
        questionLabel?.adjustsFontSizeToFitWidth = true
        questionLabel?.text = "Add your friends to this trip!\n\n\nWhen you're ready, you can\nsend them the proposed itinerary!"
        self.addSubview(questionLabel!)
        
        //Button1
        button1 = UIButton(type: .custom)
        button1?.frame = CGRect.zero
        button1?.setTitleColor(UIColor.white, for: .normal)
        button1?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button1?.layer.borderWidth = 1
        button1?.layer.borderColor = UIColor.white.cgColor
        button1?.layer.masksToBounds = true
        button1?.titleLabel?.numberOfLines = 0
        button1?.titleLabel?.textAlignment = .center
        button1?.setTitle("Add from contacts", for: .normal)
        button1?.translatesAutoresizingMaskIntoConstraints = false
        button1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button1!)
        
        //Button2
        button2 = UIButton(type: .custom)
        button2?.frame = CGRect.zero
        button2?.setTitleColor(UIColor.white, for: .normal)
        button2?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button2?.layer.borderWidth = 1
        button2?.layer.borderColor = UIColor.white.cgColor
        button2?.layer.masksToBounds = true
        button2?.titleLabel?.numberOfLines = 0
        button2?.titleLabel?.textAlignment = .center
        button2?.setTitle("Send", for: .normal)
        button2?.translatesAutoresizingMaskIntoConstraints = false
        button2?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button2!)
        
        //Button2
        button3 = UIButton(type: .custom)
        button3?.frame = CGRect.zero
        button3?.setTitleColor(UIColor.white, for: .normal)
        button3?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button3?.layer.borderWidth = 1
        button3?.layer.borderColor = UIColor.white.cgColor
        button3?.layer.masksToBounds = true
        button3?.titleLabel?.numberOfLines = 0
        button3?.titleLabel?.textAlignment = .center
        button3?.setTitle("Review itinerary first", for: .normal)
        button3?.translatesAutoresizingMaskIntoConstraints = false
        button3?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button3!)

    }
    
    func setUpTable() {
        contactsTableView = UITableView(frame: CGRect.zero, style: .plain)
        contactsTableView?.delegate = self
        contactsTableView?.dataSource = self
        contactsTableView?.separatorColor = UIColor.clear
        contactsTableView?.backgroundColor = UIColor.clear
        contactsTableView?.layer.backgroundColor = UIColor.clear.cgColor
        contactsTableView?.allowsSelection = false
        contactsTableView?.backgroundView = nil
        contactsTableView?.isOpaque = false
        contactsTableView?.register(contactsTableViewCellForScrolling.self, forCellReuseIdentifier: "contactsTableViewCellForScrolling")
        self.addSubview(contactsTableView!)
    }
    
    
    // MARK: Contacts
    func retrieveContactsWithStore(store: CNContactStore) {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        contactIDs = SavedPreferencesForTrip["contacts_in_group"] as? [NSString]
        contactPhoneNumbers = (SavedPreferencesForTrip["contact_phone_numbers"] as? [NSString])!
        
        do {
            if (contactIDs?.count)! > 0 {
                let predicate = CNContact.predicateForContacts(withIdentifiers: contactIDs! as [String])
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey] as [Any]
                let updatedContacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                
                var reorderedUpdatedContacts = [CNContact]()
                for contactID in contactIDs! {
                    for updatedContact in updatedContacts {
                        if updatedContact.identifier as NSString == contactID {
                            reorderedUpdatedContacts.append(updatedContact)
                        }
                    }
                }
                self.contacts = reorderedUpdatedContacts
                
                //Update trip preferences dictionary
                let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                SavedPreferencesForTrip["contacts_in_group"] = contactIDs
                SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
                
            } else {
                self.contacts = nil
            }
        } catch {
            print(error)
        }
    }

    

    //MARK: TableView
    // MARK: UITableviewdelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        retrieveContactsWithStore(store: addressBookStore)
        
        var numberOfRows = 0
        
        if tableView == contactsTableView {
            if contacts != nil {
                numberOfRows += contacts!.count
            }
            if numberOfRows != 0 {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "contactsListChanged"), object: nil)
            }
        }
        return numberOfRows
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        retrieveContactsWithStore(store: addressBookStore)
        
//        if tableView == contactsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactsTableViewCellForScrolling", for: indexPath) as! contactsTableViewCellForScrolling
            cell.backgroundColor = UIColor.clear
            
            if contacts != nil {
                let contact = contacts?[indexPath.row]
                cell.nameLabel.text = (contact?.givenName)! + " " + (contact?.familyName)!
                
//                if (contact?.imageDataAvailable)! {
//                    cell.thumbnailImage.image = UIImage(data: (contact?.thumbnailImageData!)!)
//                    cell.thumbnailImage.contentMode = .scaleToFill
//                    let reCenter = cell.thumbnailImage.center
//                    cell.thumbnailImage.layer.frame.size = CGSize(width: 55, height: 55)
//                    cell.thumbnailImage.layer.frame = CGRect(x: cell.thumbnailImage.layer.frame.minX
//                        , y: cell.thumbnailImage.layer.frame.minY, width: cell.thumbnailImage.layer.frame.width * 0.96, height: cell.thumbnailImage.layer.frame.height * 0.96)
//                    cell.thumbnailImage.center = reCenter
//                    cell.thumbnailImage.layer.cornerRadius = cell.thumbnailImage.frame.height / 2
//                    cell.thumbnailImage.layer.masksToBounds = true
//                    cell.initialsLabel.isHidden = true
//                } else {
                    cell.thumbnailImage.image = UIImage(named: "no_contact_image")!
                    cell.initialsLabel.isHidden = false
                    let firstInitial = contact?.givenName[0]
                    let secondInitial = contact?.familyName[0]
                    cell.initialsLabel.text = firstInitial! + secondInitial!
//                }
            }
            
            return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            deleteContact(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "👋🏼"
    }

    //MARK: Custom functions
    func deleteContact(indexPath: IndexPath) {
        contacts?.remove(at: indexPath.row)
        contactIDs?.remove(at: indexPath.row)
        contactPhoneNumbers.remove(at: indexPath.row)

        //Update trip preferences dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["contacts_in_group"] = contactIDs
        SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
        //Save updated trip preferences dictionary
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
        //Delete rows in table
        contactsTableView?.deleteRows(at: [indexPath], with: .left)
        
//        //Delete icons in collectionview
//        .contactsCollectionView.deleteItems(at: [indexPath])
//        let visibleContactsCells = TripViewController.self.contactsCollectionView.visibleCells as! [contactsCollectionViewCell]
//        for visibleContactCell in visibleContactsCells {
//            let newIndexPathForItem = TripViewController.self.contactsCollectionView.indexPath(for: visibleContactCell)
//            visibleContactCell.deleteButton.layer.setValue(newIndexPathForItem?.row, forKey: "index")
//        }
//        
//        if contacts?.count == 0 || contacts == nil {
//            TripViewController.dismissDeleteContactsMode()
//        }
//
        
        if contacts?.count == 0 || contacts == nil {
            button2?.isHidden = true
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "contactsListChanged"), object: nil)
    }

    func buttonClicked(sender:UIButton) {
        if sender == button1 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "contactPickerVC"), object: nil)
        } else if sender == button2 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "messageComposeVC"), object: nil)
        } else if sender == button3 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reviewItinerary"), object: nil)
        }
    }

    
}
