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
public class ArrayExample {
    public static void main(String[] args) {
        Integer[] array = new Integer[5];
        array[0] = 10;
        array[1] = 20;
        array[2] = 30;
        array[3] = 40;
        array[4] = 50;

        int n = array.length;

        // Access and update
        Integer element = array[2];
        array[2] = 99;

        // Iteration
        for (int i = 0; i < array.length; i++) {
            System.out.println(array[i]);
        }

        // Sorting
        Arrays.sort(array);
        Arrays.sort(array, Collections.reverseOrder());
        Arrays.sort(array, (a, b) -> a.compareTo(b));

        // Binary search
        int index = Arrays.binarySearch(array, 99);
        System.out.println("Index of 99: " + index);
    }
}
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
public class ArrayListExample {
    public static void main(String[] args) {
        ArrayList<Integer> list = new ArrayList<>();
        list.add(10);
        list.add(20);
        list.add(1, 15);
        list.addAll(Arrays.asList(30, 40));
        list.addAll(2, Arrays.asList(25, 35));

        int n = list.size();

        // Access
        Integer element = list.get(2);

        // Remove
        Integer removed = list.remove(3);
        list.clear();

        // Add again for further operations
        list.addAll(Arrays.asList(10, 20, 30, 20, 40));

        boolean isEmpty = list.isEmpty();
        boolean contains = list.contains(20);
        int index = list.indexOf(20);

        int min = Collections.min(list);
        int max = Collections.max(list);

        int count = Collections.frequency(list, 20);

        Collections.sort(list);
        Collections.sort(list, Collections.reverseOrder());
        Collections.sort(list, (a, b) -> a.compareTo(b));

        int searchIndex = Collections.binarySearch(list, 30);

        Collections.shuffle(list);

        // Iteration
        for (Integer i : list) {
            System.out.println(i);
        }
    }
}
```

**Running times**:

| Operation | Time Complexity   |
| --------- | ----------------- |
| Get       | O(1)              |
| IndexOf   | O(n)              |
| Add       | O(1) amortized    |
| Remove    | O(n)              |
| Iteration | O(n)              |

---

**LinkedList**

```java
public class LinkedListExample {
    public static void main(String[] args) {
        LinkedList<Integer> list = new LinkedList<>();
        list.add(10);           // add to end
        list.addFirst(5);       // add to front
        list.addLast(20);       // add to end

        int n = list.size();

        Integer first = list.getFirst();
        Integer last = list.getLast();

        list.removeFirst();     // remove from front
        list.removeLast();      // remove from end

        boolean isEmpty = list.isEmpty();
        boolean contains = list.contains(10);

        // Iteration
        for (Integer i : list) {
            System.out.println(i);
        }
    }
}
```

**Running times**:

| Operation          | Time Complexity|
| ------------------ | -------------- |
| Get (by index)     | O(n)           |
| Add/Remove (ends)  | O(1)           |
| Add/Remove (middle)| O(n)           |
| Iteration          | O(n)           |

---

# Stacks

**ArrayDeque (as Stack)**

```java
public class StackExample {
    public static void main(String[] args) {
        ArrayDeque<Integer> stack = new ArrayDeque<>();
        stack.push(10);
        stack.push(20);
        stack.push(30);

        int size = stack.size();
        boolean isEmpty = stack.isEmpty();

        Integer top = stack.peek();
        Integer popped = stack.pop();

        // Iteration
        for (Integer i : stack) {
            System.out.println(i);
        }
    }
}
```

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Push      | O(1)            |
| Peek      | O(1)            |
| Pop       | O(1)            |

---

# Queues

**ArrayDeque (as Queue)**

```java
public class QueueExample {
    public static void main(String[] args) {
        ArrayDeque<Integer> queue = new ArrayDeque<>();
        queue.offer(10);
        queue.offer(20);
        queue.offer(30);

        int size = queue.size();
        boolean isEmpty = queue.isEmpty();

        Integer head = queue.peek();
        Integer removed = queue.poll();

        // Iteration
        for (Integer i : queue) {
            System.out.println(i);
        }
    }
}
```

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Offer     | O(1)            |
| Peek      | O(1)            |
| Poll      | O(1)            |

---

**PriorityQueue**

```java
public class PriorityQueueExample {
    public static void main(String[] args) {
        PriorityQueue<Integer> pq = new PriorityQueue<>();
        pq.offer(30);
        pq.offer(10);
        pq.offer(20);

        int size = pq.size();
        boolean isEmpty = pq.isEmpty();
        boolean contains = pq.contains(20);

        Integer head = pq.peek();
        Integer removed = pq.poll();

        // Iteration (order not guaranteed)
        for (Integer i : pq) {
            System.out.println(i);
        }
    }
}
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
public class HashSetExample {
    public static void main(String[] args) {
        HashSet<Integer> set = new HashSet<>();
        set.add(10);
        set.add(20);
        set.add(30);

        int n = set.size();

        set.remove(20);
        set.clear();
        set.addAll(Arrays.asList(40, 50, 60));

        boolean isEmpty = set.isEmpty();
        boolean contains = set.contains(50);

        // Iteration
        for (Integer i : set) {
            System.out.println(i);
        }
    }
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

**TreeSet**

```java
public class TreeSetExample {
    public static void main(String[] args) {
        TreeSet<Integer> set = new TreeSet<>();
        set.add(10);
        set.add(20);
        set.add(30);

        int n = set.size();

        Integer first = set.first();
        Integer last = set.last();

        Integer before = set.lower(20);
        Integer after = set.higher(20);

        set.remove(10);
        set.clear();
        set.addAll(Arrays.asList(40, 50, 60));

        SortedSet<Integer> sub = set.subSet(40, true, 60, true);
        SortedSet<Integer> tail = set.tailSet(50, true);
        SortedSet<Integer> head = set.headSet(60, true);

        boolean isEmpty = set.isEmpty();
        boolean contains = set.contains(50);

        // Iteration
        for (Integer i : set) {
            System.out.println(i);
        }
    }
}
```

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Add       | O(log n)        |
| Remove    | O(log n)        |
| Contains  | O(log n)        |
| Iteration | O(n)            |

---

**LinkedHashSet**

```java
public class LinkedHashSetExample {
    public static void main(String[] args) {
        LinkedHashSet<Integer> set = new LinkedHashSet<>();
        set.add(10);
        set.add(20);
        set.add(30);

        int n = set.size();

        set.remove(20);
        set.clear();
        set.addAll(Arrays.asList(40, 50, 60));

        boolean isEmpty = set.isEmpty();
        boolean contains = set.contains(50);

        // Iteration (insertion order)
        for (Integer i : set) {
            System.out.println(i);
        }
    }
}
```

**Running times**:

| Operation | Time Complexity                              |
| --------- | -------------------------------------------- |
| Add       | O(1) (degrades to O(n) with hash collisions) |
| Remove    | O(1) (degrades to O(n) with hash collisions) |
| Contains  | O(1) (degrades to O(n) with hash collisions) |
| Iteration | O(n) (insertion order)                       |

---

**EnumSet**

```java
enum Day { MON, TUE, WED }
public class EnumSetExample {
    public static void main(String[] args) {
        EnumSet<Day> days = EnumSet.of(Day.MON, Day.WED);

        days.add(Day.TUE);
        days.remove(Day.MON);

        boolean contains = days.contains(Day.WED);

        // Iteration
        for (Day d : days) {
            System.out.println(d);
        }
    }
}
```

**Running times**:

| Operation | Time Complexity |
| --------- | --------------- |
| Add       | O(1)            |
| Remove    | O(1)            |
| Contains  | O(1)            |
| Iteration | O(n)            |

---

**BitSet**

```java
public class BitSetExample {
    public static void main(String[] args) {
        BitSet bits = new BitSet();
        bits.set(1);
        bits.set(3);
        bits.clear(1);

        boolean isSet = bits.get(3);

        // Iteration
        for (int i = bits.nextSetBit(0); i >= 0; i = bits.nextSetBit(i+1)) {
            System.out.println(i);
        }
    }
}
```

**Running times**:

| Operation     | Time Complexity |
| ------------- | --------------- |
| Set           | O(1)            |
| Clear         | O(1)            |
| Get           | O(1)            |
| Iteration     | O(n)            |

---

# Maps

**HashMap**

```java
public class HashMapExample {
    public static void main(String[] args) {
        HashMap<String, Integer> map = new HashMap<>();
        map.put("a", 1);
        map.put("b", 2);
        map.put("c", 3);

        int n = map.size();

        Integer value = map.get("b");

        map.remove("a");
        map.clear();
        map.put("d", 4);

        boolean isEmpty = map.isEmpty();
        boolean containsKey = map.containsKey("d");
        boolean containsValue = map.containsValue(4);

        // Iteration
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            String key = entry.getKey();
            Integer val = entry.getValue();
            System.out.println(key + ": " + val);
        }
    }
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

---

**TreeMap**

```java
public class TreeMapExample {
    public static void main(String[] args) {
        TreeMap<String, Integer> map = new TreeMap<>();
        map.put("a", 1);
        map.put("b", 2);
        map.put("c", 3);

        int n = map.size();

        Integer value = map.get("b");

        String firstKey = map.firstKey();
        String lastKey = map.lastKey();

        String beforeKey = map.lowerKey("b");
        String afterKey = map.higherKey("b");

        map.remove("a");
        map.clear();
        map.put("d", 4);

        NavigableMap<String, Integer> sub = map.subMap("b", true, "d", true);
        NavigableMap<String, Integer> tail = map.tailMap("b", true);
        NavigableMap<String, Integer> head = map.headMap("d", true);

        boolean isEmpty = map.isEmpty();
        boolean containsKey = map.containsKey("d");
        boolean containsValue = map.containsValue(4);

        // Iteration
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            String key = entry.getKey();
            Integer val = entry.getValue();
            System.out.println(key + ": " + val);
        }
    }
}
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

