---
title: "DSA - Data Structures and Algorithms"
description: "Data Structures and Algorithms."
date: 2024-09-26T12:00:00+01:00
draft: false
---

# Arrays

{{< highlight java >}}
E[] array = new E[10];
E[] array = new E[]{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
int n = array.length;

Arrays.sort(array);
Arrays.sort(array, Collections.reverseOrder());
Arrays.sort(array, (E e1, E e2) -> e1 - e2);

int index = Arrays.binarySearch(array, byte element);
{{< / highlight >}}

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Access    | O(1)            |
| Search    | O(n)            |
| Insertion | O(n)            |
| Deletion  | O(n)            |

# Lists

**ArrayList**

{{< highlight java >}}
ArrayList<E> list = new ArrayList<>();
int n = list.size();

list.add(E element);
list.add(int index, E element);
list.addAll(Collection<? extends E> collection);
list.addAll(int index, Collection<? extends E> collection);

E element = list.get(int index);

E element = list.remove(int index);
list.clear();

boolean isEmpty = list.isEmpty();
boolean contains = list.contains(E element);
int index = list.indexOf(E element);

Collections.sort(list);
Collections.sort(list, Collections.reverseOrder());
Collections.sort(list, (E e1, E e2) -> e1 - e2);

int index = Collections.binarySearch(list, E element);
{{< / highlight >}}

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Access    | O(1)            |
| Search    | O(n)            |
| Insertion | O(n)            |
| Deletion  | O(n)            |

# Queues

**ArrayDeque**

{{< highlight java >}}
ArrayDeque<E> deque = new ArrayDeque<>();
int n = deque.size();

deque.addFirst(E element);
deque.addLast(E element);

E first = deque.peekFirst();
E last = deque.peekLast();

E first = deque.removeFirst();
E last = deque.removeLast();

deque.clear();

boolean isEmpty = deque.isEmpty();
boolean contains = deque.contains(E element);
{{< / highlight >}}

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Insertion | O(1)            |
| Deletion  | O(1)            |
| Access    | O(n)            |

**PriorityQueue** (Heap Implementation)

{{< highlight java >}}
PriorityQueue<E> priorityQueue = new PriorityQueue<>();
PriorityQueue<E> priorityQueue = new PriorityQueue<>(Collections.reverseOrder());
PriorityQueue<E> priorityQueue = new PriorityQueue<>((E e1, E e2) -> e1 - e2);
int size = priorityQueue.size();

priorityQueue.add(E element);

E peek = priorityQueue.peek();

E element = priorityQueue.poll();

boolean isEmpty = priorityQueue.isEmpty();
boolean contains = priorityQueue.contains(E element);
{{< / highlight >}}

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Insertion | O(log n)        |
| Deletion  | O(log n)        |
| Access    | O(1)            |

# Sets

**HashSet**

{{< highlight java >}}
HashSet<E> set = new HashSet<>();
int n = set.size();

set.add(E element);

set.remove(E element);
set.clear();

boolean isEmpty = set.isEmpty();
boolean contains = set.contains(E element);
{{< / highlight >}}

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Insertion | O(1)            |
| Deletion  | O(1)            |
| Search    | O(1)            |

**TreeSet**

{{< highlight java >}}
TreeSet<E> set = new TreeSet<>();
TreeSet<E> set = new TreeSet<>(Collections.reverseOrder());
TreeSet<E> set = new TreeSet<>((E e1, E e2) -> e1 - e2);
int n = set.size();

set.add(E element);

E first = set.first();
E last = set.last();

E before = set.lower(E e);
E after = set.higher(E e);

set.remove(E element);
set.clear();

TreeSet<E> sub = set.subSet(E fromElement, boolean fromInclusive, E toElement, boolean toInclusive);
TreeSet<E> tail = set.tailSet(E fromElement, boolean inclusive);
TreeSet<E> head = set.headSet(E toElement, boolean inclusive);

boolean isEmpty = set.isEmpty();
boolean contains = set.contains(E element);
{{< / highlight >}}

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Insertion | O(log n)        |
| Deletion  | O(log n)        |
| Search    | O(log n)        |

# Maps

**HashMap**

{{< highlight java >}}
HashMap<K, V> map = new HashMap<>();
int n = map.size();

map.put(K key, V value);

V value = map.get(K key);

map.remove(K key);
map.clear();

boolean isEmpty = map.isEmpty();
boolean containsKey = map.containsKey(K key);
boolean containsValue = map.containsValue(V value);
{{< / highlight >}}

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Insertion | O(1)            |
| Deletion  | O(1)            |
| Search    | O(1)            |

**TreeMap**

{{< highlight java >}}
TreeMap<K, V> map = new TreeMap<>();
TreeMap<K, V> map = new TreeMap<>(Collections.reverseOrder());
TreeMap<K, V> map = new TreeMap<>((K k1, K k2) -> k1 - k2);
int n = map.size();

map.put(K key, V value);

V value = map.get(K key);

K firstKey = map.firstKey();
K lastKey = map.lastKey();

K beforeKey = map.lowerKey(K key);
K afterKey = map.higherKey(K key);

map.remove(K key);
map.clear();

TreeMap<K, V> sub = subMap(K fromKey, boolean fromInclusive, K toKey, boolean toInclusive);
TreeMap<K, V> tail = tailMap(K fromKey, boolean inclusive);
TreeMap<K, V> head = headMap(K toKey, boolean inclusive);

boolean isEmpty = map.isEmpty();
boolean containsKey = map.containsKey(K key);
boolean containsValue = map.containsValue(V value);
{{< / highlight >}}

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Insertion | O(log n)        |
| Deletion  | O(log n)        |
| Search    | O(log n)        |
