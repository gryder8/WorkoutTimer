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


//MARK: - Cell extension for "disabled" look
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
	private let cellFontRegular = UIFont(name: "Avenir Next", size: 17.0)
	
	
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
	
	private func roundButton(button:UIButton) { //round the corners of the button passed in
		button.layer.cornerRadius = 10
		button.clipsToBounds = true
	}
	
	//MARK: - View Overrides
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: false)
		StyledGradientView.setColorsForGradientView(view: gradientView)
		self.tableView.backgroundView = gradientView
		self.navigationController?.navigationBar.barTintColor = StyledGradientView.viewColors.first!
		self.navigationController?.navigationBar.tintColor = StyledGradientView.viewColors.last!
		setUpTableViewHeader()
		if (!WorkoutsMaster.allWorkouts.isEmpty) {
			setUpTableViewFooter()
		}
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		//self.navigationController?.navigationBar.setIsHidden(true, animated: false)
	}
	
	//MARK: - View Did Load
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//self.tableView.addGestureRecognizer(longPressGesture)
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
		//updateCellStyles()
	}
	
	@objc func buttonAction() {
		showClearAlert()
	}
	
	func reloadTableViewDataAnimated(animation: UITableView.RowAnimation = .fade) {
		self.tableView.reloadSections(IndexSet(0..<tableView.numberOfSections), with: animation)
	}
	
	func showClearAlert() {
		let alert = UIAlertController(title: "Clear Workouts?", message: "All workouts will be removed!", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { (clearAction) in
			self.workoutList.removeAll()
			self.reloadTableViewDataAnimated()
			self.tableView.tableFooterView?.setIsHidden(true, animated: true)
			//self.VCMaster.currentWorkout = self.WorkoutsMaster.getCurrentWorkout()
			//self.VCMaster.nextWorkout = self.WorkoutsMaster.getNextWorkout()
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (cancelAction) in
		}))
		self.present(alert, animated: true)
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
		label.font = UIFont (name: "Avenir Next", size: 14.0)!
		label.textAlignment = .center
		label.numberOfLines = 2
		label.text = "Swipe right to remove or edit \n Long press cell to re-arrange"
		
		label.textColor = tableGradient.endColor
		
		self.navigationItem.titleView = label
		addButton.action = #selector(self.addCellTapped)
		addButton.target = self
		self.navigationController?.navigationBar.setIsHidden(false, animated: true)
	}
	
	private func setUpTableViewFooter() {
		let customFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
		customFooterView.backgroundColor = .clear

		let clearWorkoutsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 80))
		clearWorkoutsButton.backgroundColor = gradientView.startColor
		clearWorkoutsButton.titleLabel?.font = UIFont(name: "Avenir Next", size: 18.0)
		clearWorkoutsButton.setTitleColor(gradientView.endColor, for: .normal)
		clearWorkoutsButton.setTitle("Clear Workouts", for: .normal)
		clearWorkoutsButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
		roundButton(button: clearWorkoutsButton)
		customFooterView.addSubview(clearWorkoutsButton)
		self.tableView.tableFooterView = customFooterView

		clearWorkoutsButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			clearWorkoutsButton.widthAnchor.constraint(equalToConstant: 150),
			clearWorkoutsButton.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor),
			clearWorkoutsButton.centerYAnchor.constraint(equalTo: customFooterView.centerYAnchor)
		])
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
			let wasEmpty = self.workoutList.isEmpty
			let durationInput = alert.textFields![1].text!
			var newWorkout:Workouts.Workout
			newWorkout = Workouts.Workout(duration: Double(durationInput), name: alert.textFields!.first!.text!) //input should be numeric only
			self.workoutList.append(newWorkout)
			self.VCMaster.currentWorkout = self.WorkoutsMaster.getCurrentWorkout()
			self.VCMaster.nextWorkout = self.WorkoutsMaster.getNextWorkout()
			if (wasEmpty) {
				self.setUpTableViewFooter()
			}
			self.tableView.reloadData()
			self.tableView.tableFooterView?.setIsHidden(false, animated: true)
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
		tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		tableView.separatorColor = UIColor(red:0.18, green:0.18, blue:0.18, alpha:0.5)
		let cellIdentifier = "WorkoutCell"
		
		let currentWorkoutName = WorkoutsMaster.getCurrentWorkout().name
		let indexWorkoutName = WorkoutsMaster.allWorkouts[indexPath.row].name
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? WorkoutCellTableViewCell else {
			fatalError("Dequeued cell not an instance of WorkoutCell")
		}
		if (currentWorkoutName == indexWorkoutName) {
			cell.workoutLabel.font = cellFontMedium //make the font bold?
		} else if (indexPath.row < WorkoutsMaster.currentWorkoutIndex) {
			cell.appearsEnabled(false) //give the cell the "disabled" look
		} else {
			cell.workoutLabel.font = cellFontRegular
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
				//self.VCMaster.resetAll()
				self.VCMaster.currentWorkout = self.WorkoutsMaster.getCurrentWorkout()
				self.VCMaster.nextWorkout = self.WorkoutsMaster.getNextWorkout()
				self.tableView.reloadRows(at: [indexPath], with: .left)
				self.updateCellStyles(endCellRow: indexPath.row)
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
	
	private func updateCellStyles(endCellRow: Int = -1) {
		var counter = 0
		//var hasBoldedCurrent = false
		let currentWorkoutIndex = WorkoutsMaster.currentWorkoutIndex
		let currentWorkoutName = WorkoutsMaster.getCurrentWorkout().name
		if  (endCellRow != -1){ //ending row is passed so update up until the end
			let tableCells = tableView.visibleCells as! [WorkoutCellTableViewCell]
			for cell in tableCells[0...endCellRow] {
				let cellWorkoutName = WorkoutsMaster.allWorkouts[counter].name
				if (counter < currentWorkoutIndex) {
					cell.appearsEnabled(false)
					counter += 1
				} else if (counter == currentWorkoutIndex && currentWorkoutName == cellWorkoutName) {
					cell.workoutLabel.textColor = .black
					cell.workoutLabel.font = cellFontMedium
					counter += 1
					//hasBoldedCurrent = true
				} else {
					cell.workoutLabel.textColor = .black
					cell.workoutLabel.font = cellFontRegular
					counter += 1
				}
			}
		} else {
			for cell in tableView.visibleCells as! [WorkoutCellTableViewCell] { //no end row passed
				let cellWorkoutName = WorkoutsMaster.allWorkouts[counter].name
				if (counter < currentWorkoutIndex) {
					cell.appearsEnabled(false)
					counter += 1
				} else if (counter == currentWorkoutIndex && currentWorkoutName == cellWorkoutName) {
					cell.workoutLabel.textColor = .black
					cell.workoutLabel.font = cellFontMedium
					counter += 1
					//hasBoldedCurrent = true
				} else {
					cell.workoutLabel.textColor = .black
					cell.workoutLabel.font = cellFontRegular
					counter += 1
				}
			}
		}
	}
	
}