---

**LinkedHashMap**

```java
public class LinkedHashMapExample {
    public static void main(String[] args) {
        LinkedHashMap<String, Integer> map = new LinkedHashMap<>();
        map.put("a", 1);
        map.put("b", 2);
        map.put("c", 3);

        int n = map.size();

        map.remove("a");
        map.clear();
        map.put("d", 4);

        boolean isEmpty = map.isEmpty();
        boolean containsKey = map.containsKey("d");
        boolean containsValue = map.containsValue(4);

        // Iteration (insertion order)
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            String key = entry.getKey();
            Integer val = entry.getValue();
            System.out.println(key + ": " + val);
        }
    }
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
| Iteration     | O(n) (insertion order)                       |

---

**EnumMap**

```java
enum Day { MON, TUE, WED }
public class EnumMapExample {
    public static void main(String[] args) {
        EnumMap<Day, String> map = new EnumMap<>(Day.class);
        map.put(Day.MON, "Monday");
        map.put(Day.WED, "Wednesday");

        String value = map.get(Day.MON);

        // Iteration
        for (Day d : map.keySet()) {
            System.out.println(d + ": " + map.get(d));
        }
    }
}
```

**Running times**:

| Operation     | Time Complexity |
| ------------- | --------------- |
| Put           | O(1)            |
| Get           | O(1)            |
| Remove        | O(1)            |
| ContainsKey   | O(1)            |
| ContainsValue | O(n)            |
| Iteration     | O(n)            |
