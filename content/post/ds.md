---
title: "DS - Data Structures"
description: "Data Structures in Java."
date: 2024-09-26T12:00:00+01:00
draft: false
---

Overview of the most commonly used data structures from both the Java Collections API and the Java Concurrent API.

**Note**: you can use the following to make collections thread-safe:

```java
List<String> list = Collections.synchronizedList(new ArrayList<>());
Set<Integer> set = Collections.synchronizedSet(new HashSet<>());
Map<String, Integer> map = Collections.synchronizedMap(new HashMap<>());
```

But you should prefer specialized collections from Java Concurrent API.

# Arrays

Fixed-size, contiguous memory structures that store elements of the same type. They provide high-performance random access via zero-based indexing but require manual resizing if capacity is exceeded.

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
boolean exists = Arrays.stream(numbers).anyMatch(n -> n == 3);

// Iteration
Arrays.stream(numbers).forEach(System.out::println);
for (int num : numbers) { System.out.println(num); }
```

| Operation      | Time Complexity  |
| -------------- | ---------------- |
| Access         | O(1)             |
| Update         | O(1)             |
| Copy           | O(n)             |
| Sort           | O(n log n)       |
| Search (Binary)| O(log n)         |
| Search (Linear)| O(n)             |

---

# Lists

## ArrayList

A dynamic array implementation that grows as needed. It offers fast random access and is efficient for adding/removing elements at the end, though inserting in the middle requires shifting elements.

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

| Operation | Time Complexity |
| --------- | --------------- |
| Get       | O(1)            |
| IndexOf   | O(n)            |
| Add       | O(1) Amortized  |
| Remove    | O(n)            |
| Contains  | O(n)            |
| Sort      | O(n log n)      |

## CopyOnWriteArrayList

A thread-safe variant of `ArrayList` where all mutative operations are implemented by making a fresh copy of the underlying array. It is ideal for scenarios where reads vastly outnumber writes and for thread-safe iteration without locking.

```java
List<String> list = new CopyOnWriteArrayList<>();

// Write operations (clones the array)
list.add("event1");
list.add("event2");

// Read operations (lock-free on snapshot)
String event = list.get(0);

// Sorting
list.sort(Comparator.naturalOrder());

// Iteration
list.forEach(System.out::println);
for (String s : list) { System.out.println(s); }
```

| Operation | Time Complexity |
| --------- | --------------- |
| Get       | O(1)            |
| Add       | O(n)            |
| Remove    | O(n)            |
| Contains  | O(n)            |
| Sort      | O(n log n)      |

---

# Stacks

## ArrayDeque (as Stack)

A linear collection that supports Last-In-First-Out (LIFO) semantics. `ArrayDeque` is the preferred implementation over the legacy `Stack` class as it is faster and not synchronized.

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
```

| Operation | Time Complexity |
| --------- | --------------- |
| Push      | O(1)            |
| Peek      | O(1)            |
| Pop       | O(1)            |
| Contains  | O(n)            |

## ConcurrentLinkedDeque (as Stack)

A thread-safe, non-blocking LIFO implementation using efficient CAS (Compare-And-Swap) operations. It is the preferred way to implement a concurrent stack in Java.

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

| Operation | Time Complexity |
| --------- | --------------- |
| Push      | O(1)            |
| Peek      | O(1)            |
| Pop       | O(1)            |
| Contains  | O(n)            |

---

# Queues

## ArrayDeque (as Queue)

A Double-Ended Queue (Deque) implementation that supports First-In-First-Out (FIFO) access. It is optimized for adding and removing elements from both ends with constant time performance.

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

| Operation | Time Complexity |
| --------- | --------------- |
| Offer     | O(1)            |
| Peek      | O(1)            |
| Poll      | O(1)            |
| Contains  | O(n)            |

## PriorityQueue

An unbounded priority queue based on a priority heap. Elements are ordered according to their natural ordering or by a `Comparator` provided at construction time.

```java
// Natural order (Min-Heap)
PriorityQueue<Integer> pq = new PriorityQueue<>();

// Custom order (Max-Heap)
PriorityQueue<Integer> maxPq = new PriorityQueue<>(Collections.reverseOrder());

// Priority Operations
pq.offer(15);
pq.offer(5);
Integer top = pq.peek();
Integer removed = pq.poll();

// Iteration
pq.forEach(System.out::println);
for (Integer i : pq) { System.out.println(i); }

// Conversion (Sorted)
List<Integer> sorted = pq.stream().sorted().toList();
```

