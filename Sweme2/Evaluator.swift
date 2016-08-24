
// What This Lisp Interpreter Can Do
//
// - to operate integer values by arithmetic operators
//    (+ 0 (* 11 22) (- 333 30 3))
//
// - to operate list by `first', `rest' and `list'
//    (first (1 2 3))
//
// - to bind values to local variables by `let'
//    (let (a 2 b 3 c 4) (+ a b c))
//
// - to control flows by `if' and comparison operators
//    (if (< 1 3) 2 3)
//
// - to create procedures by `\'
// - to iterate values in list by `map'
//    (map (list 1 2) (\ (x) (* 2 x)))
//
// - to define functions by `defun'
//    (defun calc (a b) (+ a b))
//    (calc 4 8)
//
// - to define variable
//    (let a 5)


// Usage
//    let evaluator = Evaluator()
//    let expression = evaluator.parse(" (map (list 1 2) (\ (x) (* 2 x)))")
//    let evaluated = evaluator.eval(expression!)
//    let result = evaluated.toString()

class Environment {
    let outer: Environment?

    var vars: [String : Expression] = [:]

    init(outer: Environment?) {
        self.outer = outer
    }

    func add(symbol: Symbol, expression: Expression) {
        vars[symbol.name] = expression
    }

    func lookup(symbol: Symbol) -> Expression! {
        return (vars[symbol.name] != nil) ? vars[symbol.name] : outer?.lookup(symbol)
    }
}

class Evaluator {
    var rootEnv = Environment(outer: nil)

    func tokenize(input: String) -> [String] {
        var tokens: [String] = []
        var nextIndex = input.startIndex
        while nextIndex != input.endIndex {
            let read = readNextToken(input, startIndex: nextIndex)
            tokens += [read.token!]
            nextIndex = read.nextIndex
        }
        return tokens
    }

    func getNextChar(input: String, nextIndex: String.Index) -> String {
        return input.substringWithRange(nextIndex..<nextIndex.advancedBy(1))
    }

    func readNextToken(input :String, startIndex : String.Index) -> (token : String?, nextIndex : String.Index) {
        var nextIndex = startIndex
        while nextIndex != input.endIndex {
            if input.substringFromIndex(nextIndex).hasPrefix(" ")
                || input.substringFromIndex(nextIndex).hasPrefix("\n") {
                nextIndex = nextIndex.successor()
            } else {
                break
            }
        }
        if nextIndex == input.endIndex {
            return (nil, nextIndex)
        }
        let nextChar = getNextChar(input, nextIndex: nextIndex)
        switch nextChar {
        case "(", ")", "+", "*", "-", "/", "%", "<", ">", "=", "\\":
            nextIndex = nextIndex.successor()
            return (nextChar, nextIndex)
        case "1", "2", "3", "4", "5", "6", "7", "8", "9", "0":
            return readNumber(input, startIndex: nextIndex)
        default:
            return readSymbol(input, startIndex: nextIndex)
        }
    }
    
    func readNumber(input: String, startIndex: String.Index) -> (token: String?, nextIndex:String.Index) {
        var value = ""
        var nextIndex = startIndex
        while nextIndex != input.endIndex {
            let nextChar = getNextChar(input, nextIndex: nextIndex)
            switch nextChar {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                value += nextChar
            default:
                return (value, nextIndex)
            }
            nextIndex = nextIndex.successor()
        }
        return (value, nextIndex)
    }

    func readSymbol(input: String, startIndex: String.Index) -> (token: String?, nextIndex: String.Index) {
        var token = ""
        var nextIndex = startIndex
        while nextIndex != input.endIndex {
            let nextChar = getNextChar(input, nextIndex: nextIndex)
            switch nextChar {
            case " ", ")":
                return (token, nextIndex)
            default :
                token += nextChar
            }
            nextIndex = nextIndex.successor()
        }
        return (token, nextIndex)
    }

    func parse(input: String) -> Expression? {
        let tokens = tokenize(input)
        return parseTokens(tokens, startIndex: tokens.startIndex, endIndex: tokens.endIndex).expression
    }

    func parseTokens(tokens: [String], startIndex: Int, endIndex: Int) -> (expression: Expression, lastIndex: Int) {
        switch tokens[startIndex] {
        case "(":
            return readTillListEnd(tokens, startIndex: startIndex + 1, endIndex: endIndex)
        case "+", "*", "-", "/", "%", "<", ">", "=", "\\":
            return (Symbol(name: tokens[startIndex]), startIndex)
        default:
            let token = tokens[startIndex]
            switch token.substringToIndex(token.startIndex.successor()) {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                return (Number(value: Int(tokens[startIndex])!), startIndex)
            default:
                return (Symbol(name: tokens[startIndex]), startIndex)
            }
        }
    }

