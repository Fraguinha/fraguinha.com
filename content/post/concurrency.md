---
title: "Concurrency - Concurrency"
description: "Concurrency in Java."
date: 2026-01-21T09:00:00Z
draft: false
---

Overview of Java concurrency primitives, patterns, and best practices for writing thread-safe, high-performance concurrent applications.

# Thread Fundamentals

## Thread Creation

Java provides two primary ways to create threads: extending `Thread` class or implementing `Runnable` interface. The `Runnable` approach is preferred as it separates the task from the execution mechanism.

```java
// Using Thread
class MyThread extends Thread {
    public void run() {
        System.out.println("Thread: " + Thread.currentThread().getName());
    }
}

// Using Runnable
class MyTask implements Runnable {
    public void run() {
        System.out.println("Task: " + Thread.currentThread().getName());
    }
}

public class ThreadDemo {
    public static void main(String[] args) {
        // Thread approach
        MyThread t1 = new MyThread();
        t1.start();

        // Runnable approach
        Thread t2 = new Thread(new MyTask());
        t2.start();

        // Lambda expression
        Thread t3 = new Thread(() -> {
            System.out.println("Lambda: " + Thread.currentThread().getName());
        });
        t3.start();
    }
}
```

## Thread Lifecycle

Threads progress through different states: NEW, RUNNABLE, BLOCKED, WAITING, TIMED_WAITING, and TERMINATED.

```java
public class ThreadLifecycleDemo {
    public static void main(String[] args) throws InterruptedException {
        Thread thread = new Thread(() -> {
            try {
                System.out.println("Running");
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });

        // NEW
        System.out.println(thread.getState());
        thread.start();
        // RUNNABLE
        System.out.println(thread.getState());
        Thread.sleep(100);
        // TIMED_WAITING
        System.out.println(thread.getState());
        thread.join();
        // TERMINATED
        System.out.println(thread.getState());
    }
}
```

## Thread Operations

Thread operations include starting, joining, interrupting, and checking thread states.

```java
public class ThreadOperationsDemo {
    public static void main(String[] args) throws InterruptedException {
        Thread thread = new Thread(() -> {
            for (int i = 0; i < 5; i++) {
                System.out.println(i);
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    return;
                }
            }
        });

        // Start thread
        thread.start();

        // Wait for completion
        thread.join();

        // Check if alive
        System.out.println("Is alive: " + thread.isAlive());
    }
}
```

---

# Synchronization

## Volatile Keyword

The `volatile` keyword ensures visibility of changes to variables across threads. It prevents caching and guarantees that reads/writes are directly from/to main memory.

```java
public class VolatileDemo {
    private volatile boolean running = true;

    public void stop() {
        running = false;
    }

    public void run() {
        while (running) {
            // Do work
        }
        System.out.println("Stopped");
    }

    public static void main(String[] args) throws InterruptedException {
        VolatileDemo demo = new VolatileDemo();

        Thread worker = new Thread(demo::run);
        worker.start();

        Thread.sleep(100);
        demo.stop();
        worker.join();
    }
}
```

## synchronized Keyword

The `synchronized` keyword provides visibility and mutual exclusion to prevent race conditions. It can be applied to methods or blocks.

```java
public class Counter {
    private int count = 0;

    // Synchronized method
    public synchronized void increment() {
        count++;
    }

    // Synchronized block
    public void decrement() {
        synchronized (this) {
            count--;
        }
    }

    public synchronized int getCount() {
        return count;
    }
}

public class SynchronizedDemo {
    public static void main(String[] args) throws InterruptedException {
        Counter counter = new Counter();

        Thread t1 = new Thread(() -> {
            for (int i = 0; i < 1000; i++) counter.increment();
        });

        Thread t2 = new Thread(() -> {
            for (int i = 0; i < 1000; i++) counter.increment();
        });

        t1.start();
        t2.start();
        t1.join();
        t2.join();

        System.out.println("Count: " + counter.getCount());
    }
}
```

## Wait and Notify

The `wait()`, `notify()`, and `notifyAll()` methods enable thread coordination. They must be called from within a synchronized context because they require ownership of the object's monitor.

