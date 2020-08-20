//
//  WorkoutEditorControllerTableViewController.swift
//  10MinWorkout
//
//  Created by Gavin Ryder on 8/15/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import UIKit
import Foundation

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
    var clean: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

class WorkoutEditorControllerTableViewController: UITableViewController, UITextFieldDelegate {
    
    private var isInitialized = false
    private var darkModeEnabled:Bool = false
    
    private let WorkoutsMaster: Workouts = Workouts.shared
    var VCMaster: ViewController = ViewController()
    private let tableGradient:GradientView = GradientView()
    var reorderTableView: LongPressReorderTableView!
    private var workoutList:[Workouts.Workout] = [] {
        didSet {
            if (isInitialized) {
                self.WorkoutsMaster.allWorkouts = self.workoutList
            }
        }
    }
    
    //MARK: - Properties
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range:NSRange, replacementString string:String) -> Bool { //restrict fields using this class as a delegate 
        
        let allowedChars = "1234567890"
        let allowedCharSet = CharacterSet(charactersIn: allowedChars)
        let typedCharSet = CharacterSet(charactersIn: string)
        return allowedCharSet.isSuperset(of: typedCharSet)
    }
    
    
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
        label.font = UIFont (name: "Avenir Next", size: 14.0)!
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 2
        label.text = "Swipe right to remove or edit a workout \n Long press to re-arrange"
        self.navigationItem.titleView = label
        addButton.action = #selector(self.addCellTapped)
        addButton.target = self
    }
    
    @objc func backTapped(){
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func addCellTapped() {
        let alert = UIAlertController(title: "", message: "Add Workout", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Workout Name"
        })
        
        alert.addTextField(configurationHandler: { (numberField) in
            numberField.keyboardType = .numberPad
            numberField.delegate = self //should restrict to nums only
            numberField.placeholder = "Duration (sec)"
        })
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (updateAction) in
            let durationInput = alert.textFields![1].text!
            var newWorkout:Workouts.Workout
            newWorkout = Workouts.Workout(duration: Double(durationInput), name: alert.textFields!.first!.text!) //input should be numeric only
            self.workoutList.append(newWorkout)
            self.VCMaster.resetAll()
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

//MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        self.darkModeEnabled = (self.traitCollection.userInterfaceStyle == .dark)
        if (darkModeEnabled){
            tableGradient.firstColor =   #colorLiteral(red: 1, green: 0.3529411765, blue: 0, alpha: 1)
            tableGradient.secondColor =  #colorLiteral(red: 1, green: 0.8361050487, blue: 0.6631416678, alpha: 1)
        } else {
            tableGradient.firstColor = #colorLiteral(red: 1, green: 0.8361050487, blue: 0.6631416678, alpha: 1)
            tableGradient.secondColor = #colorLiteral(red: 1, green: 0.3515937998, blue: 0, alpha: 1)
        }
        self.tableView.backgroundView = tableGradient
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.addWorkoutButton
        
        self.workoutList = WorkoutsMaster.allWorkouts
        reorderTableView = LongPressReorderTableView(self.tableView)
        reorderTableView.enableLongPressReorder()
        reorderTableView.delegate = self
        self.isInitialized = true
    }
    
    
    //MARK: - VC Hierarchy
//    override func addChild(_ childController: UIViewController) { //TODO: kinda hacky
//        VCMaster = childController as! ViewController
//    }
    
    
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
            combinedText = "\(name) : \(String(num.clean)) secs"
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
                numberField.delegate = self //should restrict input to numeric only
                let durationAsDouble:Double = Double(self.workoutList[indexPath.row].duration ?? 0)
                numberField.text = String(durationAsDouble.clean)
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                let durationInput = alert.textFields![1].text!
                self.workoutList[indexPath.row].name = alert.textFields!.first!.text!
                self.workoutList[indexPath.row].duration = Double(durationInput) //input should be numeric only via delegate
                self.VCMaster.resetAll()
                self.tableView.reloadRows(at: [indexPath], with: .bottom)
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
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.workoutList.remove(at: indexPath.row)
            //self.WorkoutsMaster.workoutList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    

    
    // Override to support rearranging the table view.
//    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
//        let movedObject = self.workoutList[fromIndexPath.row]
//        self.workoutList.remove(at: fromIndexPath.row)
//        self.workoutList.insert(movedObject, at: to.row)
//        VCMaster.resetAll()
//    }
    

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

extension WorkoutEditorControllerTableViewController {
    
    override func reorderFinished(initialIndex: IndexPath, finalIndex: IndexPath) {
        self.workoutList.swapAt(initialIndex.row, finalIndex.row) //swap the rows in the underlying data model
        VCMaster.resetAll()
    }
    
    
}
