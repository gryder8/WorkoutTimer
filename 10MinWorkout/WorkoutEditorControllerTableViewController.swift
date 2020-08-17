//
//  WorkoutEditorControllerTableViewController.swift
//  10MinWorkout
//
//  Created by Gavin Ryder on 8/15/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import UIKit

extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }

    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }

}

extension Double {
    var removeDecimalAndZero: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

class WorkoutEditorControllerTableViewController: UITableViewController {
    
    private var isInitialized = false
    private let WorkoutsMaster: Workouts = Workouts.shared
    private var VCMaster: ViewController = ViewController()
    private let tableGradient:GradientView = GradientView()
    private var workoutList:[Workouts.Workout] = [] {
        didSet {
            if (isInitialized) {
                self.WorkoutsMaster.allWorkouts = self.workoutList
            }
//            print(self.workoutList[0].name)
//            print(self.WorkoutsMaster.workoutList[0].name)
        }
    }//array of Workout structs
    private var darkModeEnabled:Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        setUpTableViewHeader()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - View customization and UI Event handling
    private func setUpTableViewHeader(){
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = tableGradient.firstColor
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.tintColor = .black
        navigationItem.hidesBackButton = false
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done,target: self, action: #selector(backTapped))
        let label = UILabel(frame: CGRect(x:0, y:0, width:350, height:30))
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = UIFont (name: "Avenir Next", size: 12.0)!
        label.textAlignment = .center
        label.textColor = .black
        label.text = "Swipe right on a workout to edit"
        self.navigationItem.titleView = label
    }
    
    @objc func backTapped(){
        navigationController?.popToRootViewController(animated: true)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.darkModeEnabled = (self.traitCollection.userInterfaceStyle == .dark)
        if (darkModeEnabled){
            tableGradient.firstColor =   #colorLiteral(red: 1, green: 0.3515937998, blue: 0, alpha: 1)
            tableGradient.secondColor =  #colorLiteral(red: 1, green: 0.8361050487, blue: 0.6631416678, alpha: 1)
        } else {
            tableGradient.firstColor = #colorLiteral(red: 1, green: 0.8361050487, blue: 0.6631416678, alpha: 1)
            tableGradient.secondColor = #colorLiteral(red: 1, green: 0.3515937998, blue: 0, alpha: 1)
        }
        self.tableView.backgroundView = tableGradient
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.workoutList = WorkoutsMaster.allWorkouts
        isInitialized = true
    }
    
    override func addChild(_ childController: UIViewController) { //TODO: kinda hacky
        //super.addChild(childController)
        VCMaster = childController as! ViewController
    }
    
    // MARK: - Table view data sourcing

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WorkoutsMaster.numWorkouts()
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 40)
        tableView.separatorColor = UIColor(red:0.18, green:0.18, blue:0.18, alpha:0.5)
        let cellIdentifier = "WorkoutCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? WorkoutCellTableViewCell else {
            fatalError("Dequeued cell not an instance of WorkoutCell")
        }
        cell.workoutLabel.textColor = .black
        cell.backgroundColor = .clear
        
        let name = workoutList[indexPath.row].name
        let duration = workoutList[indexPath.row].duration
        let num:Double = Double(duration ?? -1.0)
        var combinedText:String
        if (duration != nil) {
            combinedText = "\(name) : \(String(num.removeDecimalAndZero)) secs"
        } else {
            combinedText = "\(name)"
        }
        cell.workoutLabel.text = combinedText
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //self.list = PeriodNames.getPeriodNames()
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: { (action, view, boolValue) in
            let alert = UIAlertController(title: "", message: "Edit Workout", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = self.workoutList[indexPath.row].name
            })
            
            alert.addTextField(configurationHandler: { (numberField) in
                numberField.keyboardType = .numberPad
                let durationAsDouble:Double = Double(self.workoutList[indexPath.row].duration ?? 0)
                numberField.text = String(durationAsDouble.removeDecimalAndZero)
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                self.workoutList[indexPath.row].name = alert.textFields!.first!.text!
                self.workoutList[indexPath.row].duration = Double(alert.textFields![1].text!) //cast the string into a double to be used as a time interval
                //self.WorkoutsMaster.updateWorkoutList(index: indexPath.row, self.workoutList[indexPath.row].name, self.workoutList[indexPath.row].duration)
                self.VCMaster.resetAll()
                self.tableView.reloadRows(at: [indexPath], with: .right)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: false)
            
        })
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, boolValue) in
            self.workoutList.remove(at: indexPath.row)
            self.VCMaster.resetAll()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        })
        let swipeActions = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        return swipeActions
    }
    
    
    /*
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //self.list = PeriodNames.getPeriodNames()
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: { (action, indexPath) in
            let alert = UIAlertController(title: "", message: "Edit Workout", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = self.workoutList[indexPath.row].name
            })
            
            alert.addTextField(configurationHandler: { (numberField) in
                numberField.keyboardType = .numberPad
                let durationAsDouble:Double = Double(self.workoutList[indexPath.row].duration ?? 0)
                numberField.text = String(durationAsDouble.removeDecimalAndZero)
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                self.workoutList[indexPath.row].name = alert.textFields!.first!.text!
                self.workoutList[indexPath.row].duration = Double(alert.textFields![1].text!) //cast the string into a double to be used as a time interval
                self.WorkoutsMaster.updateWorkoutList(index: indexPath.row, self.workoutList[indexPath.row].name, self.workoutList[indexPath.row].duration)
                self.tableView.reloadRows(at: [indexPath], with: .right)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: false)
            
        })
        return [editAction]
    }
    */
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.workoutList.remove(at: indexPath.row)
            //self.WorkoutsMaster.workoutList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