| Operation | Time Complexity |
| --------- | --------------- |
| Offer     | O(log n)        |
| Peek      | O(1)            |
| Poll      | O(log n)        |
| Contains  | O(n)            |

## ConcurrentLinkedQueue

A thread-safe, non-blocking FIFO queue using efficient CAS (Compare-And-Swap) algorithms. It is designed for high-performance, low-latency message passing.

```java
Queue<String> queue = new ConcurrentLinkedQueue<>();

queue.offer("message");
String msg = queue.poll();

// Iteration
queue.forEach(System.out::println);
for (String s : queue) { System.out.println(s); }
```

| Operation | Time Complexity |
| --------- | --------------- |
| Offer     | O(1)            |
| Poll      | O(1)            |
| Contains  | O(n)            |


## ArrayBlockingQueue

A thread-safe, bounded blocking queue backed by an array. It is ideal for producer-consumer scenarios where backpressure is required to prevent memory exhaustion.

```java
BlockingQueue<String> queue = new ArrayBlockingQueue<>(100);

// Producer-Consumer Operations
queue.put("task");                  // Blocks if full
String item = queue.take();         // Blocks if empty

// Iteration
queue.forEach(System.out::println);
for (String s : queue) { System.out.println(s); }
```

| Operation | Time Complexity |
| --------- | --------------- |
| Put/Offer | O(1)            |
| Take/Poll | O(1)            |
| Contains  | O(n)            |

## LinkedBlockingQueue

An optionally-bounded blocking queue based on linked nodes. It typically has higher throughput than `ArrayBlockingQueue` because it uses two separate locks for put and take operations.

```java
BlockingQueue<String> queue = new LinkedBlockingQueue<>();

queue.put("data");
String data = queue.take();

// Iteration
queue.forEach(System.out::println);
for (String s : queue) { System.out.println(s); }
```

| Operation | Time Complexity |
| --------- | --------------- |
| Put/Offer | O(1)            |
| Take/Poll | O(1)            |
| Contains  | O(n)            |

## PriorityBlockingQueue

An unbounded concurrent queue that uses the same priority ordering rules as `PriorityQueue` but with thread-safety and blocking operations.

```java
BlockingQueue<Integer> pq = new PriorityBlockingQueue<>();

pq.put(50);
pq.put(10);
Integer min = pq.take();

// Iteration
pq.forEach(System.out::println);
for (Integer i : pq) { System.out.println(i); }
```

| Operation | Time Complexity |
| --------- | --------------- |
| Put/Offer | O(log n)        |
| Take/Poll | O(log n)        |
| Contains  | O(n)            |

---

# Sets

## HashSet

A set implementation backed by a `HashMap`. It makes no guarantees about the iteration order of the set and allows for `null` elements. Ideal for fast uniqueness checks.

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

| Operation | Time Complexity |
| --------- | --------------- |
| Add       | O(1) Amortized  |
| Remove    | O(1) Amortized  |
| Contains  | O(1) Amortized  |

## TreeSet

A `NavigableSet` implementation based on a `TreeMap`. Elements are kept in their natural sorted order or according to a specified `Comparator`.

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
```

| Operation | Time Complexity |
| --------- | --------------- |
| Add       | O(log n)        |
| Remove    | O(log n)        |
| Contains  | O(log n)        |

## LinkedHashSet

A `HashSet` that maintains a doubly-linked list running through all of its entries. This defines the iteration ordering, which is the order in which elements were inserted into the set.

```java
Set<String> set = new LinkedHashSet<>();
set.add("z");
set.add("a");
set.add("m");
set.remove("a");
boolean exists = set.contains("z");

// Iteration
set.forEach(System.out::println);
for (String s : set) { System.out.println(s); }
```

| Operation | Time Complexity |
| --------- | --------------- |
| Add       | O(1) Amortized  |
| Remove    | O(1) Amortized  |
| Contains  | O(1) Amortized  |

## ConcurrentHashSet (via ConcurrentHashMap)

Java does not have a standalone `ConcurrentHashSet` class. Instead, the standard way to create a high-performance concurrent set is using the `newKeySet()` method from `ConcurrentHashMap`.

```java
Set<String> set = ConcurrentHashMap.newKeySet();

set.add("concurrent-item");
boolean exists = set.contains("concurrent-item");

