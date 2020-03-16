//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2017-2018 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
// - 3mar2020 forked from https://github.com/apple/swift-nio/blob/master/Sources/NIO/CircularBuffer.swift
// - 3mar2020 converted to use UInt32 instead of UInt24 from original
//
//===----------------------------------------------------------------------===//

extension FixedWidthInteger {
    /// Returns the next power of two.
    @inlinable
    func nextPowerOf2() -> Self {
        guard self != 0 else {
            return 1
        }
        return 1 << (Self.bitWidth - (self - 1).leadingZeroBitCount)
    }
}

extension UInt32 {
    /// Returns the next power of two unless that would overflow, in which case UInt32.max (on 64-bit systems) or
    /// Int32.max (on 32-bit systems) is returned. The returned value is always safe to be cast to Int and passed
    /// to malloc on all platforms.
    func nextPowerOf2ClampedToMax() -> UInt32 {
        guard self > 0 else {
            return 1
        }

        var n = self

        #if arch(arm) || arch(i386)
            // on 32-bit platforms we can't make use of a whole UInt32.max (as it doesn't fit in an Int)
            let max = UInt32(Int.max)
        #else
            // on 64-bit platforms we're good
            let max = UInt32.max
        #endif

        n -= 1
        n |= n >> 1
        n |= n >> 2
        n |= n >> 4
        n |= n >> 8
        n |= n >> 16
        if n != max {
            n += 1
        }

        return n
    }
}

/// An automatically expanding ring buffer implementation backed by a `ContiguousArray`. Even though this implementation
/// will automatically expand if more elements than `initialCapacity` are stored, it's advantageous to prevent
/// expansions from happening frequently. Expansions will always force an allocation and a copy to happen.
public struct CircularBuffer<Element>: CustomStringConvertible {
    @usableFromInline
    internal var _buffer: ContiguousArray<Element?>

    @usableFromInline
    internal var headBackingIndex: Int

    @usableFromInline
    internal var tailBackingIndex: Int

    @inlinable
    internal var mask: Int {
        _buffer.count &- 1
    }

    @inlinable
    internal mutating func advanceHeadIdx(by: Int) {
        headBackingIndex = indexAdvanced(index: headBackingIndex, by: by)
    }

    @inlinable
    internal mutating func advanceTailIdx(by: Int) {
        tailBackingIndex = indexAdvanced(index: tailBackingIndex, by: by)
    }

    @inlinable
    internal func indexBeforeHeadIdx() -> Int {
        indexAdvanced(index: headBackingIndex, by: -1)
    }

    @inlinable
    internal func indexBeforeTailIdx() -> Int {
        indexAdvanced(index: tailBackingIndex, by: -1)
    }

    @inlinable
    internal func indexAdvanced(index: Int, by: Int) -> Int {
        (index &+ by) & mask
    }

    /// An opaque `CircularBuffer` index.
    ///
    /// You may get indices offset from other indices by using `CircularBuffer.index(:offsetBy:)`,
    /// `CircularBuffer.index(before:)`, or `CircularBuffer.index(after:)`.
    ///
    /// - note: Every index is invalidated as soon as you perform a length-changing operating on the `CircularBuffer`
    ///         but remains valid when you replace one item by another using the subscript.
    public struct Index: Comparable {
        @usableFromInline var _backingIndex: UInt32
        // @usableFromInline var _backingCheck: _UInt24
        @usableFromInline var _backingCheck: UInt32
        @usableFromInline var isIndexGEQHeadIndex: Bool

        @inlinable
        internal var backingIndex: Int {
            Int(_backingIndex)
        }

        @inlinable
        internal init(backingIndex: Int, backingCount: Int, backingIndexOfHead: Int) {
            isIndexGEQHeadIndex = backingIndex >= backingIndexOfHead
            _backingCheck = .max
            _backingIndex = UInt32(backingIndex)
            assert({
                // if we can, we store the check for the backing here
                // self._backingCheck = backingCount < Int(_UInt24.max) ? _UInt24(UInt32(backingCount)) : .max
                self._backingCheck = backingCount < Int(UInt32.max) ? UInt32(UInt32(backingCount)) : .max
                return true
            }())
        }

        @inlinable
        public static func == (lhs: Index, rhs: Index) -> Bool {
            lhs._backingIndex == rhs._backingIndex &&
                lhs._backingCheck == rhs._backingCheck &&
                lhs.isIndexGEQHeadIndex == rhs.isIndexGEQHeadIndex
        }

