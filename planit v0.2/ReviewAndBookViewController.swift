//
//  groupRankingViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/17/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import Contacts

class ReviewAndBookViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {

    // MARK: Outlets

    @IBOutlet weak var contactsCollectionView: UICollectionView!
    @IBOutlet weak var topItineraryTable: UITableView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var passportNumber: UITextField!
    @IBOutlet weak var knownTravelerNumber: UITextField!
    @IBOutlet weak var redressNumber: UITextField!
    @IBOutlet weak var birthdate: UITextField!
    @IBOutlet weak var bookOnlyIfTheyDoInfoView: UIView!
    @IBOutlet weak var popupBackgroundView: UIVisualEffectView!
    @IBOutlet weak var tripNameLabel: UITextField!
    @IBOutlet weak var nameOnCard: UITextField!
    @IBOutlet weak var cardNumber: UITextField!
    
    // Outlets for buttons
    @IBOutlet weak var bookThisTripButton: UIButton!
    @IBOutlet weak var bookOnlyIfTheyDoInfoButton: UIButton!
    @IBOutlet weak var addressLineOne: UITextField!
    @IBOutlet weak var addressLineTwo: UITextField!
    @IBOutlet weak var addressCity: UITextField!
    @IBOutlet weak var addressState: UITextField!
    @IBOutlet weak var addressZipCode: UITextField!
    