// Iteration
set.forEach(System.out::println);
for (String s : set) { System.out.println(s); }
```

| Operation | Time Complexity |
| --------- | --------------- |
| Add       | O(1) Amortized  |
| Remove    | O(1) Amortized  |
| Contains  | O(1) Amortized  |

## ConcurrentSkipListSet

A scalable concurrent `NavigableSet` implementation based on a Skip List. It is the concurrent alternative to `TreeSet`, keeping elements sorted while allowing multiple threads to access and modify the set.

```java
NavigableSet<Integer> set = new ConcurrentSkipListSet<>();

set.add(30);
set.add(10);
Integer first = set.first();

// Iteration
set.forEach(System.out::println);
for (Integer i : set) { System.out.println(i); }
```

| Operation | Time Complexity |
| --------- | --------------- |
| Add       | O(log n)        |
| Remove    | O(log n)        |
| Contains  | O(log n)        |

---

# Maps

## HashMap

A hash table-based implementation of the `Map` interface. It provides constant-time performance for basic operations like `get` and `put`, assuming a good hash function that disperses elements properly.

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

| Operation     | Time Complexity |
| ------------- | --------------- |
| Put           | O(1) Amortized  |
| Get           | O(1) Amortized  |
| Remove        | O(1) Amortized  |
| ContainsKey   | O(1) Amortized  |
| ContainsValue | O(n)            |

## TreeMap

A red-black tree-based `NavigableMap` implementation. The map is sorted according to the natural ordering of its keys or by a `Comparator` provided at map creation time.

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
```

| Operation     | Time Complexity |
| ------------- | --------------- |
| Put           | O(log n)        |
| Get           | O(log n)        |
| Remove        | O(log n)        |
| ContainsKey   | O(log n)        |
| ContainsValue | O(n)            |

## LinkedHashMap

A `HashMap` that maintains a doubly-linked list through its entries, enabling predictable iteration order (typically insertion-order or access-order).

```java
int size = 16;
float loadFactor = 0.75f;
boolean LRU = true;

Map<String, Integer> map = new LinkedHashMap<>(size, loadFactor, LRU);
map.put("one", 1);
map.put("two", 2);
map.get("one");
map.remove("two");
boolean containsK = map.containsKey("one");
boolean containsV = map.containsValue(1);

// Iteration
map.forEach((k, v) -> System.out.println(k + ": " + v));
for (Map.Entry<String, Integer> entry : map.entrySet()) {
    System.out.println(entry.getKey() + ": " + entry.getValue());
}
```

| Operation     | Time Complexity |
| ------------- | --------------- |
| Put           | O(1) Amortized  |
| Get           | O(1) Amortized  |
| Remove        | O(1) Amortized  |
| ContainsKey   | O(1) Amortized  |
| ContainsValue | O(n)            |

## ConcurrentHashMap

A highly concurrent hash table. Unlike `synchronizedMap`, it does not lock the entire table. Modern versions use CAS (Compare-And-Swap) and node-level locking to allow many threads to perform operations simultaneously.

```java
Map<String, Integer> map = new ConcurrentHashMap<>();

map.put("key", 1);
map.putIfAbsent("key", 2);
map.compute("key", (k, v) -> v + 1);

// Iteration (Safe during modification)
map.forEach((k, v) -> System.out.println(k + ": " + v));
for (Map.Entry<String, Integer> entry : map.entrySet()) {
    System.out.println(entry.getKey() + ": " + entry.getValue());
}
```

| Operation     | Time Complexity |
| ------------- | --------------- |
| Put           | O(1) Amortized  |
| Get           | O(1) Amortized  |
| Remove        | O(1) Amortized  |
| ContainsKey   | O(1) Amortized  |
| ContainsValue | O(n)            |

## ConcurrentSkipListMap

A scalable concurrent `NavigableMap` implementation. It provides concurrent sorted access and is the thread-safe alternative to `TreeMap`.

```java
NavigableMap<String, Integer> map = new ConcurrentSkipListMap<>();

map.put("Z", 26);
map.put("A", 1);
String first = map.firstKey();

// Iteration
map.forEach((k, v) -> System.out.println(k + ": " + v));
for (Map.Entry<String, Integer> entry : map.entrySet()) {
    System.out.println(entry.getKey() + ": " + entry.getValue());
}
```

| Operation     | Time Complexity |
| ------------- | --------------- |
| Put           | O(log n)        |
| Get           | O(log n)        |
| Remove        | O(log n)        |
| ContainsKey   | O(log n)        |
| ContainsValue | O(n)            |

---
