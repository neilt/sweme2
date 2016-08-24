//
//  ViewController.swift
//  Sweme2
//
//  Copyright (c) 2014 knj4484@gmail.com All rights reserved.
//  Original Use by Permision
//  Changes (c) 2016 Neil Tiffin
//  Changes (c) 2016 Performance Champions, Inc.
//

import UIKit

class ViewController: UIViewController {
    let evaluator = Evaluator()
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var codeTextView: UITextView!
    @IBAction func button() {
        let expression = evaluator.parse(codeTextView.text)
        let evaluated = evaluator.eval(expression!)
        textView.text = evaluated.toString()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

