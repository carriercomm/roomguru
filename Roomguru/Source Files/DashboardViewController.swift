//
//  DashboardViewController.swift
//  Roomguru
//
//  Created by Patryk Kaczmarek on 11.03.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

    weak var aView: DashboardView?
    
    private let viewModel = DashboardViewModel(items: [
        CellItem(title: "Revoke event", action: .Revoke),
        CellItem(title: "Book first available room", action: .Book),
    ])
    
    // MARK: View life cycle

    override func loadView() {
        aView = loadViewWithClass(DashboardView.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("didTapPlusButton:"))
        
        setupTableView()
        centralizeTableView()
    }
}

// MARK: Actions

extension DashboardViewController {
 
    func didTapBookRoom(sender: UIButton) {
        
        BookingManager.findClosestAvailableRoom { (calendarTime, error) in
            if let _error = error {
                UIAlertView(error: _error).show()
                
            } else if let _calendarTime = calendarTime {
                
                let confirmationViewController = self.bookingConfirmationViewControllerWithCalendarTime(_calendarTime)
                let navigationVC = NavigationController(rootViewController: confirmationViewController)
                self.presentViewController(navigationVC, animated: true, completion: nil)
            }
        }
    }
    
    func didTapRevokeBookedRoom(sender: UIButton) {
        let revokeEventsController = RevokeEventsViewController()
        let navigationController = NavigationController(rootViewController: revokeEventsController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func didTapPlusButton(sender: UIBarButtonItem) {
        // NGRTemp:
        let calendarEntry = CalendarEntry(calendarID: Room.Test, event: Event())
        
        let viewModel = EditEventViewModel(calendarEntry: calendarEntry)
        let controller = EditEventViewController(viewModel: viewModel)
        let navigationController = NavigationController(rootViewController: controller)
        presentViewController(navigationController, animated: true, completion: nil)
    }
}

// MARK: UITableViewDataSource Methods

extension DashboardViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(ButtonCell.reuseIdentifier()) as! UITableViewCell
        
        if let _cell = cell as? ButtonCell {
            
            let item = viewModel[indexPath.row]
            var action: Selector;
            
            switch item.action {
            case .Book: action = Selector("didTapBookRoom:")
            case .Revoke: action = Selector("didTapRevokeBookedRoom:")
            }
    
            _cell.button.setTitle(item.title)
            _cell.button.backgroundColor = item.color
            _cell.button.addTarget(self, action: action)
        }
        
        return cell;
    }
}


// MARK: UITableViewDelegate Methods

extension DashboardViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}

// MARK: Private Methods

extension DashboardViewController {
    
    private func setupTableView() {
        let tableView = aView?.tableView
        
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.registerClass(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseIdentifier())
    }
    
    private func centralizeTableView() {
        let topInset = max(0, (contentViewHeight() - requiredHeight()) / 2)
        aView?.tableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0);
    }
    
    private func requiredHeight() -> CGFloat {
        
        if let rowHeight = aView?.tableView.rowHeight {
            return CGFloat(viewModel.numberOfItems()) * rowHeight
        }
        return 0
    }
    
    private func contentViewHeight() -> CGFloat {
        
        let topInset = (self.navigationController != nil) ? self.navigationController!.navigationBar.frame.size.height : 0
        let bottomInset = (self.tabBarController != nil) ? self.tabBarController!.tabBar.frame.size.height : 0
        
        return (aView != nil) ? aView!.bounds.height - topInset - bottomInset : 0
    }
    
    private func bookingConfirmationViewControllerWithCalendarTime(calendarTime: CalendarTimeFrame) -> BookingConfirmationViewController {
        
        return BookingConfirmationViewController(calendarTime, onConfirmation: { (actualCalendarTime, summary) -> Void in
            
            BookingManager.bookTimeFrame(actualCalendarTime, summary: summary, success: { (event: Event) in
                
                if let startTimeString = event.startTime, let endTimeString = event.endTime {
                    let message = NSLocalizedString("Booked room", comment: "") + " from " + startTimeString + " to " + endTimeString
                    UIAlertView(title: NSLocalizedString("Success", comment: ""), message: message).show()
                    self.aView?.tableView.reloadData()
                }
                
                }, failure: { (error: NSError) in
                    UIAlertView(error: error).show()
                }
            )
        })
    }
}

