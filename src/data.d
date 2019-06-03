/**
 * In this module you find core data structures expressed as values. An object
 * is a value whose first four bytes of <em>A</em> identify the class of the
 * object.
 */
module waffle.data;

import waffle.value : Value;

/**
 * A collection of classes.
 */
final
class Classes
{
private:
    /**
     * All the classes, each identified by its class identifier. The class
     * identifier is four bytes; the same four bytes that appear at the start
     * of the <em>A</em> array of each object.
     */
    Class[uint] classes;

    /**
     * Some classes are created immediately when an instance of
     * <em>Classes</em> is constructed. They are assigned here.
     */
    Class objectClass; uint objectClassId;
    Class nullClass; uint nullClassId;
    Class boolClass; uint boolClassId;

    /**
     * The class identifier that will be assigned to the next class that is
     * created.
     */
    uint nextClassId = 0;

public:
    /**
     * Construct a collection of classes, initializing it with the core class
     * hierarchy.
     */
    nothrow pure @safe
    this()
    {
        newClass(null, objectClass, objectClassId);
        newClass(objectClass, nullClass, nullClassId);
        newClass(objectClass, boolClass, boolClassId);
    }

    /**
     * Create a new class and return it along with its identifier.
     */
    nothrow pure @safe
    void
    newClass(Class superclass, out Class class_, out uint classId)
    {
        class_ = new Class(superclass);
        classId = nextClassId++;
        classes[classId] = class_;
    }
}

/**
 * A class describes the behavior of an object.
 */
final
class Class
{
private:
    Class superclass;

    nothrow pure @nogc @safe
    this(Class superclass)
    {
        this.superclass = superclass;
    }
}
