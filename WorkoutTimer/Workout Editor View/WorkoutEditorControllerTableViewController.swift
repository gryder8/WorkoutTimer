//
//  WorkoutEditorControllerTableViewController.swift
//  10MinWorkout
//
//  Created by Gavin Ryder on 8/15/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import UIKit
import Foundation

//MARK: - Font Extension for Italic and Bold
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

//MARK: - Double Extension for No Decimals
extension Double {
	var clean: String {
		return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
	}
}

extension UITableViewCell {
	func appearsEnabled(_ enabled: Bool) {
		for view in contentView.subviews {
			view.isUserInteractionEnabled = enabled
			view.alpha = enabled ? 1 : 0.5
		}
	}
}

//MARK: - Class
class WorkoutEditorControllerTableViewController: UITableViewController, UITextFieldDelegate {
	
	private var isInitialized = false
	private var shouldAlert = true
	private let cellFontMedium = UIFont(name: "Avenir Next Medium", size: 17.0)
	
	
	let gradientView = StyledGradientView.shared
	private let WorkoutsMaster: Workouts = Workouts.shared
	var VCMaster: ViewController = ViewController()
	private let tableGradient:GradientBackgroundView = StyledGradientView.shared
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
	
	//MARK: - Text Input Input Restriction via Delegate
	func textField(_ textField: UITextField, shouldChangeCharactersIn range:NSRange, replacementString string:String) -> Bool { //restrict fields using this class as a delegate
		
		let allowedChars = "1234567890" //only numerical digits
		let allowedCharSet = CharacterSet(charactersIn: allowedChars)
		let typedCharSet = CharacterSet(charactersIn: string)
		return allowedCharSet.isSuperset(of: typedCharSet)
	}
	
	//MARK: - View Overrides
	override func viewWillAppear(_ animated: Bool) {
		setUpTableViewHeader()
		self.navigationController?.setNavigationBarHidden(false, animated: false)
		StyledGradientView.setColorsForGradientView(view: gradientView)
		self.tableView.backgroundView = gradientView
		self.navigationController?.navigationBar.barTintColor = StyledGradientView.viewColors.first!
		self.navigationController?.navigationBar.tintColor = StyledGradientView.viewColors.last!
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		//self.navigationController?.navigationBar.setIsHidden(true, animated: false)
	}
	
	//MARK: - View Did Load
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Uncomment the following line to preserve selection between presentations
		//self.clearsSelectionOnViewWillAppear = false
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		//self.navigationItem.rightBarButtonItem = self.addWorkoutButton
		
		self.workoutList = WorkoutsMaster.allWorkouts
		reorderTableView = LongPressReorderTableView(self.tableView)
		reorderTableView.enableLongPressReorder()
		reorderTableView.delegate = self
		self.isInitialized = true
		self.navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	//MARK: - View customization and UI Event handling
	private func setUpTableViewHeader(){
		//self.navigationController?.navigationBar.isHidden = false
		self.navigationController?.navigationBar.setIsHidden(false, animated: true)
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.isTranslucent = false
		self.navigationController?.navigationBar.barTintColor = tableGradient.startColor
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
		
		label.textColor = StyledGradientView.viewColors.last!
		
		self.navigationItem.titleView = label
		addButton.action = #selector(self.addCellTapped)
		addButton.target = self
		self.navigationController?.navigationBar.setIsHidden(false, animated: true)
	}
	
	//MARK: - Unused, stored in case of need
	@objc func backTapped(){
		navigationController?.popToRootViewController(animated: true)
	}
	
	//MARK - Add Cells
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
	
	
	
	// MARK: - Table View Data Source Config
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return WorkoutsMaster.numWorkouts()
	}
	
	
	
	//MARK: - Initialize Cells
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 40)
		tableView.separatorColor = UIColor(red:0.18, green:0.18, blue:0.18, alpha:0.5)
		let cellIdentifier = "WorkoutCell"
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? WorkoutCellTableViewCell else {
			fatalError("Dequeued cell not an instance of WorkoutCell")
		}
		//print("Cell Font: \(cellFont)")
		if (indexPath.row == WorkoutsMaster.currentWorkoutIndex) {
			cell.workoutLabel.textColor = .black
			cell.workoutLabel.font = cellFontMedium //make the font bold?
		} else if (indexPath.row < WorkoutsMaster.currentWorkoutIndex) {
			cell.appearsEnabled(false) //give the cell the "disabled" look
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
	
	
	
	//MARK: - Enable Cell Editing
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if (VCMaster.timerInitiallyStarted) {
			return indexPath.row != WorkoutsMaster.currentWorkoutIndex
		} else {
			return true
		}
	}
	
	//MARK: - Configure Edit and Delete Functionality
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		//self.list = PeriodNames.getPeriodNames()
		let editAction = UIContextualAction(style: .normal, title: "Edit", handler: { (action, view, boolValue) in
			let alert = UIAlertController(title: "", message: "Edit Workout", preferredStyle: .alert)
			alert.addTextField(configurationHandler: { (textField) in
				textField.text = self.workoutList[indexPath.row].name
			})
			
			alert.addTextField(configurationHandler: { (numberField) in
				numberField.keyboardType = .numberPad
				numberField.delegate = self //restricts input to numeric only
				let durationAsDouble:Double = Double(self.workoutList[indexPath.row].duration ?? 0)
				numberField.text = String(durationAsDouble.clean)
			})
			
			alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
				let durationInput = alert.textFields![1].text!
				self.workoutList[indexPath.row].name = alert.textFields!.first!.text!
				self.workoutList[indexPath.row].duration = Double(durationInput) //input should be numeric only via delegate
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
	
	
	//MARK: - Define Delete Behavior [UNUSED]
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if (editingStyle == .delete) {
			self.workoutList.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		}
	}
	
	override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	
}

//MARK: - Extension For Reorder Lib
//allows the reordering of cells to change the backend data according to their placement
//NOTE: Delegate of Reordering object must be set to self for this method to be called
extension WorkoutEditorControllerTableViewController {
	
	override func reorderFinished(initialIndex: IndexPath, finalIndex: IndexPath) {
		workoutList.swapAt(initialIndex.row, finalIndex.row)
		
		VCMaster.currentWorkout = WorkoutsMaster.getCurrentWorkout()
		VCMaster.nextWorkout = WorkoutsMaster.getNextWorkout()
		if (!VCMaster.isRestTimerActive) {
			VCMaster.updateLabels()
		} else {
			VCMaster.updateLabels(nextWorkoutOnly: true)
		}
		
		//code for resetting ring if needed
		//				VCMaster.timerRing.resetTimer()
		//				VCMaster.timerRing.shouldShowValueText = false
		//				VCMaster.timerInitiallyStarted = false
		//				VCMaster.changeButtonToMode(mode: .start)
		
	}
	
	
	override func allowChangingRow(atIndex: IndexPath) -> Bool{
		if (atIndex.row <= WorkoutsMaster.currentWorkoutIndex && VCMaster.timerInitiallyStarted) {
			return false
		} else {
			return true
		}
	}
	
	
}
