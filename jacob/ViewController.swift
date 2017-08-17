//
//  ViewController.swift
//  jacob
//  Created by Nanu Jogi on 29/07/17.
//  Copyright © 2017 GL. All rights reserved.

import UIKit
import CoreData
import SafariServices

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var coreDataStack: CoreDataStack!
    var tuts = [JBentity]() // is used to fetch category from coredata inside function changefilter
    
    var jbentityPredicate: NSPredicate?
    
    var fetchedResultsController: NSFetchedResultsController<JBentity>!
    
    var myclass = MyClass()
    
    // if we use below newarray we save the codeing part of fetching category & appending it an array. We can save the section name by appending them inside titleForHeaderInSection function & can simply use it inside our changeFilter function.
    
    // var newarray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Bart Jacob Tutorials"
        
        // Filter menu on right side of navigator bar. Action function name changeFilter
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(changeFilter))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(updatetutorials))
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        insertSampleData() // insertSampleData from .plist file
        loadSavedData() // load the saved data
        
    } // end of viewDidLoad()
    
    // MARK: - Table View Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
        // return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        //let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
        // return tuts.count
        
    } // end of numberOfRowsInSection
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let jbentity = fetchedResultsController.object(at: indexPath)
        //let jbentity = tuts[indexPath.row]
        
        if let txtlbl = jbentity.title,
           let detlbl = jbentity.date?.description {
            
      cell.textLabel?.attributedText = myclass.makeAttributedString(title: txtlbl, subtitle: detlbl)
        }
        
        return cell
    } // end of cellForRowAt
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let count = fetchedResultsController.sections?[section].objects?.count,
            var sectionname = fetchedResultsController.sections?[section].name  else  {
                return ""
        }
        sectionname += " \(count)"
        //  newarray.append(fetchedResultsController.sections![section].name)
        
        return sectionname
        // let count = fetchedResultsController.sections![section].objects!.count
        //  return fetchedResultsController.sections![section].name  + " \(count)"
    } // end of titleForHeaderInSection
    
    // Below functions helps cell to correctly fit its content.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    } // end of heightForRowAt
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    } // end of estimatedHeightForRowAt
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tuturl = fetchedResultsController.object(at: indexPath)
        if let getsurl = tuturl.surl {
            showTutorial(getsurl)
        }
    }
    
    // MARK: - Insert Tutorial Data
    func insertSampleData() {
        
        let fetch = NSFetchRequest<JBentity>(entityName: "JBentity")
        fetch.predicate = NSPredicate(format: "author != nil")
        
        if let count = try? coreDataStack.managedContext.count(for: fetch) {
            if count > 0 {
                // Data already in Core Data
                return
            }
        }
        
        if let path = Bundle.main.path(forResource: "jacob-data", ofType: "plist") {
            if let dataArray = NSArray(contentsOfFile: path) {
                for dict in dataArray {
                    if let entity = NSEntityDescription.entity(forEntityName: "JBentity", in: coreDataStack.managedContext) {
                        let jbentity = JBentity(entity: entity, insertInto: coreDataStack.managedContext)
                        let jbDict = dict as! [String: AnyObject]
                        jbentity.title = jbDict["title"] as? String
                        jbentity.author = jbDict["author"] as? String
                        jbentity.category = jbDict["category"] as? String
                        jbentity.surl = jbDict["surl"] as? String
                        // string to date
                        if let strdate = jbDict["date"] as? String {
                            let mydate = myclass.GetDateFromString(DateStr: strdate)
                            jbentity.date =  mydate
                        }
                    } // end of if let entity
                } // end of for dict in dataArray
                
                coreDataStack.saveContext()
                // try! coreDataStack.managedContext.save()
                loadSavedData()
            } // end of if let dataArray
        } // end of Bundle.main
    } // end of insertSampleData
    
    // MARK: - Load Saved Data
    func loadSavedData() {
        if fetchedResultsController == nil {
            let request = JBentity.createFetchRequest()
            
            let sortbycategory = NSSortDescriptor(key: "category", ascending: true)
            let sortbydate = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [sortbycategory, sortbydate]
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: "category", cacheName: nil)
            fetchedResultsController.delegate = self
        }
        fetchedResultsController.fetchRequest.predicate = jbentityPredicate
        //  request.predicate = jbentityPredicate
        
        do {
            try fetchedResultsController.performFetch()
            // tuts = try coreDataStack.managedContext.fetch(request)
            // print ("Got \(tuts.count) tutorials")
            tableView.reloadData()
        } catch {
            print ("Fetch failed")
        }
        
    } // end of loadSavedData()
    
    // MARK: - Show Tutorial
    func showTutorial(_ which: String) {
        if let url = URL(string: which)
        {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            
            // Some Color combination added after reading documentation at apple site.
            vc.preferredBarTintColor = UIColor.darkText
            vc.preferredControlTintColor = UIColor.white
            present(vc, animated: true)
        }
    }
    
    // MARK: - changeFilter
    func changeFilter() {
        let ac = UIAlertController(title: "Filter tutorials...", message: nil, preferredStyle: .actionSheet)
        // ac.view.tintColor = UIColor.black
        // UIColor(red: 218.0/255, green: 100.0/255, blue: 70.0/255, alpha: 1.0)
        
        ac.addAction(UIAlertAction(title: "Show all tutorials", style: .default)
        { [unowned self] _ in
            
            self.jbentityPredicate = nil
            self.loadSavedData()
            
        })
        var categoryarray = [String]()
        
        // Below functions will fetch ALL the category from CoreData.
        loadcategory()
        
        // We loop through the fetch category and store it in our categoryarray
        for tut in tuts {
            if let category = tut.category {
                categoryarray.append(category)
            }
        }
        // We need to remove the duplicate category so we create another variable to perform on it.
        var removeduplicates = categoryarray
        
        // var removeduplicates = newarray
        // Remove duplicates first by converting to a Set and then back to Array
        removeduplicates = Array(Set(removeduplicates))
        
        // newarray = removeduplicates.sorted()
        categoryarray = removeduplicates.sorted() // we save it back inside categoryarray in sorted order.
        
        // Below we format the addAction as per our requirement.
        
        for categories in categoryarray {
            let formattedstring = "Show only " + "\(categories.lowercased())" // this goes inside the title of UIAlterAction
            let formatpredicate = "category CONTAINS[c] " + "'\(categories)'" // this goes inside NSPredicate
            
            ac.addAction(UIAlertAction(title: formattedstring, style: .default)
            { [unowned self] _ in
                self.jbentityPredicate = NSPredicate(format: formatpredicate)
                self.loadSavedData()
            })
        } // end of for categories 
        
        //        // 1 Shows coredata tutorials only
        //        ac.addAction(UIAlertAction(title: "Show only CoreData", style: .default)
        //        { [unowned self] _ in
        //            self.jbentityPredicate = NSPredicate(format: "category CONTAINS[c] 'coredata'")
        //            self.loadSavedData()
        //        })
        
        // 2 can add more manually
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
        
    } // end of changeFilter
    
    // MARK: - Load Category
    func loadcategory() {
        
        let categoryFetch = NSFetchRequest<JBentity>(entityName: "JBentity")
        categoryFetch.predicate = NSPredicate(format: "category != nil")
        do {
            tuts =  try coreDataStack.managedContext.fetch(categoryFetch)
        } catch {
            print ("error while fetching category inside function loadcategory")
        }
        
    } // end of loadcategory()
    
    // MARK:- updatetutorials
    func updatetutorials() {
        if let path = Bundle.main.path(forResource: "update1", ofType: "plist") {
            if let dataArray = NSArray(contentsOfFile: path) {
                for dict in dataArray {
                    let jbDict = dict as! [String: AnyObject]
                    var tutsadd : Int32 = 0
                    if let totalupdate = jbDict["newtutstotal"] as? Int32 {
                        while tutsadd < totalupdate {
                            let mytitle = "newtitle" + "\(tutsadd)"
                            let myauthor = "newauthor" + "\(tutsadd)"
                            let mycategory = "newcategory" + "\(tutsadd)"
                            let mysurl = "newsurl" + "\(tutsadd)"
                            let mydate = "newdate" + "\(tutsadd)"
                            
                            if let newtitle = jbDict[mytitle] as? String,
                                let newauthor = jbDict[myauthor] as? String,
                                let newcategory = jbDict[mycategory] as? String,
                                let newsurl = jbDict[mysurl] as? String,
                                let newstrdate = jbDict[mydate] as? String {
                                let newdate = myclass.GetDateFromString(DateStr: newstrdate)
                                // call function to add new tutorials
                                addnewtuts(title: newtitle, author: newauthor, category: newcategory, surl: newsurl, mydate: newdate)
                            } // end of Optional Binding
                            tutsadd += 1
                        }
                        print ("\nSuccessfully added \(totalupdate) new tutorials")
                    } // end of if let totalupdate
                    
                    // Update of Tutorial begins here!
                    var updatetutscount : Int32 = 0
                    if let totalupdate = jbDict["updatetotal"] as? Int32 {
                        while updatetutscount < totalupdate
                        {
                            // we append 0 then 1 then 2 etc...
                            let upmytitle = "uptitle" + "\(updatetutscount)"
                            let upmyauthor = "upauthor" + "\(updatetutscount)"
                            let upmycategory = "upcategory" + "\(updatetutscount)"
                            let upmysurl = "upsurl" + "\(updatetutscount)"
                            let upmydate = "update" + "\(updatetutscount)"
                            
                            if let upnewtitle = jbDict[upmytitle] as? String,
                                let upnewauthor = jbDict[upmyauthor] as? String,
                                let upnewcategory = jbDict[upmycategory] as? String,
                                let upnewsurl = jbDict[upmysurl] as? String
                            {
                                let upnewstrdate = jbDict[upmydate] as! String // unconditional unwrapping
                                let upnewdate = myclass.GetDateFromString(DateStr: upnewstrdate)
                                
                                _ = findstring(searchtitle: upnewtitle, upauthor: upnewauthor, upcategory: upnewcategory, upsurl: upnewsurl, upmydate: upnewdate)
                            } // end of if optional binding.
                            
                            updatetutscount += 1
                        } // end of while
                        print ("Successfully updated \(updatetutscount) tutorials")
                    } // end of if let totalupdate
                } // end of for dict in dataArray
            } // end of if let dataArray
        } // end of if let path
        
        loadSavedData()
        // show successful update message to user.
        myalert(mytitle: "Successfully added & updated new tutorials", msg: "")

    } // end of updatetutorials
    
    func addnewtuts (title: String, author: String, category: String, surl: String, mydate: Date) {
        // check if title already inside coredata
        if findnewtuts(title) {
            // if true it means title already in coredata we simply return
            return
        }
        // otherwise we add the new tutorials
        if let entity = NSEntityDescription.entity(forEntityName: "JBentity", in: coreDataStack.managedContext) {
            let jbentity = JBentity(entity: entity, insertInto: coreDataStack.managedContext)
            jbentity.title = title
            jbentity.author = author
            jbentity.category = category
            jbentity.surl = surl
            jbentity.date =  mydate
            
            // Save the new tutorials
            do {
                try coreDataStack.managedContext.save()
            } catch let error as NSError {
                print("Error while saving an new tutorials inside addnewtuts function \(error), \(error.userInfo)")
            }
            
        } // end of if let entity
        
    } // end of addnewtuts function
    
    // MARK: - find new tutorial used while addeding an new tutorial.
    func findnewtuts (_ searchtitle: String)-> Bool {
        let mysearchtitle = searchtitle
        let titleFetch = NSFetchRequest<JBentity>(entityName: "JBentity")
        titleFetch.predicate = NSPredicate(format: "title == %@", mysearchtitle)
        do {
            let results = try coreDataStack.managedContext.fetch(titleFetch)
            if results.count > 0 {
                return true
            }
        }
        catch let error as NSError {
            print ("Error while trying to search for an new tutorial which we are going to add. error: \(error) description: \(error.userInfo)")
        }
        return false
        
    } // end of findnewtuts
    
    // Below function is used to Update the Coredata
    // First it will search for the title to update if found it will update returns true else false
    
    func findstring (searchtitle: String, upauthor: String, upcategory: String, upsurl: String, upmydate: Date)-> Bool {
        let mysearchtitle = searchtitle
        let titleFetch = NSFetchRequest<JBentity>(entityName: "JBentity")
        titleFetch.predicate = NSPredicate(format: "title == %@", mysearchtitle)
        do {
            let results = try coreDataStack.managedContext.fetch(titleFetch)
            if results.count > 0 {

                // let getdate = JBentity(context: coreDataStack.managedContext)
                //  getdate.date = Date()
                
                results.first?.title = mysearchtitle
                results.first?.author = upauthor
                results.first?.category = upcategory
                results.first?.surl = upsurl
                results.first?.date = upmydate
                do {
                    try coreDataStack.managedContext.save()
                    // loadSavedData()
                    return true
                } // end of inside do
                    
                catch {
                    print ("Error while updateing an record in function findstring")
                } // end of inside catch
                
                //  let getdate = JBentity(context: coreDataStack.managedContext)
                //  this adds an new record
                //  getdate.setValue("xyz", forKey: "title")
            }
        }
        catch let error as NSError {
            print ("title Fetch error: \(error) description: \(error.userInfo)")
        }
        
        return false // return false

    } // end of findstring

    
    // to use motion in stimulator Command+Control+Z
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion ==  .motionShake {
            navigationItem.leftBarButtonItem?.isEnabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