        @inlinable
        public static func < (lhs: Index, rhs: Index) -> Bool {
            if lhs.isIndexGEQHeadIndex, rhs.isIndexGEQHeadIndex {
                return lhs.backingIndex < rhs.backingIndex
            } else if lhs.isIndexGEQHeadIndex, !rhs.isIndexGEQHeadIndex {
                return true
            } else if !lhs.isIndexGEQHeadIndex, rhs.isIndexGEQHeadIndex {
                return false
            } else {
                return lhs.backingIndex < rhs.backingIndex
            }
        }

        @usableFromInline
        internal func isValidIndex(for ring: CircularBuffer<Element>) -> Bool {
            // return self._backingCheck == _UInt24.max || Int(self._backingCheck) == ring.count
            _backingCheck == UInt32.max || Int(_backingCheck) == ring.count
        }
    }
}

// MARK: Collection/MutableCollection implementation

extension CircularBuffer: Collection, MutableCollection {
    public typealias Element = Element
    public typealias Indices = DefaultIndices<CircularBuffer<Element>>
    public typealias RangeType<Bound> = Range<Bound> where Bound: Strideable, Bound.Stride: SignedInteger
    public typealias SubSequence = CircularBuffer<Element>

    /// Returns the position immediately after the given index.
    ///
    /// The successor of an index must be well defined. For an index `i` into a
    /// collection `c`, calling `c.index(after: i)` returns the same index every
    /// time.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    @inlinable
    public func index(after: Index) -> Index {
        index(after, offsetBy: 1)
    }

    /// Returns the index before `index`.
    @inlinable
    public func index(before: Index) -> Index {
        index(before, offsetBy: -1)
    }

    /// Accesses the element at the specified index.
    ///
    /// You can subscript `CircularBuffer` with any valid index other than the
    /// `CircularBuffer`'s end index. The end index refers to the position one
    /// past the last element of a collection, so it doesn't correspond with an
    /// element.
    ///
    /// - Parameter position: The position of the element to access. `position`
    ///   must be a valid index of the collection that is not equal to the
    ///   `endIndex` property.
    ///
    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> Element {
        get {
            assert(position.isValidIndex(for: self),
                   "illegal index used, index was for CircularBuffer with count \(position._backingCheck), " +
                       "but actual count is \(count)")
            return _buffer[position.backingIndex]!
        }
        set {
            assert(position.isValidIndex(for: self),
                   "illegal index used, index was for CircularBuffer with count \(position._backingCheck), " +
                       "but actual count is \(count)")
            _buffer[position.backingIndex] = newValue
        }
    }

    /// The position of the first element in a nonempty `CircularBuffer`.
    ///
    /// If the `CircularBuffer` is empty, `startIndex` is equal to `endIndex`.
    @inlinable
    public var startIndex: Index {
        .init(backingIndex: headBackingIndex,
              backingCount: count,
              backingIndexOfHead: headBackingIndex)
    }

    /// The `CircularBuffer`'s "past the end" position---that is, the position one
    /// greater than the last valid subscript argument.
    ///
    /// When you need a range that includes the last element of a collection, use
    /// the half-open range operator (`..<`) with `endIndex`. The `..<` operator
    /// creates a range that doesn't include the upper bound, so it's always
    /// safe to use with `endIndex`.
    ///
    /// If the `CircularBuffer` is empty, `endIndex` is equal to `startIndex`.
    @inlinable
    public var endIndex: Index {
        .init(backingIndex: tailBackingIndex,
              backingCount: count,
              backingIndexOfHead: headBackingIndex)
    }

    /// Returns the distance between two indices.
    ///
    /// Unless the collection conforms to the `BidirectionalCollection` protocol,
    /// `start` must be less than or equal to `end`.
    ///
    /// - Parameters:
    ///   - start: A valid index of the collection.
    ///   - end: Another valid index of the collection. If `end` is equal to
    ///     `start`, the result is zero.
    /// - Returns: The distance between `start` and `end`. The result can be
    ///   negative only if the collection conforms to the
    ///   `BidirectionalCollection` protocol.
    ///
    /// - Complexity: O(1) if the collection conforms to
    ///   `RandomAccessCollection`; otherwise, O(*k*), where *k* is the
    ///   resulting distance.
    @inlinable
    public func distance(from start: CircularBuffer<Element>.Index, to end: CircularBuffer<Element>.Index) -> Int {
        let backingCount = _buffer.count

        switch (start.isIndexGEQHeadIndex, end.isIndexGEQHeadIndex) {
        case (true, true):
            return end.backingIndex &- start.backingIndex
        case (true, false):
            return backingCount &- (start.backingIndex &- end.backingIndex)
        case (false, true):
            return -(backingCount &- (end.backingIndex &- start.backingIndex))
        case (false, false):
            return end.backingIndex &- start.backingIndex
        }
    }
}

