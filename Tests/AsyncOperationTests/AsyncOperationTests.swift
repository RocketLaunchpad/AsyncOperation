//
//  AsyncOperationTests.swift
//  AsyncOperation
//
//  Copyright 2020 Anodized Software, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import AsyncOperation
import XCTest

final class AsyncOperationTests: XCTestCase {

    enum TestOperationError: Error, Equatable {
        case valueIsOdd(Int)
    }

    class TestOperation: AsyncOperation<String, TestOperationError> {
        let value: Int

        init(value: Int) {
            self.value = value
            super.init()
        }

        override func main() {
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(value)) {
                if self.value % 2 == 0 {
                    self.finish(with: .success("\(self.value) is even"))
                }
                else {
                    self.finish(with: .failure(.valueIsOdd(self.value)))
                }
            }
        }
    }

    func testExample() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 2

        let operations: [TestOperation] = (10..<50).map {
            TestOperation(value: $0)
        }

        queue.addOperations(operations, waitUntilFinished: true)
        for op in operations {
            if op.value % 2 == 0 {
                XCTAssertEqual(.success("\(op.value) is even"), op.result)
            }
            else {
                XCTAssertEqual(.failure(TestOperationError.valueIsOdd(op.value)), op.result)
            }
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
