# Swift 2.2 Simple Lisp Interpreter

This lisp interpreter is derived from [In English](http://knj4484.blogspot.jp/2014/08/lisp-interpreter-implemented-in-185.html "In English") or [In Japanese](http://xavier.hateblo.jp/entry/2014/08/19/003609 "in Japanese")

The goal is to improve readability, handle rational numbers, error reporting, and multiple top level expressions.

Currently it is working with Xcode Version 7.3.1 (7D1014).

What This Lisp Interpreter can do today:

- to operate integer values by arithmetic operators  
	`(+ 0 (* 11 22) (- 333 30 3))`

- to operate list by 'first', 'rest' and 'list'  
    `(first (1 2 3))`

- to bind values to local variables by 'let'  
    `(let (a 2 b 3 c 4) (+ a b c))`

- to control flows by `if` and comparison operators  
	`(if (< 1 3) 2 3)`

- to create procedures by '\' for example to iterate values in list by 'map'  
    `(map (list 1 2) (\ (x) (* 2 x)))`

- to define functions by 'defun'  
	`(defun calc (a b) (+ a b))`
    `(calc 4 8)`

- to define variable  
    `(let a 5)`

Swift Usage  
    `let evaluator = Evaluator()`  
    `let expression = evaluator.parse("(map (list 1 2) (\ (x) (* 2 x)))")`  
    `let evaluated = evaluator.eval(expression!)`  
    `let result = evaluated.toString()`  
    
To use in your own project, just add the files `Evaluator.swift` and `Expression.swift` to the project.