// MARK: RandomAccessCollection implementation

extension CircularBuffer: RandomAccessCollection {
    /// Returns the index offset by `distance` from `index`.
    @inlinable
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        .init(backingIndex: (i.backingIndex &+ distance) & mask,
              backingCount: count,
              backingIndexOfHead: headBackingIndex)
    }

    /// Returns an index that is the specified distance from the given index.
    ///
    /// The following example obtains an index advanced four positions from a
    /// string's starting index and then prints the character at that position.
    ///
    ///     let s = "Swift"
    ///     let i = s.index(s.startIndex, offsetBy: 4)
    ///     print(s[i])
    ///     // Prints "t"
    ///
    /// The value passed as `distance` must not offset `i` beyond the bounds of
    /// the collection.
    ///
    /// - Parameters:
    ///   - i: A valid index of the collection.
    ///   - distance: The distance to offset `i`. `distance` must not be negative
    ///     unless the collection conforms to the `BidirectionalCollection`
    ///     protocol.
    /// - Returns: An index offset by `distance` from the index `i`. If
    ///   `distance` is positive, this is the same value as the result of
    ///   `distance` calls to `index(after:)`. If `distance` is negative, this
    ///   is the same value as the result of `abs(distance)` calls to
    ///   `index(before:)`.
    ///
    /// - Complexity: O(1) if the collection conforms to
    ///   `RandomAccessCollection`; otherwise, O(*k*), where *k* is the absolute
    ///   value of `distance`.
    @inlinable
    public subscript(bounds: Range<Index>) -> SubSequence {
        precondition(distance(from: startIndex, to: bounds.lowerBound) >= 0)
        precondition(distance(from: bounds.upperBound, to: endIndex) >= 0)

        var newRing = self
        newRing.headBackingIndex = bounds.lowerBound.backingIndex
        newRing.tailBackingIndex = bounds.upperBound.backingIndex
        return newRing
    }
}

extension CircularBuffer {
    /// Allocates a buffer that can hold up to `initialCapacity` elements and initialise an empty ring backed by
    /// the buffer. When the ring grows to more than `initialCapacity` elements the buffer will be expanded.
    @inlinable
    public init(initialCapacity: Int) {
        let capacity = Int(UInt32(initialCapacity).nextPowerOf2())
        headBackingIndex = 0
        tailBackingIndex = 0
        _buffer = ContiguousArray<Element?>(repeating: nil, count: capacity)
        assert(_buffer.count == capacity)
    }

    /// Allocates an empty buffer.
    @inlinable
    public init() {
        self = .init(initialCapacity: 16)
    }

    /// Append an element to the end of the ring buffer.
    ///
    /// Amortized *O(1)*
    @inlinable
    public mutating func append(_ value: Element) {
        _buffer[tailBackingIndex] = value
        advanceTailIdx(by: 1)

        if headBackingIndex == tailBackingIndex {
            // No more room left for another append so grow the buffer now.
            _doubleCapacity()
        }
    }

    /// Prepend an element to the front of the ring buffer.
    ///
    /// Amortized *O(1)*
    @inlinable
    public mutating func prepend(_ value: Element) {
        let idx = indexBeforeHeadIdx()
        _buffer[idx] = value
        advanceHeadIdx(by: -1)

        if headBackingIndex == tailBackingIndex {
            // No more room left for another append so grow the buffer now.
            _doubleCapacity()
        }
    }

    /// Double the capacity of the buffer and adjust the headIdx and tailIdx.
    @inlinable
    internal mutating func _doubleCapacity() {
        var newBacking: ContiguousArray<Element?> = []
        let newCapacity = _buffer.count << 1 // Double the storage.
        precondition(newCapacity > 0, "Can't double capacity of \(_buffer.count)")
        assert(newCapacity % 2 == 0)

        newBacking.reserveCapacity(newCapacity)
        newBacking.append(contentsOf: _buffer[headBackingIndex ..< _buffer.count])
        if headBackingIndex > 0 {
            newBacking.append(contentsOf: _buffer[0 ..< headBackingIndex])
        }
        let repeatitionCount = newCapacity &- newBacking.count
        newBacking.append(contentsOf: repeatElement(nil, count: repeatitionCount))
        headBackingIndex = 0
        tailBackingIndex = newBacking.count &- repeatitionCount
        _buffer = newBacking
        assert(verifyInvariants())
    }

