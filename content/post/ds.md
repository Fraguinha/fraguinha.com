---
title: "DS - Data Structures"
description: "Data Structures in Java."
date: 2024-09-26T12:00:00+01:00
draft: false
---

Overview of the most useful data structures from the Java Collections API

**Note**: In order to make any of the following collections thread safe, you can use:

```java
List<E> list = Collection.synchronizedList(list);
Set<E> set = Collection.synchronizedSet(set);
Map<K, V> map = Collection.synchronizedMap(map);
```

# Arrays

**Array**

```java
E[] array = new E[10];
int n = array.length;

E element = array[0];
array[0] = element;

Arrays.sort(array);
Arrays.sort(array, Collections.reverseOrder());
Arrays.sort(array, (E e1, E e2) -> e1.compareTo(e2));

int index = Arrays.binarySearch(array, element);
```

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Access    | O(1)            |
| Update    | O(1)            |
| Iteration | O(n)            |

---

# Lists

**ArrayList**

```java
ArrayList<E> list = new ArrayList<>();
int n = list.size();

list.add(element);
list.add(index, element);
list.addAll(collection);
list.addAll(index, collection);

E element = list.get(index);

E removed = list.remove(index);
list.clear();

boolean isEmpty = list.isEmpty();
boolean contains = list.contains(element);
int index = list.indexOf(element);

int min = Collections.min(list)
int max = Collections.max(list)

int count = Collections.frequency(list, element);

Collections.sort(list);
Collections.sort(list, Collections.reverseOrder());
Collections.sort(list, (E e1, E e2) -> e1.compareTo(e2));

int index = Collections.binarySearch(list, element);

Collections.shuffle(list);
```

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Get       | O(1)            |
| IndexOf   | O(n)            |
| Add       | O(1)            |
| Remove    | O(n)            |
| Iteration | O(n)            |

---

# Stacks

**ArrayDeque**

```java
ArrayDeque<E> stack = new ArrayDeque<>();

stack.push(element);
E top = stack.peek();
E popped = stack.pop();

boolean isEmpty = stack.isEmpty();
int size = stack.size();
```

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Push      | O(1)            |
| Peek      | O(1)            |
| Pop       | O(1)            |

---

# Queues

**ArrayDeque**

```java
ArrayDeque<E> queue = new ArrayDeque<>();

queue.offer(element);
E head = queue.peek();
E removed = queue.poll();

boolean isEmpty = queue.isEmpty();
int size = queue.size();
```

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Offer     | O(1)            |
| Peek      | O(1)            |
| Poll      | O(1)            |

**PriorityQueue** (Heap Implementation)

```java
PriorityQueue<E> priorityQueue = new PriorityQueue<>();
PriorityQueue<E> priorityQueue = new PriorityQueue<>(Collections.reverseOrder());
PriorityQueue<E> priorityQueue = new PriorityQueue<>((E e1, E e2) -> e1.compareTo(e2));
int size = priorityQueue.size();

priorityQueue.offer(element);
E head = priorityQueue.peek();
E removed = priorityQueue.poll();

boolean isEmpty = priorityQueue.isEmpty();
boolean contains = priorityQueue.contains(element);
```

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Offer     | O(log n)        |
| Peek      | O(1)            |
| Poll      | O(log n)        |

---

# Sets

**HashSet**

```java
HashSet<E> set = new HashSet<>();
int n = set.size();

set.add(element);

set.remove(element);
set.clear();

boolean isEmpty = set.isEmpty();
boolean contains = set.contains(element);
```

**Running times**:

| Operation | Time Complexity                              |
| --------- | -------------------------------------------- |
| Add       | O(1) (degrades to O(n) with hash collisions) |
| Remove    | O(1) (degrades to O(n) with hash collisions) |
| Contains  | O(1) (degrades to O(n) with hash collisions) |
| Iteration | O(n)                                         |

**TreeSet**