**Note**: while loop: Always check the condition in a loop rather than an if statement to protect against spurious wakeups.

```java
public class WaitNotifyDemo {
    private final Object lock = new Object();
    private volatile boolean ready = false;

    public void waitForSignal() throws InterruptedException {
        synchronized (lock) {
            while (!ready) {
                lock.wait();
            }
            System.out.println("Signal received");
        }
    }

    public void sendSignal() {
        synchronized (lock) {
            ready = true;
            lock.notify();
            System.out.println("Signal sent");
        }
    }

    public static void main(String[] args) {
        WaitNotifyDemo demo = new WaitNotifyDemo();

        Thread waiter = new Thread(() -> {
            try {
                demo.waitForSignal();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });

        waiter.start();

        try {
            Thread.sleep(500);
            demo.sendSignal();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
```

---

# Atomic Variables

Atomic classes provide lock-free thread-safe operations on single variables using efficient CAS (Compare-And-Swap) operations.

## AtomicInteger

An `Integer` value that may be updated atomically, supporting lock-free thread-safe operations on a single variable.


```java
public class AtomicIntegerDemo {
    public static void main(String[] args) throws InterruptedException {
        AtomicInteger counter = new AtomicInteger(0);

        Thread t1 = new Thread(() -> {
            for (int i = 0; i < 1000; i++) counter.incrementAndGet();
        });
        Thread t2 = new Thread(() -> {
            for (int i = 0; i < 1000; i++) counter.incrementAndGet();
        });

        t1.start();
        t2.start();
        t1.join();
        t2.join();

        System.out.println("Counter: " + counter.get());
    }
}
```

## AtomicReference

The `AtomicReference` class provides a way to update object references atomically. It is particularly useful for implementing lock-free data structures, where a shared reference must be updated safely across multiple threads using compare-and-swap (CAS) operations.


```java
public class AtomicReferenceDemo {
    private static class Node {
        final int value;
        final Node next;

        Node(int value, Node next) {
            this.value = value;
            this.next = next;
        }
    }

    private AtomicReference<Node> head = new AtomicReference<>(null);

    public void push(int value) {
        Node newHead;
        Node oldHead;
        do {
            oldHead = head.get();
            newHead = new Node(value, oldHead);
        } while (!head.compareAndSet(oldHead, newHead));
    }

    public Integer pop() {
        Node oldHead;
        Node newHead;
        do {
            oldHead = head.get();
            if (oldHead == null) return null;
            newHead = oldHead.next;
        } while (!head.compareAndSet(oldHead, newHead));
        return oldHead.value;
    }
}
```

---

# Locks and Conditions

## ReentrantLock

A `ReentrantLock` provides more flexibility than `synchronized`, including try-lock, timed lock, and interruptible lock acquisition.

```java
public class ReentrantLockDemo {
    private final Lock lock = new ReentrantLock();
    private int count = 0;

    public void increment() {
        lock.lock();
        try {
            count++;
        } finally {
            lock.unlock();
        }
    }

    public boolean tryIncrement() {
        if (lock.tryLock()) {
            try {
                count++;
                return true;
            } finally {
                lock.unlock();
            }
        }
        return false;
    }

    public int getCount() {
        lock.lock();
        try {
            return count;
        } finally {
            lock.unlock();
        }
    }
}
```

## ReadWriteLock

A `ReadWriteLock` maintains a pair of locks: one for read-only operations and one for writing. Multiple readers can access simultaneously, but writers have exclusive access.

```java
public class ReadWriteLockDemo {
    private final ReadWriteLock rwLock = new ReentrantReadWriteLock();
    private int value = 0;

    public int read() {
        rwLock.readLock().lock();
        try {
            return value;
        } finally {
            rwLock.readLock().unlock();
        }
    }

    public void write(int newValue) {
        rwLock.writeLock().lock();
        try {
            value = newValue;
        } finally {
            rwLock.writeLock().unlock();
        }
    }

    public static void main(String[] args) throws InterruptedException {
        ReadWriteLockDemo demo = new ReadWriteLockDemo();

        // Multiple readers
        for (int i = 0; i < 5; i++) {
            new Thread(() -> System.out.println("Read: " + demo.read())).start();
        }

        // Single writer
        Thread writer = new Thread(() -> demo.write(42));
        writer.start();
        writer.join();

        // Read updated value
        System.out.println("Final: " + demo.read());
    }
}
```

