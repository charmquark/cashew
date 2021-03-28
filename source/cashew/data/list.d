/**
 *
 */
module cashew.data.list;

import std.exception: enforce;
import std.typecons: Flag, Yes, No;


/**
 *
 */
class List(
    Element,
    Flag!`trackLength` trackLength = No.trackLength
) {

    /**
     *
     */
    static struct Node {

        /**
         *
         */
        Element data = Element.init;


        /**
         *
         */
        Node* next = null;


    } // end Node


    /**
     *
     */
    private Node* _head;


    /**
     *
     */
    private Node* _pool;


    /**
     *
     */
    static if (trackLength) {
        private size_t _length = 0u;
    }


    /**
     *
     */
    @nogc @safe pure nothrow
    this() { }


    /**
     *
     */
    @property @nogc @safe pure nothrow
    bool empty() const => _head == null;


    /**
     *
     */
    @property @safe pure
    Element front() const => enforce(_head, `tried to read from empty list`).data;


    /**
     *
     */
    @property @nogc @safe pure nothrow
    size_t length() const {
        static if (trackLength) {
            return _length;
        } else {
            size_t result = 0u;
            for (const(Node)* node = _head; node; node = node.next) {
                ++result;
            }
            return result;
        }
    }


    /**
     *
     */
    @nogc @safe pure nothrow
    void popFront() {
        if (!_head) return;

        auto tmp = _head;
        _head = _head.next;
        *tmp = Node(Element.init, _pool);
        _pool = tmp;

        static if (trackLength) { --_length; }
    }


    ///ditto
    alias pop = popFront;


    /**
     *
     */
    @safe pure nothrow
    void put(Element elt) {
        if (_pool) {
            auto tmp = _head;
            _pool = (_head = _pool).next;
            *_head = Node(elt, tmp);
        } else {
            _head = new Node(elt, _head);
        }

        static if (trackLength) { ++_length; }
    }

    ///ditto
    alias push = put;


    /**
     *
     */
    @safe pure nothrow
    List save()
    out(result; result !is null)
    out(result; result.length == length)
    do {
        auto result = new List;
        if (_head) {
            Node* dest = result._head = new Node(_head.data, _head.next);
            while (dest.next) dest = dest.next = new Node(dest.next.data, dest.next.next);

            static if (trackLength) { result._length = _length; }
        }
        return result;
    }

    ///ditto
    alias dup = save;


} // end List

@safe pure nothrow
unittest { // List should be a forward range and output range
    import std.range.primitives;
    alias IntList = List!int;
    assert(isInputRange!IntList);
    assert(isForwardRange!IntList);
    assert(is(ElementType!IntList == int));
    assert(isOutputRange!(IntList, int));
}

@safe pure
unittest { // confirm length tracking
    import std.algorithm.comparison: equal;

    auto list1 = new List!(int, Yes.trackLength);
    auto list2 = new List!(int, No.trackLength);

    foreach (int i; 0 .. 3) {
        list1.push(i);
        list2.push(i);
    }
    assert(list1.length == 3);
    assert(list1.length == list2.length);
    assert(list1.equal(list2));
    assert(list1.length == list2.length);
}

@safe pure
unittest { // confirm forward range saving
    import std.algorithm: copy, equal;
    import std.range: retro;

    immutable src = [1, 2, 3, 4];

    auto list1 = new List!(int, Yes.trackLength);
    src.copy(list1);

    auto list2 = list1.save;
    assert(list2.equal(src.retro));
    assert(list2.length == 0);

    assert(list1.length == 4);
    assert(list1.equal(src.retro));
}
