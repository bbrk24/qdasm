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

    func test_deallocate() {
        let x = Qdeql.readInput()
        let y = Qdeql.readInput()
        Qdeql.deallocate(y)
        Qdeql.print(x)

        XCTAssertEqual(
            Qdeql.program,
            #"-&&==\==-\/\/==/=*"#
        )
    }

    // This is supposed to generate a program to find the least prime factor of a number >= 2.
    // It doesn't work for reasons I haven't diagnosed yet.
    // The name starts with "zz" so it appears last in the (alphabetical) test list.
    /*
    func test_zz_print() {
        let n = Qdeql.allocate(initialValue: 254)
        let x = Qdeql.readInput()
        Qdeql.while(n) { n in
            let nCopy = Qdeql.duplicate(midValue: n)
            let p = Qdeql.allocate(initialValue: 0)
            Qdeql.subtract(p, nCopy)
            Qdeql.decrement(n)
            var y = Qdeql.duplicate(midValue: x)
            Qdeql.moveToFront(&y)
            Qdeql.while(y) { y in
                Qdeql.assumingNotMoving(y) { y in
                    let q = Qdeql.duplicate(midValue: p)
                    Qdeql.decrement(q)
                    Qdeql.clampingSubtract(&y, q)
                    // If y > 1: decrement y
                    // If y == 1: print p, decrement y, zero out n
                    // If y == 0: do nothing
                    let yCopy = Qdeql.duplicate(&y)
                    Qdeql.ifNotZero(yCopy) {
                        Qdeql.decrement(y)
                        let yCopy = Qdeql.duplicate(&y)
                        Qdeql.ifZero(yCopy) {
                            let q = Qdeql.duplicate(midValue: p)
                            Qdeql.print(q)
                            Qdeql.setZero(n)
                        }
                    }
                }
            }
            Qdeql.deallocate(p)
        }

        print(Qdeql.program)
    }
    */
}
