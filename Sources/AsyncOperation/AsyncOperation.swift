//
//  AsyncOperation.swift
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

import Foundation

open class AsyncOperation<Success, Failure>: Operation where Failure: Error {

    private enum State {

        case unstarted

        case executing

        case finished(Result<Success, Failure>)

        var isExecuting: Bool {
            switch self {
            case .executing:
                return true

            default:
                return false
            }
        }

        var isFinished: Bool {
            switch self {
            case .finished:
                return true

            default:
                return false
            }
        }

        var result: Result<Success, Failure>? {
            switch self {
            case .finished(let result):
                return result

            default:
                return nil
            }
        }
    }

    private let queue = DispatchQueue(label: "AsyncOperation", attributes: .concurrent)

    private var _state: State = .unstarted

    private var state: State {
        get {
            return queue.sync {
                _state
            }
        }

        set {
            queue.sync(flags: .barrier) {
                precondition(!_state.isFinished, "Cannot change from finished state")

                _state = newValue
                _isExecuting = _state.isExecuting
                _isFinished = _state.isFinished
            }
        }
    }

    public override var isAsynchronous: Bool {
        return true
    }

    private var _isExecuting: Bool = false {
        willSet {
            willChangeValue(for: \.isExecuting)
        }

        didSet {
            didChangeValue(for: \.isExecuting)
        }
    }

    public override var isExecuting: Bool {
        return _isExecuting
    }

    private var _isFinished: Bool = false {
        willSet {
            willChangeValue(for: \.isFinished)
        }

        didSet {
            didChangeValue(for: \.isFinished)
        }
    }

    public override var isFinished: Bool {
        return _isFinished
    }

    public var result: Result<Success, Failure>? {
        guard case .finished(let result) = state else {
            return nil
        }
        return result
    }

    public final func finish(with result: Result<Success, Failure>) {
        state = .finished(result)
    }

    public override final func start() {
        state = .executing
        main()
    }

    open override func main() { }
}
