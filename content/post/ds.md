---
title: "DS - Data Structures"
description: "Data Structures in Java."
date: 2024-09-26T12:00:00+01:00
draft: false
---

Overview of the most useful data structures from the Java Collections API

**Note**: In order to make any of the following collections thread safe, you can use:

```java
List<String> list = Collections.synchronizedList(new ArrayList<>());
Set<Integer> set = Collections.synchronizedSet(new HashSet<>());
Map<String, Integer> map = Collections.synchronizedMap(new HashMap<>());
```

---

# Arrays

The simplest data structure. Fixed size, fast access.

```java
String[] array = new String[10];
int n = array.length;

String element = array[0];
array[0] = "hello";

Arrays.sort(array);
Arrays.sort(array, Collections.reverseOrder());
Arrays.sort(array, (e1, e2) -> e1.compareTo(e2));

int index = Arrays.binarySearch(array, "hello");
```

| Operation | Time Complexity |
| --------- | --------------- |
| Access    | O(1)            |
| Update    | O(1)            |
| Iteration | O(n)            |

---

# Lists

## ArrayList

Resizable array. Fast random access, slow inserts/removes except at end.

```java
ArrayList<String> list = new ArrayList<>();
int n = list.size();

list.add("apple");
list.add(0, "banana");
list.addAll(Arrays.asList("cat", "dog"));
list.addAll(1, Arrays.asList("egg", "fish"));

String element = list.get(0);
String removed = list.remove(0);
list.clear();

boolean isEmpty = list.isEmpty();
boolean contains = list.contains("apple");
int index = list.indexOf("apple");

String min = Collections.min(list);
String max = Collections.max(list);

int count = Collections.frequency(list, "apple");

Collections.sort(list);
Collections.sort(list, Collections.reverseOrder());
Collections.sort(list, (e1, e2) -> e1.compareTo(e2));

int foundIndex = Collections.binarySearch(list, "apple");

Collections.shuffle(list);
```

| Operation | Time Complexity |
| --------- | --------------- |
| Get       | O(1)            |
| IndexOf   | O(n)            |
| Add       | O(1) (amortized)|
| Remove    | O(n)            |
| Iteration | O(n)            |

---

# Stacks

## ArrayDeque (as Stack)

LIFO structure. Prefer over `Stack` class.

```java
ArrayDeque<Integer> stack = new ArrayDeque<>();

stack.push(10);
Integer top = stack.peek();
Integer popped = stack.pop();

boolean isEmpty = stack.isEmpty();
int size = stack.size();
```

| Operation | Time Complexity |
| --------- | --------------- |
| Push      | O(1)            |
| Peek      | O(1)            |
| Pop       | O(1)            |

---

# Queues

## ArrayDeque (as Queue)

FIFO structure.

```java
ArrayDeque<String> queue = new ArrayDeque<>();

queue.offer("first");
String head = queue.peek();
String removed = queue.poll();

boolean isEmpty = queue.isEmpty();
int size = queue.size();
```

| Operation | Time Complexity |
| --------- | --------------- |
| Offer     | O(1)            |
| Peek      | O(1)            |
| Poll      | O(1)            |

## PriorityQueue

Heap-based queue for prioritized elements.

```java
PriorityQueue<Integer> pq = new PriorityQueue<>();
PriorityQueue<Integer> pqDesc = new PriorityQueue<>(Collections.reverseOrder());
PriorityQueue<Integer> pqCustom = new PriorityQueue<>((a, b) -> Integer.compare(a, b));

pq.offer(5);
Integer head = pq.peek();
Integer removed = pq.poll();

boolean isEmpty = pq.isEmpty();
boolean contains = pq.contains(5);
int size = pq.size();
```

| Operation | Time Complexity |
| --------- | --------------- |
| Offer     | O(log n)        |
| Peek      | O(1)            |
| Poll      | O(log n)        |

---

# Sets

## HashSet

Unordered, unique elements. Backed by a hash table.

```java
HashSet<String> set = new HashSet<>();
set.add("apple");
set.remove("apple");
set.clear();

boolean isEmpty = set.isEmpty();
boolean contains = set.contains("apple");
int n = set.size();
```

| Operation | Time Complexity                              |
| --------- | -------------------------------------------- |
| Add       | O(1) (degrades to O(n) with hash collisions) |
| Remove    | O(1) (degrades to O(n) with hash collisions) |
| Contains  | O(1) (degrades to O(n) with hash collisions) |
| Iteration | O(n)                                         |

## TreeSet

Sorted, unique elements. Backed by a red-black tree.

