
//
//  StudentVisitsViewController.swift
//  StudVisit
//
//  Created by Maxim Galayko on 5/22/16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit
import EPCalendarPicker

enum StudentPresentationType {
    case AllStudents
    case StudentLectionFolders
}

class StudentVisitsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    static let storyboardIdentifier = "StudentVisitsViewControllerStoryboardIdentifier"
    
    var visitsPresentationType: StudentPresentationType = .AllStudents
    
    var selectedUserName: String?
    var dataSource: [String] {
        if visitsPresentationType == .AllStudents {
            let studentNames = SVStudentVisitModel.itemsWithPredicate("studentName != nil").map { student in
                return student.studentName! // maybe remove dublicates
            }
            return Array(Set(studentNames))
            
// get from data base array of student names
//            return ["max galayko", "pavlo dumyak", "andriy gavrish"]
        } else {
            guard let selectedUserName = selectedUserName else {
                return []
            }
            let lessonFolders = SVStudentVisitModel.itemsWithPredicate("studentName == '\(selectedUserName)'").map { student in
                return student.lessonsName ?? ""
            }
            return Array(Set(lessonFolders))
            
// get visits for selected user
//            return ["architecture", "mob dev", "testing"]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()
        updateDependencies()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let title = visitsPresentationType == .AllStudents ? "Студенти" : selectedUserName
        navigationItem.title = title
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Dependencies
    
    func updateDependencies() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    class func newInstance() -> StudentVisitsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier(storyboardIdentifier) as! StudentVisitsViewController
        return controller
    }
    
    // MARK: - Fetch visit dates
    
    func visitDatesForStudent(studentName: String, lection: String) -> [NSDate] {
        let visits = SVStudentVisitModel.itemsWithPredicate("studentName == '\(studentName)' AND lessonsName == '\(lection)'").filter { student in
            return student.date != nil
        }.map { student in
            return student.date!
        }
        return visits
        
//        return [
//            NSDate(),
//            NSDate().dateByAddingTimeInterval(60 * 60 * 24 * -3),
//            NSDate().dateByAddingTimeInterval(60 * 60 * 24 * -5),
//            NSDate().dateByAddingTimeInterval(60 * 60 * 24 * -7)
//        ]
    }
    
    func presentCalendarWithVisits(visits: [NSDate]) {
        let calendarPicker = EPCalendarPicker(startYear: 2016, endYear: 2017, multiSelection: true)
        calendarPicker.calendarDelegate = self
        calendarPicker.arrSelectedDates = visits
        
        navigationController?.pushViewController(calendarPicker, animated: true)
    }
}

extension StudentVisitsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if visitsPresentationType == .AllStudents {
            let cell = tableView.dequeueReusableCellWithIdentifier(UserTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! UserTableViewCell
            cell.clear()
            cell.fillWithUserName(dataSource[indexPath.row], role: 0) // role 0 == student
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(LessonTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! LessonTableViewCell
            let lessonName = dataSource[indexPath.row]
            cell.titleLabel.text = lessonName
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if visitsPresentationType == .AllStudents { // show new table with student lection folders
            let studentName = dataSource[indexPath.row]
            let studentVisitsController = StudentVisitsViewController.newInstance()
            studentVisitsController.selectedUserName = studentName
            studentVisitsController.visitsPresentationType = .StudentLectionFolders
            navigationController?.pushViewController(studentVisitsController, animated: true)
            
        } else { // student folder choosed, show calendar
            let selectedLessonName = dataSource[indexPath.row]
            let visits = visitDatesForStudent(selectedUserName!, lection: selectedLessonName)
            presentCalendarWithVisits(visits)
        }
    }
}

extension StudentVisitsViewController: EPCalendarPickerDelegate {
    func epCalendarPicker(_: EPCalendarPicker, didCancel error : NSError) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func epCalendarPicker(_: EPCalendarPicker, didSelectDate date : NSDate) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func epCalendarPicker(_: EPCalendarPicker, didSelectMultipleDate dates : [NSDate]) {
        navigationController?.popViewControllerAnimated(true)
    }
}