    /// Return element `offset` from first element.
    ///
    /// *O(1)*
    @inlinable
    public subscript(offset offset: Int) -> Element {
        get {
            self[index(startIndex, offsetBy: offset)]
        }
        set {
            self[index(startIndex, offsetBy: offset)] = newValue
        }
    }

    /// Returns whether the ring is empty.
    @inlinable
    public var isEmpty: Bool {
        headBackingIndex == tailBackingIndex
    }

    /// Returns the number of element in the ring.
    @inlinable
    public var count: Int {
        if tailBackingIndex >= headBackingIndex {
            return tailBackingIndex &- headBackingIndex
        } else {
            return _buffer.count &- (headBackingIndex &- tailBackingIndex)
        }
    }

    /// The total number of elements that the ring can contain without allocating new storage.
    @inlinable
    public var capacity: Int {
        _buffer.count
    }

    /// Removes all members from the circular buffer whist keeping the capacity.
    @inlinable
    public mutating func removeAll(keepingCapacity: Bool = false) {
        if keepingCapacity {
            removeFirst(count)
        } else {
            _buffer.removeAll(keepingCapacity: false)
            _buffer.append(nil)
        }
        headBackingIndex = 0
        tailBackingIndex = 0
        assert(verifyInvariants())
    }

    /// Modify the element at `index`.
    ///
    /// This function exists to provide a method of modifying the element in its underlying backing storage, instead
    /// of copying it out, modifying it, and copying it back in. This emulates the behaviour of the `_modify` accessor
    /// that is part of the generalized accessors work. That accessor is currently underscored and not safe to use, so
    /// this is the next best thing.
    ///
    /// Note that this function is not guaranteed to be fast. In particular, as it is both generic and accepts a closure
    /// it is possible that it will be slower than using the get/modify/set path that occurs with the subscript. If you
    /// are interested in using this function for performance you *must* test and verify that the optimisation applies
    /// correctly in your situation.
    ///
    /// - parameters:
    ///     - index: The index of the object that should be modified. If this index is invalid this function will trap.
    ///     - modifyFunc: The function to apply to the modified object.
    @inlinable
    public mutating func modify<Result>(_ index: Index, _ modifyFunc: (inout Element) throws -> Result) rethrows -> Result {
        try modifyFunc(&_buffer[index.backingIndex]!)
    }

    // MARK: CustomStringConvertible implementation

    /// Returns a human readable description of the ring.
    public var description: String {
        var desc = "[ "
        for el in _buffer.enumerated() {
            if el.0 == headBackingIndex {
                desc += "<"
            } else if el.0 == tailBackingIndex {
                desc += ">"
            }
            desc += el.1.map { "\($0) " } ?? "_ "
        }
        desc += "]"
        desc += " (bufferCapacity: \(_buffer.count), ringLength: \(count))"
        return desc
    }
}

// MARK: - RangeReplaceableCollection

extension CircularBuffer: RangeReplaceableCollection {
    /// Removes and returns the first element of the `CircularBuffer`.
    ///
    /// Calling this method may invalidate all saved indices of this
    /// `CircularBuffer`. Do not rely on a previously stored index value after
    /// altering a `CircularBuffer` with any operation that can change its length.
    ///
    /// - Returns: The first element of the `CircularBuffer` if the `CircularBuffer` is not
    ///            empty; otherwise, `nil`.
    ///
    /// - Complexity: O(1)
    @inlinable
    public mutating func popFirst() -> Element? {
        if count > 0 {
            return removeFirst()
        } else {
            return nil
        }
    }

    /// Removes and returns the last element of the `CircularBuffer`.
    ///
    /// Calling this method may invalidate all saved indices of this
    /// `CircularBuffer`. Do not rely on a previously stored index value after
    /// altering a `CircularBuffer` with any operation that can change its length.
    ///
    /// - Returns: The last element of the `CircularBuffer` if the `CircularBuffer` is not
    ///            empty; otherwise, `nil`.
    ///
    /// - Complexity: O(1)
    @inlinable
    public mutating func popLast() -> Element? {
        if count > 0 {
            return removeLast()
        } else {
            return nil
        }
    }