    func readTillListEnd(tokens: [String], startIndex: Int, endIndex: Int) -> (expression: Expression, lastIndex: Int) {
        var elements: [Expression] = []
        var nextIndex = startIndex
        while nextIndex < endIndex && tokens[nextIndex] != ")" {
            let parsed = parseTokens(tokens, startIndex: nextIndex, endIndex: endIndex)
            elements += [parsed.expression]
            nextIndex = parsed.lastIndex + 1
        }
        return (List(es: elements), nextIndex)
    }

    func eval(expression: Expression) -> Expression {
        return evalr(expression, env: rootEnv)
    }

    /// Number value
    func numberValue(v: Expression) -> Int {
        return (v as! Number).value
    }

    /// Number values
    func numberValues(es: [Expression], env: Environment) -> [Int] {
        return es[1..<es.count].map{ self.numberValue(self.evalr($0, env: env)) }
    }

    func narithmetic(ns: [Int], op: (Int, Int) -> Int) -> Number {
        return Number(value: ns[1..<ns.count].reduce(ns[0], combine: op))
    }

    func ncompare(ns: [Int], op: (Int, Int) -> Bool) -> Boolean {
        return Boolean(value: op(ns[0], ns[1]))
    }

    func bindParam(params: List, args: [Expression], outer: Environment) -> Environment {
        let env = Environment(outer: outer)
        for (idx, param) in params.es.enumerate() {
            env.add(param as! Symbol, expression: evalr(args[idx], env: env))
        }
        return env
    }

    func evalr(expression: Expression, env: Environment) -> Expression {
        switch expression {

        case let x where x is Procedure:
            return evalr((x as! Procedure).body, env:env)

        case let x where x is Symbol:
            return (env.lookup(x as! Symbol) != nil) ? env.lookup(x as! Symbol)! : expression

        case let x where x is List:
            let l = x as! List
            switch (l.es[0] as! Symbol).name {

            case "+":
                return narithmetic(numberValues(l.es, env: env)){ $0 + $1 }

            case "-":
                return narithmetic(numberValues(l.es, env: env)){ $0 - $1 }

            case "*":
                return narithmetic(numberValues(l.es, env: env)){ $0 * $1 }

            case "/":
                return narithmetic(numberValues(l.es, env: env)){ $0 / $1 }

            case "%":
                return narithmetic(numberValues(l.es, env: env)){ $0 % $1 }

            case "<":
                return ncompare(numberValues(l.es, env: env)){ $0 < $1 }

            case ">":
                return ncompare(numberValues(l.es, env: env)){ $0 > $1 }

            case "=":
                return ncompare(numberValues(l.es, env: env)){ $0 == $1 }

            case "let":
                let localEnv = Environment(outer: env)
                var isName = true
                var name: Symbol? = nil
                for name_or_value in (l.es[1] as! List).es {
                    if isName {
                        name = (name_or_value as! Symbol)
                    } else {
                        localEnv.add(name!, expression: evalr(name_or_value, env: env))
                    }
                    isName =  !isName
                }
                return evalr(l.es[2], env: localEnv)

            case "map":
                let proc = evalr(l.es[2], env: env) as! Procedure
                let targets = evalr(l.es[1] as! List, env: env) as! List
                return List(es: targets.es.map{
                    self.evalr(proc, env: self.bindParam(proc.params, args: [$0], outer: env))
                    })

            case "defun":
                env.add(l.es[1] as! Symbol, expression: Procedure(params: l.es[2] as! List, body: l.es[3] as! List, lexicalEnv: env))
                return Nil()

            case "if":
                return evalr(l.es[(evalr(l.es[1], env: env) as! Boolean).value ? 2 : 3], env: env)

            case "\\":
                return Procedure(params: l.es[1] as! List, body: l.es[2] as! List, lexicalEnv: env)

            case "quote":
                return List(es: (l.es[1] as! List).es)

            case "cons":
                let car = evalr(l.es[1], env: env)
                let cdr = (evalr(l.es[2], env: env) as! List).es
                return List(es: [car] + cdr)

            case "list":
                return List(es: l.es[1..<l.es.count].map{ $0 }) // map is used to cnvert Slice to Array

            case "first":
                return (l.es[1] as! List).es[0]

            case "rest":
                let src = l.es[1] as! List
                return List(es: src.es[1..<src.es.count].map{ $0 }) // map is used to cnvert Slice to Array

            case let function where (env.lookup(l.es[0] as! Symbol) != nil):
                let proc = env.lookup(l.es[0] as! Symbol) as! Procedure
                return evalr(proc, env: bindParam(proc.params, args: l.es[1..<l.es.count].map{ $0 }, outer: env))

            default: return Nil()
            }

        default: return expression
        }
    }
}