## Condition

A `Condition` works with `Lock` to provide an improved version of `wait()`, `notify()`, and `notifyAll()`. Key advantages include multiple condition queues per lock, interruptible waits, and better code clarity. Each lock can have multiple conditions, allowing different threads to wait on different events.

```java
public class BoundedBuffer<T> {
    private final Lock lock = new ReentrantLock();
    private final Condition notFull = lock.newCondition();
    private final Condition notEmpty = lock.newCondition();
    private final LinkedList<T> queue = new LinkedList<>();
    private final int capacity;

    public BoundedBuffer(int capacity) {
        this.capacity = capacity;
    }

    public void put(T item) throws InterruptedException {
        lock.lock();
        try {
            while (queue.size() == capacity) {
                notFull.await();
            }
            queue.add(item);
            notEmpty.signal();
        } finally {
            lock.unlock();
        }
    }

    public T take() throws InterruptedException {
        lock.lock();
        try {
            while (queue.isEmpty()) {
                notEmpty.await();
            }
            T item = queue.remove();
            notFull.signal();
            return item;
        } finally {
            lock.unlock();
        }
    }

    public static void main(String[] args) {
        BoundedBuffer<Integer> buffer = new BoundedBuffer<>(3);

        Thread producer = new Thread(() -> {
            try {
                for (int i = 1; i <= 5; i++) {
                    buffer.put(i);
                    System.out.println("Produced: " + i);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });

        Thread consumer = new Thread(() -> {
            try {
                Thread.sleep(1000);
                for (int i = 1; i <= 5; i++) {
                    Integer item = buffer.take();
                    System.out.println("Consumed: " + item);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });

        producer.start();
        consumer.start();
    }
}
```

---

# Concurrent Utilities

## Semaphore

A counting semaphore that maintains a set of permits, useful for controlling access to a resource pool.

```java
public class SemaphoreDemo {
    public static void main(String[] args) {
        Semaphore semaphore = new Semaphore(2);

        for (int i = 0; i < 5; i++) {
            final int threadId = i;
            new Thread(() -> {
                try {
                    System.out.println("Thread " + threadId + " acquiring");
                    semaphore.acquire();
                    System.out.println("Thread " + threadId + " acquired");
                    Thread.sleep(2000);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                } finally {
                    System.out.println("Thread " + threadId + " releasing");
                    semaphore.release();
                }
            }).start();
        }
    }
}
```

## CountDownLatch

A synchronization aid that allows one or more threads to wait until a set of operations completes.

```java
public class CountDownLatchDemo {
    public static void main(String[] args) throws InterruptedException {
        int workerCount = 3;
        CountDownLatch latch = new CountDownLatch(workerCount);

        for (int i = 0; i < workerCount; i++) {
            final int workerId = i;
            new Thread(() -> {
                System.out.println("Worker " + workerId + " starting");
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                System.out.println("Worker " + workerId + " done");
                latch.countDown();
            }).start();
        }

        System.out.println("Waiting for workers...");
        latch.await();
        System.out.println("All workers completed");
    }
}
```

## CyclicBarrier

A synchronization aid that allows a set of threads to wait for each other to reach a common barrier point.

```java
public class CyclicBarrierDemo {
    public static void main(String[] args) {
        int parties = 3;
        CyclicBarrier barrier = new CyclicBarrier(parties, () -> {
            System.out.println("All parties arrived, barrier opened");
        });

        for (int i = 0; i < parties; i++) {
            final int threadId = i;
            new Thread(() -> {
                try {
                    System.out.println("Thread " + threadId + " waiting at barrier");
                    barrier.await();
                    System.out.println("Thread " + threadId + " passed barrier");
                } catch (Exception e) {
                    Thread.currentThread().interrupt();
                }
            }).start();
        }
    }
}
```

## Phaser

A more flexible barrier that supports multiple phases and dynamic registration/deregistration.