    /// Removes the specified number of elements from the end of the
    /// `CircularBuffer`.
    ///
    /// Attempting to remove more elements than exist in the `CircularBuffer`
    /// triggers a runtime error.
    ///
    /// Calling this method may invalidate all saved indices of this
    /// `CircularBuffer`. Do not rely on a previously stored index value after
    /// altering a `CircularBuffer` with any operation that can change its length.
    ///
    /// - Parameter k: The number of elements to remove from the `CircularBuffer`.
    ///   `k` must be greater than or equal to zero and must not exceed the
    ///   number of elements in the `CircularBuffer`.
    ///
    /// - Complexity: O(*k*), where *k* is the specified number of elements.
    @inlinable
    public mutating func removeLast(_ k: Int) {
        precondition(k <= count, "Number of elements to drop bigger than the amount of elements in the buffer.")
        var idx = tailBackingIndex
        for _ in 0 ..< k {
            idx = indexAdvanced(index: idx, by: -1)
            _buffer[idx] = nil
        }
        tailBackingIndex = idx
    }

    /// Removes the specified number of elements from the beginning of the
    /// `CircularBuffer`.
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// `CircularBuffer`.
    ///
    /// - Parameter k: The number of elements to remove.
    ///   `k` must be greater than or equal to zero and must not exceed the
    ///   number of elements in the `CircularBuffer`.
    ///
    /// - Complexity: O(*k*), where *k* is the specified number of elements.
    @inlinable
    public mutating func removeFirst(_ k: Int) {
        precondition(k <= count, "Number of elements to drop bigger than the amount of elements in the buffer.")
        var idx = headBackingIndex
        for _ in 0 ..< k {
            _buffer[idx] = nil
            idx = indexAdvanced(index: idx, by: 1)
        }
        headBackingIndex = idx
    }

    /// Removes and returns the first element of the `CircularBuffer`.
    ///
    /// The `CircularBuffer` must not be empty.
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// `CircularBuffer`.
    ///
    /// - Returns: The removed element.
    ///
    /// - Complexity: O(*1*)
    @discardableResult
    @inlinable
    public mutating func removeFirst() -> Element {
        defer {
            self.removeFirst(1)
        }
        return first!
    }

    /// Removes and returns the last element of the `CircularBuffer`.
    ///
    /// The `CircularBuffer` must not be empty.
    ///
    /// Calling this method may invalidate all saved indices of this
    /// `CircularBuffer`. Do not rely on a previously stored index value after
    /// altering the `CircularBuffer` with any operation that can change its length.
    ///
    /// - Returns: The last element of the `CircularBuffer`.
    ///
    /// - Complexity: O(*1*)
    @discardableResult
    @inlinable
    public mutating func removeLast() -> Element {
        defer {
            self.removeLast(1)
        }
        return last!
    }

    /// Replaces the specified subrange of elements with the given `CircularBuffer`.
    ///
    /// - Parameter subrange: The subrange of the collection to replace. The bounds of the range must be valid indices
    ///                       of the `CircularBuffer`.
    ///
    /// - Parameter newElements: The new elements to add to the `CircularBuffer`.
    ///
    /// *O(n)* where _n_ is the length of the new elements collection if the subrange equals to _n_
    ///
    /// *O(m)* where _m_ is the combined length of the collection and _newElements_
    @inlinable
    public mutating func replaceSubrange<C: Collection>(_ subrange: Range<Index>, with newElements: C) where Element == C.Element {
        precondition(subrange.lowerBound >= startIndex && subrange.upperBound <= endIndex,
                     "Subrange out of bounds")
        assert(subrange.lowerBound.isValidIndex(for: self),
               "illegal index used, index was for CircularBuffer with count \(subrange.lowerBound._backingCheck), " +
                   "but actual count is \(count)")
        assert(subrange.upperBound.isValidIndex(for: self),
               "illegal index used, index was for CircularBuffer with count \(subrange.upperBound._backingCheck), " +
                   "but actual count is \(count)")

        let subrangeCount = distance(from: subrange.lowerBound, to: subrange.upperBound)

        if subrangeCount == newElements.count {
            var index = subrange.lowerBound
            for element in newElements {
                _buffer[index.backingIndex] = element
                index = self.index(after: index)
            }
        } else if subrangeCount == count, newElements.isEmpty {
            removeSubrange(subrange)
        } else {
            var newBuffer: ContiguousArray<Element?> = []
            let neededNewCapacity = count + newElements.count - subrangeCount + 1 /* always one spare */
            let newCapacity = Swift.max(capacity, neededNewCapacity.nextPowerOf2())
            newBuffer.reserveCapacity(newCapacity)

            // This mapping is required due to an inconsistent ability to append sequences of non-optional
            // to optional sequences.
            // https://bugs.swift.org/browse/SR-7921
            newBuffer.append(contentsOf: self[startIndex ..< subrange.lowerBound].lazy.map { $0 })
            newBuffer.append(contentsOf: newElements.lazy.map { $0 })
            newBuffer.append(contentsOf: self[subrange.upperBound ..< endIndex].lazy.map { $0 })

            let repetitionCount = newCapacity &- newBuffer.count
            if repetitionCount > 0 {
                newBuffer.append(contentsOf: repeatElement(nil, count: repetitionCount))
            }
            _buffer = newBuffer
            headBackingIndex = 0
            tailBackingIndex = newBuffer.count &- repetitionCount
        }
        assert(verifyInvariants())
    }

