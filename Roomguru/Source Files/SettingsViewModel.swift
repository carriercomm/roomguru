//
//  SettingsViewModel.swift
//  Roomguru
//
//  Created by Patryk Kaczmarek on 15/03/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

class SettingsViewModel: NSObject {
    
    private let items : [SettingsItem] = [
        SettingsItem(NSLocalizedString("Sign out", comment: ""), .buttonType, "signOutHandler"),
        SettingsItem(NSLocalizedString("Receive notifications", comment: ""), .switchType, "notificationSwitchHandler:")
    ]
    
    // MARK: Public Methods
    
    func numberOfItems() -> Int {
        return items.count
    }

    func configureCellForIndex(#cell: UITableViewCell, index: Int) {
        
        let item: SettingsItem = items[index]

        if let theCell = cell as? RGRTableViewSwitchCell {
            theCell.switchControl.addTarget(self, action: Selector(item.action), forControlEvents: .ValueChanged)
            
            switch(index) {
            default: //temporary in default statement. Play with indexes later if more cell will appear
                theCell.switchControl.setOn(Settings.isNotifcationEnabled(), animated: false)
            }
        }

        cell.textLabel?.text = item.title
    }
    
    func identifierForIndex(index: Int) -> String {
        return (items[index] as SettingsItem).signature().identifier
    }
    
    func signatures() -> [String : AnyClass] {
        var dictionary = Dictionary<String, AnyClass>()
        for type: SettingsItem in items {
            dictionary[type.signature().identifier] = type.signature().registeredClass
        }
        return dictionary
    }
    
    func performActionForIndex(index: Int) {
         (items[index] as SettingsItem).performActionWithTarget(self)
    }
    
    func selectable(index: Int) -> Bool {
        return (items[index] as SettingsItem).selectable()
    }
    
    // MARK: Settings Item Action Handlers
    
    func signOutHandler() {
        (UIApplication.sharedApplication().delegate as AppDelegate).signOut()
    }
    
    func notificationSwitchHandler(sender: UISwitch) {
        Settings.reverseNotificationEnabled()
    }
    
}
