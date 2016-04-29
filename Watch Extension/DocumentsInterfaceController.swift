//
//  DocumentsInterfaceController.swift
//  Dictamed
//
//  Created by Adrian Mateoaea on 29.04.2016.
//  Copyright © 2016 Adrian Mateoaea. All rights reserved.
//

import WatchKit
import Foundation

class DocumentsInterfaceController: WKInterfaceController {

    @IBOutlet var tableView: WKInterfaceTable!
    
    var items: [TranscriptModel] = [] {
        didSet {
            self.tableView.setNumberOfRows(self.items.count, withRowType: "cell")
            
            for i in 0..<self.items.count {
                let cell = self.tableView.rowControllerAtIndex(i) as! DocumentTableViewCell
                let item = self.items[i]
                
                cell.titleLabel.setText(item.title)
                cell.contentLabel.setText(item.translation)
                
                if item.validated {
                    cell.imageView.setImage(UIImage(named: "ic_check"))
                } else {
                    cell.imageView.setImage(UIImage(named: "ic_pending"))
                }
            }
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()
        
        DictamedAPI.sharedInstance.getAllPosts { (items) in
            self.items = items.sort { $0.validated && !$1.validated }
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

}