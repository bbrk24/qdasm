import XCTest
@testable import qdasm

final class qdasmTests: XCTestCase {
    override func setUp() {
        Qdeql.reset()
    }

    func test_subtraction() {
        let a = Qdeql.readInput()
        let b = Qdeql.readInput()
        Qdeql.subtract(a, b)
        Qdeql.print(a)

        XCTAssertEqual(Qdeql.program, #"-&&==\=--\/\/==/=*"#)
    }

    func test_constant200() {
        let twoHundred = Qdeql.allocate(initialValue: 200)
        Qdeql.print(twoHundred)

        XCTAssertEqual(
            Qdeql.program,
            #"-\=/-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*"#
        )
    }

    func test_constant1() {
        let one = Qdeql.allocate(initialValue: 1)
        Qdeql.print(one)

        XCTAssertEqual(
            Qdeql.program,
            #"-\=/-\==/=\=--\/\/==/=*"#
        )
    }

    func test_truthMachine() {
        let input = Qdeql.readInput()
        Qdeql.decrement(input, by: 48)
        Qdeql.while(input) { _ in
            let asciiOne = Qdeql.allocate(initialValue: 49)
            Qdeql.print(asciiOne)
        }
        let asciiZero = Qdeql.allocate(initialValue: 48)
        Qdeql.print(asciiZero)
        
        XCTAssertEqual(
            Qdeql.program,
            #"-&=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\==\/\/\==/-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-=\===/=\==--\/\/===/==*/=\=/-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\==/=\=--\/\/==/=*"#
        )
    }

    func test_cat() {
        let input = Qdeql.readInput()
        Qdeql.while(input) { input in
            Qdeql.printAndReread(input)
        }

        XCTAssertEqual(Qdeql.program, #"-&=\==\/\/=*&=/="#)
    }

    func test_notZero() {
        let input = Qdeql.readInput()
        let in2 = Qdeql.readInput()
        Qdeql.ifNotZero(input) {
            let zero = Qdeql.allocate(initialValue: 0)
            Qdeql.print(zero)
        }
        Qdeql.print(in2)

        XCTAssertEqual(Qdeql.program, #"-&&=\===\/\/=\===/*\==\====-\/\/====///*"#)
    }

    func test_dup() {
        var input = Qdeql.readInput()
        let copy = Qdeql.duplicate(&input)
        Qdeql.print(input)
        Qdeql.print(copy)

        XCTAssertEqual(Qdeql.program, #"-&\==/=\=--\/\/==/\=\==\===---\/\/=====/=//**"#)
    }

    func test_zero() {
        let input = Qdeql.readInput()
        let in2 = Qdeql.readInput()
        Qdeql.ifZero(input) {
            let zero = Qdeql.allocate(initialValue: 0)
            Qdeql.print(zero)
        }
        Qdeql.print(in2)

        XCTAssertEqual(
            Qdeql.program,
            #"-&&\===/=\==--\/\/===/=\==\==\====---\/\/======/==//-\====\/\/==\===-\/\/===/==\===/=\===\=====-\/\/=====///==\===\/\/=\===/*\==\====-\/\/====///*"#
        )
    }

    func test_clampingSubtract() {
        var x = Qdeql.readInput()
        let y = Qdeql.readInput()
        Qdeql.clampingSubtract(&x, y)
        Qdeql.print(x)

        XCTAssertEqual(
            Qdeql.program,
            #"-&&\===/=\==--\/\/===/=\==\==\====---\/\/======/==//==\====\/\/===-==\====\/\/==-\===\=====-\/\/=====///=\===/=\==--\/\/===/=\==\==\====---\/\/======/==//==/\==-\/\/==/=*"#
        )
    }

    func test_duplicateInContext() {
        let a = Qdeql.readInput()
        var b = Qdeql.readInput()
        let c = Qdeql.readInput()
        let b2 = Qdeql.duplicate(&b)
        Qdeql.print(a)
        Qdeql.print(b)
        Qdeql.print(b2)
        Qdeql.print(c)

        print(Qdeql.program)
    }
}
