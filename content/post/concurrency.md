---
title: "Concurrency - Concurrency"
description: "Threads, executors, the Java Memory Model, coordination, cancellation, and diagnosis."
date: 2026-01-21T09:00:00Z
draft: false
---

## Contents

- [Workload and execution model](#workload-and-execution-model)
- [Thread fundamentals](#thread-fundamentals)
- [Executor framework](#executor-framework)
- [CompletableFuture composition](#completablefuture)
- [Shared state and the Java Memory Model](#shared-state-and-the-java-memory-model)
- [Synchronization](#synchronization), [atomic variables](#atomic-variables), and [locks and conditions](#locks-and-conditions)
- [Concurrent utilities](#concurrent-utilities) and [thread-safe patterns](#thread-safe-patterns)
- [Advanced task and context APIs](#advanced-task-and-context-apis)
- [Practical API choices](#best-practices) and [testing and diagnosis](#testing-and-diagnosis)

## Workload and execution model {#workload-and-execution-model}

Separate what a task does from how its execution is scheduled.

### Tasks, concurrency, and parallelism {#tasks-concurrency-and-parallelism}

A task describes work; a thread executes it. An executor chooses whether to run it directly, create a thread, or use pooled workers. Runnable has no result; Callable&lt;T&gt; returns a value and can throw checked exceptions.

Concurrency allows activities to make overlapping progress, including by taking turns on one CPU. Parallelism runs instructions simultaneously. Concurrent network requests can reduce total waiting time; ten CPU-heavy tasks on one core still share that core.

The same task can run directly, on a raw thread, or through an executor:

```java
public class TaskExecutionDemo {
    public static void main(String[] args) throws InterruptedException, ExecutionException {
        Runnable task = () -> System.out.println(
            "Task on " + Thread.currentThread().getName());

        task.run();

        Thread raw = new Thread(task, "raw-worker");
        raw.start();
        try {
            raw.join();
        } finally {
            raw.interrupt();
            raw.join();
        }

        try (ExecutorService platform = Executors.newSingleThreadExecutor()) {
            platform.submit(task).get();
        }
        try (ExecutorService virtual = Executors.newVirtualThreadPerTaskExecutor()) {
            virtual.submit(task).get();
        }
    }
}
```

Calling run() is an ordinary method call. start() schedules another thread and can be called only once per Thread; restarting it throws IllegalThreadStateException. An Executor may reuse workers or even run the task in its caller.

### Choose an execution policy {#choosing-an-execution-policy}

- **Short sequential work:** call directly; latency and exceptions stay with the caller.
- **Independent CPU work:** use a bounded platform pool near available CPU parallelism; bound its queue and avoid excessive splitting.
- **Mostly blocking requests:** use one virtual thread per task; limit admission and downstream resource use.
- **Delayed or repeated work:** use a scheduled executor; account for task duration, overlap, and cancellation.
- **Recursive CPU work:** use fork/join with a suitable split threshold; avoid unmanaged blocking.
- **Children needed for one result:** use futures or a structured scope; handle sibling failure and wait for child cleanup.

Pool sizing depends on CPU availability, service times, and downstream limits. Virtual threads cost less to park than platform threads, but still retain stacks and reachable objects; neither adds CPU cores or database connections.

Platform threads normally inherit their creator's daemon status; virtual threads are always daemon threads. Daemon threads do not keep the JVM alive, so wait for required work before exiting.

## Thread fundamentals {#thread-fundamentals}

A thread's lifecycle and interruption status determine how its owner starts, waits for, and cancels its work.

### Thread creation {#thread-creation}

Define raw platform-thread work by extending [Thread](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Thread.html) or implementing Runnable. Unless you need a specialized thread type, implement Runnable; the same task can also be submitted to an executor.

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
    public static void main(String[] args) throws InterruptedException {
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
        try {
            t1.join();
            t2.join();
            t3.join();
        } finally {
            t1.interrupt();
            t2.interrupt();
            t3.interrupt();
            t1.join();
            t2.join();
            t3.join();
        }
    }
}
```

### Thread lifecycle {#thread-lifecycle}

Thread states are NEW, RUNNABLE, BLOCKED, WAITING, TIMED_WAITING, and TERMINATED. Intermediate states depend on scheduling; [getState()](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Thread.html#getState()) monitors them but does not synchronize. For an already-started thread, an untimed join() returning normally means termination; joining an unstarted thread returns immediately. sleep() requests a delay, not coordination.

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
        System.out.println(thread.getState());
        try {
            thread.join();
        } finally {
            thread.interrupt();
            thread.join();
        }
        // TERMINATED
        System.out.println(thread.getState());
    }
}
```

### Thread operations {#thread-operations}

The worker prints 0 through 4, then join() waits for termination. If that wait is interrupted, the finally block requests worker interruption and joins it before the exception propagates.

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

        try {
            thread.join();
        } finally {
            thread.interrupt();
            thread.join();
        }

        // Check if alive
        System.out.println("Is alive: " + thread.isAlive());
    }
}
```

[interrupt()](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Thread.html#interrupt()) requests cooperative cancellation. sleep(), wait(), join(), and many blocking concurrency operations throw InterruptedException and clear the status. If the method can throw InterruptedException, propagate it; otherwise, clean up, restore the status, and exit. Restoring the flag and retrying the same interruptible wait can spin rather than cancel.

CPU loops must check isInterrupted(), which leaves the status unchanged. Static Thread.interrupted() checks and clears the current thread's status:

```java
public class InterruptionDemo {
    public static void main(String[] args) throws InterruptedException {
        CountDownLatch entered = new CountDownLatch(1);
        Thread worker = new Thread(() -> {
            entered.countDown();
            while (!Thread.currentThread().isInterrupted()) {
                Thread.onSpinWait();
            }
            System.out.println("Worker observed interruption");
        });
        worker.start();
        try {
            if (!entered.await(5, TimeUnit.SECONDS)) {
                throw new IllegalStateException("Worker did not start");
            }
        } finally {
            worker.interrupt();
            worker.join();
        }
        System.out.println("Worker alive: " + worker.isAlive());
    }
}
```

A task that ignores interruption, or a native call without an interruption contract, can outlive cancellation. Entering a synchronized monitor is not interruptible; [lock acquisition can be](#reentrantlock). Resource APIs may need their own deadlines or an explicit socket or channel close to unblock a call.

## Executor framework {#executor-framework}

Executors own execution policy; futures expose task outcomes without guaranteeing that canceled workers have stopped.

### Callable interface {#callable}

Callable&lt;T&gt; returns a value and can throw checked exceptions; Runnable can do neither. Calling task.call() runs synchronously; submitting it delegates execution to an executor:

```java
Callable<Integer> task = () -> {
    Thread.sleep(1000);
    return 42;
};
```

### Outcomes, cancellation, and ownership {#outcomes-cancellation-and-ownership}

Waiting, cancellation, and worker termination are separate:

- **get() returns:** the task succeeded and its result is available.
- **ExecutionException:** the computation failed; inspect getCause().
- **InterruptedException:** the waiting caller was interrupted and its status cleared; the worker may still be running.
- **get(timeout, unit) throws TimeoutException:** the wait expired without canceling the task.
- **cancel(true) succeeds:** the future is canceled. A running FutureTask requests worker interruption but does not wait for it to stop.
- **CancellationException:** cancellation made the result unavailable; it does not prove worker termination.
- **Untimed join() returns normally:** an already-started thread terminated, not necessarily successfully.

None of these operations automatically cancels siblings or shuts down an executor. The [Future contract](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/Future.html) describes cancellation as an attempt; cancel(false) does not request interruption. After a timeout, cancellation and cleanup remain separate steps. [CompletableFuture cancellation](#a-completed-future-is-not-necessarily-stopped-work) does not interrupt its computation.

Close locally created executors; ExecutorService implements AutoCloseable. If a request uses a shared executor, cancel only its own unfinished futures and leave the executor open; the application closes it at shutdown. APIs returning futures should specify who observes failures and cancels unfinished work.

[Executor lifecycle methods](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ExecutorService.html) have different effects:

| Method | Effect |
|---|---|
| shutdown() | Rejects new work; allows previously submitted work to run; does not wait |
| awaitTermination(timeout, unit) | Waits after shutdown; false means termination has not been observed |
| shutdownNow() | Removes queued work and makes a best-effort interruption request to active workers; returns work that never started; does not wait |
| close() | Initiates orderly shutdown and waits for termination; if interrupted while waiting, requests shutdown-now behavior, continues waiting, and reasserts the caller's interrupt status before returning |

Try-with-resources calls close() even when result retrieval throws. It does not cancel siblings on failure or impose a shutdown deadline: non-cooperative tasks can keep it waiting. Calling it from the executor's own task can make that task wait for itself. shutdownNow() does not automatically cancel the queued FutureTask objects it returns; cancel their futures explicitly.

### Future results {#future}

FutureTask combines a Runnable execution with a Future result, so a raw thread or an executor can run it. If result retrieval fails or is interrupted, the finally block requests cancellation and waits for the worker:

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

        try {
            Integer result = futureTask.get();
            System.out.println("Result: " + result);
        } finally {
            futureTask.cancel(true);
            thread.join();
        }
    }
}
```

Here a latch prevents normal completion, making the timeout and later cancellation observable separately:

```java
public class TimeoutCancellationDemo {
    public static void main(String[] args) throws Exception {
        CountDownLatch started = new CountDownLatch(1);
        CountDownLatch stopped = new CountDownLatch(1);
        try (ExecutorService executor = Executors.newSingleThreadExecutor()) {
            Future<Integer> future = executor.submit(() -> {
                started.countDown();
                try {
                    new CountDownLatch(1).await();
                    return 42;
                } finally {
                    stopped.countDown();
                }
            });
            try {
                if (!started.await(5, TimeUnit.SECONDS)) {
                    throw new IllegalStateException("Worker did not start");
                }
                try {
                    future.get(0, TimeUnit.NANOSECONDS);
                } catch (TimeoutException e) {
                    System.out.println("Timed out; cancelled: " + future.isCancelled());
                }
                System.out.println("Cancellation accepted: " + future.cancel(true));
                try {
                    future.get();
                } catch (CancellationException e) {
                    System.out.println("Outcome: cancelled");
                }
                if (!stopped.await(5, TimeUnit.SECONDS)) {
                    throw new IllegalStateException("Worker did not stop");
                }
            } finally {
                future.cancel(true);
            }
        }
        System.out.println("Worker stopped: " + (stopped.getCount() == 0));
    }
}
```

The timeout leaves isCancelled() returning false. Only the later cancel(true) interrupts the latch wait. The stopped latch and executor termination confirm cleanup; cancellation alone does not. Timeouts are not hard real-time scheduling guarantees.

### ExecutorService interface {#executorservice}

Try-with-resources closes a locally created executor even when get() throws:

```java
public class ExecutorServiceDemo {
    public static void main(String[] args) throws InterruptedException, ExecutionException {
        try (ExecutorService executor = Executors.newFixedThreadPool(4)) {
            Future<Integer> future = executor.submit(() -> {
                Thread.sleep(1000);
                return 42;
            });

            executor.execute(() -> System.out.println("Task executed"));

            Integer result = future.get();
            System.out.println("Result: " + result);

            executor.shutdown();
            if (!executor.awaitTermination(5, TimeUnit.SECONDS)) {
                throw new IllegalStateException("Executor did not terminate in time");
            }
        }
    }
}
```

InterruptedException or ExecutionException propagates after the executor closes. Orderly close waits for the finite worker rather than canceling it. The five-second awaitTermination() bounds only that explicit wait, not the implicit close.

Ordinary futures do not cancel siblings on failure. Without this finally block, executor close would wait forever for the sibling's latch:

```java
public class ExecutorFailureDemo {
    public static void main(String[] args) throws InterruptedException {
        CountDownLatch siblingStarted = new CountDownLatch(1);
        CountDownLatch siblingStopped = new CountDownLatch(1);

        try (ExecutorService executor = Executors.newFixedThreadPool(2)) {
            Future<?> sibling = executor.submit(() -> {
                siblingStarted.countDown();
                try {
                    new CountDownLatch(1).await();
                    return null;
                } finally {
                    siblingStopped.countDown();
                }
            });
            try {
                Future<?> failed = executor.submit(() -> {
                    if (!siblingStarted.await(5, TimeUnit.SECONDS)) {
                        throw new IllegalStateException("Sibling did not start");
                    }
                    throw new IllegalArgumentException("Order unavailable");
                });
                try {
                    failed.get();
                } catch (ExecutionException e) {
                    System.out.println("Failed: " + e.getCause().getMessage());
                }
            } finally {
                sibling.cancel(true);
            }
        }
        System.out.println("Sibling stopped: " + (siblingStopped.getCount() == 0));
    }
}
```

Cancellation interrupts the sibling's latch wait; its finally block runs before executor close returns, including when the owner is interrupted. [Structured concurrency](#structured-concurrency) automates sibling cancellation within a scope.

### ThreadPoolExecutor class {#threadpoolexecutor}

[ThreadPoolExecutor](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ThreadPoolExecutor.html) creates workers up to corePoolSize, then queues submissions. Only a full queue causes growth toward maximumPoolSize; after that, the rejection handler applies. CallerRunsPolicy runs saturated submissions in the caller but discards them after shutdown. These ten tasks cannot fill the queue of 100, so this example uses at most two workers.

```java
public class ThreadPoolExecutorDemo {
    public static void main(String[] args) {
        // Thread pool configuration
        int corePoolSize = 2;
        int maximumPoolSize = 4;
        long keepAliveTime = 60L;
        BlockingQueue<Runnable> workQueue = new LinkedBlockingQueue<>(100);

        // Executor
        try (ThreadPoolExecutor executor = new ThreadPoolExecutor(
                corePoolSize,
                maximumPoolSize,
                keepAliveTime,
                TimeUnit.SECONDS,
                workQueue,
                new ThreadPoolExecutor.CallerRunsPolicy())) {

            for (int i = 0; i < 10; i++) {
                final int taskId = i;
                executor.execute(() -> {
                    System.out.println("Task " + taskId + " on " +
                        Thread.currentThread().getName());
                });
            }
            executor.shutdown();
        }
    }
}
```

### Capacity, saturation, and resource budgets {#capacity-saturation-and-resource-budgets}

[newFixedThreadPool(n)](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/Executors.html#newFixedThreadPool(int)) limits workers, not queued work. If arrivals remain faster than completion, its effectively unbounded queue grows, increasing latency and memory use.

With corePoolSize = 1, maximumPoolSize = 2, and queue capacity 1, latches hold workers so submissions exercise every step:

| Submission | Pool and queue decision |
|---|---|
| A | Create core worker; A waits for release |
| B | Queue B; core size has already been reached |
| C | Queue is full, so create second worker; C waits for release |
| D | Both workers occupied and queue full: apply rejection handler |

```java
public class SaturationDemo {
    public static void main(String[] args) throws InterruptedException {
        runCase("caller-runs", new ThreadPoolExecutor.CallerRunsPolicy());
        runCase("abort", new ThreadPoolExecutor.AbortPolicy());
    }

    private static void runCase(String name, RejectedExecutionHandler policy)
            throws InterruptedException {
        CountDownLatch firstStarted = new CountDownLatch(1);
        CountDownLatch secondStarted = new CountDownLatch(1);
        CountDownLatch release = new CountDownLatch(1);
        AtomicInteger completed = new AtomicInteger();

        try (ThreadPoolExecutor pool = new ThreadPoolExecutor(
                1, 2, 1, TimeUnit.SECONDS, new ArrayBlockingQueue<>(1), policy)) {
            try {
                pool.execute(() -> held(firstStarted, release, completed));
                await(firstStarted);
                pool.execute(completed::incrementAndGet);
                pool.execute(() -> held(secondStarted, release, completed));
                await(secondStarted);
                System.out.println(name + ": workers=" + pool.getPoolSize()
                    + ", queued=" + pool.getQueue().size());
                try {
                    pool.execute(() -> {
                        completed.incrementAndGet();
                        System.out.println("D ran on submitting thread: "
                            + Thread.currentThread().getName());
                    });
                } catch (RejectedExecutionException e) {
                    System.out.println("D rejected");
                }
            } finally {
                release.countDown();
            }
        }
        System.out.println(name + ": completed=" + completed.get());
    }

    private static void held(CountDownLatch started, CountDownLatch release,
                             AtomicInteger completed) {
        started.countDown();
        try {
            if (!release.await(5, TimeUnit.SECONDS)) {
                throw new IllegalStateException("Workers were not released");
            }
            completed.incrementAndGet();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    private static void await(CountDownLatch latch) throws InterruptedException {
        if (!latch.await(5, TimeUnit.SECONDS)) {
            throw new IllegalStateException("Worker did not start");
        }
    }
}
```

Both cases report workers=2, queued=1. Caller-runs executes D on main and completes four tasks; abort rejects D and completes three. Caller-runs delays the submitter, but can block an event loop, run inside a caller-held lock, and increase active tasks beyond the pool's worker count. After shutdown it silently discards work, potentially leaving a submitted future incomplete. Use explicit rejection when callers need an overload result.

These limits bound different things:

| Limit | Bounds |
|---|---|
| Admission: 100 requests | Active and waiting accepted work, including retained request state |
| Backlog: queue capacity 80 | Work waiting at this queue, not upstream queues |
| Resource use: 20 semaphore permits | Simultaneous downstream operations |
| CPU parallelism: four workers | CPU work, not waiting virtual threads |

Assuming one database call per request and no other stage, 100 admitted requests and 20 database permits leave at most 80 admitted requests waiting for the database. A semaphore alone leaves its waiter count unbounded; a queue does not limit connections opened elsewhere. Acquire admission before creating or retaining a task, release it on completion or rejection, and hold a database permit only during database use. The [virtual-thread example](#virtual-threads-executorservice) combines these limits; the [producer-consumer pattern](#producer-consumer-pattern) uses queue backpressure.

### ScheduledExecutorService interface {#scheduledexecutorservice}

ScheduledExecutorService runs delayed or periodic work. This example uses a latch to wait for three periodic runs. [Successive executions of one periodic task do not overlap](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ScheduledThreadPoolExecutor.html), so the count check prevents extra work while cancellation is pending. A scheduled delay is a minimum, not an exact start time.

```java
public class ScheduledExecutorDemo {
    public static void main(String[] args) throws InterruptedException, ExecutionException {
        CountDownLatch periodicRuns = new CountDownLatch(3);

        try (ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(2)) {
            ScheduledFuture<?> delayed = scheduler.schedule(() -> {
                System.out.println("Executed after 2 seconds");
            }, 2, TimeUnit.SECONDS);

            ScheduledFuture<?> periodic = scheduler.scheduleAtFixedRate(() -> {
                if (periodicRuns.getCount() > 0) {
                    System.out.println("Periodic task");
                    periodicRuns.countDown();
                }
            }, 0, 1, TimeUnit.SECONDS);

            try {
                delayed.get();
                periodicRuns.await();
            } finally {
                periodic.cancel(false);
            }
        }
    }
}
```

scheduleAtFixedRate() targets start times relative to the original schedule; slow runs make later runs late, not overlapping. scheduleWithFixedDelay() waits until a run finishes, then starts the delay. Both suppress later executions if a run throws; inspect the ScheduledFuture for failure. Different scheduled tasks can overlap. Cancellation with false lets a running invocation finish; true requests interruption.

### Virtual threads and structured concurrency {#virtual-threads-and-structured-concurrency}

Virtual threads reduce per-thread cost. [Structured concurrency](#structured-concurrency) manages child task lifetimes and failure.

#### Virtual threads {#virtual-threads}

[Virtual threads](https://openjdk.org/jeps/444) run on JVM-managed carrier platform threads. They scale mostly waiting tasks, especially blocking I/O, but do not accelerate CPU work. Create one per task rather than pooling them.

Blocking while pinned occupies a virtual thread's carrier; holding a synchronized monitor or executing native or foreign code can cause pinning. Some other blocking operations cannot unmount but may be compensated by extra carriers. For frequently executed locks held across long blocking calls, consider ReentrantLock; short in-memory critical sections need no rewrite. [JFR and thread dumps](#diagnosing-running-java-21-programs) can identify pinning. Native libraries' blocking behavior needs separate attention.

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

#### Virtual-thread executor {#virtual-threads-executorservice}

The newVirtualThreadPerTaskExecutor method starts a virtual thread per task. This example processes 100,000 tasks with at most 100 outstanding futures and 20 simultaneous resource users:

```java
public class VirtualThreadExecutorDemo {
    public static void main(String[] args) throws Exception {
        int taskCount = 100_000;
        int window = 100;
        Semaphore resource = new Semaphore(20);
        AtomicInteger active = new AtomicInteger();
        AtomicInteger peak = new AtomicInteger();
        long sum = 0;

        try (ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor()) {
            CompletionService<Integer> completion = new ExecutorCompletionService<>(executor);
            Set<Future<Integer>> inFlight = new HashSet<>();
            int submitted = 0;
            try {
                while (submitted < Math.min(window, taskCount)) {
                    int id = submitted++;
                    inFlight.add(completion.submit(() -> operation(id, resource, active, peak)));
                }
                while (!inFlight.isEmpty()) {
                    Future<Integer> done = completion.take();
                    inFlight.remove(done);
                    sum += done.get();
                    if (submitted < taskCount) {
                        int id = submitted++;
                        inFlight.add(completion.submit(() -> operation(id, resource, active, peak)));
                    }
                }
            } finally {
                for (Future<Integer> future : inFlight) {
                    future.cancel(true);
                }
            }
        }
        System.out.println("Sum: " + sum);
        System.out.println("Active after close: " + active.get());
        System.out.println("Peak at most 20: " + (peak.get() <= 20));
    }

    private static int operation(int id, Semaphore resource,
                                 AtomicInteger active, AtomicInteger peak)
            throws InterruptedException {
        resource.acquire();
        try {
            int now = active.incrementAndGet();
            try {
                peak.accumulateAndGet(now, Math::max);
                return id;
            } finally {
                active.decrementAndGet();
            }
        } finally {
            resource.release();
        }
    }
}
```

The sum is 4999950000, active use returns to zero, and peak use stays at most 20. The tiny arithmetic operation demonstrates accounting, not virtual-thread performance. A blocking downstream call would go inside the permit-protected interval with its own I/O timeout.

CompletionService returns completed tasks rather than waiting in submission order; the rolling window avoids retaining 100,000 result handles. Failure or owner interruption cancels remaining admitted tasks before executor close waits for cleanup. Release a permit only after successful, interruptible semaphore acquisition.

## CompletableFuture composition {#completablefuture}

[CompletableFuture](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/CompletableFuture.html) composes computations. Without an explicit executor, asynchronous factory methods such as supplyAsync() normally use ForkJoinPool.commonPool(); if its parallelism is below two, they create a thread per task. Non-asynchronous continuations such as thenApply() and thenCombine() may run on the thread completing the preceding stage, or in the caller if it is already complete. Stages do not each get a thread.

Use an explicit executor for blocking work to avoid occupying common-pool workers:

```java
public class CompletableFutureDemo {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        try (ExecutorService executor = Executors.newFixedThreadPool(2)) {
            CompletableFuture<String> future =
                CompletableFuture.supplyAsync(() -> "Hello", executor);
            CompletableFuture<String> result = future
                .thenApply(s -> s + " World")
                .thenApply(String::toUpperCase);
            System.out.println(result.get());

            CompletableFuture<Integer> future1 =
                CompletableFuture.supplyAsync(() -> 10, executor);
            CompletableFuture<Integer> future2 =
                CompletableFuture.supplyAsync(() -> 20, executor);
            System.out.println(future1.thenCombine(future2, Integer::sum).get());

            CompletableFuture<String> withError =
                CompletableFuture.<String>supplyAsync(() -> {
                    throw new IllegalStateException("Error");
                }, executor).exceptionally(e -> "Handled: " + e.getCause().getMessage());
            System.out.println(withError.get());
        }
    }
}
```

get() reports failure through checked ExecutionException; join() throws unchecked CompletionException and does not provide an interruptible wait. Both report direct cancellation through CancellationException; dependent stages may wrap upstream cancellation as exceptional completion.

### Result dependencies {#dependencies-apply-compose-and-combine}

- **thenApply():** transform one result into an ordinary value, such as parsing or formatting.
- **thenCompose():** start an operation dependent on one result and flatten its future, such as fetching orders after obtaining a user ID.
- **thenCombine():** combine two independently started results, such as an order and shipping quote. It does not start either input.

Returning a future from thenApply() yields CompletableFuture&lt;CompletableFuture&lt;T&gt;&gt;. Blocking on the inner future can exhaust the executor; thenCompose() expresses that dependency without blocking.

The order stage depends on user, while shipping is independent:

```java
public class DependentRequestsDemo {
    private record User(String id, String name) {}
    private record Order(String number, int cents) {}
    private static final Map<String, User> USERS =
        Map.of("u1", new User("u1", "Alice"));
    private static final Map<String, Order> ORDERS =
        Map.of("u1", new Order("Order123", 1200));

    public static void main(String[] args) throws Exception {
        try (ExecutorService executor = Executors.newFixedThreadPool(2)) {
            CompletableFuture<User> user = findUser("u1", executor);
            CompletableFuture<String> name = user.thenApply(u -> u.name().toUpperCase(Locale.ROOT));
            CompletableFuture<Order> order =
                user.thenCompose(u -> findOrder(u.id(), executor));
            CompletableFuture<Integer> shipping =
                CompletableFuture.supplyAsync(() -> 50, executor);
            CompletableFuture<String> receipt = order.thenCombine(shipping,
                (o, fee) -> o.number() + " total: " + (o.cents() + fee));

            System.out.println(name.get());
            System.out.println(receipt.get());
        }
    }

    private static CompletableFuture<User> findUser(String id, Executor executor) {
        return CompletableFuture.supplyAsync(
            () -> Objects.requireNonNull(USERS.get(id), "Unknown user"), executor);
    }

    private static CompletableFuture<Order> findOrder(String id, Executor executor) {
        return CompletableFuture.supplyAsync(
            () -> Objects.requireNonNull(ORDERS.get(id), "No order"), executor);
    }
}
```

Keep non-asynchronous stages short because they can run on the completing thread. thenApplyAsync(fn, executor) selects a continuation executor without changing dependency or failure semantics.

### Recovery, observation, and outcomes {#recovery-observation-and-outcomes}

- **thenApply() and thenCompose():** transform success; skip the function on upstream failure.
- **exceptionally():** recover from failure with a successful value, unless recovery throws.
- **whenComplete():** observe success or failure, normally preserving it. A throwing observer can turn success into failure.
- **handle():** derive a new value from either outcome, unless the handler throws.

A fallback turns failure into success for downstream stages; observing it with whenComplete() does not.

```java
public class CompletionOutcomesDemo {
    public static void main(String[] args) {
        CompletableFuture<String> failed =
            CompletableFuture.failedFuture(new IllegalStateException("Missing order"));
        CompletableFuture<String> observed = failed.whenComplete((value, error) ->
            System.out.println("Observed: " + error.getMessage()));

        try {
            observed.join();
        } catch (CompletionException e) {
            System.out.println("Still failed: " + e.getCause().getMessage());
        }
        System.out.println(failed.exceptionally(error -> "Fallback order").join());
        System.out.println(failed.handle((value, error) ->
            error == null ? value : "Handled failure: " + error.getMessage()).join());
    }
}
```

A handler receives its stage's stored exception. Asynchronous failures may already be wrapped in CompletionException, so getMessage() need not be the original error message.

### Future completion and worker lifetime {#a-completed-future-is-not-necessarily-stopped-work}

CompletableFuture.cancel(true) cancels the future without interrupting its computation; the mayInterruptIfRunning parameter has no effect. The orTimeout() method completes the same future exceptionally without canceling or interrupting its supplier; it does not create a copy. Neither mechanism automatically cancels siblings.

The supplier remains blocked on a latch after either outcome is reported:

```java
public class CompletableFutureLifetimeDemo {
    public static void main(String[] args) throws Exception {
        runCase(false);
        runCase(true);
    }

    private static void runCase(boolean cancel) throws Exception {
        CountDownLatch started = new CountDownLatch(1);
        CountDownLatch release = new CountDownLatch(1);
        AtomicBoolean finished = new AtomicBoolean();
        String label = cancel ? "cancel" : "timeout";

        try (ExecutorService executor = Executors.newSingleThreadExecutor()) {
            CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
                started.countDown();
                try {
                    if (!release.await(5, TimeUnit.SECONDS)) {
                        throw new IllegalStateException("Supplier not released");
                    }
                    finished.set(true);
                    return "Finished";
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    throw new CompletionException(e);
                }
            }, executor);
            try {
                if (!started.await(5, TimeUnit.SECONDS)) {
                    throw new IllegalStateException("Supplier did not start");
                }
                if (cancel) {
                    future.cancel(true);
                } else {
                    future.orTimeout(0, TimeUnit.NANOSECONDS);
                }
                try {
                    future.join();
                } catch (CancellationException e) {
                    System.out.println("Observed cancellation");
                } catch (CompletionException e) {
                    if (!(e.getCause() instanceof TimeoutException)) {
                        throw e;
                    }
                    System.out.println("Observed timeout");
                }
                System.out.println(label + ": finished before release=" + finished.get());
            } finally {
                release.countDown();
            }
        }
        System.out.println(label + ": finished after close=" + finished.get());
    }
}
```

Both cases report finished before release=false, then finished after close=true. Stopping blocking work requires an underlying cancelable operation or closeable resource. A [structured scope](#structured-concurrency) instead interrupts unfinished child threads and waits for them on close.

## Shared state and the Java Memory Model {#shared-state-and-the-java-memory-model}

Correct shared-state access must preserve both memory visibility and the relationships between values.

### Visibility, atomicity, and invariants {#visibility-atomicity-and-invariants}

- **Visibility and ordering:** which earlier writes a read must see.
- **Atomicity:** whether other threads can observe or interleave part of an operation.
- **Invariant:** a relationship between values that must hold when observed.

Consider two threads incrementing count, initially zero:

| Step | Thread A | Thread B |
|---|---|---|
| 1 | Read 0 | |
| 2 | | Read 0 |
| 3 | Calculate 1 | |
| 4 | | Calculate 1 |
| 5 | Write 1 | |
| 6 | | Write 1 |

Both writes store 1, losing an increment. Declaring count as volatile orders the individual reads and writes, not the complete read-add-write operation. Latches reproduce this schedule:

```java
public class LostUpdateDemo {
    private static volatile int count;

    public static void main(String[] args) throws Exception {
        CountDownLatch bothRead = new CountDownLatch(2);
        CountDownLatch allowWrites = new CountDownLatch(1);
        Callable<Void> increment = () -> {
            int old = count;
            bothRead.countDown();
            if (!allowWrites.await(5, TimeUnit.SECONDS)) {
                throw new IllegalStateException("Writes were not released");
            }
            count = old + 1;
            return null;
        };

        try (ExecutorService executor = Executors.newFixedThreadPool(2)) {
            Future<Void> first = executor.submit(increment);
            Future<Void> second = executor.submit(increment);
            try {
                if (!bothRead.await(5, TimeUnit.SECONDS)) {
                    throw new IllegalStateException("Readers did not start");
                }
            } finally {
                allowWrites.countDown();
            }
            first.get(5, TimeUnit.SECONDS);
            second.get(5, TimeUnit.SECONDS);
            System.out.println("Lost-update result: " + count);
        }
    }
}
```

Use one lock around the increment or AtomicInteger.incrementAndGet().

Atomic fields do not make a multi-field update atomic. Transferring 10 between balances of 100 should preserve a total of 200, but an observer between left.addAndGet(-10) and right.addAndGet(10) sees 190. Compare that intermediate state with a pair protected by one monitor:

```java
final class LockedBalances {
    private int left = 100;
    private int right = 100;

    synchronized void transfer(int amount) {
        left -= amount;
        right += amount;
    }

    synchronized int total() {
        return left + right;
    }
}

public class InvariantDemo {
    public static void main(String[] args) throws Exception {
        AtomicInteger left = new AtomicInteger(100);
        AtomicInteger right = new AtomicInteger(100);
        CountDownLatch debited = new CountDownLatch(1);
        CountDownLatch finishTransfer = new CountDownLatch(1);

        try (ExecutorService executor = Executors.newSingleThreadExecutor()) {
            Future<?> transfer = executor.submit(() -> {
                left.addAndGet(-10);
                debited.countDown();
                if (!finishTransfer.await(5, TimeUnit.SECONDS)) {
                    throw new IllegalStateException("Transfer not released");
                }
                right.addAndGet(10);
                return null;
            });
            try {
                if (!debited.await(5, TimeUnit.SECONDS)) {
                    throw new IllegalStateException("Debit not reached");
                }
                System.out.println("Individually atomic total: " + (left.get() + right.get()));
            } finally {
                finishTransfer.countDown();
            }
            transfer.get(5, TimeUnit.SECONDS);
            System.out.println("Completed total: " + (left.get() + right.get()));
        }

        LockedBalances balances = new LockedBalances();
        balances.transfer(10);
        System.out.println("Protected total: " + balances.total());
    }
}
```

Both readers and writers must use the same monitor. An alternative is a compare-and-set (CAS) operation on one AtomicReference to an immutable pair; two independent atomics do not update the pair as a unit.

### Happens-before and safe publication {#happens-before-and-safe-publication}

The [Java Memory Model's happens-before relation](https://docs.oracle.com/javase/specs/jls/se21/html/jls-17.html#jls-17.4.5) specifies visibility and ordering, not wall-clock observations or cache behavior. Program order and transitivity connect a producer's ordinary writes to a consumer's reads.

| Mechanism | Happens-before edge |
|---|---|
| Monitor | Unlocking a monitor happens-before a subsequent lock of that same monitor |
| Volatile field | A write happens-before a subsequent read of that same volatile field |
| Thread.start() | Actions before starting a thread happen-before its actions |
| Thread.join() | A thread's actions happen-before another thread successfully detects its termination through join(); a timed join that returns while the thread is still alive does not detect termination |
| Executor submission | Actions before submission happen-before the task's actions |
| Future.get() | The computation's actions happen-before actions following retrieval of its result |
| Concurrent queue handoff | Actions before placing an element happen-before actions after another thread accesses or removes that element |
| Locks and synchronizers | Their documented release and acquire edges publish preceding actions; see the [package memory-consistency contract](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/package-summary.html#MemoryVisibility) |

For example, ordinary payload is safe here because the volatile flag publishes it:

```java
public class PublicationDemo {
    private static int payload;
    private static volatile boolean ready;

    public static void main(String[] args) throws Exception {
        try (ExecutorService executor = Executors.newSingleThreadExecutor()) {
            Future<Integer> reader = executor.submit(() -> {
                while (!ready) {
                    if (Thread.currentThread().isInterrupted()) {
                        throw new InterruptedException("Reader cancelled");
                    }
                    Thread.onSpinWait();
                }
                return payload;
            });
            try {
                payload = 42;
                ready = true;
                System.out.println("Published: " + reader.get(5, TimeUnit.SECONDS));
            } finally {
                reader.cancel(true);
            }
        }
    }
}
```

payload = 42 precedes ready = true; the volatile write and the reader's observation of it publish the payload, so the reader prints Published: 42. Without a publication edge there is no such guarantee. sleep(), yield(), logging, and getState() are not publication protocols. onSpinWait() is a performance hint; use blocking coordination for substantial waits.

Publish constructed objects under a shared lock, through a volatile reference, by class initialization, before a thread start or task submission, or through a concurrent collection. Publication does not synchronize later mutations.

Letting this escape from a constructor—for example through callback registration or a started thread—can expose incomplete state. The [final-field rules](https://docs.oracle.com/javase/specs/jls/se21/html/jls-17.html#jls-17.5) protect properly constructed final state, not later mutation. See [immutability](#immutable-objects) for mutable referenced objects and [double-checked locking](#double-checked-locking) for volatile reference publication.

## Synchronization

Synchronization orders shared-state access; mutual exclusion also protects compound invariants.

### volatile keyword {#volatile-keyword}

Use volatile for state read or written independently, such as a stop flag. Its writes publish earlier actions to later reads of that field. Compound updates such as count++ still need a lock or atomic operation.

```java
public class VolatileDemo {
    private volatile boolean running = true;

    public void stop() {
        running = false;
    }

    public void run() {
        long iterations = 0;
        while (running) {
            iterations++;
            Thread.onSpinWait();
        }
        System.out.println("Stopped after " + iterations + " iterations");
    }

    public static void main(String[] args) throws InterruptedException {
        VolatileDemo demo = new VolatileDemo();

        Thread worker = new Thread(demo::run);
        worker.start();

        demo.stop();
        worker.join();
    }
}
```

### synchronized keyword {#synchronized-keyword}

synchronized provides mutual exclusion and visibility through one monitor. Instance methods lock this; static methods lock the Class object; blocks name their monitor. Acquisition is reentrant, with matching exits. Normal and exceptional block exit both release the monitor.

```java
class Counter {
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

The count is 2000; reads and updates use the same monitor. Prefer a private final lock object over string literals, boxed numbers, or externally shared objects that unrelated code might also lock.

### Monitor waiting and notification {#wait-and-notify}

[wait(), notify(), and notifyAll()](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Object.html#wait()) require ownership of the object's monitor or throw IllegalMonitorStateException. wait() releases that monitor, not other held locks, and reacquires it before returning or throwing. Check the predicate in a while loop: wakeups may be spurious, or another thread may consume the opportunity first.

```java
public class WaitNotifyDemo {
    private final Object lock = new Object();
    private boolean ready = false;

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

    public static void main(String[] args) throws InterruptedException {
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
            demo.sendSignal();
            waiter.join();
        } finally {
            waiter.interrupt();
            waiter.join();
        }
    }
}
```

The predicate records state; notification only wakes waiters. If sending happens first, the waiter sees ready and skips waiting. notify() selects one waiter but retains the monitor until the synchronized block exits, so Signal sent precedes Signal received.

When any one waiter can proceed, use notify(). With different predicates sharing a monitor, use notifyAll() so all waiters recheck rather than waking only an ineligible one. The ready field needs no volatile modifier because every access holds lock.

## Atomic variables {#atomic-variables}

Atomic classes update individual variables indivisibly. The get(), set(), and strong compareAndSet() operations used here have volatile-style visibility; plain, opaque, acquire, and release variants have different memory effects. CAS installs an update only when the current value matches the expected value.

### AtomicInteger class {#atomicinteger}

AtomicInteger supplies atomic integer updates:

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

incrementAndGet() returns the updated value; getAndIncrement() returns the previous value. set(get() + 1) recreates the [lost-update race](#visibility-atomicity-and-invariants). Update functions such as updateAndGet() may run repeatedly after CAS failures, so they must not have side effects such as charging a card.

### AtomicReference class {#atomicreference}

AtomicReference atomically replaces a reference, not the object's contents. This stack publishes immutable nodes; failed CAS attempts retry from the new head:

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

    private final AtomicReference<Node> head = new AtomicReference<>(null);

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

    public static void main(String[] args) {
        AtomicReferenceDemo stack = new AtomicReferenceDemo();
        stack.push(10);
        stack.push(20);
        System.out.println(stack.pop());
        System.out.println(stack.pop());
        System.out.println(stack.pop());
    }
}
```

If two pushes read head A and one installs B, the other's compareAndSet(A, C) fails and retries with B. Each successful push() or pop() operation takes effect at its CAS. Lock-free means system-wide progress, not wait-free progress for every thread: a particular contender may keep losing.

Store immutable snapshots or synchronize mutable contents. CAS can miss an ABA change: A → B → A between reads. This stack creates new nodes and never exposes or reinserts popped node identities, avoiding that reuse path. Reused identities or counters may need stamped or versioned state. For multi-field invariants, one lock is often simpler.

## Locks and conditions {#locks-and-conditions}

Explicit locks support acquisition policies and condition waits beyond monitor locking.

### ReentrantLock class {#reentrantlock}

[ReentrantLock](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/locks/ReentrantLock.html) adds nonblocking, timed, and interruptible acquisition to monitor-style mutual exclusion and visibility. After acquisition succeeds, unlock in a finally block.

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

    public boolean timedIncrement() throws InterruptedException {
        if (!lock.tryLock(100, TimeUnit.MILLISECONDS)) {
            return false;
        }
        try {
            count++;
            return true;
        } finally {
            lock.unlock();
        }
    }

    public void interruptibleIncrement() throws InterruptedException {
        lock.lockInterruptibly();
        try {
            count++;
        } finally {
            lock.unlock();
        }
    }

    public int getCount() {
        lock.lock();
        try {
            return count;
        } finally {
            lock.unlock();
        }
    }

    public static void main(String[] args) throws InterruptedException {
        ReentrantLockDemo demo = new ReentrantLockDemo();
        demo.increment();
        System.out.println("Immediate: " + demo.tryIncrement());
        System.out.println("Timed: " + demo.timedIncrement());
        demo.interruptibleIncrement();
        System.out.println("Count: " + demo.getCount());
    }
}
```

lock() has no interruptible acquisition contract; lockInterruptibly() can abandon its wait by throwing. Timed tryLock(timeout, unit) returns false on timeout and also responds to interruption. An unsuccessful acquisition must not reach unlock().

new ReentrantLock(true) favors longer-waiting acquirers, usually at a throughput cost. It does not guarantee fair CPU scheduling or prevent every form of starvation. Untimed tryLock() can barge even on a fair lock.

### ReadWriteLock interface {#readwritelock}

A [ReadWriteLock](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/locks/ReadWriteLock.html) allows simultaneous readers or one exclusive writer. Both locks participate in publication; protected reads must be read-only.

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

Initial reads may see 0 or 42; Final: 42 follows the completed writer. Read locks help when concurrent reads save more work than the locking costs; this tiny integer example illustrates access rules, not a performance gain.

Read-to-write upgrade can deadlock. Release the read lock, acquire the write lock, and recheck the condition. ReentrantReadWriteLock allows downgrading: acquire the read lock while holding the write lock, then release the write lock. Fairness can reduce throughput.

### Condition interface {#condition}

A [Condition](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/locks/Condition.html) gives one Lock separate wait sets, such as "not full" and "not empty". Like Object.wait(), await() is interruptible, releases and reacquires its lock, and belongs in a predicate loop.

```java
final class BoundedBuffer<T> {
    private final Lock lock = new ReentrantLock();
    private final Condition notFull = lock.newCondition();
    private final Condition notEmpty = lock.newCondition();
    private final LinkedList<T> queue = new LinkedList<>();
    private final int capacity;

    public BoundedBuffer(int capacity) {
        if (capacity <= 0) {
            throw new IllegalArgumentException("Capacity must be positive");
        }
        this.capacity = capacity;
    }

    public void put(T item) throws InterruptedException {
        lock.lockInterruptibly();
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
        lock.lockInterruptibly();
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

}

public class ConditionDemo {
    public static void main(String[] args) throws Exception {
        BoundedBuffer<Integer> buffer = new BoundedBuffer<>(3);
        try (ExecutorService executor = Executors.newFixedThreadPool(2)) {
            Future<?> producer = executor.submit(() -> {
                for (int i = 1; i <= 5; i++) {
                    buffer.put(i);
                    System.out.println("Produced: " + i);
                }
                return null;
            });
            Future<?> consumer = executor.submit(() -> {
                for (int i = 1; i <= 5; i++) {
                    System.out.println("Consumed: " + buffer.take());
                }
                return null;
            });
            try {
                producer.get(5, TimeUnit.SECONDS);
                consumer.get(5, TimeUnit.SECONDS);
            } finally {
                producer.cancel(true);
                consumer.cancel(true);
            }
        }
    }
}
```

Taking signals notFull; putting signals notEmpty. Signaling does not immediately transfer the lock. The loops handle spurious wakeups and competing consumers; items arrive in FIFO order even when log lines interleave.

This fixed-count example cancels both tasks on failure or interruption. A long-running buffer also needs a closed or failed state in its predicates, a call to signalAll() on closure, and a decision to drain or discard queued items. Otherwise an early producer failure can strand consumers. Unless you need separate custom predicates, use BlockingQueue.

### Safety and progress {#safety-and-progress}

Safety rules out invalid results; liveness requires eventual progress. Starvation continually denies one participant access; livelock keeps participants reacting without progress. Mutual exclusion alone prevents none of these progress failures.

#### Lock-order deadlock {#lock-order-deadlock}

Opposite-direction transfers can each hold one account while waiting for the other:

```text
T1 locks account A
T2 locks account B
T1 waits for account B while retaining A
T2 waits for account A while retaining B
Neither can reach the unlock that the other requires
```

The JVM does not repair the cycle, and interrupting monitor acquisition does not release held monitors. With timed second acquisitions, each thread retains its first lock until both attempts finish, so both time out without leaving stuck threads.

```java
public class LockOrderTimeoutDemo {
    public static void main(String[] args) throws Exception {
        ReentrantLock a = new ReentrantLock();
        ReentrantLock b = new ReentrantLock();
        CountDownLatch bothHeld = new CountDownLatch(2);
        CountDownLatch bothAttempted = new CountDownLatch(2);

        try (ExecutorService executor = Executors.newFixedThreadPool(2)) {
            Future<Boolean> first = executor.submit(() -> attempt(a, b, bothHeld, bothAttempted));
            Future<Boolean> second = executor.submit(() -> attempt(b, a, bothHeld, bothAttempted));
            try {
                System.out.println("A then B acquired both: " + first.get(5, TimeUnit.SECONDS));
                System.out.println("B then A acquired both: " + second.get(5, TimeUnit.SECONDS));
            } finally {
                first.cancel(true);
                second.cancel(true);
            }
        }
    }

    private static boolean attempt(ReentrantLock first, ReentrantLock second,
                                   CountDownLatch bothHeld, CountDownLatch bothAttempted)
            throws InterruptedException {
        first.lockInterruptibly();
        try {
            bothHeld.countDown();
            if (!bothHeld.await(5, TimeUnit.SECONDS)) {
                throw new IllegalStateException("First locks were not acquired");
            }
            boolean acquired = second.tryLock(100, TimeUnit.MILLISECONDS);
            if (acquired) {
                second.unlock();
            }
            bothAttempted.countDown();
            if (!bothAttempted.await(5, TimeUnit.SECONDS)) {
                throw new IllegalStateException("Second attempts did not finish");
            }
            return acquired;
        } finally {
            first.unlock();
        }
    }
}
```

Both attempts return false. Blind simultaneous retries could livelock. Taking accounts in one global order removes the cycle:

```java
final class Account {
    final int id;
    int balance;

    Account(int id, int balance) {
        this.id = id;
        this.balance = balance;
    }
}

public class OrderedTransferDemo {
    private static void transfer(Account from, Account to, int amount) {
        if (from == to) {
            return;
        }
        Account first = from.id < to.id ? from : to;
        Account second = from.id < to.id ? to : from;
        synchronized (first) {
            synchronized (second) {
                from.balance -= amount;
                to.balance += amount;
            }
        }
    }

    public static void main(String[] args) throws Exception {
        Account a = new Account(1, 100);
        Account b = new Account(2, 100);
        try (ExecutorService executor = Executors.newFixedThreadPool(2)) {
            Future<?> first = executor.submit(() -> transfer(a, b, 10));
            Future<?> second = executor.submit(() -> transfer(b, a, 10));
            try {
                first.get(5, TimeUnit.SECONDS);
                second.get(5, TimeUnit.SECONDS);
            } finally {
                first.cancel(true);
                second.cancel(true);
            }
        }
        System.out.println("Balances: " + a.balance + ", " + b.balance);
    }
}
```

Every transfer takes the lower, stable account ID first. IDs must be unique, or ties need explicit ordering. Balances are read here after completion; concurrent readers must also lock. Unknown callbacks and blocking external calls inside locks can introduce further dependencies.

#### Nested-task pool exhaustion {#nested-task-pool-exhaustion}

A parent can exhaust a pool without locks: it occupies the only worker, queues a child on that executor, and waits for work that cannot start:

```java
public class PoolExhaustionDemo {
    public static void main(String[] args) throws Exception {
        try (ExecutorService executor = Executors.newSingleThreadExecutor()) {
            Future<String> parent = executor.submit(() -> {
                Future<Integer> child = executor.submit(() -> 42);
                try {
                    child.get(100, TimeUnit.MILLISECONDS);
                    throw new AssertionError("Child ran while sole worker was occupied");
                } catch (TimeoutException e) {
                    return "Nested child timed out with one worker";
                } finally {
                    child.cancel(true);
                }
            });
            try {
                System.out.println(parent.get(5, TimeUnit.SECONDS));
            } finally {
                parent.cancel(true);
            }

            CompletableFuture<Integer> fixed = CompletableFuture
                .supplyAsync(() -> 41, executor)
                .thenCompose(value ->
                    CompletableFuture.supplyAsync(() -> value + 1, executor));
            System.out.println("Composed result: " + fixed.get(5, TimeUnit.SECONDS));
        }
    }
}
```

The child times out because the parent holds its only worker, not because it is slow. After the parent cancels it and returns, composition computes 42 without blocking a worker on queued children. Running tiny dependent work directly also avoids the wait. Adding one worker only moves the limit when dependency depth or load can grow; fork/join's specialized work stealing does not make arbitrary blocking safe.

## Concurrent utilities {#concurrent-utilities}

- **Semaphore:** limit simultaneous permit holders; admission is separate.
- **CountDownLatch:** wait for one-time completion signals; inspect failures separately.
- **CyclicBarrier:** repeatedly gather a fixed group; missing parties need abort or reset.
- **Phaser:** advance registered parties through phases; deregister departures or terminate abandoned phases.
- **Exchanger:** swap values between two participants; bound the wait for a missing partner.

### Semaphore class {#semaphore}

A semaphore limits resource users with permits. [release() does not check ownership](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/Semaphore.html), so acquire a permit before entering the try block that releases it in finally. Interrupted acquisition must not add a permit; interrupted resource use must release one.

```java
public class SemaphoreDemo {
    public static void main(String[] args) throws Exception {
        Semaphore semaphore = new Semaphore(2);
        AtomicInteger active = new AtomicInteger();
        AtomicInteger peak = new AtomicInteger();
        List<Future<?>> tasks = new ArrayList<>();

        try (ExecutorService executor = Executors.newFixedThreadPool(5)) {
            try {
                for (int i = 0; i < 5; i++) {
                    int threadId = i;
                    tasks.add(executor.submit(() -> {
                        System.out.println("Thread " + threadId + " acquiring");
                        semaphore.acquire();
                        try {
                            int now = active.incrementAndGet();
                            try {
                                peak.accumulateAndGet(now, Math::max);
                                System.out.println("Thread " + threadId + " acquired");
                                Thread.sleep(100);
                            } finally {
                                active.decrementAndGet();
                            }
                        } finally {
                            System.out.println("Thread " + threadId + " releasing");
                            semaphore.release();
                        }
                        return null;
                    }));
                }
                for (Future<?> task : tasks) {
                    task.get(5, TimeUnit.SECONDS);
                }
            } finally {
                tasks.forEach(task -> task.cancel(true));
            }
        }
        System.out.println("Permits restored: " + semaphore.availablePermits());
        System.out.println("Peak at most two: " + (peak.get() <= 2));
    }
}
```

Two permits are restored, and peak use stays at most two. A fair semaphore can favor waiting acquirers but neither assigns resource ownership nor bounds waiters. [Admission](#capacity-saturation-and-resource-budgets) needs a separate limit.

### CountDownLatch class {#countdownlatch}

A [CountDownLatch](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/CountDownLatch.html) waits for a one-time count to reach zero and cannot be reset. Writes before countDown() are visible after a successful await(). Count down in finally to signal completion; futures report whether the tasks succeeded.

```java
public class CountDownLatchDemo {
    public static void main(String[] args) throws Exception {
        int workerCount = 3;
        CountDownLatch latch = new CountDownLatch(workerCount);
        List<Future<Integer>> tasks = new ArrayList<>();
        try (ExecutorService executor = Executors.newFixedThreadPool(workerCount)) {
            try {
                for (int i = 0; i < workerCount; i++) {
                    int workerId = i;
                    tasks.add(executor.submit(() -> {
                        System.out.println("Worker " + workerId + " starting");
                        try {
                            Thread.sleep(100);
                            return workerId;
                        } finally {
                            System.out.println("Worker " + workerId + " done");
                            latch.countDown();
                        }
                    }));
                }
                System.out.println("Waiting for workers...");
                if (!latch.await(5, TimeUnit.SECONDS)) {
                    throw new IllegalStateException("Workers did not finish");
                }
                int sum = 0;
                for (Future<Integer> task : tasks) {
                    sum += task.get(5, TimeUnit.SECONDS);
                }
                System.out.println("All workers completed; result sum: " + sum);
            } finally {
                tasks.forEach(task -> task.cancel(true));
            }
        }
    }
}
```

A failed worker still signals the latch, then its get() reports failure. A latch can also be a starting gate; the [testing example](#deterministic-concurrency-tests) uses both roles.

### CyclicBarrier class {#cyclicbarrier}

A [CyclicBarrier](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/CyclicBarrier.html) repeatedly gathers a fixed group. BrokenBarrierException reports a broken round, not interruption of the current thread.

```java
public class CyclicBarrierDemo {
    public static void main(String[] args) throws Exception {
        int parties = 3;
        CyclicBarrier barrier = new CyclicBarrier(parties, () ->
            System.out.println("All parties arrived, barrier opened"));
        List<Future<Boolean>> tasks = new ArrayList<>();
        try (ExecutorService executor = Executors.newFixedThreadPool(parties)) {
            try {
                for (int i = 0; i < parties; i++) {
                    int threadId = i;
                    tasks.add(executor.submit(() -> {
                        try {
                            System.out.println("Thread " + threadId + " waiting at barrier");
                            barrier.await(5, TimeUnit.SECONDS);
                            System.out.println("Thread " + threadId + " passed barrier");
                            return true;
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                            return false;
                        } catch (BrokenBarrierException e) {
                            System.err.println("Barrier broken for thread " + threadId);
                            return false;
                        } catch (TimeoutException e) {
                            System.err.println("Barrier timed out for thread " + threadId);
                            return false;
                        }
                    }));
                }
                for (Future<Boolean> task : tasks) {
                    if (!task.get(6, TimeUnit.SECONDS)) {
                        throw new IllegalStateException("Barrier round failed");
                    }
                }
            } finally {
                tasks.forEach(task -> task.cancel(true));
            }
        }
    }
}
```

The barrier action runs after all three arrivals, before any participant passes. Interruption, timeout, or action failure breaks the round and wakes other waiters exceptionally. Failure before await() leaves a missing party, so peers still need bounded waits or group cancellation. Coordinate reset() so old-round and new-round participants cannot mix.

### Phaser class {#phaser}

A [Phaser](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/Phaser.html) supports repeated phases and dynamic registration. Arrival does not deregister a party. arriveAndAwaitAdvance() is not interruptible; the owner uses arrive() and timed awaitAdvanceInterruptibly(), then terminates the phaser in finally.

```java
public class PhaserDemo {
    public static void main(String[] args) throws Exception {
        Phaser phaser = new Phaser(1);
        List<Future<?>> tasks = new ArrayList<>();
        try (ExecutorService executor = Executors.newFixedThreadPool(3)) {
            try {
                for (int i = 0; i < 3; i++) {
                    int threadId = i;
                    phaser.register();
                    tasks.add(executor.submit(() -> {
                        try {
                            System.out.println("Thread " + threadId + " phase 1");
                            if (phaser.arriveAndAwaitAdvance() < 0) {
                                throw new CancellationException("Phaser terminated");
                            }
                            System.out.println("Thread " + threadId + " phase 2");
                            if (phaser.arriveAndAwaitAdvance() < 0) {
                                throw new CancellationException("Phaser terminated");
                            }
                            System.out.println("Thread " + threadId + " done");
                        } finally {
                            phaser.arriveAndDeregister();
                        }
                    }));
                }
                advanceWithin(phaser);
                System.out.println("Main: Phase 1 complete");
                advanceWithin(phaser);
                System.out.println("Main: Phase 2 complete");
                phaser.arriveAndDeregister();
                for (Future<?> task : tasks) {
                    task.get(5, TimeUnit.SECONDS);
                }
            } finally {
                phaser.forceTermination();
                tasks.forEach(task -> task.cancel(true));
            }
        }
    }

    private static void advanceWithin(Phaser phaser)
            throws InterruptedException, TimeoutException {
        int phase = phaser.arrive();
        if (phaser.awaitAdvanceInterruptibly(phase, 5, TimeUnit.SECONDS) < 0) {
            throw new CancellationException("Phaser terminated");
        }
    }
}
```

All phase-one messages precede phase-two work; subsequent logs may race with the main thread's phase-complete messages. Workers deregister in finally, and the owner deregisters after its second phase. Unlike a barrier, a phaser does not break automatically on waiter interruption or timeout. forceTermination() releases waiters with a negative phase number.

### Exchanger class {#exchanger}

[Exchanger&lt;T&gt;](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/Exchanger.html) swaps objects between two participants and publishes each one's preceding writes to the other. In a double-buffered pipeline, one fills a buffer while the other consumes the previous one, then they swap. Stop mutating a handed-off buffer until it is returned.

```java
public class ExchangerDemo {
    public static void main(String[] args) throws InterruptedException {
        Exchanger<String> exchanger = new Exchanger<>();
        Thread first = new Thread(() ->
            exchange(exchanger, "Thread 1", "Data from Thread 1"));
        Thread second = new Thread(() ->
            exchange(exchanger, "Thread 2", "Data from Thread 2"));
        first.start();
        second.start();
        try {
            first.join();
            second.join();
        } finally {
            first.interrupt();
            second.interrupt();
            first.join();
            second.join();
        }
    }

    private static void exchange(Exchanger<String> exchanger, String name, String data) {
        try {
            System.out.println(name + " exchanging: " + data);
            String received = exchanger.exchange(data, 5, TimeUnit.SECONDS);
            System.out.println(name + " received: " + received);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        } catch (TimeoutException e) {
            System.err.println(name + " had no partner before the deadline");
        }
    }
}
```

Timed exchange reports a missing partner; untimed exchange(data) waits for pairing or interruption. With more than two participants, pairing order does not guarantee routing to a particular destination; use queues when destinations matter.

## Thread-safe patterns {#thread-safe-patterns}

Thread-safe designs make mutation ownership, publication, and handoff explicit.

### Immutable objects {#immutable-objects}

An immutable object's state cannot change after construction, so safely published instances need no read locks. A final reference—and likewise a record component—can still point to mutable state.

```java
final class ImmutablePerson {
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

public class ImmutableObjectsDemo {
    public static void main(String[] args) {
        List<String> input = new ArrayList<>(List.of("Chess"));
        ImmutablePerson person = new ImmutablePerson("Alice", 30, input);
        input.add("Running");
        System.out.println(person.getName() + ": " + person.getHobbies());
        try {
            person.getHobbies().add("Swimming");
        } catch (UnsupportedOperationException e) {
            System.out.println("Returned hobbies cannot be modified");
        }
    }
}
```

List.copyOf() detaches list membership; immutable strings make the reachable hobbies state immutable. Mutable elements would still be shared. See [copies versus views](/post/ds/#factories-copies-and-mutability) for their aliasing and mutation contracts.

Without constructor-time this escape, the [final-field rules](https://docs.oracle.com/javase/specs/jls/se21/html/jls-17.html#jls-17.5) protect initialized final fields and construction-time state reachable through them. They do not protect later mutations or every non-final field under racy publication. Use [safe publication](#happens-before-and-safe-publication) as well. This class combines final fields, copying, no mutators, and no subclassing.

### Double-checked locking {#double-checked-locking}

Double-checked locking avoids monitor acquisition after lazy initialization. The second check handles threads that passed the first check together. volatile publishes the instance to readers that skip the monitor.

```java
final class DoubleCheckedLocking {
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

    public String getData() {
        return data;
    }
}

public class DoubleCheckedLockingDemo {
    public static void main(String[] args) throws Exception {
        try (ExecutorService executor = Executors.newFixedThreadPool(2)) {
            Future<DoubleCheckedLocking> first =
                executor.submit(
                    DoubleCheckedLocking::getInstance);
            Future<DoubleCheckedLocking> second =
                executor.submit(
                    DoubleCheckedLocking::getInstance);
            DoubleCheckedLocking a = first.get(5, TimeUnit.SECONDS);
            DoubleCheckedLocking b = second.get(5, TimeUnit.SECONDS);
            System.out.println("Same instance: " + (a == b));
            System.out.println("Data: " + a.getData());
        }
    }
}
```

Constructor writes precede the volatile assignment; a fast-path read of that reference sees the initialized state. Removing volatile loses publication on the unsynchronized path. This does not make later mutable singleton state thread-safe. Eager static initialization or an initialization-on-demand holder is simpler when suitable; class initialization supplies synchronization.

### Producer-consumer pattern {#producer-consumer-pattern}

A bounded queue decouples producers from consumers: put() blocks when full, take() when empty. Handoff publishes preceding writes, not later item mutations. This queue of ten carries 20 items in the successful run; the second run fails the producer early.

```java
public class ProducerConsumerDemo {
    public static void main(String[] args) throws Exception {
        runPipeline(false);
        runPipeline(true);
    }

    private static void runPipeline(boolean failProducer) throws Exception {
        BlockingQueue<Integer> queue = new LinkedBlockingQueue<>(10);
        int itemCount = 20;
        List<Future<Integer>> tasks = new ArrayList<>();
        try (ExecutorService executor = Executors.newFixedThreadPool(2)) {
            CompletionService<Integer> completion = new ExecutorCompletionService<>(executor);
            try {
                tasks.add(completion.submit(() -> {
                    for (int i = 0; i < itemCount; i++) {
                        if (failProducer && i == 7) {
                            throw new IllegalStateException("Producer failed at 7");
                        }
                        queue.put(i);
                        System.out.println("Produced: " + i);
                        Thread.sleep(10);
                    }
                    return 0;
                }));
                tasks.add(completion.submit(() -> {
                    int sum = 0;
                    for (int i = 0; i < itemCount; i++) {
                        int item = queue.take();
                        sum += item;
                        System.out.println("Consumed: " + item);
                        Thread.sleep(20);
                    }
                    return sum;
                }));

                int sum = 0;
                for (int i = 0; i < tasks.size(); i++) {
                    Future<Integer> done = completion.poll(5, TimeUnit.SECONDS);
                    if (done == null) {
                        throw new TimeoutException("Pipeline did not finish");
                    }
                    sum += done.get();
                }
                System.out.println("Consumed sum: " + sum);
            } catch (ExecutionException e) {
                if (!failProducer || !(e.getCause() instanceof IllegalStateException)) {
                    throw e;
                }
                System.out.println("Pipeline failed: " + e.getCause().getMessage());
            } finally {
                tasks.forEach(task -> task.cancel(true));
            }
        }
        System.out.println("Pipeline workers stopped");
    }
}
```

The successful run consumes 0 through 19 in FIFO order, totaling 190. Unequal sleeps simulate a slower consumer; they do not synchronize it. The failed run reports Producer failed at 7. Completion-order retrieval catches that failure without waiting for a consumer expecting 13 more items. Canceling unfinished tasks interrupts their queue waits or sleeps, and both runs end with Pipeline workers stopped.

[BlockingQueue has no close operation](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/BlockingQueue.html). Open-ended work needs an end marker per consumer after successful production, or out-of-band reporting of completion or failure, plus cancellation. A failed producer can itself become stuck trying to enqueue a marker after consumers stop. Specify whether queued items are drained or discarded and how their resources are released. Queue capacity bounds backlog, not producers waiting to put.

## Advanced task and context APIs {#advanced-task-and-context-apis}

Choose context APIs for request data, structured scopes for related tasks, and fork/join for divisible CPU work.

### Thread-local and scoped values {#thread-local-and-scoped-values}

Thread-local and scoped context let callees access request data without passing it through every intermediate method.

#### ThreadLocal class {#threadlocal}

ThreadLocal&lt;T&gt; stores a separate value for each executing thread, not each request. Remove request context in finally so a pooled worker does not carry Alice's data into Bob's request.

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

    public static void main(String[] args) throws Exception {
        try (ExecutorService executor = Executors.newSingleThreadExecutor()) {
            executor.submit(() -> processRequest("Alice")).get();
            executor.submit(() -> processRequest("Bob")).get();
            System.out.println("After requests: " + executor.submit(userContext::get).get());
        }
    }
}
```

A thread-local slot does not make a shared object thread-confined. Ordinary ThreadLocal values are not inherited. InheritableThreadLocal initializes child values at thread creation, not executor submission; mutable values may remain shared by reference.

Virtual threads support thread locals, but each thread retains its own state. Caching scarce resources this way can multiply allocations across a large thread population; use a [resource pool or semaphore](#semaphore) instead.

#### Scoped values {#scoped-values}

[ScopedValue](https://openjdk.org/jeps/446) binds a value for callees within a dynamic scope. Bindings cannot be changed in place; nested scopes may rebind them temporarily. The bound object can still be mutable and need synchronization.

```java
public class ScopedValueDemo {
    private static final ScopedValue<String> USER_ID = ScopedValue.newInstance();

    public static void main(String[] args) {
        ScopedValue.where(USER_ID, "admin").run(() -> {
            handleRequest();
            ScopedValue.where(USER_ID, "auditor").run(ScopedValueDemo::handleRequest);
            handleRequest();
        });
        System.out.println("Bound after scope: " + USER_ID.isBound());
    }

    private static void handleRequest() {
        System.out.println("Processing request for: " + USER_ID.get());
    }
}
```

Nested rebinding prints admin, auditor, then admin. Normal or exceptional scope exit restores the previous binding; after the outer scope, isBound() returns false and get() would throw NoSuchElementException. A private key restricts access to intended callees.

##### Context inheritance through structured scopes {#context-inheritance-is-structured-not-automatic-submission}

StructuredTaskScope [captures scoped bindings when created](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ScopedValue.html#inheritance); threads started by its fork() method inherit them. Ordinary executor submission does not:

```java
public class ScopedInheritanceDemo {
    private static final ScopedValue<String> USER_ID = ScopedValue.newInstance();

    public static void main(String[] args) throws Exception {
        String inherited = ScopedValue.where(USER_ID, "admin").call(() -> {
            try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
                var child = scope.fork(USER_ID::get);
                scope.join().throwIfFailed();
                try (ExecutorService executor = Executors.newSingleThreadExecutor()) {
                    System.out.println("Ordinary submission bound: "
                        + executor.submit(USER_ID::isBound).get());
                }
                return child.get();
            }
        });
        System.out.println("Inherited: " + inherited);
        System.out.println("Bound after scope: " + USER_ID.isBound());
    }
}
```

The structured child inherits admin; the ordinary executor task has no binding. Close scopes within the binding's lifetime rather than retaining them to fork under unrelated bindings.

### Structured concurrency {#structured-concurrency}

[StructuredTaskScope.ShutdownOnFailure](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/StructuredTaskScope.ShutdownOnFailure.html) ([JEP 453](https://openjdk.org/jeps/453)) starts virtual threads by default and interrupts unfinished siblings when a subtask fails. After join(), throwIfFailed() reports failure as ExecutionException; scope close waits for child termination.

```java
public class StructuredConcurrencyDemo {
    private static final Map<Integer, String> USERS = Map.of(1, "User1");
    private static final Map<Integer, String> ORDERS = Map.of(1, "Order123");

    public static void main(String[] args) throws InterruptedException, ExecutionException {
        try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {

            var userReq = scope.fork(() -> findUser());
            var orderReq = scope.fork(() -> fetchOrder());

            scope.join().throwIfFailed();

            System.out.println("User: " + userReq.get() + ", Order: " + orderReq.get());
        }
    }

    private static String findUser() {
        return Objects.requireNonNull(USERS.get(1));
    }

    private static String fetchOrder() {
        return Objects.requireNonNull(ORDERS.get(1));
    }
}
```

#### Sibling failure and the scope boundary {#sibling-failure-and-the-scope-boundary}

Here the order task fails after its sibling starts an interruptible wait:

```java
public class StructuredFailureDemo {
    public static void main(String[] args) throws InterruptedException {
        CountDownLatch siblingStarted = new CountDownLatch(1);
        AtomicBoolean siblingStopped = new AtomicBoolean();

        try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
            scope.fork(() -> {
                siblingStarted.countDown();
                try {
                    new CountDownLatch(1).await();
                    return "Unused result";
                } finally {
                    siblingStopped.set(true);
                }
            });
            scope.fork(() -> {
                if (!siblingStarted.await(5, TimeUnit.SECONDS)) {
                    throw new IllegalStateException("Sibling did not start");
                }
                throw new IllegalArgumentException("Order unavailable");
            });
            scope.join().throwIfFailed();
            throw new AssertionError("Expected a failed subtask");
        } catch (ExecutionException e) {
            System.out.println("Failure: " + e.getCause().getMessage());
        }
        System.out.println("Sibling stopped before leaving scope: " + siblingStopped.get());
    }
}
```

ShutdownOnFailure interrupts the sibling. join() may return on shutdown before sibling cleanup finishes; close() waits for child termination, so the final siblingStopped flag is true. Retrieve results only after joining and checking failure: joining alone does not make canceled or unfinished subtasks successful.

Owner interruption during join() propagates after close() interrupts and awaits unfinished children. A child ignoring interruption can delay closure. joinUntil(Instant) bounds the join wait, not subsequent shutdown or cleanup in close(). The owner must join and close the scope; arbitrary executor threads cannot take over.

### Fork/join for CPU work {#forkjoin-for-cpu-work}

[ForkJoinPool](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ForkJoinPool.html) uses work stealing for decomposable CPU work. It is not a virtual-thread-per-task executor; the virtual-thread scheduler is separate from ForkJoinPool.commonPool().

This reduction splits a read-only array without copying segments. Below the threshold it sums sequentially; above it, the worker forks one half and computes the other:

```java
final class RangeSum extends RecursiveTask<Long> {
    private static final int THRESHOLD = 10_000;
    private final long[] values;
    private final int from;
    private final int to;

    RangeSum(long[] values, int from, int to) {
        this.values = values;
        this.from = from;
        this.to = to;
    }

    @Override
    protected Long compute() {
        if (to - from <= THRESHOLD) {
            long sum = 0;
            for (int i = from; i < to; i++) {
                sum += values[i];
            }
            return sum;
        }
        int middle = from + (to - from) / 2;
        RangeSum left = new RangeSum(values, from, middle);
        RangeSum right = new RangeSum(values, middle, to);
        left.fork();
        long rightSum = right.compute();
        return left.join() + rightSum;
    }
}

public class ForkJoinReductionDemo {
    public static void main(String[] args) {
        int size = 1_000_000;
        long[] values = new long[size];
        for (int i = 0; i < size; i++) {
            values[i] = i + 1L;
        }
        int parallelism = Math.max(1, Math.min(4, Runtime.getRuntime().availableProcessors()));
        try (ForkJoinPool pool = new ForkJoinPool(parallelism)) {
            long actual = pool.invoke(new RangeSum(values, 0, values.length));
            long expected = (long) size * (size + 1) / 2;
            if (actual != expected) {
                throw new AssertionError("Expected " + expected + ", got " + actual);
            }
            System.out.println("Sum: " + actual);
        }
    }
}
```

The sum is 500000500000. Submission publishes the initialized array; no task mutates it. Total work stays O(n), while parallel splits shorten the critical path and add scheduling overhead. The 10_000 threshold is workload-specific. Small arrays, memory bandwidth, allocation and boxing, and competing CPU load can favor a sequential loop. Arbitrary inputs may overflow long.

Unmanaged blocking I/O or unrelated locks can starve fork/join workers. ForkJoinPool.ManagedBlocker lets the scheduler compensate for unavoidable blocking, not create downstream capacity; otherwise use a separate executor. Canceling a fork/join task does not promise to interrupt running computation. Large cancelable reductions need cooperative checks between finite leaves.

## Practical API choices {#best-practices}

Match execution, cancellation, and synchronization APIs to the work and the invariant they must preserve.

### Prefer high-level concurrency utilities {#prefer-high-level-concurrency-utilities}

Standard utilities cover permit counts, completion signals, barriers, and queue handoff. If their protocols do not fit, use custom wait() and notify() coordination.

### Use executors {#use-thread-pools}

Close locally created executors after use:

```java
Runnable task = () -> System.out.println("Task executed");

try (ExecutorService platformThreads = Executors.newFixedThreadPool(4)) {
    platformThreads.submit(task);
}

try (ExecutorService virtualThreads = Executors.newVirtualThreadPerTaskExecutor()) {
    virtualThreads.submit(task);
}
```

### Handle InterruptedException {#handle-interruptedexception-properly}

At a boundary that cannot throw, restore interruption after cleanup. The caller must handle the flag; restoration alone does not stop a loop. See [thread operations](#thread-operations).

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

### Minimize synchronization scope {#minimize-synchronization-scope}

Protect the [shared invariant](#visibility-atomicity-and-invariants), not unrelated computation or I/O.

### Use concurrent collections {#use-concurrent-collections}

For a read-modify-write, lock the synchronized wrapper or use ConcurrentHashMap.merge() for an atomic per-key update. The collection article covers [wrapper traversal rules](/post/ds/#thread-safety-boundaries) and [ConcurrentHashMap traversal, nulls, and multi-key limits](/post/ds/#concurrenthashmap).

```java
Map<String, Integer> synchronizedMap = Collections.synchronizedMap(new HashMap<>());
synchronized (synchronizedMap) {
    synchronizedMap.put("count", synchronizedMap.getOrDefault("count", 0) + 1);
}

ConcurrentHashMap<String, Integer> concurrentMap = new ConcurrentHashMap<>();
concurrentMap.merge("count", 1, Integer::sum);
```

## Testing and diagnosis {#testing-and-diagnosis}

Coordinated tests check defined outcomes; stress tests and live diagnostics expose behavior beyond a controlled schedule.

### Deterministic concurrency tests {#deterministic-concurrency-tests}

- Coordinate “started,” “may proceed,” and “finished” with latches or barriers, not guessed sleeps.
- Bound waits; an external process timeout also covers code that ignores interruption.
- Retrieve task outcomes and assert invariants after a defined completion edge.
- Exercise worker failure, caller interruption, timeout, cancellation, and overload.
- Release gates and cancel tasks in finally, then close executors.

This check covers atomic increments, reported worker failure, and acknowledged cancellation:

```java
public class ConcurrentInvariantTestDemo {
    public static void main(String[] args) throws Exception {
        AtomicInteger counter = new AtomicInteger();
        CountDownLatch ready = new CountDownLatch(2);
        CountDownLatch start = new CountDownLatch(1);
        List<Future<?>> tasks = new ArrayList<>();
        try (ExecutorService executor = Executors.newFixedThreadPool(2)) {
            try {
                for (int i = 0; i < 2; i++) {
                    tasks.add(executor.submit(() -> {
                        ready.countDown();
                        require(start.await(5, TimeUnit.SECONDS), "Start gate timed out");
                        for (int n = 0; n < 1000; n++) {
                            counter.incrementAndGet();
                        }
                        return null;
                    }));
                }
                require(ready.await(5, TimeUnit.SECONDS), "Workers did not become ready");
                start.countDown();
                for (Future<?> task : tasks) {
                    task.get(5, TimeUnit.SECONDS);
                }
                require(counter.get() == 2000, "Counter invariant failed");

                Future<Void> failed = executor.submit((Callable<Void>) () -> {
                    throw new IllegalStateException("Expected failure");
                });
                tasks.add(failed);
                try {
                    failed.get(5, TimeUnit.SECONDS);
                    throw new AssertionError("Worker failure was not reported");
                } catch (ExecutionException e) {
                    require(e.getCause() instanceof IllegalStateException, "Wrong failure");
                }

                CountDownLatch waiting = new CountDownLatch(1);
                CountDownLatch stopped = new CountDownLatch(1);
                Future<Void> cancellable = executor.submit(() -> {
                    waiting.countDown();
                    try {
                        new CountDownLatch(1).await();
                        return null;
                    } finally {
                        stopped.countDown();
                    }
                });
                tasks.add(cancellable);
                require(waiting.await(5, TimeUnit.SECONDS), "Cancellation target did not start");
                require(cancellable.cancel(true), "Cancellation was not accepted");
                require(stopped.await(5, TimeUnit.SECONDS), "Worker cleanup was not observed");
                require(cancellable.isCancelled(), "Future did not retain cancelled outcome");
            } finally {
                start.countDown();
                tasks.forEach(task -> task.cancel(true));
            }
        }
        System.out.println("Invariant, failure, and cancellation checks passed");
    }

    private static void require(boolean condition, String message) {
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}
```

Expected output is Invariant, failure, and cancellation checks passed. Other finite failure cases cover [saturation](#capacity-saturation-and-resource-budgets), [lock order](#lock-order-deadlock), [pool exhaustion](#nested-task-pool-exhaustion), [pipelines](#producer-consumer-pattern), and [structured siblings](#sibling-failure-and-the-scope-boundary).

To test caller interruption, run ExecutorServiceDemo.main() on another thread. Observe its stack waiting in Future.get(), interrupt that caller, then join it with a deadline. Report its exception and check process termination. Interrupting the worker exercises a different path; sleeping before interruption does not establish which wait was interrupted.

### Stress tests with jcstress {#stress-testing-and-jcstress}

Stress tests explore schedules, compiler optimizations, architectures, and load beyond coordinated test cases. Successful runs cannot supply a missing happens-before edge; logging or test coordination may accidentally add synchronization and hide a race.

[OpenJDK jcstress](https://openjdk.org/projects/code-tools/jcstress/) tests allowed and forbidden concurrency outcomes, not throughput; its [project and examples](https://github.com/openjdk/jcstress) use a generated harness.

The publication example has these actors and outcomes:

| Actor or outcome | Operation |
|---|---|
| Writer | Assign ordinary payload = 42, then volatile ready = true |
| Reader | Read ready once; record payload if true, otherwise record -1 |
| Acceptable outcome | -1: reader did not observe publication; 42: published payload observed |
| Forbidden outcome | 0 after observing ready == true: violates the volatile publication edge |

Without volatile or another publication edge, 0 is not forbidden. A latch from writer completion to reader execution would add that edge and test a different program; coordinate trial setup and result collection without synchronizing away the actor race.

Two actors incrementing a volatile counter with count++ can finish at 1 or 2; two actors using atomic incrementAndGet() must finish at 2. Classify outcomes from the Java Memory Model before testing. Measure performance separately, including queueing latency, cancellation cost, resource saturation, and allocation—not only throughput.

### Diagnose running programs {#diagnosing-running-java-21-programs}

- **Platform workers blocked on locks:** compare stacks, owned locks, and repeated dumps for a lock-order cycle versus contention.
- **Parent in Future.get(), child queued:** inspect queue and active-worker counts for pool exhaustion versus slow work.
- **Many waiting virtual threads:** compare virtual-thread dumps with permit, connection, and queue counts for expected I/O versus unbounded admission.
- **Runnable virtual work with low throughput:** inspect pinned events alongside carrier and native stacks for pinning versus CPU saturation.
- **Periodic work stopped:** inspect its scheduled future and exception for failure suppression versus late execution.
- **Timed-out future, busy resources:** inspect supplier stacks and cleanup acknowledgements for work continuing after completion.

Attach on the same host with matching effective user and group IDs. Containers also require matching PID namespaces and attach access. The [jcmd manual](https://docs.oracle.com/en/java/javase/21/docs/specs/man/jcmd.html) describes command impact and target-specific help. Select the application PID:

```sh
jcmd -l
printf 'Java PID: '
read -r PID
jcmd "$PID" help Thread.print
jcmd "$PID" Thread.print -l
jcmd "$PID" Thread.dump_to_file -format=json "/tmp/threads-$PID.json"
```

Thread.print -l shows platform stacks and lock information. The [JSON thread dump](https://openjdk.org/jeps/444#Observing-virtual-threads) includes virtual and platform threads but omits traditional dumps' object addresses, lock details, and JNI details. Use a new filename for each dump. WAITING alone does not prove deadlock; compare lock ownership and dependencies across dumps. ThreadMXBean deadlock detection covers platform threads, not virtual-thread cycles.

Record the selected live process for 30 seconds:

```sh
jcmd "$PID" JFR.start name=concurrency settings=profile duration=30s filename=/tmp/concurrency.jfr
jcmd "$PID" JFR.check name=concurrency
```

After recording finishes, inspect the file with JDK Mission Control or the jfr print command:

```sh
jfr print --events jdk.VirtualThreadPinned /tmp/concurrency.jfr
jfr print --events jdk.JavaMonitorEnter /tmp/concurrency.jfr
jfr print --events jdk.ThreadPark /tmp/concurrency.jfr
```

Compare event durations and stacks with latency, queue size, active workers, and downstream occupancy. With a 20 ms threshold, shorter pinning intervals produce no jdk.VirtualThreadPinned event. No events may simply mean none qualified during the recording. Settings determine collection. For native blocking, also collect evidence from native code or libraries.

#### Finite pinning reproducer {#a-finite-pinning-reproducer}

Sleeping while holding a monitor can pin a virtual thread to its carrier:

```java
public class VirtualThreadPinningDemo {
    public static void main(String[] args) throws InterruptedException {
        Object lock = new Object();
        Thread worker = Thread.ofVirtual().start(() -> {
            synchronized (lock) {
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }
        });
        try {
            worker.join();
        } finally {
            worker.interrupt();
            worker.join();
        }
        System.out.println("Pinning worker terminated");
    }
}
```

When possible, move long blocking calls outside critical sections; an explicit lock is an alternative for frequent blocking paths. Compare under the same workload. Replacing every synchronized block or reducing thread count does not fix a downstream bottleneck.
