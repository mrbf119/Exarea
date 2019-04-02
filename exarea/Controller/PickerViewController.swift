//
//  PickerViewController.swift
//  exarea
//
//  Created by Soroush on 12/16/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {
    
    @IBOutlet private var pickerView: UIPickerView!
    
    weak var delegate: (UIPickerViewDelegate & UIPickerViewDataSource)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.delegate = self.delegate
        self.pickerView.dataSource = self.delegate
    }
}