```java
public class PhaserDemo {
    public static void main(String[] args) {
        Phaser phaser = new Phaser(1);

        for (int i = 0; i < 3; i++) {
            final int threadId = i;
            phaser.register();
            new Thread(() -> {
                System.out.println("Thread " + threadId + " phase 1");
                phaser.arriveAndAwaitAdvance();

                System.out.println("Thread " + threadId + " phase 2");
                phaser.arriveAndAwaitAdvance();

                System.out.println("Thread " + threadId + " done");
                phaser.arriveAndDeregister();
            }).start();
        }

        phaser.arriveAndAwaitAdvance();
        System.out.println("Main: Phase 1 complete");

        phaser.arriveAndAwaitAdvance();
        System.out.println("Main: Phase 2 complete");

        phaser.arriveAndDeregister();
    }
}
```

## Exchanger

A synchronization point where threads can exchange objects.

```java
public class ExchangerDemo {
    public static void main(String[] args) {
        Exchanger<String> exchanger = new Exchanger<>();

        new Thread(() -> {
            try {
                String data = "Data from Thread 1";
                System.out.println("Thread 1 exchanging: " + data);
                String received = exchanger.exchange(data);
                System.out.println("Thread 1 received: " + received);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }).start();

        new Thread(() -> {
            try {
                String data = "Data from Thread 2";
                System.out.println("Thread 2 exchanging: " + data);
                String received = exchanger.exchange(data);
                System.out.println("Thread 2 received: " + received);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }).start();
    }
}
```

---

# Thread Local and Scoped Values

## ThreadLocal

Provides variables that are local to a specific thread, ensuring each thread has its own independently initialized copy of the data, useful for associating state with a thread.

```java
public class ThreadLocalDemo {
    private static final ThreadLocal<String> userContext = new ThreadLocal<>();

    public static void processRequest(String userId) {
        userContext.set(userId);
        try {
            performAction();
        } finally {
            userContext.remove();
        }
    }

    private static void performAction() {
        System.out.println("Processing for: " + userContext.get());
    }

    public static void main(String[] args) {
        new Thread(() -> processRequest("Alice")).start();
        new Thread(() -> processRequest("Bob")).start();
    }
}
```

## Scoped Values

Allows sharing immutable data within a bounded scope, providing a modern and lightweight alternative to `ThreadLocal` that is optimized for virtual threads and massive concurrency.

```java
public class ScopedValueDemo {
    private static final ScopedValue<String> USER_ID = ScopedValue.newInstance();

    public static void main(String[] args) {
        ScopedValue.where(USER_ID, "admin").run(() -> {
            handleRequest();
        });
    }

    private static void handleRequest() {
        System.out.println("Processing request for: " + USER_ID.get());
    }
}
```

---

# Virtual Threads and Structured Concurrency

Virtual Threads and Structured Concurrency simplify the development of high-throughput concurrent applications.

## Virtual Threads

Virtual threads are lightweight threads not tied to a specific operating system thread, allowing applications to scale to millions of concurrent tasks with minimal overhead.

```java
public class VirtualThreadsDemo {
    public static void main(String[] args) throws InterruptedException {
        // Virtual thread
        Thread vThread = Thread.ofVirtual().start(() -> {
            System.out.println("Running on virtual thread: " + Thread.currentThread());
        });

        // Join
        vThread.join();

        // Unstarted virtual thread
        Thread vThread2 = Thread.ofVirtual().unstarted(() -> {
            System.out.println("Unstarted virtual thread");
        });

        // Start
        vThread2.start();

        // Join
        vThread2.join();
    }
}
```

## Structured Concurrency

Structured Concurrency treats multiple tasks running in different threads as a single unit of work, streamlining error handling and cancellation.

```java
public class StructuredConcurrencyDemo {
    public static void main(String[] args) throws InterruptedException, ExecutionException {
        try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {

            var userReq = scope.fork(() -> findUser());
            var orderReq = scope.fork(() -> fetchOrder());

            scope.join()
                .throwIfFailed();

            System.out.println("User: " + userReq.get() + ", Order: " + orderReq.get());
        }
    }

    private static String findUser() { return "User1"; }
    private static String fetchOrder() { return "Order123"; }
}
```

---

# Executor Framework