//MARK: - Extension For Reorder Lib
//allows the reordering of cells to change the backend data according to their placement
//NOTE: Delegate of Reordering object must be set to self for this method to be called
extension WorkoutEditorControllerTableViewController {
	
	override func reorderFinished(initialIndex: IndexPath, finalIndex: IndexPath) {
		workoutList.swapAt(initialIndex.row, finalIndex.row)
//		if (initialIndex.row == WorkoutsMaster.currentWorkoutIndex) {
//			let cell:WorkoutCellTableViewCell = tableView.cellForRow(at: initialIndex) as! WorkoutCellTableViewCell //should cast as all cells are forced to have this as their class
//			cell.workoutLabel.textColor = .black
//			cell.workoutLabel.font = cellFontMedium
//
//			let otherCell = tableView.cellForRow(at: finalIndex) as! WorkoutCellTableViewCell
//			otherCell.workoutLabel.textColor = .black
//			otherCell.workoutLabel.font = cellFontRegular
//		} else if (finalIndex.row == WorkoutsMaster.currentWorkoutIndex) {
//			let cell:WorkoutCellTableViewCell = tableView.cellForRow(at: finalIndex) as! WorkoutCellTableViewCell //should cast as all cells are forced to have this as their class
//			cell.workoutLabel.textColor = .black
//			cell.workoutLabel.font = cellFontMedium
//
//			let otherCell = tableView.cellForRow(at: initialIndex) as! WorkoutCellTableViewCell
//			otherCell.workoutLabel.textColor = .black
//			otherCell.workoutLabel.font = cellFontRegular
//		}
		updateCellStyles(endCellRow: max(initialIndex.row, finalIndex.row))
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
