/**
 * In this module you find the implementation of values, including a
 * description of their in-memory layouts.
 */
module waffle.value;

import core.memory : GC;
import std.traits : hasIndirections;

/**
 * A value is a pair of arrays (<em>P</em>, <em>A</em>). <em>P</em> is an array
 * of pointers to other values. <em>A</em> is an array of arbitrary bytes. The
 * arrays may be of any length.
 *
 * Value is a reference type: creating a copy will not copy the elements of the
 * arrays. Rather, the copy will share the arrays with the original.
 *
 * After a value has been created, the lengths of the arrays cannot be changed.
 */
struct Value
{
private:
    /**
     * Iff <em>payload</em> is null, the arrays are considered to be empty.
     * This ensures that pointer equality holds, and that a default-constructed
     * value is empty.
     */
    invariant (payload is null || header.Plength != 0 || header.Alength != 0);

    /**
     * The pointed-to value is a <em>Header</em> value directly followed by
     * <em>P</em> which in turn is directly followed by <em>A</em>.
     */
    void* payload;

    /**
     * Get at the header of the value.
     */
    inout nothrow pure @nogc @trusted
    Header*
    header()
    {
        return cast(Header*) payload;
    }

public:
    /**
     * Construct a value given its <em>P</em> and <em>A</em> arrays. The array
     * elements will be copied into the value; it will not share them with the
     * given slices.
     */
    nothrow pure @trusted
    this(Value[] p, const(ubyte)[] a)
    out
    {
        // XXX: If this proves to be too slow, just assert the lengths here and
        // XXX: transfer the equality checks to a unittest.
        assert (P == p);
        assert (A == a);
    }
    do
    {
        if (p.length == 0 && a.length == 0)
            return;

        auto size = Header.sizeof + p.length * Value.sizeof + a.length;
        payload = GC.calloc(size);

        header.Plength = p.length;
        header.Alength = a.length;

        P[0 .. header.Plength] = p;
        A[0 .. header.Alength] = a;
    }

    /**
     * Get at the elements of the <em>P</em> array.
     */
    inout nothrow pure @nogc @trusted
    Value[]
    P()
    {
        if (payload is null) return [];
        return (cast(Value*) (header + 1))[0 .. header.Plength];
    }

    /**
     * Get at the elements of the <em>A</em> array.
     */
    inout nothrow pure @nogc @trusted
    ubyte[]
    A()
    {
        if (payload is null) return [];
        return (cast(ubyte*) (P.ptr + P.length))[0 .. header.Alength];
    }

    /**
     * Two values are considered equal if they are the same value in memory,
     * not necessarily if they have the same values in their arrays.
     */
    nothrow pure @nogc @safe
    bool
    opEquals(Value other)
    {
        return payload is other.payload;
    }
}

/**
 * The header of a value says something about its layout in memory, namely the
 * lengths of the arrays.
 */
private
struct Header
{
    size_t Plength;
    size_t Alength;
}

/**
 * In the future we may want to hint the garbage collector about the layout of
 * values. In that case, we must ensure that <em>Header</em> does not itself
 * contain any pointers.
 */
static assert (!hasIndirections!Header);

/**
 * Test, through the constructor postconditions, that value construction works
 * as expected.
 */
nothrow pure @safe
unittest
{
    auto empty = Value([], []);
    auto one = Value([], [1, 0, 0, 0]);
    auto pair = Value([empty, one], []);
    auto complex = Value([empty, one], [1, 0, 0, 0]);
}