The Executor framework provides a high-level API for managing thread pools and asynchronous task execution.

## Callable

`Callable` represents a task that returns a value and can throw checked exceptions, unlike `Runnable` which does not return a result.

```java
Callable<Integer> task = () -> {
    Thread.sleep(1000);
    return 42;
};
```

## Future

A `Future` serves as a placeholder for the result of an asynchronous computation.

```java
public class FutureDemo {
    public static void main(String[] args) throws InterruptedException, ExecutionException {
        Callable<Integer> task = () -> {
            Thread.sleep(1000);
            return 42;
        };

        FutureTask<Integer> futureTask = new FutureTask<>(task);
        Thread thread = new Thread(futureTask);
        thread.start();

        Integer result = futureTask.get();
        System.out.println("Result: " + result);
    }
}
```

## ExecutorService

```java
public class ExecutorServiceDemo {
    public static void main(String[] args) throws InterruptedException, ExecutionException {
        // Fixed thread pool
        ExecutorService executor = Executors.newFixedThreadPool(4);

        // Submit tasks
        Future<Integer> future = executor.submit(() -> {
            Thread.sleep(1000);
            return 42;
        });

        executor.execute(() -> System.out.println("Task executed"));

        // Get result
        Integer result = future.get();
        System.out.println("Result: " + result);

        // Shutdown
        executor.shutdown();
        executor.awaitTermination(5, TimeUnit.SECONDS);
    }
}
```

## ThreadPoolExecutor

For more control over thread pool configuration, use `ThreadPoolExecutor` directly.

```java
public class ThreadPoolExecutorDemo {
    public static void main(String[] args) {
        // Thread pool configuration
        int corePoolSize = 2;
        int maximumPoolSize = 4;
        long keepAliveTime = 60L;
        BlockingQueue<Runnable> workQueue = new LinkedBlockingQueue<>(100);

        // Executor
        ThreadPoolExecutor executor = new ThreadPoolExecutor(
            corePoolSize,
            maximumPoolSize,
            keepAliveTime,
            TimeUnit.SECONDS,
            workQueue,
            new ThreadPoolExecutor.CallerRunsPolicy()
        );

        // Submit tasks
        for (int i = 0; i < 10; i++) {
            final int taskId = i;
            executor.execute(() -> {
                System.out.println("Task " + taskId + " on " +
                    Thread.currentThread().getName());
            });
        }

        // Shutdown
        executor.shutdown();
    }
}
```

## ScheduledExecutorService

For scheduling tasks with delays or periodic execution.

```java
public class ScheduledExecutorDemo {
    public static void main(String[] args) throws InterruptedException {
        // Executor
        ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(2);

        // Schedule with delay
        scheduler.schedule(() -> {
            System.out.println("Executed after 2 seconds");
        }, 2, TimeUnit.SECONDS);

        // Shutdown
        scheduler.shutdown();

        // Schedule at fixed rate
        ScheduledFuture<?> periodic = scheduler.scheduleAtFixedRate(() -> {
            System.out.println("Periodic task");
        }, 0, 1, TimeUnit.SECONDS);

        // Cancel
        periodic.cancel(false);
    }
}
```

## Virtual Threads ExecutorService

An executor that creates a new virtual thread for each submitted task, enabling massive concurrency without the need for thread pooling.

```java
public class VirtualThreadExecutorDemo {
    public static void main(String[] args) {
        try (ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor()) {
            // Submit many tasks
            for (int i = 0; i < 100_000; i++) {
                final int taskId = i;
                executor.submit(() -> {
                     Thread.sleep(Duration.ofMillis(100));
                     return taskId;
                });
            }
        }
    }
}
```

---

# CompletableFuture

`CompletableFuture` provides a powerful API for composing asynchronous operations, bringing many reactive programming patterns to standard Java.