    // Set up vars for Contacts - COPY
    var contacts: [CNContact]?
    var contactIDs: [NSString]?
    fileprivate var addressBookStore: CNContactStore!
    var rankedPotentialTripsDictionary = [Dictionary<String, Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let SavedPreferencesForTrip = self.fetchSavedPreferencesForTrip()
        if let rankedPotentialTripsDictionaryFromSingleton = SavedPreferencesForTrip["rankedPotentialTripsDictionary"] as? [NSDictionary] {
            if rankedPotentialTripsDictionaryFromSingleton.count > 0 {
                rankedPotentialTripsDictionary = rankedPotentialTripsDictionaryFromSingleton as! [Dictionary<String, AnyObject>]
            }
        }
        
        //Load the values from our shared data container singleton
        self.tripNameLabel.delegate = self
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
        
        //Appearance of booking buttons
        bookThisTripButton.layer.borderWidth = 1
        bookThisTripButton.layer.borderColor = UIColor.white.cgColor
        bookThisTripButton.layer.cornerRadius = 5
        bookThisTripButton.layer.backgroundColor = UIColor(red:1,green:1,blue:1,alpha:0.18).cgColor
        
        // book info view appearance
        bookOnlyIfTheyDoInfoView.layer.cornerRadius = 5
        bookOnlyIfTheyDoInfoView.alpha = 0
        bookOnlyIfTheyDoInfoView.layer.isHidden = true
        
        // Center booking button text
        bookThisTripButton.titleLabel?.textAlignment = .center
        
        
        // Set up tap outside info view
        popupBackgroundView.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissPopup(touch:)))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        popupBackgroundView.addGestureRecognizer(tap)
        
        let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        if existing_trips?.count == 1 {
            let when = DispatchTime.now() + 0.4
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.animateInfoViewIn()
            }
        }

        //Set up notifications for moving VC up when keyboard presented
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.hideKeyboardWhenTappedAround()

        // Initialize address book - COPY
        addressBookStore = CNContactStore()
        
        // Create delegates for text fields
        self.firstName.delegate = self
        self.lastName.delegate = self
        self.emailAddress.delegate = self
        self.gender.delegate = self
        self.phone.delegate = self
        self.passportNumber.delegate = self
        self.knownTravelerNumber.delegate = self
        self.redressNumber.delegate = self
        self.birthdate.delegate = self
        self.nameOnCard.delegate = self
        self.cardNumber.delegate = self
        self.addressLineOne.delegate = self
        self.addressLineTwo.delegate = self
        self.addressCity.delegate = self
        self.addressState.delegate = self
        self.addressZipCode.delegate = self
        
        topItineraryTable.layer.cornerRadius = 5
        
        // Set appearance of textfield
        firstName.layer.borderWidth = 0.5
        firstName.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        firstName.layer.masksToBounds = true
        firstName.layer.cornerRadius = 5
        let firstNameLabelPlaceholder = firstName!.value(forKey: "placeholderLabel") as? UILabel
        firstNameLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        
        lastName.layer.borderWidth = 0.5
        lastName.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        lastName.layer.masksToBounds = true
        lastName.layer.cornerRadius = 5
        let lastNameLabelPlaceholder = lastName!.value(forKey: "placeholderLabel") as? UILabel
        lastNameLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        emailAddress.layer.borderWidth = 0.5
        emailAddress.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        emailAddress.layer.masksToBounds = true
        emailAddress.layer.cornerRadius = 5
        let emailAddressLabelPlaceholder = emailAddress!.value(forKey: "placeholderLabel") as? UILabel
        emailAddressLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        gender.layer.borderWidth = 0.5
        gender.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        gender.layer.masksToBounds = true
        gender.layer.cornerRadius = 5
        let genderLabelPlaceholder = gender!.value(forKey: "placeholderLabel") as? UILabel
        genderLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        
        phone.layer.borderWidth = 0.5
        phone.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        phone.layer.masksToBounds = true
        phone.layer.cornerRadius = 5
        let phoneLabelPlaceholder = phone!.value(forKey: "placeholderLabel") as? UILabel
        phoneLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        passportNumber.layer.borderWidth = 0.5
        passportNumber.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        passportNumber.layer.masksToBounds = true
        passportNumber.layer.cornerRadius = 5
        let passportNumberLabelPlaceholder = passportNumber!.value(forKey: "placeholderLabel") as? UILabel
        passportNumberLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        knownTravelerNumber.layer.borderWidth = 0.5
        knownTravelerNumber.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        knownTravelerNumber.layer.masksToBounds = true
        knownTravelerNumber.layer.cornerRadius = 5
        let knownTravelerNumberLabelPlaceholder = knownTravelerNumber!.value(forKey: "placeholderLabel") as? UILabel
        knownTravelerNumberLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        redressNumber.layer.borderWidth = 0.5
        redressNumber.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        redressNumber.layer.masksToBounds = true
        redressNumber.layer.cornerRadius = 5
        let redressNumberLabelPlaceholder = redressNumber!.value(forKey: "placeholderLabel") as? UILabel
        redressNumberLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        birthdate.layer.borderWidth = 0.5
        birthdate.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        birthdate.layer.masksToBounds = true
        birthdate.layer.cornerRadius = 5
        let birthdateLabelPlaceholder = birthdate!.value(forKey: "placeholderLabel") as? UILabel
        birthdateLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        nameOnCard.layer.borderWidth = 0.5
        nameOnCard.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        nameOnCard.layer.masksToBounds = true
        nameOnCard.layer.cornerRadius = 5
        let nameOnCardLabelPlaceholder = nameOnCard!.value(forKey: "placeholderLabel") as? UILabel
        nameOnCardLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        cardNumber.layer.borderWidth = 0.5
        cardNumber.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        cardNumber.layer.masksToBounds = true
        cardNumber.layer.cornerRadius = 5
        let cardNumberLabelPlaceholder = cardNumber!.value(forKey: "placeholderLabel") as? UILabel
        cardNumberLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        addressLineOne.layer.borderWidth = 0.5
        addressLineOne.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        addressLineOne.layer.masksToBounds = true
        addressLineOne.layer.cornerRadius = 5
        let addressLineOneLabelPlaceholder = addressLineOne!.value(forKey: "placeholderLabel") as? UILabel
        addressLineOneLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        addressLineTwo.layer.borderWidth = 0.5
        addressLineTwo.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        addressLineTwo.layer.masksToBounds = true
        addressLineTwo.layer.cornerRadius = 5
        let addressLineTwoLabelPlaceholder = addressLineTwo!.value(forKey: "placeholderLabel") as? UILabel
        addressLineTwoLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        addressCity.layer.borderWidth = 0.5
        addressCity.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        addressCity.layer.masksToBounds = true
        addressCity.layer.cornerRadius = 5
        let addressCityLabelPlaceholder = addressCity!.value(forKey: "placeholderLabel") as? UILabel
        addressCityLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        addressState.layer.borderWidth = 0.5
        addressState.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        addressState.layer.masksToBounds = true
        addressState.layer.cornerRadius = 5
        let addressStateLabelPlaceholder = addressState!.value(forKey: "placeholderLabel") as? UILabel
        addressStateLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        addressZipCode.layer.borderWidth = 0.5
        addressZipCode.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        addressZipCode.layer.masksToBounds = true
        addressZipCode.layer.cornerRadius = 5
        let addressZipCodeLabelPlaceholder = addressZipCode!.value(forKey: "placeholderLabel") as? UILabel
        addressZipCodeLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        //Load the values from our shared data container singleton
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        let firstNameValue = DataContainerSingleton.sharedDataContainer.firstName ?? ""
        let lastNameValue = DataContainerSingleton.sharedDataContainer.lastName ?? ""
        let emailAddressValue = DataContainerSingleton.sharedDataContainer.emailAddress ?? ""
        let genderValue = DataContainerSingleton.sharedDataContainer.gender ?? ""
        let phoneValue = DataContainerSingleton.sharedDataContainer.phone ?? ""
        let passportNumberValue = DataContainerSingleton.sharedDataContainer.passportNumber ?? ""
        let knownTravelerNumberValue = DataContainerSingleton.sharedDataContainer.knownTravelerNumber ?? ""
        let redressNumberValue = DataContainerSingleton.sharedDataContainer.redressNumber ?? ""
        let birthdateValue = DataContainerSingleton.sharedDataContainer.birthdate ?? ""
        
        //Install the value into the text field.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
        self.firstName.text =  "\(firstNameValue)"
        self.lastName.text =  "\(lastNameValue)"
        self.emailAddress.text =  "\(emailAddressValue)"
        self.gender.text =  "\(genderValue)"
        self.phone.text =  "\(phoneValue)"
        self.passportNumber.text =  "\(passportNumberValue)"
        self.knownTravelerNumber.text =  "\(knownTravelerNumberValue)"
        self.redressNumber.text =  "\(redressNumberValue)"
        self.birthdate.text =  "\(birthdateValue)"
    }
    
    
    //UITapGestureRecognizer
    func dismissPopup(touch: UITapGestureRecognizer) {
            dismissInfoViewOut()
    }
    
    func animateInfoViewIn(){
        bookOnlyIfTheyDoInfoView.layer.isHidden = false
        bookOnlyIfTheyDoInfoView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        bookOnlyIfTheyDoInfoView.alpha = 0
        bookThisTripButton.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.4) {
            self.popupBackgroundView.isHidden = false
            self.bookOnlyIfTheyDoInfoView.alpha = 1
            self.bookOnlyIfTheyDoInfoView.transform = CGAffineTransform.identity
        }
    }
    
    func dismissInfoViewOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.bookOnlyIfTheyDoInfoView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.bookOnlyIfTheyDoInfoView.alpha = 0
            self.popupBackgroundView.isHidden = true
            self.bookThisTripButton.isUserInteractionEnabled = true
        }) { (Success:Bool) in
            self.bookOnlyIfTheyDoInfoView.layer.isHidden = true
        }
    }

    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        emailAddress.resignFirstResponder()
        gender.resignFirstResponder()
        phone.resignFirstResponder()
        passportNumber.resignFirstResponder()
        knownTravelerNumber.resignFirstResponder()
        redressNumber.resignFirstResponder()
        birthdate.resignFirstResponder()
        tripNameLabel.resignFirstResponder()
        nameOnCard.resignFirstResponder()
        cardNumber.resignFirstResponder()
        addressLineOne.resignFirstResponder()
        addressLineTwo.resignFirstResponder()
        addressCity.resignFirstResponder()
        addressState.resignFirstResponder()
        addressZipCode.resignFirstResponder()

        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //Save trip name
        if textField == tripNameLabel {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["trip_name"] = tripNameLabel.text
            //Save
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
        
        DataContainerSingleton.sharedDataContainer.firstName = firstName.text
        DataContainerSingleton.sharedDataContainer.lastName = lastName.text
        DataContainerSingleton.sharedDataContainer.emailAddress = emailAddress.text
        DataContainerSingleton.sharedDataContainer.gender = gender.text
        DataContainerSingleton.sharedDataContainer.phone = phone.text
        DataContainerSingleton.sharedDataContainer.passportNumber = passportNumber.text
        DataContainerSingleton.sharedDataContainer.knownTravelerNumber = knownTravelerNumber.text
        DataContainerSingleton.sharedDataContainer.redressNumber = redressNumber.text
        DataContainerSingleton.sharedDataContainer.birthdate = birthdate.text
        return true
    }

    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemizedItineraryPrototypeCell", for: indexPath) as! itemizedItineraryTableViewCell
        
        let topTrip = rankedPotentialTripsDictionary[0] 
        
        cell.destinationLabel.text = topTrip["destination"] as? String
        cell.totalPriceLabel.text = "$1,000"
        cell.accomodationLabel.text = "5 nights"
        cell.accomodationPriceLabel.text = "$700"
        cell.TravelLabel.text = "Roundtrip flights"
        cell.travelPriceLabel.text = "$300"
        
        cell.layer.cornerRadius = 5
        
        return (cell)
    }

    ///////////////////////////////////COLLECTION VIEW/////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////
    // Fetch Contacts
    func retrieveContactsWithStore(store: CNContactStore) {
        contactIDs = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]
        do {
            if (contactIDs?.count)! > 0 {
                let predicate = CNContact.predicateForContacts(withIdentifiers: contactIDs as! [String])
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey] as [Any]
                contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
            } else {
                contacts = nil
            }
            DispatchQueue.main.async (execute: { () -> Void in
            })
        } catch {
            print(error)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let contactIDs = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]
        if (contactIDs?.count)! > 0 {
            return (contactIDs?.count)!
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let contactsCell = contactsCollectionView.dequeueReusableCell(withReuseIdentifier: "contactsCollectionPrototypeCell", for: indexPath) as! contactsCollectionViewCell
        
        retrieveContactsWithStore(store: addressBookStore)
        let contact = contacts?[indexPath.row]
        if (contact?.imageDataAvailable)! {
            contactsCell.thumbnailImage.image = UIImage(data: (contact?.thumbnailImageData!)!)
            contactsCell.thumbnailImage.contentMode = .scaleToFill
            let reCenter = contactsCell.thumbnailImage.center
            contactsCell.thumbnailImage.layer.frame = CGRect(x: contactsCell.thumbnailImage.layer.frame.minX
                , y: contactsCell.thumbnailImage.layer.frame.minY, width: contactsCell.thumbnailImage.layer.frame.width * 0.91, height: contactsCell.thumbnailImage.layer.frame.height * 0.91)
            contactsCell.thumbnailImage.center = reCenter
            contactsCell.thumbnailImage.layer.cornerRadius = contactsCell.thumbnailImage.frame.height / 2
            contactsCell.thumbnailImage.layer.masksToBounds = true
            contactsCell.initialsLabel.isHidden = true
            contactsCell.thumbnailImageFilter.isHidden = false
            contactsCell.thumbnailImageFilter.image = UIImage(named: "no_contact_image_selected")!
            contactsCell.thumbnailImageFilter.alpha = 0.5
        } else {
            contactsCell.thumbnailImage.image = UIImage(named: "no_contact_image")!
            contactsCell.thumbnailImageFilter.isHidden = true
            contactsCell.initialsLabel.isHidden = false
            let firstInitial = contact?.givenName[0]
            let secondInitial = contact?.familyName[0]
            contactsCell.initialsLabel.text = firstInitial! + secondInitial!
        }
        
        return contactsCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if collectionView == contactsCollectionView {
            retrieveContactsWithStore(store: addressBookStore)
            
            // Create date lists and color array            
            let colors = [UIColor.purple, UIColor.gray, UIColor.red, UIColor.green, UIColor.orange, UIColor.yellow, UIColor.brown, UIColor.black]
            
            // Change color of thumbnail image
            let contact = contacts?[indexPath.row]
            let SelectedContact = contactsCollectionView.cellForItem(at: indexPath) as! contactsCollectionViewCell
            
            if (contact?.imageDataAvailable)! {
                SelectedContact.thumbnailImageFilter.alpha = 0
            } else {
                SelectedContact.thumbnailImage.image = UIImage(named: "no_contact_image_selected")!
                //                SelectedContact.initialsLabel.textColor = UIColor(red: 132/255, green: 137/255, blue: 147/255, alpha: 1)
                SelectedContact.initialsLabel.textColor = colors[indexPath.row]
            }
            
            //Add highlight action
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if collectionView == contactsCollectionView {
            retrieveContactsWithStore(store: addressBookStore)
            
            let contact = contacts?[indexPath.row]
            let DeSelectedContact = contactsCollectionView.cellForItem(at: indexPath) as! contactsCollectionViewCell
            
            if (contact?.imageDataAvailable)! {
                DeSelectedContact.thumbnailImageFilter.alpha = 0.5
            } else {
                DeSelectedContact.thumbnailImage.image = UIImage(named: "no_contact_image")!
                DeSelectedContact.initialsLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            }
            
            //Add unhighlight action
            
        }
    }
    
    // MARK: - UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let picDimension = 55
        return CGSize(width: picDimension, height: picDimension)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //COPY
        let contactIDs = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]
        
        let spacing = 10
        if (contactIDs?.count)! > 0 {
            var leftRightInset = (self.contactsCollectionView.frame.size.width / 2.0) - CGFloat((contactIDs?.count)!) * 27.5 - CGFloat(spacing / 2 * ((contactIDs?.count)! - 1))
            if (contactIDs?.count)! > 4 {
                leftRightInset = 30
            }
            return UIEdgeInsetsMake(0, leftRightInset, 0, 0)
        }
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
        //Update preference vars if an existing trip
        //Trip status
        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
        let finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
        //New Trip VC
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString ?? NSString()
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString] ?? [NSString]()
        let contactPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
        let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? [NSNumber] ?? [NSNumber]()
        let segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [NSNumber] ?? [NSNumber]()
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate] ?? [NSDate]()
        let leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? NSDictionary ?? NSDictionary()
        let rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? NSDictionary ?? NSDictionary()
        let numberDestinations = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "numberDestinations") as? NSNumber ?? NSNumber()
        let nonSpecificDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "nonSpecificDates") as? NSDictionary ?? NSDictionary()
        //Budget VC
        let budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? NSString ?? NSString()
        let expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? NSString ?? NSString()
        let expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? NSString ?? NSString()
        //Suggested Destination VC
        let decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? NSString ?? NSString()
        let decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? NSString ?? NSString()
        let suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? NSString ?? NSString()
        let suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? NSString ?? NSString()
        //Activities VC
        let selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [NSString] ?? [NSString]()
        //Ranking VC
        let topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()
        let rankedPotentialTripsDictionary = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionary") as? [NSDictionary] ?? [NSDictionary]()

        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus, "finished_entering_preferences_status": finishedEnteringPreferencesStatus,"trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips,"numberDestinations":numberDestinations,"nonSpecificDates":nonSpecificDates, "rankedPotentialTripsDictionary": rankedPotentialTripsDictionary] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
    }
    func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }

    
    // MARK: Actions
    @IBAction func gotItButtonTouchedUpInside(_ sender: Any) {
        dismissInfoViewOut()
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        animateInfoViewIn()
    }
    
    @IBAction func bookButtonPressed(_ sender: Any) {
        updateCompletionStatus()
        handleBookingStatus()
    }
    @IBAction func bookLaterButtonPressed(_ sender: Any) {
        updateCompletionStatus()
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }
    
    func handleBookingStatus() {
        let bookingStatusValue = 1 as NSNumber
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["booking_status"] = bookingStatusValue as NSNumber
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    func updateCompletionStatus() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["finished_entering_preferences_status"] = "booking" as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if passportNumber.isEditing || redressNumber.isEditing || knownTravelerNumber.isEditing {
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0{
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

}