    /// Removes the elements in the specified subrange from the circular buffer.
    ///
    /// - Parameter bounds: The range of the circular buffer to be removed. The bounds of the range must be valid indices of the collection.
    @inlinable
    public mutating func removeSubrange(_ bounds: Range<Index>) {
        precondition(bounds.upperBound >= startIndex && bounds.upperBound <= endIndex, "Invalid bounds.")

        let boundsCount = distance(from: bounds.lowerBound, to: bounds.upperBound)
        switch boundsCount {
        case 1:
            remove(at: bounds.lowerBound)
        case count:
            self = .init(initialCapacity: _buffer.count)
        default:
            replaceSubrange(bounds, with: [])
        }
        assert(verifyInvariants())
    }

    /// Removes & returns the item at `position` from the buffer
    ///
    /// - Parameter position: The index of the item to be removed from the buffer.
    ///
    /// *O(1)* if the position is `headIdx` or `tailIdx`.
    /// otherwise
    /// *O(n)* where *n* is the number of elements between `position` and `tailIdx`.
    @discardableResult
    @inlinable
    public mutating func remove(at position: Index) -> Element {
        assert(position.isValidIndex(for: self),
               "illegal index used, index was for CircularBuffer with count \(position._backingCheck), " +
                   "but actual count is \(count)")
        defer {
            assert(self.verifyInvariants())
        }
        precondition(indices.contains(position), "Position out of bounds.")
        var bufferIndex = position.backingIndex
        let element = _buffer[bufferIndex]!

        switch bufferIndex {
        case headBackingIndex:
            advanceHeadIdx(by: 1)
            _buffer[bufferIndex] = nil
        case indexBeforeHeadIdx():
            advanceTailIdx(by: -1)
            tailBackingIndex = indexBeforeTailIdx()
            _buffer[bufferIndex] = nil
        default:
            _buffer[bufferIndex] = nil
            var nextIndex = indexAdvanced(index: bufferIndex, by: 1)
            while nextIndex != tailBackingIndex {
                _buffer.swapAt(bufferIndex, nextIndex)
                bufferIndex = nextIndex
                nextIndex = indexAdvanced(index: bufferIndex, by: 1)
            }
            advanceTailIdx(by: -1)
        }

        return element
    }
}

extension CircularBuffer {
    @usableFromInline
    internal func verifyInvariants() -> Bool {
        var index = headBackingIndex
        while index != tailBackingIndex {
            if _buffer[index] == nil {
                return false
            }
            index = indexAdvanced(index: index, by: 1)
        }
        return true
    }

    // this is not a general invariant (not true for CircularBuffer that have been sliced)
    private func unreachableAreNil() -> Bool {
        var index = tailBackingIndex
        while index != headBackingIndex {
            if _buffer[index] != nil {
                return false
            }
            index = indexAdvanced(index: index, by: 1)
        }
        return true
    }

    internal func testOnly_verifyInvariantsForNonSlices() -> Bool {
        verifyInvariants() && unreachableAreNil()
    }
}

extension CircularBuffer: Equatable where Element: Equatable {
    public static func == (lhs: CircularBuffer, rhs: CircularBuffer) -> Bool {
        lhs.count == rhs.count && zip(lhs, rhs).allSatisfy(==)
    }
}

extension CircularBuffer: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        for element in self {
            hasher.combine(element)
        }
    }
}

extension CircularBuffer: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}