```java
TreeSet<Integer> set = new TreeSet<>();
TreeSet<Integer> setDesc = new TreeSet<>(Collections.reverseOrder());
TreeSet<Integer> setCustom = new TreeSet<>((a, b) -> Integer.compare(a, b));

set.add(10);
Integer first = set.first();
Integer last = set.last();
Integer before = set.lower(10);
Integer after = set.higher(10);

set.remove(10);
set.clear();

SortedSet<Integer> sub = set.subSet(1, true, 5, true);
SortedSet<Integer> tail = set.tailSet(3, true);
SortedSet<Integer> head = set.headSet(7, true);

boolean isEmpty = set.isEmpty();
boolean contains = set.contains(10);
int n = set.size();
```

| Operation | Time Complexity |
| --------- | --------------- |
| Add       | O(log n)        |
| Remove    | O(log n)        |
| Contains  | O(log n)        |
| Iteration | O(n)            |

## LinkedHashSet

HashSet with predictable iteration order (insertion order).

```java
LinkedHashSet<String> set = new LinkedHashSet<>();
set.add("apple");
set.remove("apple");
set.clear();

boolean isEmpty = set.isEmpty();
boolean contains = set.contains("apple");
int n = set.size();

// Iteration in insertion order
for (String s : set) {
    System.out.println(s);
}
```

| Operation | Time Complexity                              |
| --------- | -------------------------------------------- |
| Add       | O(1) (degrades to O(n) with hash collisions) |
| Remove    | O(1) (degrades to O(n) with hash collisions) |
| Contains  | O(1) (degrades to O(n) with hash collisions) |
| Iteration | O(n)                                         |

---

# Maps

## HashMap

Key-value pairs, unordered. Backed by a hash table.

```java
HashMap<String, Integer> map = new HashMap<>();
map.put("a", 1);
Integer value = map.get("a");

map.remove("a");
map.clear();

boolean isEmpty = map.isEmpty();
boolean containsKey = map.containsKey("a");
boolean containsValue = map.containsValue(1);
int n = map.size();
```

| Operation     | Time Complexity                              |
| ------------- | -------------------------------------------- |
| Put           | O(1) (degrades to O(n) with hash collisions) |
| Get           | O(1) (degrades to O(n) with hash collisions) |
| Remove        | O(1) (degrades to O(n) with hash collisions) |
| ContainsKey   | O(1) (degrades to O(n) with hash collisions) |
| ContainsValue | O(n)                                         |
| Iteration     | O(n)                                         |

## TreeMap

Sorted key-value pairs. Backed by a red-black tree.

```java
TreeMap<String, Integer> map = new TreeMap<>();
TreeMap<String, Integer> mapDesc = new TreeMap<>(Collections.reverseOrder());
TreeMap<String, Integer> mapCustom = new TreeMap<>((k1, k2) -> k1.compareTo(k2));

map.put("a", 1);
Integer value = map.get("a");

String firstKey = map.firstKey();
String lastKey = map.lastKey();
String beforeKey = map.lowerKey("b");
String afterKey = map.higherKey("a");

map.remove("a");
map.clear();

NavigableMap<String, Integer> sub = map.subMap("a", true, "z", true);
NavigableMap<String, Integer> tail = map.tailMap("m", true);
NavigableMap<String, Integer> head = map.headMap("n", true);

boolean isEmpty = map.isEmpty();
boolean containsKey = map.containsKey("a");
boolean containsValue = map.containsValue(1);
int n = map.size();
```

| Operation     | Time Complexity |
| ------------- | --------------- |
| Put           | O(log n)        |
| Get           | O(log n)        |
| Remove        | O(log n)        |
| ContainsKey   | O(log n)        |
| ContainsValue | O(n)            |
| Iteration     | O(n)            |

## LinkedHashMap

HashMap with predictable iteration order (insertion order).

```java
LinkedHashMap<String, Integer> map = new LinkedHashMap<>();
map.put("a", 1);
map.remove("a");
map.clear();

boolean isEmpty = map.isEmpty();
boolean containsKey = map.containsKey("a");
boolean containsValue = map.containsValue(1);
int n = map.size();

// Iteration in insertion order
for (Map.Entry<String, Integer> entry : map.entrySet()) {
    String key = entry.getKey();
    Integer val = entry.getValue();
    System.out.println(key + ": " + val);
}
```

| Operation     | Time Complexity                              |
| ------------- | -------------------------------------------- |
| Put           | O(1) (degrades to O(n) with hash collisions) |
| Get           | O(1) (degrades to O(n) with hash collisions) |
| Remove        | O(1) (degrades to O(n) with hash collisions) |
| ContainsKey   | O(1) (degrades to O(n) with hash collisions) |
| ContainsValue | O(n)                                         |
| Iteration     | O(n)                                         |

---

**Tip:**
Choose your data structure based on the required operations and their time complexities. For thread safety, always use the synchronized wrappers or consider concurrent collections
