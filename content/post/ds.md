---
title: "DS - Data Structures"
description: "Java collections: selection, contracts, views, operations, and complexity."
date: 2024-09-26T12:00:00+01:00
draft: false
---

## Contents

- **Selection:** [Choosing a structure](#choosing-a-structure), [cost and storage](#cost-and-storage-model).
- **Foundations:** [Contracts and order](#interface-contracts-and-order), [equality](#equality-hashing-and-sorted-equivalence), [factories and mutability](#factories-copies-and-mutability), [sequenced collections](#java-21-sequenced-collections), [views and traversal](#views-and-traversal), [thread safety](#thread-safety-boundaries).
- [Arrays](#arrays).
- **Lists:** [ArrayList](#arraylist), [subList and traversal mutation](#sublist-and-traversal-mutation), [LinkedList](#linkedlist), [CopyOnWriteArrayList](#copyonwritearraylist).
- **Stacks:** [ArrayDeque](#arraydeque-as-stack), [ConcurrentLinkedDeque](#concurrentlinkeddeque-as-stack).
- **Queues:** [Operation families](#queue-operation-families), [ArrayDeque](#arraydeque-as-queue), [PriorityQueue](#priorityqueue), [ConcurrentLinkedQueue](#concurrentlinkedqueue), [ArrayBlockingQueue](#arrayblockingqueue), [LinkedBlockingQueue](#linkedblockingqueue), [PriorityBlockingQueue](#priorityblockingqueue).
- **Sets:** [HashSet](#hashset), [TreeSet](#treeset), [LinkedHashSet](#linkedhashset), [EnumSet](#enumset), [ConcurrentHashSet](#concurrenthashset-via-concurrenthashmap), [ConcurrentSkipListSet](#concurrentskiplistset).
- **Maps:** [HashMap](#hashmap), [TreeMap](#treemap), [LinkedHashMap](#linkedhashmap), [EnumMap](#enummap), [ConcurrentHashMap](#concurrenthashmap), [ConcurrentSkipListMap](#concurrentskiplistmap).

# Choosing a structure

- **Fixed-length indexed primitive/reference storage:** an [array](#arrays); growth requires a new array or a collection.
- **Growable indexed sequence:** [ArrayList](#arraylist); middle edits shift elements. For concurrent, read-mostly traversal, consider [CopyOnWriteArrayList](#copyonwritearraylist).
- **Non-concurrent stack or FIFO queue:** [ArrayDeque](#arraydeque-as-stack); no nulls, blocking, or built-in thread safety.
- **Repeated removal by priority:** [PriorityQueue](#priorityqueue); the comparator selects the head, not iteration order.
- **Capacity-limited producer-consumer work:** [ArrayBlockingQueue](#arrayblockingqueue) or bounded [LinkedBlockingQueue](#linkedblockingqueue); choose waiting, timeout, rejection, and interruption behavior.
- **Unordered uniqueness or key lookup:** [HashSet](#hashset) or [HashMap](#hashmap); equality/hash state must stay stable.
- **Predictable encounter order and endpoint positioning:** [LinkedHashSet](#linkedhashset) or [LinkedHashMap](#linkedhashmap); extra links maintain insertion/access order, not sorted order.
- **Sorted ranges and nearest neighbors:** [TreeSet](#treeset) or [TreeMap](#treemap); comparator equivalence determines uniqueness, with O(log n) operations.
- **Flags or lookup within one enum type:** [EnumSet](#enumset) or [EnumMap](#enummap); enum declaration order, not arbitrary positioning.
- **Concurrent non-blocking FIFO/LIFO:** [ConcurrentLinkedQueue](#concurrentlinkedqueue) or [ConcurrentLinkedDeque](#concurrentlinkeddeque-as-stack); unbounded storage provides no backpressure, and traversal is not a snapshot.
- **Concurrent lookup or sorted navigation:** [ConcurrentHashMap](#concurrenthashmap) or [ConcurrentSkipListMap](#concurrentskiplistmap); per-key operations do not protect cross-key invariants.

## Cost and storage model

In the tables, `n` is the number of elements or mappings. Costs assume O(1) hashing, equality, comparisons, and callbacks. **Expected** hash costs require well-dispersed hashes. **Amortized** growth spreads copying/rehashing across operations; one insertion can still cost O(n). Skip-list bounds are expected averages; tree bounds are worst-case. Concurrent costs exclude waiting, retries, and contention.

Capacity reserves storage; it is usually neither size nor a maximum. An `ArrayList` with capacity 100 starts empty and can exceed 100; a capacity-100 blocking queue cannot accept a 101st item until space is released. Array-backed structures use spare slots and occasional copying. Linked structures allocate nodes and links, and locating a position can dominate mutation.

Hash tables trade bucket capacity against collisions and resizing. `HashMap`/`HashSet` traversal scans capacity as well as entries; linked hash variants add links but traverse in O(n). Presize for a known expected count, not an arbitrary huge table.

Collections store references: `List<Integer>` uses boxing, unlike `int[]`; cached wrappers can avoid allocations. Copies and snapshots below are shallow. Arrays, nodes, and links cost storage, but Java does not specify object byte counts, physical layout, or cache behavior.

# Foundations

## Interface contracts and order

The [Collections Framework](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/package-summary.html#CollectionsFramework) defines these contracts:

- **`Collection<E>`:** a group with `size`, `isEmpty`, traversal, membership tests, and optional mutations: `add`, `remove`, `addAll`, `removeAll`, `retainAll`, `removeIf`, and `clear`.
- **`List<E>`:** an indexed sequence allowing duplicates. `get`, `set`, and indexed insertion/removal follow list order; indexed access need not be constant-time.
- **`Set<E>`:** unique elements under its equality/equivalence contract; `add` returns `false` when already present. No indexed access or universal ordering.
- **`Queue<E>`:** head-oriented insertion, inspection, and removal, with exception/sentinel method families. Not necessarily FIFO: a priority queue removes by priority.
- **`Deque<E>`:** a double-ended queue whose first/last operations support FIFO or LIFO.
- **`Map<K,V>`:** at most one value per equivalent key; updating a key replaces its value.

**`Map` is not a `Collection`.** Its `keySet()` is a set, `values()` is a collection that can contain duplicates, and `entrySet()` is a set of mappings. The base `Collection` interface does not fix duplicate or order policy. Null acceptance and thread safety depend on the implementation. Mutations can be optional: an unmodifiable implementation throws `UnsupportedOperationException`.

Order and duplication are separate:

- **Duplicate semantics:** lists and queues can hold repeated equal elements; sets cannot, and maps cannot hold repeated equivalent keys.
- **Encounter order:** the order seen by iteration/streams, such as list position or linked insertion/access order. Unspecified order is not a promise of randomness or stability.
- **Sorted order:** a comparator or natural ordering governs all elements/keys and enables range/navigation operations.
- **Priority order:** governs which item is removed next, not the order of ordinary iteration. Equal priorities do not imply FIFO tie-breaking.

Null policy:

- **`ArrayList`, `LinkedList`, and `CopyOnWriteArrayList`:** permit null elements. Null can make deque sentinel results ambiguous in `LinkedList`.
- **`HashSet` and `LinkedHashSet`:** permit one null element.
- **`HashMap` and `LinkedHashMap`:** permit one null key and multiple null values.
- **`TreeSet` and `TreeMap`:** natural ordering rejects null elements/keys; a comparator that explicitly handles null can permit them. Map values may be null.
- **`ArrayDeque`, `PriorityQueue`, and all concurrent queues/deques shown:** reject null elements.
- **Concurrent hash/skip-list sets and maps:** reject null elements/keys/values, even if a supplied comparator could compare null.
- **`EnumSet` and `EnumMap`:** `EnumSet` rejects null elements; `EnumMap` rejects null keys but permits null values.
- **Unmodifiable collection factories and copies:** `List.of`, `List.copyOf`, `Set.of`, `Set.copyOf`, `Map.of`, `Map.ofEntries`, and `Map.copyOf` reject null elements, keys, and values.

## Equality, hashing, and sorted equivalence

The [`equals`/`hashCode` contract](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Object.html#hashCode()) requires equal objects to have equal hash codes; unequal objects may collide. Hash lookup resolves collisions using equality. A stored set element or map key must keep its equality/hash-relevant state stable.

Records with immutable components work as value keys:

```java
record CustomerId(String region, long number) {}

Map<CustomerId, String> customers = new HashMap<>();
customers.put(new CustomerId("EU", 42), "Alice");
System.out.println(customers.get(new CustomerId("EU", 42)));
System.out.println(customers.size());
```

The second `CustomerId` has equal components, so lookup finds `Alice`. Records are only shallowly immutable: changing a list component or a mutable object's ID can change equality/hash codes. A stored key can then become unreachable even to `remove`. Remove it before mutation and reinsert it, or use immutable keys.

Sorted sets/maps treat `compare(a, b) == 0` as equivalence. The ordering [should be consistent with `equals`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Comparator.html) to honor the general `Set`/`Map` contracts. Comparing only one property can discard an unequal set element or replace an unequal map key's value:

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

`byLength` treats every two-character string as one key: the set retains only `aa`, and the map replaces `1` with `2`. The lexical tie-breaker retains distinct strings in `[c, aa, bb]`. Comparator equivalence is not a hash collision.

Keep comparator-relevant item and external state stable in trees, skip lists, and priority queues; they do not automatically resort. Remove and reinsert an item to change its priority.

`List.equals` compares elements in order; `Set.equals` compares membership irrespective of encounter order; `Map.equals` compares mappings irrespective of encounter order. Thus two linked sets/maps can be equal while iterating differently. A general `Collection` or `Deque` does not promise list-style value equality merely because it is sequenced.

## Factories, copies, and mutability

Unmodifiable collections can still contain mutable elements. Copies below share element references; only backed views reflect later source membership changes.

- **`Arrays.asList(array)`:** fixed-size, backed by the reference array in both directions. `set` works; size-changing operations do not. Allows nulls and duplicates; array order.
- **`new ArrayList<>(source)`:** independently mutable, copying element references in source traversal order. Allows nulls and duplicates.
- **`Collections.unmodifiableList(source)`:** a live read-only view, inheriting source contents and order, including nulls. Mutations through the wrapper throw.
- **[`List.of` / `List.copyOf`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/List.html#unmodifiable):** unmodifiable, reject nulls, retain duplicates and encounter order. `copyOf` may reuse a suitable unmodifiable list.
- **[`stream.toList()`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/stream/Stream.html#toList()):** unmodifiable, permits nulls and duplicates, preserves encounter order when present. Do not assume `ArrayList`.
- **[`Set.of` / `Set.copyOf`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Set.html#unmodifiable):** unmodifiable, reject nulls, unspecified encounter order. `of` rejects duplicate arguments with `IllegalArgumentException`; `copyOf` collapses duplicates and may reuse a suitable result.
- **[`Map.of`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Map.html#unmodifiable), `Map.ofEntries`, `Map.copyOf`:** unmodifiable, reject null keys/values, unspecified encounter order. Factories reject duplicate keys with `IllegalArgumentException`; no fresh-allocation guarantee.

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

After the source edit, `live` contains `[draft!, new]`; both copies contain `[draft!]`. Clearing `mutableCopy` leaves the source unchanged. All three originally shared the same first `StringBuilder`.

[`Arrays.asList`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Arrays.html#asList(T...)) does not box primitive arrays: `Arrays.asList(new int[]{1, 2})` is a one-element `List<int[]>`. Use a primitive stream and explicit boxing for a boxed list.

`Map.of` accepts up to ten mappings; `Map.ofEntries` accepts more. `Map.copyOf` does not guarantee `LinkedHashMap` encounter order. For an independent order-preserving copy, use `new LinkedHashSet<>(source)` or `new LinkedHashMap<>(source)`, then wrap if needed. Do not depend on factory object identity or a concrete implementation.

## Sequenced collections {#java-21-sequenced-collections}

[Sequenced collections](https://openjdk.org/jeps/431) provide three interfaces:

- [`SequencedCollection`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/SequencedCollection.html) adds a defined encounter order, `getFirst/getLast`, optional `addFirst/addLast` and `removeFirst/removeLast`, and `reversed()`.
- `SequencedSet` combines that contract with set uniqueness. `LinkedHashSet` implements it; `SortedSet` and therefore `NavigableSet` extend it.
- [`SequencedMap`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/SequencedMap.html) adds `firstEntry/lastEntry`, `pollFirstEntry/pollLastEntry`, optional `putFirst/putLast`, `reversed()`, and sequenced key/value/entry views.

`List` and `Deque` extend `SequencedCollection`; `SortedMap` and `NavigableMap` extend `SequencedMap`. A reference typed only as `Collection`, `Set`, or `Map` does not expose these methods. `EnumSet` and `EnumMap` do not implement these interfaces despite their deterministic iteration order.

On an empty mutable sequenced collection, `getFirst/getLast` and supported `removeFirst/removeLast` throw `NoSuchElementException`. Sequenced-map entry queries/polls return null; sorted `firstKey/lastKey` throw. Unmodifiable mutators can throw even when empty. Endpoint methods guarantee neither O(1) access nor arbitrary positioning.

`reversed()` is a reverse-ordered view: supported mutations write through to the backing structure, with visibility guarantees defined by the implementation. Use `new ArrayList<>(list.reversed())` for independent mutable membership/order.

## Views and traversal

A [view collection](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Collection.html#view) shares backing membership: examples include `subList`, sorted range/descending views, map views, unmodifiable wrappers, and reversed views. Supported removals change the backing structure. A map key set cannot add a key without a value; sorted ranges reject out-of-bounds insertions.

Traversal policies:

- **Best-effort fail-fast:** ordinary array/linked lists and hash/tree/linked collections may throw `ConcurrentModificationException` after unexpected structural changes. This detects bugs; it is not synchronization.
- **Snapshot:** a `CopyOnWriteArrayList` iterator retains its creation-time array, not later membership changes. Elements are still shared references.
- **Weakly consistent:** concurrent queues/deques and hash/skip-list structures, plus non-thread-safe enum collections, need not show one instant. They may reflect changes and do not use fail-fast exceptions to detect them.

A single thread can invalidate its iterator by modifying a collection directly in an enhanced `for` loop. Do not use fail-fast exceptions for retries or infer safety from their absence. Use supported iterator removal after `next()`, a positioned list iterator, or `removeIf`; snapshot iterators cannot mutate. Weak consistency does not make enum collections thread-safe: shared modifications still require coordination.

## Thread-safety boundaries

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

Access the backing collection only through its wrapper. Lock **that wrapper** during iterator, spliterator, or stream traversal; for map views, lock the synchronized **map**, not its `keySet`. Hold the same lock for compound invariants. Derived views retain the original synchronization discipline.

A thread-safe `get` followed by `put` is not an atomic update. Use documented atomic operations for per-key changes; coordinate multi-key invariants and mutable elements separately. A blocking queue [publishes](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/BlockingQueue.html) producer actions before insertion to a consumer after access/removal of that element; later unsynchronized element edits are not covered.

# Arrays

[Java arrays](https://docs.oracle.com/javase/specs/jls/se21/html/jls-10.html) have fixed length, zero-based indices, and one component type. Reference arrays store references. [`Arrays.copyOf`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Arrays.html) allocates another array; it does not grow the original.

New slots hold default values: null for references, zero for `int`. Use arrays for known lengths, unboxed primitive storage, or array-based APIs. `array.length` is a field, unlike collection `size()`. Invalid indices outside `0` through `length - 1` throw `ArrayIndexOutOfBoundsException`.

`Arrays.binarySearch` requires sorting with the same ordering used for search. It returns a matching index or `-(insertionPoint) - 1`; test `index >= 0` for presence. With duplicates, it need not find the first match. Linear search needs no sorting.

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

| Operation      | Time Complexity  |
| -------------- | ---------------- |
| Access         | O(1)             |
| Update         | O(1)             |
| Copy to length m | O(m), including initialization of the new array |
| Sort           | O(n log n)       |
| Search (Binary)| O(log n)         |
| Search (Linear)| O(n)             |

The sort bound describes the documented type-specific implementations, not an identical comparison count for every input. Arrays provide no compound-operation synchronization.

---

# Lists

Lists preserve positions and allow duplicates. Array-backed, linked, and copy-on-write storage have different access and mutation costs.

## ArrayList

[`ArrayList`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/ArrayList.html) is a growable array for indexed sequences. Indexed access/update is O(1); front/middle edits shift later references. Appending is amortized O(1); removing the last element needs no shifting. It is not thread-safe.

Initial capacity creates no elements. `ensureCapacity` can avoid repeated growth for a known bulk load; `trimToSize` releases spare capacity but may make the next append allocate again. The growth factor is not an interface guarantee.

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

For an absent value, `contains` is false and `indexOf` is `-1`. `Collections.min` requires a nonempty collection and an ordering capable of comparing its elements.

For `List<Integer>`, `remove(1)` removes index one; `remove(Integer.valueOf(1))` removes an equal value.

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

Adding first through `reversed()` appends to the original; `set` changes remain visible in reverse. `unmodifiableList` retains `List`'s sequenced API; `unmodifiableSequencedCollection` exposes only that narrower contract. Both are live read-only views.

| Operation | Time Complexity |
| --- | --- |
| `size`, `get`, `set`, `getFirst/getLast` | O(1) |
| `indexOf`, `contains`, `Collections.min/frequency` | O(n) |
| `add` / `addLast` | O(1) amortized; O(n) on growth |
| `add(index, value)` / `addFirst` | O(n) worst case |
| `remove(index)` / `removeFirst` | O(n) worst case |
| `removeLast` | O(1) |
| `addAll` of m elements at end | O(n + m) worst case with growth |
| `sort` | O(n log n) |
| Complete traversal / structural copy | O(n) |

## subList and traversal mutation

[`subList(from, to)`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/List.html#subList(int,int)) is a backed half-open range: `from` included, `to` excluded.

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

Iterator removal must follow `next()` once per element; otherwise it throws `IllegalStateException`. `removeIf` removes all matches and reports whether anything changed. `ArrayList`'s bulk implementation avoids repeated shifting; an iterator-removal loop can cost O(n²) when many front/middle elements are removed.

Do not reuse a sublist after structural backing changes made outside it: its semantics are undefined, not merely “it throws an exception.” `set` is nonstructural. Use `new ArrayList<>(list.subList(from, to))` for independent membership. A small retained view can keep a large backing list reachable.

## LinkedList

[`LinkedList`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/LinkedList.html) implements `List` and `Deque` with linked nodes. Endpoints are O(1); indexed access walks from the nearer end. Repeated `get(i)` can turn traversal into O(n²). It is not thread-safe.

Insertion/removal is O(1) only after an iterator is positioned; indexed insertion includes a search. A cursor supports scan-and-edit workloads:

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

| Operation | Time Complexity |
| --- | --- |
| `get/set/add/remove` at index i | O(1 + min(i, n - i)) locating/mutation cost, O(n) worst case |
| Endpoint `get/add/remove` | O(1) |
| Iterator-positioned `set/add/remove` | O(1) per mutation |
| `contains` / `indexOf` / complete iterator traversal | O(n) |
| `sort` | O(n log n), with temporary storage rather than repeated indexed access |

Nodes require allocation and link maintenance. “Many insertions” does not justify them if every edit starts with an index search. Prefer `ArrayList` for indexing and `ArrayDeque` for non-concurrent stack/queue operations.

## CopyOnWriteArrayList

[`CopyOnWriteArrayList`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/CopyOnWriteArrayList.html) is thread-safe and replaces its backing array on content-changing writes. Read-mostly listener/subscriber registries can traverse without external locking while writers pay for copying.

Iterators retain their creation-time array; later writes are invisible to them. Iterator `remove` and list-iterator `add/set` are unsupported. Frequent writes allocate/copy whole arrays and increase garbage-collection pressure; slow readers can retain old arrays.

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

The iterator prints `first`, `second`; the current list is `[second, third]`. `addIfAbsent` atomically checks and adds, unlike separate `contains`/`add` calls. Ordinary `add` still permits duplicates.

| Operation | Time Complexity |
| --- | --- |
| `get`, `size`, endpoint reads | O(1) |
| Content-changing `add`, `set`, or `remove` | O(n) copying; a no-change call need not copy |
| `contains` / `addIfAbsent` | O(n) comparisons, plus a copy if inserted |
| `sort` | O(n log n), plus replacement-array allocation |
| Iterator creation / complete snapshot traversal | O(1) / O(n) |

---

# Stacks

A stack removes the newest item first: Last-In-First-Out (LIFO).

## ArrayDeque (as Stack)

[`ArrayDeque`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/ArrayDeque.html) is preferred over legacy `Stack` for non-concurrent use. Its growable array makes pushes amortized O(1), with no linked node per push. It is not thread-safe.

`push/pop/peek` mean `addFirst/removeFirst/peekFirst`; iteration runs top-to-bottom. `pop` throws `NoSuchElementException` on empty; `peek` and `pollFirst` return null. Null rejection makes that sentinel unambiguous.

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

| Operation | Time Complexity |
| --------- | --------------- |
| Push      | O(1) Amortized  |
| Peek      | O(1)            |
| Pop       | O(1)            |
| Contains  | O(n)            |
| `size`, `getFirst/getLast` | O(1) |
| `addFirst/addLast` | O(1) amortized |
| `removeFirst/removeLast` | O(1) |
| Complete traversal | O(n) |

## ConcurrentLinkedDeque (as Stack)

[`ConcurrentLinkedDeque`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentLinkedDeque.html) is a thread-safe, non-blocking linked deque with weakly consistent iteration. It is unbounded. Endpoint operations do not wait for items or capacity, but non-blocking does not guarantee bounded completion under contention.

Each insertion allocates a node. `if (!stack.isEmpty()) stack.pop()` races with another remover; use one `pollFirst()` for remove-if-present. Bulk operations are not whole-deque transactions.

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

`size()` traverses the deque and may already be stale on return; do not use it to coordinate consumers.

| Operation | Time Complexity |
| --------- | --------------- |
| Push      | O(1)            |
| Peek      | O(1)            |
| Pop       | O(1)            |
| Contains  | O(n)            |
| `size` / complete traversal | O(n) |

---

# Queues

FIFO order, priority selection, and blocking are separate properties. A blocking queue adds waiting operations to either FIFO or priority ordering.

## Queue operation families

[`Queue`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Queue.html) provides exception/sentinel forms; [`BlockingQueue`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/BlockingQueue.html) adds waiting and timed forms:

- **Insert:** `add(e)` throws `IllegalStateException` when full; `offer(e)` returns `false`. `put(e)` waits; `offer(e, timeout, unit)` returns `false` on timeout.
- **Remove head:** `remove()` throws `NoSuchElementException` when empty; `poll()` returns null. `take()` waits; `poll(timeout, unit)` returns null on timeout.
- **Inspect head:** `element()` throws `NoSuchElementException` when empty; `peek()` returns null. No blocking/timed inspection method.

Sentinel forms still reject invalid input: `offer(null)` throws on a null-rejecting queue. `remove()` removes the head; `remove(value)` searches for an equal element. Deques have corresponding `First`/`Last` families; `push/pop` select the first end.

Plain `offer/poll` do not wait for capacity/data, though they can contend for an internal lock. `put/take` can wait indefinitely; timed methods bound the capacity/data wait, not scheduling delay. Blocking/timed waits are interruptible. Propagate `InterruptedException` or apply an application cancellation policy; if caught without propagation, normally restore interruption with `Thread.currentThread().interrupt()`.

An empty queue is not end-of-stream. These interfaces define no universal `close`; consumers need a finite-work, end-of-stream, or cancellation protocol.

## ArrayDeque (as Queue)

[`ArrayDeque`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/ArrayDeque.html) is an array-backed, non-thread-safe deque. For FIFO, `offer` appends at the tail and `peek/poll` inspect/remove the head. `push` instead inserts at the head for LIFO.

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

`offerFirst/offerLast`, `peekFirst/peekLast`, and `pollFirst/pollLast` select an end; `getFirst/getLast` and `removeFirst/removeLast` throw when empty. `reversed()` swaps the ends in a backed view. Construction capacity does not cap queue length.

| Operation | Time Complexity |
| --------- | --------------- |
| Offer     | O(1) Amortized  |
| Peek      | O(1)            |
| Poll      | O(1)            |
| Contains  | O(n)            |
| Complete traversal / `remove(value)` | O(n) |
| `size` | O(1) |

## PriorityQueue

[`PriorityQueue`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/PriorityQueue.html) is an unbounded array-backed heap. Natural order or a comparator selects the head. Iteration is not sorted; repeated `poll()` calls remove items in priority order. Sorting a copy leaves the queue intact.

It is not thread-safe. Equal-priority ties have no FIFO guarantee; add a tie-breaking key to choose their order. `contains` and `remove(value)` use equality, not comparator equivalence; comparison-zero values are not deduplicated.

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

| Operation | Time Complexity |
| --- | --- |
| `offer` / `add` | O(log n) amortized heap work; occasional O(n) array growth |
| `peek` / `element` / `size` | O(1) |
| `poll` / head `remove()` | O(log n) |
| `contains` / `remove(value)` | O(n) search |
| Unordered traversal | O(n) |
| Sorted copy / complete priority drain | O(n log n), plus O(n) storage for a copy |

The heap maintains enough order to select the next priority item without keeping a fully sorted list. Its array capacity grows as needed.

## ConcurrentLinkedQueue

[`ConcurrentLinkedQueue`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentLinkedQueue.html) is a thread-safe, non-blocking FIFO using linked nodes and compare-and-set. It has no capacity limit or waiting retrieval; polling an empty queue is not a blocking consumer protocol.

Traversal is weakly consistent; bulk operations are not atomic.

```java
Queue<String> queue = new ConcurrentLinkedQueue<>();

queue.offer("message");
String msg = queue.poll();

// Iteration
queue.forEach(System.out::println);
for (String s : queue) { System.out.println(s); }
```

Use the `poll()` result rather than a separate `isEmpty` check. Linked storage allocates nodes as items arrive, and an unbounded backlog can exhaust memory.

| Operation | Time Complexity |
| --------- | --------------- |
| Offer     | O(1)            |
| Poll      | O(1)            |
| Contains  | O(n)            |
| `peek` | O(1) usual uncontended structural work |
| `size` / complete traversal | O(n) |

`size()` traverses and can be inaccurate during mutation; it is not a synchronization condition.


## ArrayBlockingQueue

[`ArrayBlockingQueue`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ArrayBlockingQueue.html) is a thread-safe FIFO with fixed capacity. It reserves array storage up front rather than allocating nodes per item. The hard element-count limit provides backpressure.

Optional fairness serves waiting producers/consumers in FIFO order, usually at a throughput cost; it does not guarantee end-to-end task scheduling fairness.

```java
BlockingQueue<String> queue = new ArrayBlockingQueue<>(100);

// Producer-Consumer Operations
queue.put("task");                  // Blocks if full
String item = queue.take();         // Blocks if empty

// Iteration
queue.forEach(System.out::println);
for (String s : queue) { System.out.println(s); }
```

A capacity-one queue exercises the full/empty outcomes:

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

Handle a failed offer or work is lost. `remainingCapacity` observes space; it does not reserve it against another producer.

| Operation | Time Complexity |
| --------- | --------------- |
| Put/Offer | O(1)            |
| Take/Poll | O(1)            |
| Contains  | O(n)            |
| `peek`, `size`, `remainingCapacity` | O(1) |
| `remove(value)` / complete traversal | O(n) |

## LinkedBlockingQueue

[`LinkedBlockingQueue`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/LinkedBlockingQueue.html) is an optionally bounded FIFO blocking queue. Omitted capacity means `Integer.MAX_VALUE`; supply a smaller bound for backpressure. Linked storage is allocated as items arrive rather than reserving an entire element array up front.

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

| Operation | Time Complexity |
| --------- | --------------- |
| Put/Offer | O(1)            |
| Take/Poll | O(1)            |
| Contains  | O(n)            |
| `peek`, `size`, `remainingCapacity` | O(1) |
| `remove(value)` / complete traversal | O(n) |

## PriorityBlockingQueue

[`PriorityBlockingQueue`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/PriorityBlockingQueue.html) is an unbounded concurrent heap with `PriorityQueue` ordering rules. Iterators are weakly consistent and unsorted. `take` waits when empty; `put` and even timed `offer` do not wait for capacity. There is no capacity-based backpressure.

Initial capacity is an allocation hint. `remainingCapacity()` is `Integer.MAX_VALUE`, not available memory; an unbounded backlog can exhaust memory.

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

| Operation | Time Complexity |
| --- | --- |
| `put` / `offer` | O(log n) amortized heap work, occasional O(n) growth |
| `take` / `poll` | O(log n), excluding any wait for an element |
| `peek` / `size` | O(1) |
| `contains` / `remove(value)` | O(n) |
| Unordered traversal | O(n) |
| Complete priority drain | O(n log n) |

---

# Sets

## HashSet

[`HashSet`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/HashMap.html) is backed by a `HashMap`, with unspecified encounter order. It is not thread-safe.

`add`/`remove` report membership changes. Capacity/load factor affect bucket storage, collisions, and resizing, not maximum size. [`HashSet.newHashSet(expectedElements)`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/HashSet.html#newHashSet(int)) sizes for an expected count.

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

| Operation | Expected Time Complexity |
| --------- | ------------------------ |
| Add       | O(1) Amortized           |
| Remove    | O(1)                     |
| Contains  | O(1)                     |
| `size` | O(1) |
| Complete traversal / copy by traversal | O(n + capacity) |

The bucket array can retain spare capacity after removals.

## TreeSet

[`TreeSet`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/TreeSet.html) is a `TreeMap`-backed `NavigableSet` for sorted ranges and nearest-neighbor queries. It uses natural order or a comparator and is not thread-safe.

`lower/higher` are strict neighbors; `floor/ceiling` include equality. All return null when no candidate exists. `first/last` and `getFirst/getLast` throw when empty; `pollFirst/pollLast` remove endpoints or return null. With a null-friendly comparator, a null result can also be a stored element.

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

`subSet(5, true, 15, true)` includes both bounds; `headSet`/`tailSet` give one-sided views. Supported removals, `clear`, and in-range additions change the backing set. Inserting `30` through this subset throws `IllegalArgumentException`.

`descendingSet()` and `reversed()` are backed reverse-order views. `addFirst/addLast` throw `UnsupportedOperationException`: implementing `SequencedSet` does not override comparator positioning.

`new TreeSet<>(subset)` gives independent membership, preserving the view's comparator through the sorted-set constructor.

| Operation | Time Complexity |
| --- | --- |
| `add`, `remove`, `contains` | O(log n) |
| `lower/higher/floor/ceiling` | O(log n) |
| `first/last`, `getFirst/getLast`, endpoint removal | O(log n) |
| Complete traversal | O(n) |

Tree nodes store navigation links and balancing information. Updates maintain sorted order rather than an indexed array or hash-only membership.

## LinkedHashSet

[`LinkedHashSet`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/LinkedHashSet.html) adds encounter-order links to a hash set. It defaults to insertion order and is not thread-safe. Ordinary `add` of an existing element returns `false` without moving it; sequenced methods can reposition it.

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

`addFirst("m")` and `addLast("m")` move the existing element without changing membership. Adding first through `reversed()` appends to the original. `unmodifiableSequencedSet` is live: it sees the later `"x"` but rejects mutations. Linked order provides neither sorting nor indexed access.

| Operation | Expected Time Complexity |
| --------- | ------------------------ |
| Add       | O(1) Amortized           |
| Remove    | O(1)                     |
| Contains  | O(1)                     |
| `getFirst/getLast`, `size` | O(1) |
| `addFirst/addLast` | O(1) expected amortized |
| `removeFirst/removeLast` | O(1) expected |
| Complete traversal | O(n), independent of bucket capacity |

Encounter-order links add storage and maintenance but avoid scanning unused hash capacity during iteration.

## EnumSet

[`EnumSet`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/EnumSet.html) is a mutable bit-vector set for one enum type, a type-safe alternative to integer flag masks. Iteration follows enum declaration order, not insertion order. It does not implement `SequencedSet`.

`noneOf(Type.class)` creates an empty typed set; `allOf` selects every constant; `of` selects specific constants; `range` selects an inclusive declaration-order range. `complementOf` uses the enum's entire universe, not an application-defined subset.

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

With enum-set operands, `addAll`, `retainAll`, and `removeAll` implement union, intersection, and difference on bit vectors. `saved` has independent membership.

Null insertion throws `NullPointerException`; testing/removing null returns `false`. `EnumSet.copyOf` cannot infer a type from an empty ordinary collection and throws `IllegalArgumentException`; an empty `EnumSet` retains its type and can be copied. Use `noneOf` for empty external input.

| Operation | Cost model |
| --- | --- |
| `add`, `remove`, `contains`, `size` | O(1) basic operations |
| Enum-set bulk operations, complement, copy | Bit-vector work; scales with the enum universe's representation, not a hash table |
| Complete traversal | At most O(u), where u is the number of constants in the enum |

For a fixed enum type, its universe and bit-vector width are fixed, hence the constant-time basic operations.

## ConcurrentHashSet (via ConcurrentHashMap)

There is no standalone `ConcurrentHashSet` class. [`ConcurrentHashMap.newKeySet()`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentHashMap.html#newKeySet()) creates a concurrent set with unspecified encounter order and weakly consistent traversal.

`add` atomically tests and inserts; use its boolean result instead of separate `contains`/`add` calls. This protects one membership change, not a multi-element transaction.

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

| Operation | Expected Time Complexity |
| --------- | ------------------------ |
| Add       | O(1) Amortized           |
| Remove    | O(1)                     |
| Contains  | O(1)                     |
| Complete traversal | O(n + backing capacity), excluding concurrent changes |

`newKeySet` supports insertion; ordinary `map.keySet()` cannot add a key without a value. `ConcurrentHashMap.keySet(mappedValue)` explicitly supplies that value for additions.

## ConcurrentSkipListSet

[`ConcurrentSkipListSet`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentSkipListSet.html) is a concurrent sorted `NavigableSet` backed by a skip list. Use it for concurrent range/navigation queries rather than unordered hash membership.

Bulk operations are not necessarily atomic. `size()` traverses and may be inaccurate during mutation. Ascending traversal is generally faster than descending.

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

Range, descending, and reversed views are backed and sorted, not snapshots. `addFirst/addLast` remain unsupported: the comparator determines position.

| Operation | Expected Average Time Complexity |
| --------- | -------------------------------- |
| Add       | O(log n)                         |
| Remove    | O(log n)                         |
| Contains  | O(log n)                         |
| Navigation / endpoint removal | O(log n) expected |
| `size` / complete traversal | O(n) |

Skip-list nodes and index links add allocation costs for concurrent sorted access.

---

# Maps

[`keySet`, `values`, and `entrySet`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Map.html#keySet()) are backed views: supported `remove`/`clear` delete mappings, while additions are unsupported. Removing from `values` deletes one matching mapping, not all equal-valued mappings. Entry iteration may support `entry.setValue`; endpoint entry queries instead return unmodifiable mapping snapshots.

## HashMap

[`HashMap`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/HashMap.html) uses a hash table with expected O(1) lookup and amortized insertion. It is not thread-safe and has no encounter-order guarantee.

Here `capacity` means bucket count. [`HashMap.newHashMap(expectedMappings)`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/HashMap.html#newHashMap(int)) sizes for an expected mapping count; `new HashMap<>(count)` takes an initial capacity instead. Neither caps size.

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

`put`/`remove` return the previous value, or null with the ambiguity below. Replacing a value does not increase map size.

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

`get` returns null for both absent and null-valued keys; `containsKey` distinguishes them. `getOrDefault` uses its default only for absence, not a mapped null. `putIfAbsent` treats null as absent. Unboxing a nullable `Integer` into `int` can throw `NullPointerException`.

The [`Map` functional-update contracts](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Map.html) distinguish:

- `computeIfPresent`: skip absent/null values; a null callback result removes the mapping.
- `computeIfAbsent`: compute for absent/null values; a null result installs nothing.
- `merge`: use the supplied non-null value for absent/null mappings, otherwise combine with the existing value; a null remapping result removes the mapping.
- Conditional `replace`/`remove`: return whether the expected-value condition matched.

| Operation     | Expected Time Complexity |
| ------------- | ------------------------ |
| Put           | O(1) Amortized           |
| Get           | O(1)                     |
| Remove        | O(1)                     |
| ContainsKey   | O(1)                     |
| ContainsValue | O(n + capacity)          |
| `putIfAbsent`, conditional remove/replace, compute/merge | Expected O(1) lookup/update plus callback cost; insertion can resize |
| `size` | O(1) |
| Complete traversal | O(n + capacity) |

Do not structurally modify the same map from a computation callback.

## TreeMap

[`TreeMap`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/TreeMap.html) is a red-black-tree `NavigableMap` for key ranges and nearest-key searches. Keys, not values, determine natural/comparator order; [comparator equivalence](#equality-hashing-and-sorted-equivalence) determines uniqueness. It is not thread-safe.

`lowerKey/higherKey` are strict neighbors; `floorKey/ceilingKey` include equality. Corresponding `*Entry` methods return mapping snapshots or null if no candidate exists. `firstKey/lastKey` throw when empty; `firstEntry/lastEntry` and endpoint polls return null.

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

The range edits produce `{B=2, C=3, D=4}` in the original, while `sub` sees `{B=2, C=3}` and rejects out-of-range D with `IllegalArgumentException`. `putFirst/putLast` throw `UnsupportedOperationException` because keys stay sorted. The saved entry remains `B=2` after the backing value becomes `20`: endpoint entries are snapshots.

Bounds apply to insertions and nested views. Unlike an invalidated list `subList`, sorted ranges continue tracking their key range after outside backing changes; an active ordinary iterator can still fail fast. `new TreeMap<>(sub)` copies membership and retains its comparator. `descendingMap()` and `reversed()` are backed reverse-order views.

| Operation     | Time Complexity |
| ------------- | --------------- |
| Put           | O(log n)        |
| Get           | O(log n)        |
| Remove        | O(log n)        |
| ContainsKey   | O(log n)        |
| ContainsValue | O(n)            |
| Nearest-key/entry lookup, endpoint query/removal | O(log n) |
| Complete traversal | O(n) |

Red-black-tree nodes require navigation links and balancing state. Hashing avoids maintaining sorted order when only equality lookup is needed.

## LinkedHashMap

[`LinkedHashMap`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/LinkedHashMap.html) adds encounter-order links to a hash table. The default is insertion order; ordinary `put` of an existing key keeps its position. `accessOrder = true` instead orders entries from least to most recently accessed. It is not thread-safe.

Access order does not supply eviction. Initial capacity is not a size limit: override `removeEldestEntry` or explicitly remove the first entry for that policy. In access order, even `get` can change order and invalidate an iterator. Access through a reversed map moves the entry to the backing map's most-recent end—the reversed view's first end.

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

`get("one")` changes order from `[one, two]` to `[two, one]`. Key/value/entry-view operations do not count as accesses. `putFirst/putLast` position directly rather than generating an access.

Two-entry LRU eviction:

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

Accessing one makes two eldest; adding three evicts two. This limits element count, not bytes. Shared use requires synchronization of the complete access/eviction protocol.

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

`putFirst/putLast` update and reposition existing keys. Adding first through the reversed map appends to the original.

`sequencedKeySet()` and `sequencedEntrySet()` are `SequencedSet` views; `sequencedValues()` is a `SequencedCollection` because values can repeat. Removals delete mappings; adding/positioning mappings through these collection views is unsupported.

`firstEntry`, `lastEntry`, `pollFirstEntry`, and `pollLastEntry` return unmodifiable shallow snapshots. This implementation supports write-through `entry.setValue` during `entrySet` iteration, but `sequencedEntrySet().getFirst()` has no portable write-through guarantee. `unmodifiableSequencedMap` is live and also protects its exposed entries/views.

| Operation     | Expected Time Complexity |
| ------------- | ------------------------ |
| Put           | O(1) Amortized           |
| Get           | O(1)                     |
| Remove        | O(1)                     |
| ContainsKey   | O(1)                     |
| ContainsValue | O(n)                     |
| `firstEntry / lastEntry` / `size` | O(1) |
| `putFirst / putLast` | O(1) expected amortized |
| `pollFirstEntry / pollLastEntry` | O(1) expected |
| Complete traversal | O(n), independent of bucket capacity |

Encounter-order links add storage/maintenance beyond `HashMap` but avoid scanning spare buckets during iteration.

## EnumMap

[`EnumMap`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/EnumMap.html) is a mutable map for one enum key type. Array-based storage avoids general-purpose hashing; iteration follows declaration order. Use it for enum-indexed counters, dispatch tables, or settings. It does not implement `SequencedMap`.

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

`new EnumMap<>(counts)` copies membership and value references independently of later mapping changes.

Null-key insertion throws `NullPointerException`; null-key queries/removals treat it as absent. Null values follow the [HashMap lookup rules](#hashmap). The enum-class constructor works for empty maps; an empty ordinary `Map` cannot supply the key type and causes `IllegalArgumentException`. An empty `EnumMap` retains its type and can be copied.

| Operation | Time Complexity |
| --- | --- |
| `put`, `get`, `remove`, `containsKey`, `size` | O(1) |
| Functional single-key update | O(1) map work plus callback |
| Construction/copy, `clear`, `containsValue`, complete traversal | O(u) worst case, where u is the enum key universe |

Storage is sized for the enum universe even when few mappings are populated.

## ConcurrentHashMap

[`ConcurrentHashMap`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentHashMap.html) is a thread-safe hash table with generally non-blocking retrievals. Synchronizing on the map object does not prevent other callers accessing it.

Use `putIfAbsent`, conditional `remove/replace`, `compute`, or `merge` for atomic per-key changes; separate calls are not atomic together. Multi-key invariants need separate coordination. Weakly consistent traversal and aggregate queries (`size`, `isEmpty`, `containsValue`) can observe transient states.

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

An absent counter needs a null check before unboxing: `map.compute("requests", (key, value) -> value == null ? 1 : value + 1)`. The entire `ConcurrentHashMap.compute` invocation is atomic, with one callback invocation—not one initialization for the key's lifetime. Keep callbacks short and do not update the same map inside them; other updates can block while they run. Other `ConcurrentMap` implementations have different callback guarantees.

| Operation     | Expected Time Complexity |
| ------------- | ------------------------ |
| Put           | O(1) Amortized           |
| Get           | O(1)                     |
| Remove        | O(1)                     |
| ContainsKey   | O(1)                     |
| ContainsValue | O(n + capacity)          |
| Per-key conditional update / compute/merge | Expected O(1) map work plus callback; contention can delay updates |
| Complete weakly consistent traversal | O(n + capacity), excluding concurrent growth/change |

Null rejection makes `get` returning null unambiguously absent; a later call can observe a different state. Copying during writes is not a whole-map snapshot. Presizing reduces resizing/allocation work; it does not cap size.

## ConcurrentSkipListMap

[`ConcurrentSkipListMap`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentSkipListMap.html) is a concurrent skip-list `NavigableMap` for sorted key ranges and navigation.

Ascending views/iterators are generally faster than descending ones. Range, descending, and reversed/sequenced views are backed and concurrent, not snapshots. `putFirst/putLast` are unsupported because the comparator determines position. All entries from this implementation and its views are unmodifiable mapping snapshots; use map updates instead of `Entry.setValue`.

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

Unlike `ConcurrentHashMap`, this implementation [does not guarantee a single computation/remapping callback invocation](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentSkipListMap.html#compute(K,java.util.function.BiFunction)): contention can cause repeated calls. Keep callbacks free of externally visible side effects. Conditional updates protect one key; bulk operations such as `putAll`, `clear`, and `containsValue` are not whole-map atomic operations.

| Operation     | Expected Average Time Complexity |
| ------------- | -------------------------------- |
| Put           | O(log n)                         |
| Get           | O(log n)                         |
| Remove        | O(log n)                         |
| ContainsKey   | O(log n)                         |
| ContainsValue | O(n)                             |
| Nearest-key/entry navigation, endpoint removal | O(log n) expected |
| Complete traversal | O(n), excluding concurrent changes |

Skip-list nodes and index links add allocation/comparison costs for concurrent sorted navigation.

---
