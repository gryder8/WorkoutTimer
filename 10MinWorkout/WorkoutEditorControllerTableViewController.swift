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
    
    private let WorkoutsMaster: Workouts = Workouts.shared
    private let tableGradient:GradientView = GradientView()
    private var workoutList:[Workouts.Workout] = [] //array of Workout structs
    private var darkModeEnabled:Bool = false


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
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WorkoutsMaster.numWorkouts()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 40)
        tableView.separatorColor = UIColor(red:0.18, green:0.18, blue:0.18, alpha:0.5)
        self.workoutList = WorkoutsMaster.workoutList
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
        if (indexPath.row != WorkoutsMaster.numWorkouts()-1) { //make the last cell not editable (for now at least)
            return true
        }
        return false
    }
    

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
