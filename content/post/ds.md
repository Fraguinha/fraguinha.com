---
title: "DS - Data structures"
description: "Java collections: selection, contracts, views, operations, and complexity."
date: 2024-09-26T12:00:00+01:00
draft: false
---

## Contents

- **Selection:** [Choose a structure](#choosing-a-structure), [Cost and storage model](#cost-and-storage-model)
- **Foundations:** [Interface contracts and order](#interface-contracts-and-order), [Equality, hashing, and sorted equivalence](#equality-hashing-and-sorted-equivalence), [Factories, copies, and mutability](#factories-copies-and-mutability), [Sequenced collections](#java-21-sequenced-collections), [Views and traversal](#views-and-traversal), [Thread-safety boundaries](#thread-safety-boundaries)
- [Arrays](#arrays)
- **Lists:** [ArrayList class](#arraylist), [subList views and traversal mutation](#sublist-and-traversal-mutation), [LinkedList class](#linkedlist), [CopyOnWriteArrayList class](#copyonwritearraylist)
- **Stacks:** [ArrayDeque as a stack](#arraydeque-as-stack), [ConcurrentLinkedDeque as a stack](#concurrentlinkeddeque-as-stack)
- **Queues:** [Queue operation families](#queue-operation-families), [ArrayDeque as a queue](#arraydeque-as-queue), [PriorityQueue class](#priorityqueue), [ConcurrentLinkedQueue class](#concurrentlinkedqueue), [ArrayBlockingQueue class](#arrayblockingqueue), [LinkedBlockingQueue class](#linkedblockingqueue), [PriorityBlockingQueue class](#priorityblockingqueue)
- **Sets:** [HashSet class](#hashset), [TreeSet class](#treeset), [LinkedHashSet class](#linkedhashset), [EnumSet class](#enumset), [Concurrent hash set with ConcurrentHashMap](#concurrenthashset-via-concurrenthashmap), [ConcurrentSkipListSet class](#concurrentskiplistset)
- **Maps:** [HashMap class](#hashmap), [TreeMap class](#treemap), [LinkedHashMap class](#linkedhashmap), [EnumMap class](#enummap), [ConcurrentHashMap class](#concurrenthashmap), [ConcurrentSkipListMap class](#concurrentskiplistmap)

## Choose a structure {#choosing-a-structure}

<div class="collection-decision-tree">
  <div class="decision-node">
    <span class="decision-question">Need key-value lookup?</span>
    <ul class="decision-answers" role="list">
      <li>
        <span class="decision-answer">Yes:</span>
        <div class="decision-node">
          <span class="decision-question">Need sorted keys or range queries?</span>
          <ul class="decision-answers" role="list">
            <li>
              <span class="decision-answer">Yes:</span>
              <div class="decision-node">
                <span class="decision-question">Need shared mutation?</span>
                <ul class="decision-answers" role="list">
                  <li><span class="decision-answer">Yes:</span> <span class="decision-leaf"><a href="#concurrentskiplistmap">ConcurrentSkipListMap</a></span></li>
                  <li><span class="decision-answer">No:</span> <span class="decision-leaf"><a href="#treemap">TreeMap</a> <span class="decision-note">O(log n) lookup and updates; supports ranges and nearest-key queries.</span></span></li>
                </ul>
              </div>
            </li>
            <li>
              <span class="decision-answer">No:</span>
              <div class="decision-node">
                <span class="decision-question">Need insertion order, access order, or endpoint positioning?</span>
                <ul class="decision-answers" role="list">
                  <li><span class="decision-answer">Yes:</span> <span class="decision-leaf"><a href="#linkedhashmap">LinkedHashMap</a> <span class="decision-note">Extra links maintain encounter order, not sorting; coordinate shared mutation.</span></span></li>
                  <li>
                    <span class="decision-answer">No:</span>
                    <div class="decision-node">
                      <span class="decision-question">Are all keys from one enum type?</span>
                      <ul class="decision-answers" role="list">
                        <li><span class="decision-answer">Yes:</span> <span class="decision-leaf"><a href="#enummap">EnumMap</a> <span class="decision-note">Keys follow enum declaration order; coordinate shared mutation.</span></span></li>
                        <li>
                          <span class="decision-answer">No:</span>
                          <div class="decision-node">
                            <span class="decision-question">Need shared mutation?</span>
                            <ul class="decision-answers" role="list">
                              <li><span class="decision-answer">Yes:</span> <span class="decision-leaf"><a href="#concurrenthashmap">ConcurrentHashMap</a></span></li>
                              <li><span class="decision-answer">No:</span> <span class="decision-leaf"><a href="#hashmap">HashMap</a></span></li>
                            </ul>
                          </div>
                        </li>
                      </ul>
                    </div>
                  </li>
                </ul>
              </div>
            </li>
          </ul>
        </div>
      </li>
      <li>
        <span class="decision-answer">No:</span>
        <div class="decision-node">
          <span class="decision-question">Need unique values?</span>
          <ul class="decision-answers" role="list">
            <li>
              <span class="decision-answer">Yes:</span>
              <div class="decision-node">
                <span class="decision-question">Need sorted values or range queries?</span>
                <ul class="decision-answers" role="list">
                  <li>
                    <span class="decision-answer">Yes:</span>
                    <div class="decision-node">
                      <span class="decision-question">Need shared mutation?</span>
                      <ul class="decision-answers" role="list">
                        <li><span class="decision-answer">Yes:</span> <span class="decision-leaf"><a href="#concurrentskiplistset">ConcurrentSkipListSet</a></span></li>
                        <li><span class="decision-answer">No:</span> <span class="decision-leaf"><a href="#treeset">TreeSet</a> <span class="decision-note">O(log n) lookup and updates; supports ranges and nearest-neighbor queries.</span></span></li>
                      </ul>
                    </div>
                  </li>
                  <li>
                    <span class="decision-answer">No:</span>
                    <div class="decision-node">
                      <span class="decision-question">Need insertion order or endpoint positioning?</span>
                      <ul class="decision-answers" role="list">
                        <li><span class="decision-answer">Yes:</span> <span class="decision-leaf"><a href="#linkedhashset">LinkedHashSet</a> <span class="decision-note">Extra links maintain encounter order, not sorting; coordinate shared mutation.</span></span></li>
                        <li>
                          <span class="decision-answer">No:</span>
                          <div class="decision-node">
                            <span class="decision-question">Are all values from one enum type?</span>
                            <ul class="decision-answers" role="list">
                              <li><span class="decision-answer">Yes:</span> <span class="decision-leaf"><a href="#enumset">EnumSet</a> <span class="decision-note">Values follow declaration order and cannot be positioned arbitrarily; coordinate shared mutation.</span></span></li>
                              <li>
                                <span class="decision-answer">No:</span>
                                <div class="decision-node">
                                  <span class="decision-question">Need shared mutation?</span>
                                  <ul class="decision-answers" role="list">
                                    <li><span class="decision-answer">Yes:</span> <span class="decision-leaf"><a href="#concurrenthashset-via-concurrenthashmap">ConcurrentHashMap.<wbr>newKeySet()</a></span></li>
                                    <li><span class="decision-answer">No:</span> <span class="decision-leaf"><a href="#hashset">HashSet</a></span></li>
                                  </ul>
                                </div>
                              </li>
                            </ul>
                          </div>
                        </li>
                      </ul>
                    </div>
                  </li>
                </ul>
              </div>
            </li>
            <li>
              <span class="decision-answer">No:</span>
              <div class="decision-node">
                <span class="decision-question">Need a work queue or stack?</span>
                <ul class="decision-answers" role="list">
                  <li>
                    <span class="decision-answer">Yes:</span>
                    <div class="decision-node">
                      <span class="decision-question">Remove items by priority?</span>
                      <ul class="decision-answers" role="list">
                        <li>
                          <span class="decision-answer">Yes:</span>
                          <div class="decision-node">
                            <span class="decision-question">Need shared mutation?</span>
                            <ul class="decision-answers" role="list">
                              <li><span class="decision-answer">Yes:</span> <span class="decision-leaf"><a href="#priorityblockingqueue">PriorityBlockingQueue</a> <span class="decision-note">Unbounded, with no backpressure. Priority selects the head, not iteration order.</span></span></li>
                              <li><span class="decision-answer">No:</span> <span class="decision-leaf"><a href="#priorityqueue">PriorityQueue</a> <span class="decision-note">Priority selects the head, not iteration order.</span></span></li>
                            </ul>
                          </div>
                        </li>
                        <li>
                          <span class="decision-answer">No:</span>
                          <div class="decision-node">
                            <span class="decision-question">Need bounded capacity or blocking operations?</span>
                            <ul class="decision-answers" role="list">
                              <li>
                                <span class="decision-answer">Yes:</span>
                                <div class="decision-node">
                                  <span class="decision-question">Prefer fixed array backing without per-item nodes?</span>
                                  <ul class="decision-answers" role="list">
                                    <li><span class="decision-answer">Yes:</span> <span class="decision-leaf"><a href="#arrayblockingqueue">ArrayBlockingQueue</a> <span class="decision-note">Fixed capacity, no per-item nodes; choose waiting, timeout, rejection, and interruption policies.</span></span></li>
                                    <li><span class="decision-answer">No:</span> <span class="decision-leaf"><a href="#linkedblockingqueue">LinkedBlockingQueue</a> <span class="decision-note">Set an explicit capacity; choose waiting, timeout, rejection, and interruption policies.</span></span></li>
                                  </ul>
                                </div>
                              </li>
                              <li>
                                <span class="decision-answer">No:</span>
                                <div class="decision-node">
                                  <span class="decision-question">Need shared mutation?</span>
                                  <ul class="decision-answers" role="list">
                                    <li>
                                      <span class="decision-answer">Yes:</span>
                                      <div class="decision-node">
                                        <span class="decision-question">Need double-ended or stack operations?</span>
                                        <ul class="decision-answers" role="list">
                                          <li><span class="decision-answer">Yes:</span> <span class="decision-leaf"><a href="#concurrentlinkeddeque-as-stack">ConcurrentLinkedDeque</a> <span class="decision-note">Non-blocking, unbounded double-ended queue or LIFO stack; no backpressure or snapshot traversal.</span></span></li>
                                          <li><span class="decision-answer">No:</span> <span class="decision-leaf"><a href="#concurrentlinkedqueue">ConcurrentLinkedQueue</a> <span class="decision-note">Non-blocking, unbounded FIFO; no backpressure or snapshot traversal.</span></span></li>
                                        </ul>
                                      </div>
                                    </li>
                                    <li><span class="decision-answer">No:</span> <span class="decision-leaf"><a href="#arraydeque-as-queue">ArrayDeque</a> <span class="decision-note">FIFO queue or <a href="#arraydeque-as-stack">LIFO stack</a>; rejects null elements.</span></span></li>
                                  </ul>
                                </div>
                              </li>
                            </ul>
                          </div>
                        </li>
                      </ul>
                    </div>
                  </li>
                  <li>
                    <span class="decision-answer">No:</span>
                    <div class="decision-node">
                      <span class="decision-question">Need fixed-length indexed storage?</span>
                      <ul class="decision-answers" role="list">
                        <li><span class="decision-answer">Yes:</span> <span class="decision-leaf"><a href="#arrays">array</a> <span class="decision-note">Stores primitives or references; resizing requires a new array and copying.</span></span></li>
                        <li>
                          <span class="decision-answer">No:</span>
                          <div class="decision-node">
                            <span class="decision-question">Shared mutation with far more reads than writes?</span>
                            <ul class="decision-answers" role="list">
                              <li><span class="decision-answer">Yes:</span> <span class="decision-leaf"><a href="#copyonwritearraylist">CopyOnWriteArrayList</a> <span class="decision-note">Traversal sees a snapshot; content-changing writes copy the array.</span></span></li>
                              <li><span class="decision-answer">No:</span> <span class="decision-leaf"><a href="#arraylist">ArrayList</a> <span class="decision-note">Middle insertions and removals shift later elements; coordinate shared mutation.</span></span></li>
                            </ul>
                          </div>
                        </li>
                      </ul>
                    </div>
                  </li>
                </ul>
              </div>
            </li>
          </ul>
        </div>
      </li>
    </ul>
  </div>
  <span class="decision-note">Keep <a href="#equality-hashing-and-sorted-equivalence">equality, hashing, and comparator state stable</a>; comparator equivalence defines sorted uniqueness. <a href="#thread-safety-boundaries">Coordinate shared mutation of ordinary structures</a>. Concurrent alternatives differ in traversal and atomicity; per-key safety does not protect cross-key invariants.</span>
</div>

### Cost and storage model

In the tables, n is the number of elements or mappings. Costs assume O(1) hashing, equality, comparisons, and callbacks. Expected hash costs require well-dispersed hashes. Amortized growth spreads copying and rehashing across operations; one insertion can still cost O(n). Skip-list bounds are expected averages; tree bounds are worst-case. Concurrent costs exclude waiting, retries, and contention.

Capacity reserves storage; it is usually neither size nor a maximum. An ArrayList with capacity 100 starts empty and can exceed 100; a capacity-100 blocking queue cannot accept a 101st item until space is released. Array-backed structures use spare slots and occasional copying. Linked structures allocate nodes and links, and locating a position can dominate mutation.

Hash tables trade bucket capacity against collisions and resizing. Traversal in HashMap and HashSet scans capacity as well as entries; linked hash variants add links but traverse in O(n). For a known expected count, presize the structure rather than allocating an arbitrarily large table.

Collections store references: List&lt;Integer&gt; uses boxing, unlike int[]; cached wrappers can avoid allocations. Copies and snapshots below are shallow. Arrays, nodes, and links cost storage, but Java does not specify object byte counts, physical layout, or cache behavior.

## Foundations

Collection contracts determine which elements a structure accepts, how it orders them, and which mutations it supports.

### Interface contracts and order

The [Collections Framework](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/package-summary.html#CollectionsFramework) defines these contracts:

- **Collection&lt;E&gt;:** A group with size, isEmpty, traversal, membership tests, and optional mutations: add, remove, addAll, removeAll, retainAll, removeIf, and clear.
- **List&lt;E&gt;:** An indexed sequence allowing duplicates. The get, set, and indexed insertion and removal operations follow list order; indexed access need not be constant-time.
- **Set&lt;E&gt;:** Unique elements under its equality or equivalence contract; add returns false when an element is already present. Sets provide neither indexed access nor a universal ordering.
- **Queue&lt;E&gt;:** Head-oriented insertion, inspection, and removal, with methods that throw exceptions or return sentinel values. Queues are not necessarily FIFO: a priority queue removes by priority.
- **Deque&lt;E&gt;:** A double-ended queue whose first-end and last-end operations support FIFO or LIFO.
- **Map&lt;K,V&gt;:** At most one value per equivalent key; updating a key replaces its value.

Map is not a Collection. Its keySet() is a set, values() is a collection that can contain duplicates, and entrySet() is a set of mappings. The base Collection interface does not fix duplicate or order policy. Null acceptance and thread safety depend on the implementation. Mutations can be optional: an unmodifiable implementation throws UnsupportedOperationException.

Order and duplication are separate:

- **Duplicate semantics:** Lists and queues can hold repeated equal elements; sets cannot, and maps cannot hold repeated equivalent keys.
- **Encounter order:** The order seen during iteration or stream traversal, such as list position, linked insertion order, or access order. Unspecified order is not a promise of randomness or stability.
- **Sorted order:** A comparator or natural ordering governs all elements or keys and enables range and navigation operations.
- **Priority order:** The order in which items are removed, not the order of ordinary iteration. Equal priorities do not imply FIFO tie-breaking.

Null policy:

- **ArrayList, LinkedList, and CopyOnWriteArrayList:** Permit null elements. A null element can make deque sentinel results ambiguous in LinkedList.
- **HashSet and LinkedHashSet:** Permit one null element.
- **HashMap and LinkedHashMap:** Permit one null key and multiple null values.
- **TreeSet and TreeMap:** Reject null elements and keys under natural ordering; a comparator that explicitly handles null can permit them. Map values may be null.
- **ArrayDeque, PriorityQueue, and all concurrent queues and deques shown:** Reject null elements.
- **Concurrent hash and skip-list sets and maps:** Reject null elements, keys, and values, even if a supplied comparator could compare null.
- **EnumSet and EnumMap:** Reject null elements in EnumSet and null keys in EnumMap; EnumMap permits null values.
- **Unmodifiable collection factories and copies:** Reject null elements, keys, and values in List.of, List.copyOf, Set.of, Set.copyOf, Map.of, Map.ofEntries, and Map.copyOf.

### Equality, hashing, and sorted equivalence

The [equals and hashCode contract](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Object.html#hashCode()) requires equal objects to have equal hash codes; unequal objects may collide. Hash lookup resolves collisions using equality. A stored set element or map key must keep its equality- and hash-relevant state stable.

Records with immutable components work as value keys:

```java
record CustomerId(String region, long number) {}

Map<CustomerId, String> customers = new HashMap<>();
customers.put(new CustomerId("EU", 42), "Alice");
System.out.println(customers.get(new CustomerId("EU", 42)));
System.out.println(customers.size());
```

The second CustomerId has equal components, so lookup finds Alice. Records are only shallowly immutable: changing a list component or a mutable object's ID can change equality or hash codes. A stored key can then become unreachable even to remove. Before changing a key, remove it and reinsert it afterward, or use immutable keys.

Sorted sets and maps treat compare(a, b) == 0 as equivalence. The ordering [should be consistent with equals](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Comparator.html) to honor the general Set and Map contracts. Comparing only one property can discard an unequal set element or replace an unequal map key's value:

```java
Comparator<String> byLength = Comparator.comparingInt(String::length);
NavigableSet<String> lengths = new TreeSet<>(byLength);
System.out.println(lengths.add("aa"));
System.out.println(lengths.add("bb"));
System.out.println(lengths.contains("cc"));
System.out.println(lengths);

NavigableMap<String, Integer> counts = new TreeMap<>(byLength);
counts.put("aa", 1);
System.out.println(counts.put("bb", 2));
System.out.println(counts.get("cc"));
System.out.println(counts.size());

NavigableSet<String> distinct = new TreeSet<>(
        byLength.thenComparing(
                Comparator.naturalOrder()));
distinct.addAll(List.of("bb", "aa", "c"));
System.out.println(distinct);
```

byLength treats every two-character string as one key: the set retains only aa, and the map replaces 1 with 2. The lexical tie-breaker retains distinct strings in \[c, aa, bb\]. Comparator equivalence is not a hash collision.

Keep comparator-relevant item and external state stable in trees, skip lists, and priority queues; they do not automatically resort. Remove and reinsert an item to change its priority.

List.equals compares elements in order; Set.equals compares membership irrespective of encounter order; Map.equals compares mappings irrespective of encounter order. Thus two linked sets or maps can be equal while iterating differently. A general Collection or Deque does not promise list-style value equality merely because it is sequenced.

### Factories, copies, and mutability

Unmodifiable collections can still contain mutable elements. Copies below share element references; only backed views reflect later source membership changes.

- **Arrays.asList(array):** A fixed-size list, backed by the reference array in both directions. The set method works; size-changing operations do not. The list allows null elements and duplicates and follows array order.
- **new ArrayList&lt;&gt;(source):** An independently mutable list that copies element references in source traversal order. It allows null elements and duplicates.
- **Collections.unmodifiableList(source):** A live read-only view that inherits source contents and order, including null elements. Mutations through the wrapper throw an exception.
- **[List.of and List.copyOf](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/List.html#unmodifiable):** Unmodifiable lists that reject null elements and retain duplicates and encounter order. The copyOf method may reuse a suitable unmodifiable list.
- **[stream.toList()](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/stream/Stream.html#toList()):** An unmodifiable list that permits null elements and duplicates and preserves encounter order when present. Do not assume the result is an ArrayList instance.
- **[Set.of and Set.copyOf](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Set.html#unmodifiable):** Unmodifiable sets that reject null elements and have unspecified encounter order. The of method rejects duplicate arguments with IllegalArgumentException; copyOf collapses duplicates and may reuse a suitable result.
- **[Map.of](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Map.html#unmodifiable), Map.ofEntries, and Map.copyOf:** Unmodifiable maps that reject null keys and values and have unspecified encounter order. Factories reject duplicate keys with IllegalArgumentException; a call does not guarantee a fresh allocation.

Views track source membership changes; copies still share elements:

```java
String[] array = {"one", "two"};
List<String> fixed = Arrays.asList(array);
fixed.set(0, "ONE");
array[1] = "TWO";
System.out.println(fixed);
try {
    fixed.add("three");
} catch (UnsupportedOperationException ex) {
    System.out.println("fixed-size");
}

List<StringBuilder> source = new ArrayList<>();
source.add(new StringBuilder("draft"));
List<StringBuilder> live = Collections.unmodifiableList(source);
List<StringBuilder> mutableCopy = new ArrayList<>(source);
List<StringBuilder> frozenMembership = List.copyOf(source);
source.add(new StringBuilder("new"));
source.getFirst().append("!");
System.out.println(live);
System.out.println(mutableCopy);
System.out.println(frozenMembership);
mutableCopy.clear();
System.out.println(source.size());

List<String> withNull = Arrays.asList("ok", null);
System.out.println(withNull.stream().toList());
System.out.println(Set.copyOf(List.of("x", "x")).size());
try {
    Set.of("x", "x");
} catch (IllegalArgumentException ex) {
    System.out.println("duplicate factory argument");
}
```

After the source edit, live contains \[draft!, new\]; both copies contain \[draft!\]. Clearing mutableCopy leaves the source unchanged. All three originally shared the same first StringBuilder.

[Arrays.asList](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Arrays.html#asList(T...)) does not box primitive arrays: Arrays.asList(new int[]{1, 2}) is a one-element List&lt;int[]&gt;. Use a primitive stream and explicit boxing for a boxed list.

Map.of accepts up to ten mappings; Map.ofEntries accepts more. Map.copyOf does not guarantee LinkedHashMap encounter order. For an independent order-preserving copy, use new LinkedHashSet&lt;&gt;(source) or new LinkedHashMap&lt;&gt;(source), then wrap if needed. Do not depend on factory object identity or a concrete implementation.

### Sequenced collections {#java-21-sequenced-collections}

[Sequenced collections](https://openjdk.org/jeps/431) provide three interfaces:

- [SequencedCollection](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/SequencedCollection.html) adds a defined encounter order, getFirst and getLast, optional addFirst, addLast, removeFirst, and removeLast, and reversed().
- SequencedSet combines that contract with set uniqueness. The LinkedHashSet class implements it; SortedSet and therefore NavigableSet extend it.
- [SequencedMap](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/SequencedMap.html) adds firstEntry, lastEntry, pollFirstEntry, pollLastEntry, optional putFirst and putLast, reversed(), and sequenced key, value, and entry views.

List and Deque extend SequencedCollection; SortedMap and NavigableMap extend SequencedMap. A reference typed only as Collection, Set, or Map does not expose these methods. EnumSet and EnumMap do not implement these interfaces despite their deterministic iteration order.

On an empty mutable sequenced collection, getFirst, getLast, and supported removeFirst and removeLast calls throw NoSuchElementException. Sequenced-map entry queries and polls return null; sorted firstKey and lastKey calls throw an exception. Unmodifiable mutators can throw even when empty. Endpoint methods guarantee neither O(1) access nor arbitrary positioning.

reversed() is a reverse-ordered view: supported mutations write through to the backing structure, with visibility guarantees defined by the implementation. For independent mutable membership and order, use new ArrayList&lt;&gt;(list.reversed()).

### Views and traversal

A [view collection](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Collection.html#view) shares backing membership: examples include subList, sorted range and descending views, map views, unmodifiable wrappers, and reversed views. Supported removals change the backing structure. A map key set cannot add a key without a value; sorted ranges reject out-of-bounds insertions.

Traversal policies:

- **Best-effort fail-fast:** Ordinary array-backed and linked lists and hash, tree, and linked collections may throw ConcurrentModificationException after unexpected structural changes. This detects bugs; it is not synchronization.
- **Snapshot:** A CopyOnWriteArrayList iterator retains its creation-time array, not later membership changes. Elements are still shared references.
- **Weakly consistent:** Concurrent queues, deques, and hash and skip-list structures, plus non-thread-safe enum collections, need not show one instant. They may reflect changes and do not use fail-fast exceptions to detect them.

A single thread can invalidate its iterator by modifying a collection directly in an enhanced for loop. Do not use fail-fast exceptions for retries or infer safety from their absence. Use supported iterator removal after next(), a positioned list iterator, or removeIf; snapshot iterators cannot mutate. Weak consistency does not make enum collections thread-safe: shared modifications still require coordination.

### Thread-safety boundaries

[Synchronized wrappers](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Collections.html#synchronizedList(java.util.List)) synchronize individual collection operations:

```java
List<String> list = Collections.synchronizedList(new ArrayList<>());
Set<Integer> set = Collections.synchronizedSet(new HashSet<>());
Map<String, Integer> map = Collections.synchronizedMap(new HashMap<>());
list.add("event");

synchronized (list) {
    for (String item : list) {
        System.out.println(item);
    }
}
```

Access the backing collection only through its wrapper. During iterator, spliterator, or stream traversal, lock that wrapper; for map views, lock the synchronized map, not its keySet view. Hold the same lock for compound invariants. Derived views retain the original synchronization discipline.

A thread-safe get followed by put is not an atomic update. For per-key changes, use documented atomic operations; coordinate multi-key invariants and mutable elements separately. A blocking queue [publishes producer actions](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/BlockingQueue.html) before insertion to a consumer after access to or removal of that element; this guarantee does not cover later unsynchronized element edits.

## Arrays

[Java arrays](https://docs.oracle.com/javase/specs/jls/se21/html/jls-10.html) have fixed length, zero-based indices, and one component type. Reference arrays store references. [Arrays.copyOf](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Arrays.html) allocates another array; it does not grow the original.

New slots hold default values: null for references, zero for int. Use arrays for known lengths, unboxed primitive storage, or array-based APIs. The array.length field differs from the collection size() method. Indices outside 0 through length - 1 throw ArrayIndexOutOfBoundsException.

Arrays.binarySearch requires sorting with the same ordering used for search. It returns a matching index or -(insertionPoint) - 1; test index >= 0 for presence. With duplicates, it need not find the first match. Linear search needs no sorting.

```java
// Initialization
String[] array = new String[10];
int[] numbers = {1, 2, 3, 4, 5};
int n = array.length;

// Access and Update
String element = array[0];
array[0] = "hello";

// Utility Methods
int[] copy = Arrays.copyOf(numbers, numbers.length * 2);

// Sorting
Arrays.sort(numbers);

// Searching
int index = Arrays.binarySearch(numbers, 3);
boolean exists = Arrays.stream(numbers).anyMatch(value -> value == 3);

// Iteration
Arrays.stream(numbers).forEach(System.out::println);
for (int num : numbers) { System.out.println(num); }
```

The larger copy has five trailing zeroes. Reference-array copies share the referenced objects. Sorting mutates the source array; copy first to retain an unsorted version.

| Operation      | Time complexity  |
| -------------- | ---------------- |
| Access         | O(1)             |
| Update         | O(1)             |
| Copy to length m | O(m), including initialization of the new array |
| Sort           | O(n log n)       |
| Binary search  | O(log n)         |
| Linear search  | O(n)             |

The sort bound describes the documented type-specific implementations, not an identical comparison count for every input. Arrays provide no compound-operation synchronization.

## Lists

Lists preserve positions and allow duplicates. Array-backed, linked, and copy-on-write storage have different access and mutation costs.

### ArrayList class {#arraylist}

[ArrayList](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/ArrayList.html) is a growable array for indexed sequences. Indexed access and updates are O(1); front or middle edits shift later references. Appending is amortized O(1); removing the last element needs no shifting. It is not thread-safe.

Initial capacity creates no elements. ensureCapacity can avoid repeated growth for a known bulk load; trimToSize releases spare capacity but may make the next append allocate again. The growth factor is not an interface guarantee.

```java
List<String> list = new ArrayList<>();
int size = list.size();

// Adding Elements
list.add("apple");
list.add(0, "banana");                  // O(n) due to shifting
list.addAll(List.of("cat", "dog"));

// Access and Modification
String item = list.get(0);
list.set(1, "cherry");
list.remove(0);                         // O(n) due to shifting

// Sorting
list.sort(Comparator.naturalOrder());

// Searching
boolean exists = list.contains("apple");
int idx = list.indexOf("apple");

// Aggregates
String min = Collections.min(list);
int freq = Collections.frequency(list, "apple");

// Iteration
list.forEach(System.out::println);
for (String s : list) { System.out.println(s); }
```

For an absent value, contains returns false and indexOf returns -1. The Collections.min method requires a nonempty collection and an ordering capable of comparing its elements.

For List&lt;Integer&gt;, remove(1) removes index one; remove(Integer.valueOf(1)) removes an equal value.

Endpoint operations and a reversed view:

```java
List<String> list = new ArrayList<>(List.of("a", "b"));
System.out.println(list.getFirst() + ":" + list.getLast());
list.addFirst("start");
list.addLast("end");
System.out.println(list.removeFirst());
System.out.println(list.removeLast());

List<String> reverse = list.reversed();
reverse.addFirst("c");
System.out.println(list);
list.set(0, "A");
System.out.println(reverse);

SequencedCollection<String> readOnly =
        Collections.unmodifiableSequencedCollection(list);
System.out.println(readOnly.getLast());
try {
    readOnly.removeFirst();
} catch (UnsupportedOperationException ex) {
    System.out.println("read-only");
}
try {
    new ArrayList<String>().getFirst();
} catch (NoSuchElementException ex) {
    System.out.println("empty");
}
```

Adding first through reversed() appends to the original; set changes remain visible in reverse. The unmodifiableList method retains the sequenced List API; unmodifiableSequencedCollection exposes only that narrower contract. Both return live read-only views.

| Operation | Time complexity |
| --- | --- |
| size, get, set, getFirst, getLast | O(1) |
| indexOf, contains, Collections.min, Collections.frequency | O(n) |
| add or addLast | O(1) amortized; O(n) on growth |
| add(index, value) or addFirst | O(n) worst case |
| remove(index) or removeFirst | O(n) worst case |
| removeLast | O(1) |
| addAll of m elements at end | O(n + m) worst case with growth |
| sort | O(n log n) |
| Complete traversal or structural copy | O(n) |

### subList views and traversal mutation {#sublist-and-traversal-mutation}

[subList(from, to)](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/List.html#subList(int,int)) is a backed half-open range: from included, to excluded.

```java
List<String> list = new ArrayList<>(List.of("a", "b", "c", "d"));
List<String> middle = list.subList(1, 3);
middle.set(0, "B");
middle.remove(1);
middle.add("X");
System.out.println(list);

Iterator<String> iterator = list.iterator();
while (iterator.hasNext()) {
    String value = iterator.next();
    if (Character.isUpperCase(value.charAt(0))) {
        iterator.remove();
    }
}
System.out.println(list);
boolean changed = list.removeIf(value -> value.equals("d"));
System.out.println(changed + " " + list);
```

Iterator removal must follow next() once per element; otherwise it throws IllegalStateException. The removeIf method removes all matches and reports whether anything changed. Its bulk implementation in ArrayList avoids repeated shifting; an iterator-removal loop can cost O(n²) when many front or middle elements are removed.

After structural backing changes made outside a sublist, do not reuse it: its semantics are undefined, not merely “it throws an exception.” The set method is nonstructural. For independent membership, use new ArrayList&lt;&gt;(list.subList(from, to)). A small retained view can keep a large backing list reachable.

### LinkedList class {#linkedlist}

[LinkedList](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/LinkedList.html) implements List and Deque with linked nodes. Endpoints are O(1); indexed access walks from the nearer end. Repeated get(i) can turn traversal into O(n²). It is not thread-safe.

After an iterator is positioned, insertion or removal is O(1); indexed insertion includes a search. A cursor supports scan-and-edit workloads:

```java
LinkedList<String> steps = new LinkedList<>(List.of("read", "write", "close"));
ListIterator<String> cursor = steps.listIterator();
while (cursor.hasNext()) {
    String step = cursor.next();
    if (step.equals("write")) {
        cursor.set("flush");
        cursor.add("audit");
    } else if (step.equals("close")) {
        cursor.remove();
    }
}
steps.addFirst("open");
steps.addLast("done");
System.out.println(steps.getFirst() + ":" + steps.getLast());
System.out.println(steps);
System.out.println(steps.removeFirst());
System.out.println(steps.removeLast());
System.out.println(steps);
```

| Operation | Time complexity |
| --- | --- |
| get, set, add, or remove at index i | O(1 + min(i, n - i)) for locating and mutation, O(n) worst case |
| Endpoint get, add, or remove | O(1) |
| Iterator-positioned set, add, or remove | O(1) per mutation |
| contains, indexOf, or complete iterator traversal | O(n) |
| sort | O(n log n), with temporary storage rather than repeated indexed access |

Nodes require allocation and link maintenance. “Many insertions” does not justify them if every edit starts with an index search. For indexing, prefer ArrayList; for non-concurrent stack or queue operations, prefer ArrayDeque.

### CopyOnWriteArrayList class {#copyonwritearraylist}

[CopyOnWriteArrayList](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/CopyOnWriteArrayList.html) is thread-safe and replaces its backing array on content-changing writes. Read-mostly listener or subscriber registries can traverse without external locking while writers pay for copying.

Iterators retain their creation-time array; later writes are invisible to them. Iterator remove and list-iterator add and set are unsupported. Frequent writes allocate and copy whole arrays and increase garbage-collection pressure; slow readers can retain old arrays.

```java
List<String> list = new CopyOnWriteArrayList<>();

// Write operations (clones the array)
list.add("event1");
list.add("event2");

String event = list.get(0);

// Sorting
list.sort(Comparator.naturalOrder());

// Iteration
list.forEach(System.out::println);
for (String s : list) { System.out.println(s); }
```

Sorting is also a write, even without a size change.

```java
CopyOnWriteArrayList<String> listeners =
        new CopyOnWriteArrayList<>(List.of("first", "second"));
Iterator<String> snapshot = listeners.iterator();
listeners.remove("first");
listeners.addIfAbsent("second");
listeners.addIfAbsent("third");
snapshot.forEachRemaining(System.out::println);
System.out.println(listeners);
```

The iterator prints first, second; the current list is \[second, third\]. The addIfAbsent method atomically checks and adds, unlike separate contains and add calls. Ordinary add still permits duplicates.

| Operation | Time complexity |
| --- | --- |
| get, size, endpoint reads | O(1) |
| Content-changing add, set, or remove | O(n) copying; a no-change call need not copy |
| contains or addIfAbsent | O(n) comparisons, plus a copy if inserted |
| sort | O(n log n), plus replacement-array allocation |
| Iterator creation; complete snapshot traversal | O(1) for creation; O(n) for traversal |

## Stacks

A stack removes the newest item first: last in, first out (LIFO).

### ArrayDeque as a stack {#arraydeque-as-stack}

[ArrayDeque](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/ArrayDeque.html) is preferred over legacy Stack for non-concurrent use. Its growable array makes pushes amortized O(1), with no linked node per push. It is not thread-safe.

The push, pop, and peek methods correspond to addFirst, removeFirst, and peekFirst, respectively; iteration runs from top to bottom. On an empty stack, pop throws NoSuchElementException, while peek and pollFirst return null. Null rejection makes that sentinel unambiguous.

```java
Deque<Integer> stack = new ArrayDeque<>();

// LIFO Operations
stack.push(10);
stack.push(20);
Integer top = stack.peek();
Integer popped = stack.pop();

// Iteration
stack.forEach(System.out::println);
for (Integer i : stack) { System.out.println(i); }
System.out.println(stack.pop());
System.out.println(stack.peek());
try {
    stack.pop();
} catch (NoSuchElementException ex) {
    System.out.println("empty stack");
}
```

| Operation | Time complexity |
| --------- | --------------- |
| push    | O(1) amortized  |
| peek    | O(1)            |
| pop     | O(1)            |
| contains | O(n)           |
| size, getFirst, getLast | O(1) |
| addFirst or addLast | O(1) amortized |
| removeFirst or removeLast | O(1) |
| Complete traversal | O(n) |

### ConcurrentLinkedDeque as a stack {#concurrentlinkeddeque-as-stack}

[ConcurrentLinkedDeque](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentLinkedDeque.html) is a thread-safe, non-blocking linked deque with weakly consistent iteration. It is unbounded. Endpoint operations do not wait for items or capacity, but non-blocking does not guarantee bounded completion under contention.

Each insertion allocates a node. if (!stack.isEmpty()) stack.pop() races with another remover; use one pollFirst() for remove-if-present. Bulk operations are not whole-deque transactions.

```java
Deque<Integer> stack = new ConcurrentLinkedDeque<>();

// LIFO Operations
stack.push(100);
stack.push(200);
Integer top = stack.peek();
Integer popped = stack.pop();

// Iteration
stack.forEach(System.out::println);
for (Integer i : stack) { System.out.println(i); }
```

size() traverses the deque and may already be stale on return; do not use it to coordinate consumers.

| Operation | Time complexity |
| --------- | --------------- |
| push    | O(1)            |
| peek    | O(1)            |
| pop     | O(1)            |
| contains | O(n)           |
| size or complete traversal | O(n) |

## Queues

FIFO order, priority selection, and blocking are separate properties. A blocking queue adds waiting operations to either FIFO or priority ordering.

### Queue operation families

[Queue](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Queue.html) provides methods that throw exceptions or return sentinel values; [BlockingQueue](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/BlockingQueue.html) adds waiting and timed forms:

- **Insert:** When full, add(e) throws IllegalStateException and offer(e) returns false. The put(e) method waits for space; offer(e, timeout, unit) returns false on timeout.
- **Remove the head:** When empty, remove() throws NoSuchElementException and poll() returns null. The take() method waits for an item; poll(timeout, unit) returns null on timeout.
- **Inspect the head:** When empty, element() throws NoSuchElementException and peek() returns null. There is no blocking or timed inspection method.

Sentinel forms still reject invalid input: offer(null) throws on a null-rejecting queue. The remove() method removes the head; remove(value) searches for an equal element. Deques have corresponding First and Last method families; push and pop select the first end.

Plain offer and poll do not wait for capacity or data, though they can contend for an internal lock. The put and take methods can wait indefinitely; timed methods bound the wait for capacity or data, not scheduling delay. Blocking and timed waits are interruptible. Propagate InterruptedException or apply an application cancellation policy; if you catch it without propagating it, normally restore interruption with Thread.currentThread().interrupt().

An empty queue is not end-of-stream. These interfaces define no universal close; consumers need a finite-work, end-of-stream, or cancellation protocol.

### ArrayDeque as a queue {#arraydeque-as-queue}

[ArrayDeque](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/ArrayDeque.html) is an array-backed, non-thread-safe deque. For FIFO, offer appends at the tail, peek inspects the head, and poll removes the head. The push method instead inserts at the head for LIFO.

```java
Deque<String> queue = new ArrayDeque<>();

// FIFO Operations
queue.offer("first");
queue.offer("second");
String head = queue.peek();
String item = queue.poll();

// Iteration
queue.forEach(System.out::println);
for (String s : queue) { System.out.println(s); }
```

The offerFirst, offerLast, peekFirst, peekLast, pollFirst, and pollLast methods select an end; getFirst, getLast, removeFirst, and removeLast throw when empty. The reversed() method swaps the ends in a backed view. Construction capacity does not cap queue length.

| Operation | Time complexity |
| --------- | --------------- |
| offer   | O(1) amortized  |
| peek    | O(1)            |
| poll    | O(1)            |
| contains | O(n)           |
| Complete traversal or remove(value) | O(n) |
| size | O(1) |

### PriorityQueue class {#priorityqueue}

[PriorityQueue](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/PriorityQueue.html) is an unbounded array-backed heap. Natural order or a comparator selects the head. Iteration is not sorted; repeated poll() calls remove items in priority order. Sorting a copy leaves the queue intact.

It is not thread-safe. Equal-priority ties have no FIFO guarantee; to choose their order, add a tie-breaking key. The contains and remove(value) methods use equality, not comparator equivalence; values that compare as equal are not deduplicated.

```java
// Natural order (Min-Heap)
PriorityQueue<Integer> pq = new PriorityQueue<>();

// Custom order (Max-Heap)
PriorityQueue<Integer> maxPq = new PriorityQueue<>(Collections.reverseOrder());

// Priority Operations
pq.offer(15);
pq.offer(5);
pq.offer(20);
pq.offer(10);
Integer top = pq.peek();

// Iteration
pq.forEach(System.out::println);
for (Integer i : pq) { System.out.println(i); }

// Conversion (Sorted)
List<Integer> sorted = pq.stream().sorted().toList();
System.out.println(sorted);
maxPq.addAll(List.of(15, 5, 20, 10));
System.out.println(maxPq.poll());

Integer removed = pq.poll();
System.out.println(removed);
while (!pq.isEmpty()) {
    System.out.println(pq.poll());
}
```

| Operation | Time complexity |
| --- | --- |
| offer or add | O(log n) amortized heap work; occasional O(n) array growth |
| peek, element, size | O(1) |
| poll or head remove() | O(log n) |
| contains or remove(value) | O(n) search |
| Unordered traversal | O(n) |
| Sorted copy or complete priority drain | O(n log n), plus O(n) storage for a copy |

The heap maintains enough order to select the next priority item without keeping a fully sorted list. Its array capacity grows as needed.

### ConcurrentLinkedQueue class {#concurrentlinkedqueue}

[ConcurrentLinkedQueue](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentLinkedQueue.html) is a thread-safe, non-blocking FIFO queue using linked nodes and compare-and-set. It has no capacity limit or waiting retrieval; polling an empty queue is not a blocking consumer protocol.

Traversal is weakly consistent; bulk operations are not atomic.

```java
Queue<String> queue = new ConcurrentLinkedQueue<>();

queue.offer("message");
String msg = queue.poll();

// Iteration
queue.forEach(System.out::println);
for (String s : queue) { System.out.println(s); }
```

Use the poll() result rather than a separate isEmpty check. Linked storage allocates nodes as items arrive, and an unbounded backlog can exhaust memory.

| Operation | Time complexity |
| --------- | --------------- |
| offer   | O(1)            |
| poll    | O(1)            |
| contains | O(n)           |
| peek | O(1) usual uncontended structural work |
| size or complete traversal | O(n) |

size() traverses and can be inaccurate during mutation; it is not a synchronization condition.

### ArrayBlockingQueue class {#arrayblockingqueue}

[ArrayBlockingQueue](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ArrayBlockingQueue.html) is a thread-safe FIFO with fixed capacity. It reserves array storage up front rather than allocating nodes per item. The hard element-count limit provides backpressure.

Optional fairness serves waiting producers and consumers in FIFO order, usually at a throughput cost; it does not guarantee end-to-end task scheduling fairness.

```java
BlockingQueue<String> queue = new ArrayBlockingQueue<>(100);

// Producer-Consumer Operations
queue.put("task");                  // Blocks if full
String item = queue.take();         // Blocks if empty

// Iteration
queue.forEach(System.out::println);
for (String s : queue) { System.out.println(s); }
```

A capacity-one queue exercises the full and empty outcomes:

```java
BlockingQueue<String> queue = new ArrayBlockingQueue<>(1);
queue.add("first");
System.out.println(queue.element());
System.out.println(queue.peek());
System.out.println(queue.offer("second"));
try {
    queue.add("second");
} catch (IllegalStateException ex) {
    System.out.println("full");
}
System.out.println(queue.offer("second", 10, TimeUnit.MILLISECONDS));
System.out.println(queue.remove());
System.out.println(queue.poll());
try {
    queue.remove();
} catch (NoSuchElementException ex) {
    System.out.println("empty removal");
}
try {
    queue.element();
} catch (NoSuchElementException ex) {
    System.out.println("empty inspection");
}
System.out.println(queue.poll(10, TimeUnit.MILLISECONDS));
queue.put("task");
System.out.println(queue.take());
```

Handle a failed offer call to avoid losing work. The remainingCapacity method observes space; it does not reserve it against another producer.

| Operation | Time complexity |
| --------- | --------------- |
| put or offer | O(1)      |
| take or poll | O(1)      |
| contains | O(n)           |
| peek, size, remainingCapacity | O(1) |
| remove(value) or complete traversal | O(n) |

### LinkedBlockingQueue class {#linkedblockingqueue}

[LinkedBlockingQueue](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/LinkedBlockingQueue.html) is an optionally bounded FIFO blocking queue. Omitted capacity means Integer.MAX_VALUE; supply a smaller bound for backpressure. Linked storage is allocated as items arrive rather than reserving an entire element array up front.

The bound limits item count, not total bytes. A default-capacity backlog can exhaust memory.

```java
BlockingQueue<String> queue = new LinkedBlockingQueue<>(1);

queue.put("data");
boolean accepted = queue.offer("next");
System.out.println(accepted);
String data = queue.take();
queue.put("next");

// Iteration
queue.forEach(System.out::println);
for (String s : queue) { System.out.println(s); }
```

| Operation | Time complexity |
| --------- | --------------- |
| put or offer | O(1)      |
| take or poll | O(1)      |
| contains | O(n)           |
| peek, size, remainingCapacity | O(1) |
| remove(value) or complete traversal | O(n) |

### PriorityBlockingQueue class {#priorityblockingqueue}

[PriorityBlockingQueue](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/PriorityBlockingQueue.html) is an unbounded concurrent heap with PriorityQueue ordering rules. Iterators are weakly consistent and unsorted. take waits when empty; put and even timed offer do not wait for capacity. There is no capacity-based backpressure.

Initial capacity is an allocation hint. remainingCapacity() is Integer.MAX_VALUE, not available memory; an unbounded backlog can exhaust memory.

```java
BlockingQueue<Integer> pq = new PriorityBlockingQueue<>();

pq.put(50);
pq.put(10);
pq.put(30);
pq.put(20);

// Iteration
pq.forEach(System.out::println);
for (Integer i : pq) { System.out.println(i); }

Integer min = pq.take();
System.out.println(min);
Integer next;
while ((next = pq.poll()) != null) {
    System.out.println(next);
}
```

Polling until null drains currently available items, not future arrivals. Concurrent producers can change which priorities are available at each removal.

| Operation | Time complexity |
| --- | --- |
| put or offer | O(log n) amortized heap work, occasional O(n) growth |
| take or poll | O(log n), excluding any wait for an element |
| peek or size | O(1) |
| contains or remove(value) | O(n) |
| Unordered traversal | O(n) |
| Complete priority drain | O(n log n) |

## Sets

Sets keep unique elements; equality or comparator equivalence determines whether a value is already present.

### HashSet class {#hashset}

[HashSet](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/HashSet.html) is backed by a HashMap, with unspecified encounter order. It is not thread-safe.

The add and remove methods report membership changes. Capacity and load factor affect bucket storage, collisions, and resizing, not maximum size. The [HashSet.newHashSet(expectedElements) method](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/HashSet.html#newHashSet(int)) sizes for an expected count.

```java
Set<String> set = new HashSet<>();

set.add("apple");
set.add("banana");
boolean added = set.add("apple");

set.remove("apple");
boolean contains = set.contains("banana");

// Iteration
set.forEach(System.out::println);
for (String s : set) { System.out.println(s); }
```

| Operation | Expected time complexity |
| --------- | ------------------------ |
| add     | O(1) amortized           |
| remove  | O(1)                     |
| contains | O(1)                    |
| size | O(1) |
| Complete traversal or copy by traversal | O(n + capacity) |

The bucket array can retain spare capacity after removals.

### TreeSet class {#treeset}

[TreeSet](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/TreeSet.html) is a TreeMap-backed NavigableSet for sorted ranges and nearest-neighbor queries. It uses natural order or a comparator and is not thread-safe.

The lower and higher methods find strict neighbors; floor and ceiling include equality. All return null when no candidate exists. On an empty set, first, last, getFirst, and getLast throw an exception, while pollFirst and pollLast return null. Otherwise, pollFirst and pollLast remove endpoints. With a null-friendly comparator, a null result can also be a stored element.

```java
NavigableSet<Integer> set = new TreeSet<>();
set.addAll(List.of(10, 5, 20, 15));

// Navigational Methods
Integer min = set.first();
Integer max = set.last();
Integer lower = set.lower(15);
Integer higher = set.higher(15);

// Basic Operations
set.add(25);
set.remove(10);
boolean hasValue = set.contains(15);

// Iteration
set.forEach(System.out::println);
for (Integer i : set) { System.out.println(i); }

// Specialized Views
NavigableSet<Integer> subset = set.subSet(5, true, 15, true);
NavigableSet<Integer> descending = set.descendingSet();
System.out.println(subset);
subset.remove(5);
subset.add(10);
System.out.println(set);
try {
    subset.add(30);
} catch (IllegalArgumentException ex) {
    System.out.println("outside range");
}
System.out.println(descending);
System.out.println(set.floor(16));
System.out.println(set.ceiling(16));
System.out.println(set.getFirst() + ":" + set.getLast());
try {
    set.addFirst(30);
} catch (UnsupportedOperationException ex) {
    System.out.println("sorted positioning");
}
System.out.println(set.pollFirst());
System.out.println(set.pollLast());
System.out.println(set);
```

The subSet(5, true, 15, true) view includes both bounds; headSet and tailSet give one-sided views. Supported removals, clear, and in-range additions change the backing set. Inserting 30 through this subset throws IllegalArgumentException.

The descendingSet() and reversed() methods return backed reverse-order views. The addFirst and addLast methods throw UnsupportedOperationException: implementing SequencedSet does not override comparator positioning.

new TreeSet&lt;&gt;(subset) gives independent membership, preserving the view's comparator through the sorted-set constructor.

| Operation | Time complexity |
| --- | --- |
| add, remove, contains | O(log n) |
| lower, higher, floor, ceiling | O(log n) |
| first, last, getFirst, getLast, endpoint removal | O(log n) |
| Complete traversal | O(n) |

Tree nodes store navigation links and balancing information. Updates maintain sorted order rather than an indexed array or hash-only membership.

### LinkedHashSet class {#linkedhashset}

[LinkedHashSet](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/LinkedHashSet.html) adds encounter-order links to a hash set. It defaults to insertion order and is not thread-safe. Ordinary add of an existing element returns false without moving it; sequenced methods can reposition it.

```java
SequencedSet<String> set = new LinkedHashSet<>();
set.add("z");
set.add("a");
set.add("m");
set.remove("a");
boolean exists = set.contains("z");

// Iteration
set.forEach(System.out::println);
for (String s : set) { System.out.println(s); }
System.out.println(set.add("z"));
set.addFirst("m");
System.out.println(set);
set.addLast("m");
System.out.println(set);
SequencedSet<String> reverse = set.reversed();
reverse.addFirst("a");
System.out.println(set);
System.out.println(reverse);
System.out.println(set.getFirst() + ":" + set.getLast());
System.out.println(set.removeFirst());
System.out.println(set.removeLast());

SequencedSet<String> readOnly = Collections.unmodifiableSequencedSet(set);
set.addFirst("x");
System.out.println(readOnly);
try {
    readOnly.addLast("q");
} catch (UnsupportedOperationException ex) {
    System.out.println("read-only set");
}
```

addFirst(&quot;m&quot;) and addLast(&quot;m&quot;) move the existing element without changing membership. Adding first through reversed() appends to the original. unmodifiableSequencedSet is live: it sees the later &quot;x&quot; but rejects mutations. Linked order provides neither sorting nor indexed access.

| Operation | Expected time complexity |
| --------- | ------------------------ |
| add     | O(1) amortized           |
| remove  | O(1)                     |
| contains | O(1)                    |
| getFirst, getLast, size | O(1) |
| addFirst or addLast | O(1) expected amortized |
| removeFirst or removeLast | O(1) expected |
| Complete traversal | O(n), independent of bucket capacity |

Encounter-order links add storage and maintenance but avoid scanning unused hash capacity during iteration.

### EnumSet class {#enumset}

[EnumSet](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/EnumSet.html) is a mutable bit-vector set for one enum type, a type-safe alternative to integer flag masks. Iteration follows enum declaration order, not insertion order. It does not implement SequencedSet.

noneOf(Type.class) creates an empty typed set; allOf selects every constant; of selects specific constants; range selects an inclusive declaration-order range. complementOf uses the enum's entire universe, not an application-defined subset.

```java
enum Permission { READ, WRITE, ADMIN }

EnumSet<Permission> granted = EnumSet.noneOf(Permission.class);
granted.add(Permission.READ);
granted.add(Permission.WRITE);
System.out.println(
    granted.contains(
        Permission.READ));
System.out.println(granted.add(Permission.READ));
EnumSet<Permission> required = EnumSet.of(Permission.READ, Permission.WRITE);
System.out.println(granted.containsAll(required));

EnumSet<Permission> saved = EnumSet.copyOf(granted);
System.out.println(
    EnumSet.complementOf(granted));
granted.addAll(EnumSet.allOf(Permission.class));
granted.remove(Permission.ADMIN);
granted.retainAll(EnumSet.range(Permission.READ, Permission.WRITE));
granted.removeAll(EnumSet.of(Permission.WRITE));
System.out.println(granted);
System.out.println(saved);
for (Permission permission : granted) {
    System.out.println(permission);
}
```

With enum-set operands, addAll, retainAll, and removeAll implement union, intersection, and difference on bit vectors. saved has independent membership.

Inserting null throws NullPointerException; testing or removing null returns false. The EnumSet.copyOf method cannot infer a type from an empty ordinary collection and throws IllegalArgumentException; an empty EnumSet instance retains its type and can be copied. For empty external input, use noneOf.

| Operation | Cost model |
| --- | --- |
| add, remove, contains, size | O(1) basic operations |
| Enum-set bulk operations, complement, copy | Bit-vector work; scales with the enum universe's representation, not a hash table |
| Complete traversal | At most O(u), where u is the number of constants in the enum |

For a fixed enum type, its universe and bit-vector width are fixed, hence the constant-time basic operations.

### Concurrent hash set with ConcurrentHashMap {#concurrenthashset-via-concurrenthashmap}

There is no standalone ConcurrentHashSet class. [ConcurrentHashMap.newKeySet()](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentHashMap.html#newKeySet()) creates a concurrent set with unspecified encounter order and weakly consistent traversal.

The add method atomically tests and inserts; use its boolean result instead of separate contains and add calls. This protects one membership change, not a multi-element transaction.

```java
Set<String> set = ConcurrentHashMap.newKeySet();

set.add("concurrent-item");
boolean exists = set.contains("concurrent-item");

// Iteration
set.forEach(System.out::println);
for (String s : set) { System.out.println(s); }
System.out.println(set.add("concurrent-item"));
System.out.println(set.remove("concurrent-item"));
System.out.println(set.contains("concurrent-item"));
```

| Operation | Expected time complexity |
| --------- | ------------------------ |
| add     | O(1) amortized           |
| remove  | O(1)                     |
| contains | O(1)                    |
| Complete traversal | O(n + backing capacity), excluding concurrent changes |

newKeySet supports insertion; ordinary map.keySet() cannot add a key without a value. ConcurrentHashMap.keySet(mappedValue) explicitly supplies that value for additions.

### ConcurrentSkipListSet class {#concurrentskiplistset}

[ConcurrentSkipListSet](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentSkipListSet.html) is a concurrent sorted NavigableSet backed by a skip list. Use it for concurrent range and navigation queries rather than unordered hash membership.

Bulk operations are not necessarily atomic. size() traverses and may be inaccurate during mutation. Ascending traversal is generally faster than descending.

```java
NavigableSet<Integer> set = new ConcurrentSkipListSet<>();

set.add(30);
set.add(10);
Integer first = set.first();

// Iteration
set.forEach(System.out::println);
for (Integer i : set) { System.out.println(i); }
System.out.println(set.lower(30));
System.out.println(set.ceiling(20));
System.out.println(set.remove(30));
System.out.println(set.pollFirst());
System.out.println(set.pollFirst());
```

Range, descending, and reversed views are backed and sorted, not snapshots. The addFirst and addLast methods remain unsupported: the comparator determines position.

| Operation | Expected average time complexity |
| --------- | -------------------------------- |
| add     | O(log n)                         |
| remove  | O(log n)                         |
| contains | O(log n)                        |
| Navigation or endpoint removal | O(log n) expected |
| size or complete traversal | O(n) |

Skip-list nodes and index links add allocation costs for concurrent sorted access.

## Maps

The [keySet, values, and entrySet methods](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Map.html#keySet()) return backed views: supported remove and clear calls delete mappings, while additions are unsupported. Removing from values deletes one matching mapping, not all equal-valued mappings. Entry iteration may support entry.setValue; endpoint entry queries instead return unmodifiable mapping snapshots.

### HashMap class {#hashmap}

[HashMap](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/HashMap.html) uses a hash table with expected O(1) lookup and amortized insertion. It is not thread-safe and has no encounter-order guarantee.

Here capacity means bucket count. The [HashMap.newHashMap(expectedMappings) method](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/HashMap.html#newHashMap(int)) sizes for an expected mapping count; new HashMap&lt;&gt;(count) takes an initial capacity instead. Neither caps size.

```java
Map<String, Integer> map = new HashMap<>();

// Put and Get
map.put("Alice", 25);
map.putIfAbsent("Bob", 30);
Integer age = map.getOrDefault("Alice", 0);

// Inspection
boolean hasKey = map.containsKey("Alice");
boolean hasValue = map.containsValue(25);

// Removal
map.remove("Alice");

// Functional Operations
map.computeIfPresent("Bob", (k, v) -> v + 1);

// Iteration
map.forEach((k, v) -> System.out.println(k + ": " + v));
for (Map.Entry<String, Integer> entry : map.entrySet()) {
    System.out.println(entry.getKey() + ": " + entry.getValue());
}
```

The put and remove methods return the previous value, or null with the ambiguity below. Replacing a value does not increase map size.

Absence and a mapping to null differ:

```java
Map<String, Integer> map = HashMap.newHashMap(4);
map.put("unknown", null);
System.out.println(map.get("missing"));
System.out.println(map.get("unknown"));
System.out.println(map.containsKey("unknown"));
System.out.println(map.containsKey("missing"));
System.out.println(map.getOrDefault("unknown", -1));
System.out.println(map.getOrDefault("missing", -1));
map.putIfAbsent("unknown", 5);
System.out.println(map.get("unknown"));

map.put("removed", 1);
map.computeIfPresent("removed", (key, value) -> null);
System.out.println(map.containsKey("removed"));
map.put("notComputed", null);
map.computeIfPresent("notComputed", (key, value) -> 99);
System.out.println(map.get("notComputed"));
map.computeIfAbsent("notComputed", key -> 7);
map.merge("notComputed", 3, Integer::sum);
System.out.println(map.get("notComputed"));
System.out.println(map.replace("notComputed", 10, 11));
System.out.println(map.remove("notComputed", 11));
```

The get method returns null for both absent and null-valued keys; containsKey distinguishes them. The getOrDefault method uses its default only for absence, not a mapped null. The putIfAbsent method treats null as absent. Unboxing a nullable Integer into int can throw NullPointerException.

The [Map functional-update contracts](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Map.html) distinguish:

- computeIfPresent: Skips absent or null values; a null callback result removes the mapping.
- computeIfAbsent: Computes for absent or null values; a null result installs nothing.
- merge: Uses the supplied non-null value for absent or null mappings; otherwise, combines it with the existing value. A null remapping result removes the mapping.
- Conditional replace and remove: Return whether the expected-value condition matched.

| Operation     | Expected time complexity |
| ------------- | ------------------------ |
| put         | O(1) amortized           |
| get         | O(1)                     |
| remove      | O(1)                     |
| containsKey | O(1)                     |
| containsValue | O(n + capacity)        |
| putIfAbsent, conditional remove or replace, compute, merge | Expected O(1) lookup and update plus callback cost; insertion can resize |
| size | O(1) |
| Complete traversal | O(n + capacity) |

Do not structurally modify the same map from a computation callback.

### TreeMap class {#treemap}

[TreeMap](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/TreeMap.html) is a red-black-tree NavigableMap for key ranges and nearest-key searches. Keys, not values, determine natural or comparator order; [comparator equivalence](#equality-hashing-and-sorted-equivalence) determines uniqueness. It is not thread-safe.

The lowerKey and higherKey methods find strict neighbors; floorKey and ceilingKey include equality. Corresponding \*Entry methods return mapping snapshots or null if no candidate exists. On an empty map, firstKey and lastKey throw an exception, while firstEntry, lastEntry, and endpoint polls return null.

```java
NavigableMap<String, Integer> map = new TreeMap<>();
map.put("C", 3);
map.put("A", 1);
map.put("B", 2);

// Navigational Methods
String first = map.firstKey();
String last = map.lastKey();

// Basic Operations
Integer val = map.get("A");
map.remove("B");
boolean hasK = map.containsKey("C");
boolean hasV = map.containsValue(3);

// Iteration
map.forEach((k, v) -> System.out.println(k + ": " + v));
for (Map.Entry<String, Integer> entry : map.entrySet()) {
    System.out.println(entry.getKey() + ": " + entry.getValue());
}

// Range Views
NavigableMap<String, Integer> head = map.headMap("B", true);
NavigableMap<String, Integer> tail = map.tailMap("B", true);
NavigableMap<String, Integer> sub = map.subMap("A", true, "C", true);
head.remove("A");
head.put("B", 2);
tail.put("D", 4);
System.out.println(map);
System.out.println(sub);
try {
    sub.put("D", 40);
} catch (IllegalArgumentException ex) {
    System.out.println("outside map range");
}
System.out.println(
    map.reversed().sequencedKeySet());
System.out.println(map.lowerKey("C") + "/" + map.floorKey("C")
        + "/" + map.ceilingKey("C") + "/" + map.higherKey("C"));
System.out.println(map.firstEntry() + " / " + map.lastEntry());
try {
    map.putFirst("Z", 26);
} catch (UnsupportedOperationException ex) {
    System.out.println("sorted map positioning");
}
Map.Entry<String, Integer> snapshot = map.firstEntry();
map.put("B", 20);
System.out.println(snapshot);
System.out.println(map.pollFirstEntry());
System.out.println(map.pollLastEntry());
System.out.println(map.keySet().remove("C"));
System.out.println(map.firstEntry());
```

The range edits produce {B=2, C=3, D=4} in the original, while sub sees {B=2, C=3} and rejects the out-of-range key D with IllegalArgumentException. The putFirst and putLast methods throw UnsupportedOperationException because keys stay sorted. The saved entry remains B=2 after the backing value becomes 20: endpoint entries are snapshots.

Bounds apply to insertions and nested views. Unlike an invalidated list subList, sorted ranges continue tracking their key range after outside backing changes; an active ordinary iterator can still fail fast. new TreeMap&lt;&gt;(sub) copies membership and retains its comparator. descendingMap() and reversed() are backed reverse-order views.

| Operation     | Time complexity |
| ------------- | --------------- |
| put         | O(log n)        |
| get         | O(log n)        |
| remove      | O(log n)        |
| containsKey | O(log n)        |
| containsValue | O(n)          |
| Nearest-key or entry lookup, endpoint query or removal | O(log n) |
| Complete traversal | O(n) |

Red-black-tree nodes require navigation links and balancing state. Hashing avoids maintaining sorted order when only equality lookup is needed.

### LinkedHashMap class {#linkedhashmap}

[LinkedHashMap](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/LinkedHashMap.html) adds encounter-order links to a hash table. The default is insertion order; ordinary put of an existing key keeps its position. accessOrder = true instead orders entries from least to most recently accessed. It is not thread-safe.

Access order does not supply eviction. Initial capacity is not a size limit: override removeEldestEntry or explicitly remove the first entry for that policy. In access order, even get can change order and invalidate an iterator. Access through a reversed map moves the entry to the backing map's most-recent end—the reversed view's first end.

```java
int initialCapacity = 16;
float loadFactor = 0.75f;
boolean accessOrder = true;

Map<String, Integer> map = new LinkedHashMap<>(initialCapacity, loadFactor, accessOrder);
map.put("one", 1);
map.put("two", 2);
System.out.println(map.keySet());
map.get("one");
System.out.println(map.keySet());
map.remove("two");
boolean containsK = map.containsKey("one");
boolean containsV = map.containsValue(1);

// Iteration
map.forEach((k, v) -> System.out.println(k + ": " + v));
for (Map.Entry<String, Integer> entry : map.entrySet()) {
    System.out.println(entry.getKey() + ": " + entry.getValue());
}
```

The get(&quot;one&quot;) call changes order from \[one, two\] to \[two, one\]. Key, value, and entry view operations do not count as accesses. The putFirst and putLast methods position entries directly rather than generating an access.

A two-entry least recently used (LRU) cache:

```java
Map<String, Integer> cache = new LinkedHashMap<>(4, 0.75f, true) {
    @Override
    protected boolean removeEldestEntry(Map.Entry<String, Integer> eldest) {
        return size() > 2;
    }
};
cache.put("one", 1);
cache.put("two", 2);
cache.get("one");
cache.put("three", 3);
System.out.println(cache);
```

Accessing one makes two the eldest entry; adding three evicts two. This limits element count, not bytes. Shared use requires synchronization of the complete access and eviction protocol.

Insertion-ordered sequenced-map operations; reads do not reposition entries:

```java
SequencedMap<String, Integer> map = new LinkedHashMap<>();
map.put("one", 1);
map.put("two", 2);
map.put("three", 3);
System.out.println(map.firstEntry() + " / " + map.lastEntry());
map.putFirst("three", 30);
map.putLast("one", 10);
System.out.println(map.sequencedKeySet());

SequencedMap<String, Integer> reverse = map.reversed();
reverse.putFirst("four", 4);
SequencedSet<String> keys = map.sequencedKeySet();
SequencedCollection<Integer> values = map.sequencedValues();
SequencedSet<Map.Entry<String, Integer>> entries = map.sequencedEntrySet();
System.out.println(keys.reversed());
System.out.println(values);
System.out.println(entries);

Map.Entry<String, Integer> snapshot = map.firstEntry();
map.put("three", 31);
System.out.println(snapshot);
try {
    snapshot.setValue(99);
} catch (UnsupportedOperationException ex) {
    System.out.println("snapshot entry");
}
for (Map.Entry<String, Integer> entry : map.entrySet()) {
    if (entry.getKey().equals("three")) {
        entry.setValue(32);
    }
}
System.out.println(map.get("three"));
System.out.println(keys.remove("two"));
try {
    keys.add("new");
} catch (UnsupportedOperationException ex) {
    System.out.println("key view cannot add");
}
System.out.println(map.pollFirstEntry());
System.out.println(map.pollLastEntry());
System.out.println(values.remove(10));
System.out.println(map.firstEntry());

SequencedMap<String, Integer> readOnly =
        Collections.unmodifiableSequencedMap(map);
map.putLast("five", 5);
System.out.println(readOnly.sequencedKeySet());
try {
    readOnly.pollFirstEntry();
} catch (UnsupportedOperationException ex) {
    System.out.println("read-only map");
}
```

The putFirst and putLast methods update and reposition existing keys. Adding first through the reversed map appends to the original.

The sequencedKeySet() and sequencedEntrySet() methods return SequencedSet views; sequencedValues() returns a SequencedCollection because values can repeat. Removals delete mappings; adding or positioning mappings through these collection views is unsupported.

The firstEntry, lastEntry, pollFirstEntry, and pollLastEntry methods return unmodifiable shallow snapshots. This implementation supports write-through entry.setValue during entrySet iteration, but sequencedEntrySet().getFirst() has no portable write-through guarantee. The unmodifiableSequencedMap method returns a live view that also protects its exposed entries and views.

| Operation     | Expected time complexity |
| ------------- | ------------------------ |
| put         | O(1) amortized           |
| get         | O(1)                     |
| remove      | O(1)                     |
| containsKey | O(1)                     |
| containsValue | O(n)                   |
| firstEntry, lastEntry, size | O(1) |
| putFirst or putLast | O(1) expected amortized |
| pollFirstEntry or pollLastEntry | O(1) expected |
| Complete traversal | O(n), independent of bucket capacity |

Encounter-order links add storage and maintenance beyond HashMap but avoid scanning spare buckets during iteration.

### EnumMap class {#enummap}

[EnumMap](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/EnumMap.html) is a mutable map for one enum key type. Array-based storage avoids general-purpose hashing; iteration follows declaration order. Use it for enum-indexed counters, dispatch tables, or settings. It does not implement SequencedMap.

```java
enum JobState { QUEUED, RUNNING, DONE }

EnumMap<JobState, Integer> counts = new EnumMap<>(JobState.class);
counts.put(JobState.DONE, 2);
counts.put(JobState.QUEUED, 3);
counts.putIfAbsent(JobState.RUNNING, 0);
counts.computeIfPresent(JobState.QUEUED, (state, count) -> count - 1);
counts.merge(JobState.RUNNING, 1, Integer::sum);
System.out.println(counts.get(JobState.QUEUED));
System.out.println(
    counts.containsKey(
        JobState.RUNNING));
System.out.println(counts.containsValue(2));
counts.forEach((state, count) -> System.out.println(state + "=" + count));

EnumMap<JobState, Integer> saved = new EnumMap<>(counts);
counts.remove(JobState.DONE);
counts.put(JobState.RUNNING, null);
System.out.println(
    counts.getOrDefault(
        JobState.RUNNING, -1));
System.out.println(
    counts.containsKey(
        JobState.RUNNING));
System.out.println(saved);
System.out.println(counts);
```

new EnumMap&lt;&gt;(counts) copies membership and value references independently of later mapping changes.

Inserting a null key throws NullPointerException; queries or removals treat a null key as absent. Null values follow the [HashMap lookup rules](#hashmap). The enum-class constructor works for empty maps; an empty ordinary Map cannot supply the key type and causes IllegalArgumentException. An empty EnumMap instance retains its type and can be copied.

| Operation | Time complexity |
| --- | --- |
| put, get, remove, containsKey, size | O(1) |
| Functional single-key update | O(1) map work plus callback |
| Construction or copy, clear, containsValue, complete traversal | O(u) worst case, where u is the enum key universe |

Storage is sized for the enum universe even when few mappings are populated.

### ConcurrentHashMap class {#concurrenthashmap}

[ConcurrentHashMap](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentHashMap.html) is a thread-safe hash table with generally non-blocking retrievals. Synchronizing on the map object does not prevent other callers accessing it.

For atomic per-key changes, use putIfAbsent, conditional remove or replace, compute, or merge; separate calls are not atomic together. Multi-key invariants need separate coordination. Weakly consistent traversal and aggregate queries (size, isEmpty, containsValue) can observe transient states.

```java
ConcurrentMap<String, Integer> map = new ConcurrentHashMap<>();

map.put("key", 1);
map.putIfAbsent("key", 2);
map.compute("key", (k, v) -> v + 1);

map.forEach((k, v) -> System.out.println(k + ": " + v));
for (Map.Entry<String, Integer> entry : map.entrySet()) {
    System.out.println(entry.getKey() + ": " + entry.getValue());
}
System.out.println(map.putIfAbsent("key", 99));
System.out.println(map.replace("key", 2, 3));
System.out.println(map.remove("key", 2));
System.out.println(map.merge("key", 4, Integer::sum));
map.compute("key", (key, value) -> null);
System.out.println(map.containsKey("key"));
```

An absent counter needs a null check before unboxing: map.compute(&quot;requests&quot;, (key, value) -> value == null ? 1 : value + 1). The entire ConcurrentHashMap.compute invocation is atomic, with one callback invocation—not one initialization for the key's lifetime. Keep callbacks short and do not update the same map inside them; other updates can block while they run. Other ConcurrentMap implementations have different callback guarantees.

| Operation     | Expected time complexity |
| ------------- | ------------------------ |
| put         | O(1) amortized           |
| get         | O(1)                     |
| remove      | O(1)                     |
| containsKey | O(1)                     |
| containsValue | O(n + capacity)        |
| Per-key conditional update, compute, or merge | Expected O(1) map work plus callback; contention can delay updates |
| Complete weakly consistent traversal | O(n + capacity), excluding concurrent growth or change |

Null rejection makes a null result from get unambiguously absent; a later call can observe a different state. Copying during writes is not a whole-map snapshot. Presizing reduces resizing and allocation work; it does not cap size.

### ConcurrentSkipListMap class {#concurrentskiplistmap}

[ConcurrentSkipListMap](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentSkipListMap.html) is a concurrent skip-list NavigableMap for sorted key ranges and navigation.

Ascending views and iterators are generally faster than descending ones. Range, descending, reversed, and sequenced views are backed and concurrent, not snapshots. The putFirst and putLast methods are unsupported because the comparator determines position. All entries from this implementation and its views are unmodifiable mapping snapshots; use map updates instead of Entry.setValue.

```java
ConcurrentNavigableMap<String, Integer> map = new ConcurrentSkipListMap<>();

map.put("Z", 26);
map.put("A", 1);
String first = map.firstKey();

// Iteration
map.forEach((k, v) -> System.out.println(k + ": " + v));
for (Map.Entry<String, Integer> entry : map.entrySet()) {
    System.out.println(entry.getKey() + ": " + entry.getValue());
}
Map.Entry<String, Integer> saved = map.firstEntry();
map.compute("A", (key, value) -> value + 1);
System.out.println(saved);
try {
    saved.setValue(99);
} catch (UnsupportedOperationException ex) {
    System.out.println("skip-list entry snapshot");
}
System.out.println(map.floorEntry("M"));
ConcurrentNavigableMap<String, Integer> range = map.headMap("M", true);
range.put("B", 2);
System.out.println(map.keySet());
System.out.println(map.remove("B", 2));
System.out.println(map.pollFirstEntry());
System.out.println(map.pollLastEntry());
System.out.println(map.firstEntry());
```

Unlike ConcurrentHashMap, this implementation [does not guarantee a single computation or remapping callback invocation](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentSkipListMap.html#compute(K,java.util.function.BiFunction)): contention can cause repeated calls. Keep callbacks free of externally visible side effects. Conditional updates protect one key; bulk operations such as putAll, clear, and containsValue are not whole-map atomic operations.

| Operation     | Expected average time complexity |
| ------------- | -------------------------------- |
| put         | O(log n)                         |
| get         | O(log n)                         |
| remove      | O(log n)                         |
| containsKey | O(log n)                         |
| containsValue | O(n)                           |
| Nearest-key or entry navigation, endpoint removal | O(log n) expected |
| Complete traversal | O(n), excluding concurrent changes |

Skip-list nodes and index links add allocation and comparison costs for concurrent sorted navigation.