```java
public class CompletableFutureDemo {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        // Simple async computation
        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
            return "Hello";
        });

        // Chain operations
        CompletableFuture<String> result = future
            .thenApply(s -> s + " World")
            .thenApply(String::toUpperCase);

        System.out.println(result.get());

        // Combine futures
        CompletableFuture<Integer> future1 = CompletableFuture.supplyAsync(() -> 10);
        CompletableFuture<Integer> future2 = CompletableFuture.supplyAsync(() -> 20);

        CompletableFuture<Integer> combined = future1.thenCombine(future2, Integer::sum);
        System.out.println(combined.get());

        // Exception handling
        CompletableFuture<String> withError = CompletableFuture.supplyAsync(() -> {
            if (true) throw new RuntimeException("Error");
            return "Success";
        }).exceptionally(e -> "Handled: " + e.getMessage());

        System.out.println(withError.get());
    }
}
```

---

# Thread-Safe Patterns

## Immutable Objects

Immutable objects are inherently thread-safe as their state cannot be modified after construction.

```java
public final class ImmutablePerson {
    private final String name;
    private final int age;
    private final List<String> hobbies;

    public ImmutablePerson(String name, int age, List<String> hobbies) {
        this.name = name;
        this.age = age;
        // Defensive copy
        this.hobbies = List.copyOf(hobbies);
    }

    public String getName() { return name; }
    public int getAge() { return age; }
    public List<String> getHobbies() { return hobbies; }
}
```

## Double-Checked Locking

A pattern for reducing locking overhead in lazy initialization.

```java
public class DoubleCheckedLocking {
    private static volatile DoubleCheckedLocking instance;
    private String data;

    private DoubleCheckedLocking() {
        data = "initialized";
    }

    public static DoubleCheckedLocking getInstance() {
        if (instance == null) {
            synchronized (DoubleCheckedLocking.class) {
                if (instance == null) {
                    instance = new DoubleCheckedLocking();
                }
            }
        }
        return instance;
    }
}
```

## Producer-Consumer Pattern

A classic pattern for coordinating work between producers and consumers.

```java
public class ProducerConsumerDemo {
    public static void main(String[] args) {
        BlockingQueue<Integer> queue = new LinkedBlockingQueue<>(10);

        // Producer
        Thread producer = new Thread(() -> {
            try {
                for (int i = 0; i < 20; i++) {
                    queue.put(i);
                    System.out.println("Produced: " + i);
                    Thread.sleep(100);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });

        // Consumer
        Thread consumer = new Thread(() -> {
            try {
                while (true) {
                    Integer item = queue.take();
                    System.out.println("Consumed: " + item);
                    Thread.sleep(200);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });

        producer.start();
        consumer.start();
    }
}
```

---

# Best Practices

## Prefer High-Level Concurrency Utilities

Use the `java.util.concurrent` package instead of low-level primitives when possible.

```java
// Bad: Manual synchronization
synchronized (lock) {
    if (condition) {
        lock.wait();
    }
}

// Good: Use Semaphore, CountDownLatch, or other utilities
Semaphore semaphore = new Semaphore(1);
semaphore.acquire();
```

## Use Thread Pools

Create threads through executor services rather than manually creating `Thread` instances.

```java
// Bad: Creating threads manually
new Thread(() -> doWork()).start();

// Good: Use executor service
ExecutorService executor = Executors.newFixedThreadPool(4);

// Better: Use virtual threads
ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();

executor.submit(() -> doWork());
```

## Handle InterruptedException Properly

Never swallow interruption; either propagate it or restore the interrupt status.

```java
// Bad
try {
    Thread.sleep(1000);
} catch (InterruptedException e) {
    // Ignore
}

// Good
try {
    Thread.sleep(1000);
} catch (InterruptedException e) {
    Thread.currentThread().interrupt();
}
```

## Minimize Synchronization Scope

Keep synchronized blocks as small as possible to reduce contention.

```java
// Bad: Large synchronized block
public synchronized void method() {
    doExpensiveWork();
    updateSharedState();
    doMoreWork();
}

// Good: Minimal synchronization
public void method() {
    doExpensiveWork();
    synchronized (this) {
        updateSharedState();
    }
    doMoreWork();
}
```

## Use Concurrent Collections

Prefer concurrent collections over synchronized wrappers for better performance.

```java
// Bad: Synchronized wrapper
Map<String, Integer> map = Collections.synchronizedMap(new HashMap<>());

// Good: Concurrent collection
Map<String, Integer> map = new ConcurrentHashMap<>();
```
