//
//  Sweme2Tests.swift
//  Sweme2Tests
//
//  Created by YOSHIHASHI Kenji on 8/17/14.
//  Copyright (c) 2014 mannan. All rights reserved.
//

import UIKit
import XCTest

@testable import Sweme2

class Sweme2Tests: XCTestCase {

    var testData = [(code: String, expectedResult: String)]()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        testData.append( (code: "(+ 0 (* 11 22) (- 333 30 3))",      expectedResult: "542")   ) // to operate integer values by arithmetic operators
        testData.append( (code: "(first (1 2 3))",                   expectedResult: "1"  )   ) // to operate list by `first', `rest' and `list'
        testData.append( (code: "(rest (1 2 3))",                    expectedResult: "(2 3)") ) // to operate list by `first', `rest' and `list'
        testData.append( (code: "(let (a 2 b 3 c 4) (+ a b c))",     expectedResult: "9"  )   ) // to bind values to local variables by `let'
        testData.append( (code: "(if (< 1 3) 2 3)",                  expectedResult: "2"  )   ) // to control flows by `if' and comparison operators
        testData.append( (code: "(map (list 1 2) (\\ (x) (* 2 x)))", expectedResult: "(2 4)") ) // to create procedures by `\', to iterate values in list by `map'
        testData.append( (code: "(defun calc (a b) (+ a b))",        expectedResult: "#N" )   ) // to define functions by `defun'
        testData.append( (code: "(calc 4 8)",                        expectedResult: "12" )   ) // to use function from environment

        //testData.append( (code: "(cons 5 (cons 3 4))",                expectedResult: "") ) // cons
        //testData.append( (code: "(quote calc)",                       expectedResult: "12" )   ) // quote

        testData.append( (code: "(defun f (x) (if (= x 0) 1 (if (= x 1) 1 (+ (f (- x 1)) (f (- x 2))))))", expectedResult: "#N" )) // function to calc the Fibonacci numbers
        testData.append( (code: "(map (list 0 1 2 3 4 5 6 7 8 9 10) (\\ (x) (f x)))", expectedResult: "(1 1 2 3 5 8 13 21 34 55 89)" )) // calc the Fibonacci numbers

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test001() {
        self.measureBlock() {
            let evaluator = Evaluator()
            for (code, expectedResult) in self.testData {
                let expression = evaluator.parse(code)
                let evaluated = evaluator.eval(expression!)
                let result = evaluated.toString()
                XCTAssertTrue(expectedResult == result, "test: \(code) expected: \(expectedResult) actual: \(result) ")
            }
        }
    }
    
}