```java
TreeSet<E> set = new TreeSet<>();
TreeSet<E> set = new TreeSet<>(Collections.reverseOrder());
TreeSet<E> set = new TreeSet<>((E e1, E e2) -> e1.compareTo(e2));
int n = set.size();

set.add(element);

E first = set.first();
E last = set.last();

E before = set.lower(element);
E after = set.higher(element);

set.remove(element);
set.clear();

SortedSet<E> sub = set.subSet(fromElement, fromInclusive, toElement, toInclusive);
SortedSet<E> tail = set.tailSet(fromElement, inclusive);
SortedSet<E> head = set.headSet(toElement, inclusive);

boolean isEmpty = set.isEmpty();
boolean contains = set.contains(element);
```

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Add       | O(log n)        |
| Remove    | O(log n)        |
| Contains  | O(log n)        |
| Iteration | O(n)            |

**LinkedHashSet**

```java
LinkedHashSet<E> set = new LinkedHashSet<>();
int n = set.size();

set.add(element);
set.remove(element);
set.clear();

boolean isEmpty = set.isEmpty();
boolean contains = set.contains(element);

// insertion order iteration
for (E e : set) {

}
```

**Running times**:

| Operation | Time Complexity                              |
| --------- | -------------------------------------------- |
| Add       | O(1) (degrades to O(n) with hash collisions) |
| Remove    | O(1) (degrades to O(n) with hash collisions) |
| Contains  | O(1) (degrades to O(n) with hash collisions) |
| Iteration | O(n)                                         |

---

# Maps

**HashMap**

```java
HashMap<K, V> map = new HashMap<>();
int n = map.size();

map.put(key, value);

V value = map.get(key);

map.remove(key);
map.clear();

boolean isEmpty = map.isEmpty();
boolean containsKey = map.containsKey(key);
boolean containsValue = map.containsValue(value);
```

**Running times**:

| Operation     | Time Complexity                              |
| ------------- | -------------------------------------------- |
| Put           | O(1) (degrades to O(n) with hash collisions) |
| Get           | O(1) (degrades to O(n) with hash collisions) |
| Remove        | O(1) (degrades to O(n) with hash collisions) |
| ContainsKey   | O(1) (degrades to O(n) with hash collisions) |
| ContainsValue | O(n)                                         |
| Iteration     | O(n)                                         |

**TreeMap**

```java
TreeMap<K, V> map = new TreeMap<>();
TreeMap<K, V> map = new TreeMap<>(Collections.reverseOrder());
TreeMap<K, V> map = new TreeMap<>((K k1, K k2) -> k1.compareTo(k2));
int n = map.size();

map.put(key, value);

V value = map.get(key);

K firstKey = map.firstKey();
K lastKey = map.lastKey();

K beforeKey = map.lowerKey(key);
K afterKey = map.higherKey(key);

map.remove(key);
map.clear();

NavigableMap<K, V> sub = map.subMap(fromKey, fromInclusive, toKey, toInclusive);
NavigableMap<K, V> tail = map.tailMap(fromKey, inclusive);
NavigableMap<K, V> head = map.headMap(toKey, inclusive);

boolean isEmpty = map.isEmpty();
boolean containsKey = map.containsKey(key);
boolean containsValue = map.containsValue(value);
```

**Running times**:

| Operation     | Time Complexity |
| ------------- | --------------- |
| Put           | O(log n)        |
| Get           | O(log n)        |
| Remove        | O(log n)        |
| ContainsKey   | O(log n)        |
| ContainsValue | O(n)            |
| Iteration     | O(n)            |

**LinkedHashMap**

```java
LinkedHashMap<E> map = new LinkedHashMap<>();
LinkedHashMap<E> map = new LinkedHashMap<>(Collections.reverseOrder());
LinkedHashMap<E> map = new LinkedHashMap<>((E e1, E e2) -> e1.compareTo(e2));
int n = map.size();

map.add(element);
map.remove(element);
map.clear();

boolean isEmpty = map.isEmpty();
boolean contains = map.contains(element);

// insertion order iteration
for (Map.Entry<K, V> entry : map.entrySet()) {
  K key = entry.getKey();
  V value = entry.getValue();
}
```

**Running times**:

| Operation     | Time Complexity                              |
| ------------- | -------------------------------------------- |
| Put           | O(1) (degrades to O(n) with hash collisions) |
| Get           | O(1) (degrades to O(n) with hash collisions) |
| Remove        | O(1) (degrades to O(n) with hash collisions) |
| ContainsKey   | O(1) (degrades to O(n) with hash collisions) |
| ContainsValue | O(n)                                         |
| Iteration     | O(n)                                         |
