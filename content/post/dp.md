---
title: "DP - Design Patterns"
description: "22 design patterns in Java, with examples and practical trade-offs."
date: 2024-12-30T13:00:00Z
draft: false
---

These 22 patterns follow [*Dive Into Design Patterns*](https://refactoring.guru/design-patterns/book).

## Contents

- **Creational:** [Factory Method](#factory-method), [Abstract Factory](#abstract-factory), [Builder](#builder), [Prototype](#prototype), [Singleton](#singleton).
- **Structural:** [Adapter](#adapter), [Bridge](#bridge), [Composite](#composite), [Decorator](#decorator), [Facade](#facade), [Flyweight](#flyweight), [Proxy](#proxy).
- **Behavioral:** [Chain of Responsibility](#chain-of-responsibility), [Command](#command), [Iterator](#iterator), [Mediator](#mediator), [Memento](#memento), [Observer](#observer), [State](#state), [Strategy](#strategy), [Template Method](#template-method), [Visitor](#visitor).
- **Comparisons and Java alternatives:** [Creational choices](#choosing-creational-patterns), [records and ownership](#records-and-ownership), [structural wrappers](#choosing-structural-wrappers), [Mediator or Observer](#mediator-or-observer), [behavioral choices](#choosing-behavioral-boundaries), [sealed data and switches](#sealed-data-and-exhaustive-switches).

# Creational Patterns

## Factory Method

Factory Method lets a superclass algorithm create products through a method its subclasses override. Here the window-rendering workflow stays the same while each dialog selects a platform-specific button.

```java
// Product
interface Button {
    void render();
}

// Concrete Product
class WindowsButton implements Button {
    @Override
    public void render() {
        System.out.println("Rendering Windows Button");
    }
}

// Concrete Product
class MacButton implements Button {
    @Override
    public void render() {
        System.out.println("Rendering Mac Button");
    }
}

// Creator
abstract class Dialog {
    abstract Button createButton();

    void renderWindow() {
        Button btn = createButton();
        btn.render();
    }
}

// Concrete Creator
class WindowsDialog extends Dialog {
    @Override
    Button createButton() {
        return new WindowsButton();
    }
}

// Concrete Creator
class MacDialog extends Dialog {
    @Override
    Button createButton() {
        return new MacButton();
    }
}

// Client code
public class FactoryMethodDemo {
    public static void main(String[] args) {
        Dialog dialog = new WindowsDialog();
        dialog.renderWindow();

        dialog = new MacDialog();
        dialog.renderWindow();
    }
}
```

Product selection is tied to a creator subclass. If no superclass workflow needs that creation hook, a supplier or simple factory is clearer. A static method named `createButton` alone is not Factory Method: the superclass must call an overridable creation method.

## Abstract Factory

Abstract Factory chooses related products together: one factory supplies a platform's button and checkbox, so clients need not select each separately.

```java
// Product
interface Button {
    void render();
}

interface Checkbox {
    void render();
}

// Concrete Product
class WindowsButton implements Button {
    @Override
    public void render() {
        System.out.println("Rendering Windows Button");
    }
}

class WindowsCheckbox implements Checkbox {
    @Override
    public void render() {
        System.out.println("Rendering Windows Checkbox");
    }
}

class MacButton implements Button {
    @Override
    public void render() {
        System.out.println("Rendering Mac Button");
    }
}

class MacCheckbox implements Checkbox {
    @Override
    public void render() {
        System.out.println("Rendering Mac Checkbox");
    }
}

// Abstract Factory
interface GUIFactory {
    Button createButton();

    Checkbox createCheckbox();
}

// Concrete Factory
class WindowsFactory implements GUIFactory {
    @Override
    public Button createButton() {
        return new WindowsButton();
    }

    @Override
    public Checkbox createCheckbox() {
        return new WindowsCheckbox();
    }
}

class MacFactory implements GUIFactory {
    @Override
    public Button createButton() {
        return new MacButton();
    }

    @Override
    public Checkbox createCheckbox() {
        return new MacCheckbox();
    }
}

// Client code
public class AbstractFactoryDemo {
    public static void main(String[] args) {
        GUIFactory factory = new WindowsFactory();
        Button button = factory.createButton();
        Checkbox checkbox = factory.createCheckbox();
        button.render();
        checkbox.render();

        factory = new MacFactory();
        button = factory.createButton();
        checkbox = factory.createCheckbox();
        button.render();
        checkbox.render();
    }
}
```

Adding a platform leaves the client unchanged; adding a product kind changes the factory interface and every implementation. Family compatibility is a promise of those implementations, not something `GUIFactory` proves.

### Choosing creational patterns

| Pattern | Use when |
| --- | --- |
| Factory Method | A superclass workflow needs subclasses to choose one product. |
| Abstract Factory | Different products must be selected as a compatible family. |
| Builder | Assembly has optional steps or several useful representations. |
| Prototype | A configured object is the starting point, with a defined copy policy. |
| Singleton | One globally accessible instance is an actual requirement. |

Factory Method can implement individual creation operations in an Abstract Factory. For a fixed configuration built once, direct construction may be clearer than either.

## Builder

Builder gives names to optional construction steps and keeps unfinished assembly separate from the product. This product has three optional strings; omitted parts stay `null`. A fluent builder creates products directly; `PartsBuilder<T>` lets the same `assemble` recipe produce either a product or a textual specification.

```java
interface PartsBuilder<T> {
    PartsBuilder<T> setA(String part);
    PartsBuilder<T> setB(String part);
    PartsBuilder<T> setC(String part);
    T build();
}

// Product
class Product {
    private final String partA;
    private final String partB;
    private final String partC;

    private Product(Builder b) {
        this.partA = b.partA;
        this.partB = b.partB;
        this.partC = b.partC;
    }

    @Override
    public String toString() {
        return "Product{partA=" + partA + ", partB=" + partB + ", partC=" + partC + "}";
    }

    // Builder
    public static class Builder implements PartsBuilder<Product> {
        private String partA;
        private String partB;
        private String partC;

        public Builder setA(String a) {
            this.partA = a;
            return this;
        }

        public Builder setB(String b) {
            this.partB = b;
            return this;
        }

        public Builder setC(String c) {
            this.partC = c;
            return this;
        }

        public Product build() {
            return new Product(this);
        }
    }
}

class PartsTextBuilder implements PartsBuilder<String> {
    private String partA;
    private String partB;
    private String partC;

    public PartsTextBuilder setA(String part) {
        partA = part;
        return this;
    }

    public PartsTextBuilder setB(String part) {
        partB = part;
        return this;
    }

    public PartsTextBuilder setC(String part) {
        partC = part;
        return this;
    }

    public String build() {
        return "Specification[A=" + partA + ", B=" + partB + ", C=" + partC + "]";
    }
}

// Client code
public class BuilderDemo {
    static <T> T assemble(PartsBuilder<T> builder) {
        return builder.setA("A").setB("B").setC("C").build();
    }

    public static void main(String[] args) {
        Product p = new Product.Builder()
                .setA("A")
                .setB("B")
                .setC("C")
                .build();
        System.out.println(p);

        Product.Builder reusable = new Product.Builder().setA("A");
        Product first = reusable.build();
        Product second = reusable.setB("B").build();
        System.out.println(first);
        System.out.println(second);
        System.out.println(assemble(new Product.Builder()));
        System.out.println(assemble(new PartsTextBuilder()));
    }
}
```

Each `build()` creates a fresh product, but retains the builder's settings. The product's final fields and immutable string parts keep previous builds unchanged. Use a fresh builder when old settings should not carry over; do not share this mutable builder between threads.

Check individual values when supplied and cross-field rules in `build()` or the product constructor, when the full state is available. Mutable parts need an explicit copy or ownership transfer.

New representations implement the existing steps; a new required step changes every representation. A [separate director is optional](https://refactoring.guru/design-patterns/builder): `assemble` is the recipe. For a few clear required arguments, prefer a constructor or named factory.

### Records and ownership

Records generate component accessors, equality, hashing, and `toString`; they do not provide a builder or [deep immutability](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Record.html). A final component reference can still point to a mutable object.

```java
record Basket(List<String> items) {}

record OwnedBasket(List<String> items) {
    OwnedBasket {
        items = List.copyOf(items);
    }
}

public class RecordValuesDemo {
    public static void main(String[] args) {
        List<String> source = new ArrayList<>(List.of("coffee"));
        Basket shared = new Basket(source);
        OwnedBasket owned = new OwnedBasket(source);
        source.add("tea");
        System.out.println(shared.items());
        System.out.println(owned.items());
        System.out.println(owned.equals(new OwnedBasket(List.of("coffee"))));
    }
}
```

`Basket` shares its supplied list; `OwnedBasket` takes an unmodifiable copy with `List.copyOf`, which rejects null elements. Sharing the string elements is safe; mutable elements would need their own copy policy. Public component accessors also make a record unsuitable for [Memento's opaque snapshot](#memento).

## Prototype

Prototype lets callers copy a configured object through a common interface without reproducing each concrete constructor. Here `clone()` copies the label list; `shallowCopy()` shares it. Both copies can share the immutable string labels.

```java
// Prototype
interface Shape {
    Shape clone();
}

// Concrete Prototype
class Circle implements Shape {
    private final int radius;
    private final List<String> labels;

    public Circle(int radius) {
        this(radius, new ArrayList<>());
    }

    private Circle(int radius, List<String> labels) {
        this.radius = radius;
        this.labels = labels;
    }

    public void addLabel(String label) {
        labels.add(label);
    }

    public String describe() {
        return "Circle[radius=" + radius + ", labels=" + labels + "]";
    }

    public Circle shallowCopy() {
        return new Circle(radius, labels);
    }

    @Override
    public Circle clone() {
        return new Circle(radius, new ArrayList<>(labels));
    }
}

// Client code
public class PrototypeDemo {
    public static void main(String[] args) {
        Circle original = new Circle(10);
        original.addLabel("source");
        Circle copy = (Circle) original.clone();
        Circle shallow = original.shallowCopy();
        original.addLabel("edited");
        System.out.println(original.describe());
        System.out.println(shallow.describe());
        System.out.println(copy.describe());
        System.out.println(original == copy);
    }
}
```

Copying the list covers this circle's mutable state. A graph copy may also need to copy mutable elements, preserve intentional sharing, and handle cycles. Locks, resources, identities, and registrations need a domain-specific copy policy.

`Cloneable` and [`Object.clone()`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Object.html#clone()) are not required: this implementation constructs its copy explicitly. `Object.clone()` would perform only a shallow field copy. For a simple value, a copy constructor may suffice.

## Singleton

Singleton combines one shared instance with global access. Those are separate requirements: passing one ordinary instance to consumers gives shared lifetime without a global lookup. This example uses lazy double-checked locking.

```java
// Singleton
class Singleton {
    private static volatile Singleton instance;

    private Singleton() {
    }

    public static Singleton getInstance() {
        if (instance == null) {
            synchronized (Singleton.class) {
                if (instance == null) {
                    instance = new Singleton();
                }
            }
        }
        return instance;
    }
}

// Client code
public class SingletonDemo {
    public static void main(String[] args) {
        Singleton s1 = Singleton.getInstance();
        Singleton s2 = Singleton.getInstance();
        System.out.println(s1 == s2);
    }
}
```

The synchronized recheck prevents duplicate initialization; `volatile` publishes completed construction and lets later callers avoid locking. [Safe publication](https://docs.oracle.com/javase/specs/jls/se21/html/jls-17.html#jls-17.4.5) does **not** make later mutations thread-safe.

The instance is unique per [loaded class](https://docs.oracle.com/javase/specs/jls/se21/html/jls-4.html#jls-4.3.4), not across class loaders or processes. Global lookup hides dependencies and carries state between tests; explicit injection makes alternatives easier to supply. If lazy creation is unnecessary, use a `static final` instance.

# Structural Patterns

## Adapter

Adapter translates an existing API into the interface a caller expects. `UsbAdapter` makes `UsbA.power()` available as `UsbC.charge()` without changing the phone or cable. This is method adaptation, not USB protocol negotiation.

```java
// Target
interface UsbC {
    void charge();
}

// Adaptee
class UsbA {
    void power() {
        System.out.println("USB-A power");
    }
}

// Adapter
class UsbAdapter implements UsbC {
    private final UsbA usbA;

    public UsbAdapter(UsbA usbA) {
        this.usbA = usbA;
    }

    @Override
    public void charge() {
        usbA.power();
    }
}

// Client
class Phone {
    public void charge(UsbC connector) {
        connector.charge();
    }
}

// Client code
public class AdapterDemo {
    public static void main(String[] args) {
        Phone phone = new Phone();
        UsbA cable = new UsbA();
        UsbC adapter = new UsbAdapter(cable);
        phone.charge(adapter);
    }
}
```

Translation must preserve units, errors, and resource lifetime, not just rename methods. Each adapter must follow changes to the target contract. If you own both interfaces and can make them consistent without breaking callers, do that instead.

## Bridge

Bridge lets remote-control features and device types change independently. A remote holds a `Device` rather than inheriting a TV-specific or radio-specific implementation; a confirmation remote could then work with either device.

```java
// Implementor
interface Device {
    void turnOn();
}

// Concrete Implementor
class TV implements Device {
    @Override
    public void turnOn() {
        System.out.println("TV on");
    }
}
class Radio implements Device {
    @Override
    public void turnOn() {
        System.out.println("Radio on");
    }
}

// Abstraction
abstract class Remote {
    protected final Device device;

    public Remote(Device device) {
        this.device = device;
    }

    abstract void pressButton();
}

// Concrete Abstraction
class BasicRemote extends Remote {
    public BasicRemote(Device device) {
        super(device);
    }

    @Override
    void pressButton() {
        device.turnOn();
    }
}

// Client code
public class BridgeDemo {
    public static void main(String[] args) {
        Device tv = new TV();
        Remote remote = new BasicRemote(tv);
        remote.pressButton();

        Device radio = new Radio();
        remote = new BasicRemote(radio);
        remote.pressButton();
    }
}
```

Remote operations can combine device primitives, so the two interfaces need not match. New device types leave remotes unchanged, but adding a device primitive changes every implementation. Unlike Adapter, this pairing is designed for independent development, not to reconcile an existing mismatch. One stable pairing needs no separate hierarchy.

## Composite

Composite gives individual files and folders the same `show()` operation. Folders delegate recursively to their children; callers can display either one file or a subtree without branching on type. Only folders expose `add`, rather than requiring meaningless child operations on leaves.

```java
// Component
interface FileSystem {
    void show();
}

// Leaf
class File implements FileSystem {
    @Override
    public void show() {
        System.out.println("File");
    }
}

// Composite
class Folder implements FileSystem {
    private final List<FileSystem> children = new ArrayList<>();

    public void add(FileSystem fs) {
        children.add(fs);
    }

    @Override
    public void show() {
        System.out.println("Folder");
        for (FileSystem fs : children) {
            fs.show();
        }
    }
}

// Client code
public class CompositeDemo {
    public static void main(String[] args) {
        Folder root = new Folder();
        root.add(new File());
        Folder sub = new Folder();
        sub.add(new File());
        root.add(sub);
        root.show();
    }
}
```

Traversal is depth-first in insertion order: `O(n)` work and `O(h)` call depth for `n` nodes and tree height `h`.

`add` does not enforce a tree: self/ancestor insertion causes unbounded recursion, and a shared child is visited once per path. The caller must keep the structure acyclic and avoid mutation during traversal. Enforce parent ownership at attachment if the domain requires it.

New component types work with existing callers; a new common operation requires every component to implement it.

## Decorator

Decorator adds optional behavior by wrapping objects that share an interface. Compression and encryption can be stacked per data source instead of subclassing every combination. The wrappers below only label strings; they do not implement either algorithm.

```java
// Component
interface DataSource {
    void write(String data);
}

// Concrete Component
class FileDataSource implements DataSource {
    @Override
    public void write(String data) {
        System.out.println("Writing: " + data);
    }
}

// Decorator
abstract class DataSourceDecorator implements DataSource {
    protected final DataSource wrapped;

    public DataSourceDecorator(DataSource ds) {
        this.wrapped = ds;
    }

    @Override
    public void write(String data) {
        wrapped.write(data);
    }
}

// Concrete Decorator
class EncryptionDecorator extends DataSourceDecorator {
    public EncryptionDecorator(DataSource ds) {
        super(ds);
    }

    @Override
    public void write(String data) {
        super.write("Encrypted(" + data + ")");
    }
}
class CompressionDecorator extends DataSourceDecorator {
    public CompressionDecorator(DataSource ds) {
        super(ds);
    }

    @Override
    public void write(String data) {
        super.write("Compressed(" + data + ")");
    }
}

// Client code
public class DecoratorDemo {
    public static void main(String[] args) {
        DataSource ds = new FileDataSource();
        ds = new EncryptionDecorator(ds);
        ds = new CompressionDecorator(ds);
        ds.write("secret");

        DataSource reversed = new EncryptionDecorator(
                new CompressionDecorator(new FileDataSource()));
        reversed.write("secret");
    }
}
```

The first stack receives the call at compression, then encryption, producing `Encrypted(Compressed(secret))`. Reversing the wrappers produces `Compressed(Encrypted(secret))`. The outermost wrapper runs first, but its label ends up inside the result.

Order is part of behavior, and the stack still needs a failure and resource-closing policy. A wrapper shares the interface, not the identity, of its component. For a fixed transformation, an explicit pipeline may be clearer.

## Facade

Facade offers a convenient operation over several subsystems. `leaveHome()` packages the departure routine in one place; the subsystems remain usable directly if the application allows it.

```java
// Subsystems
class Light {
    void off() {
        System.out.println("Lights off");
    }
}
class AirConditioner {
    void off() {
        System.out.println("AC off");
    }
}
class SecuritySystem {
    void arm() {
        System.out.println("Alarm armed");
    }
}

// Facade
class SmartHome {
    void leaveHome() {
        new Light().off();
        new AirConditioner().off();
        new SecuritySystem().arm();
    }
}

// Client code
public class FacadeDemo {
    public static void main(String[] args) {
        SmartHome home = new SmartHome();
        home.leaveHome();
    }
}
```

The calls are sequential, not transactional: if arming security fails, the earlier light and AC operations are not rolled back. Real devices would be supplied to the facade rather than discovered by constructing objects. Keep it focused on this use case, not every application feature.

## Flyweight

Flyweight shares immutable intrinsic state while keeping per-occurrence extrinsic state separate. Transactions here share user and merchant metadata, but retain their own IDs and amounts.

```java
// Flyweight
class Merchant {
    private final String name;
    private final String location;

    public Merchant(String name, String location) {
        this.name = name;
        this.location = location;
    }

    public String getName() {
        return name;
    }
}
class User {
    private final String name;
    private final String email;

    public User(String name, String email) {
        this.name = name;
        this.email = email;
    }

    public String getName() {
        return name;
    }
}

// Flyweight Factory
class TransactionFactory {
    private static final Map<String, Merchant> merchants = new HashMap<>();
    private static final Map<String, User> users = new HashMap<>();

    public static Transaction getTransaction(String userName, String merchantName, String id, int amount) {
        User user = users.computeIfAbsent(userName, k -> new User(userName, userName + "@email.com"));
        Merchant merchant = merchants.computeIfAbsent(merchantName, k -> new Merchant(merchantName, merchantName + " location"));

        return new Transaction(id, amount, user, merchant);
    }
}

// Context
class Transaction {
    private final String id;
    private final int amount;
    private final User user;
    private final Merchant merchant;

    public Transaction(String id, int amount, User user, Merchant merchant) {
        this.id = id;
        this.amount = amount;
        this.user = user;
        this.merchant = merchant;
    }

    public boolean sharesUserWith(Transaction other) {
        return user == other.user;
    }

    public boolean sharesMerchantWith(Transaction other) {
        return merchant == other.merchant;
    }

    public void process() {
        System.out.println("Processing " + amount + "$ for " + user.getName() + " at " + merchant.getName());
    }
}

// Client code
public class FlyweightDemo {
    public static void main(String[] args) {
        Transaction t1 = TransactionFactory.getTransaction("Alice", "CoffeeShop", "TXN-001", 50);
        Transaction t2 = TransactionFactory.getTransaction("Alice", "CoffeeShop", "TXN-002", 100);
        Transaction t3 = TransactionFactory.getTransaction("Bob", "CoffeeShop", "TXN-003", 25);

        t1.process();
        t2.process();
        t3.process();
        System.out.println("Alice shared: " + t1.sharesUserWith(t2));
        System.out.println("Alice and Bob shared: " + t1.sharesUserWith(t3));
        System.out.println("Merchant shared: " + t1.sharesMerchantWith(t3));
    }
}
```

Pooling uses names as canonical keys and derives stable metadata from them. Real profiles may need IDs and versioned values instead. The static maps retain every entry for the loaded class's lifetime; this unsynchronized [`HashMap`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/HashMap.html) example is single-threaded, even when using `computeIfAbsent`.

For `t` transactions, `u` users, and `m` merchants, storage is `t` contexts plus `u + m` flyweights. Maps, keys, lookups, and unused entries also cost memory. [Measure before pooling](https://refactoring.guru/design-patterns/flyweight): mostly unique keys or already-shared values can make it a loss. Bound the pool's lifetime to the workload. Records can model immutable data but do not canonicalize it.

## Proxy

Proxy keeps the subject's interface while controlling access to it. This virtual proxy opens its database on the first query and reuses it thereafter; other proxies might check authorization, cache results, or forward remotely.

```java
// Subject
interface Database {
    void query(String sql);
}

// Real Subject
class RealDatabase implements Database {
    public RealDatabase() {
        System.out.println("Connecting to DB...");
    }

    @Override
    public void query(String sql) {
        System.out.println("Executing: " + sql);
    }
}

// Proxy
class DatabaseProxy implements Database {
    private RealDatabase realDb;

    @Override
    public void query(String sql) {
        if (realDb == null) {
            realDb = new RealDatabase();
        }
        realDb.query(sql);
    }
}

// Client code
public class ProxyDemo {
    public static void main(String[] args) {
        Database db = new DatabaseProxy();
        db.query("SELECT * FROM users");
        db.query("SELECT COUNT(*) FROM users");
    }
}
```

Lazy creation also delays cost and failures until a query. This implementation is single-threaded: concurrent queries could create multiple subjects or publish one unsafely. Safe initialization and the connection's own concurrency policy are separate requirements.

This demonstration only prints; a real connection needs an explicit owner and closing policy, including initialization and query failures.

### Choosing structural wrappers

| Pattern | Purpose |
| --- | --- |
| Adapter | Translate an incompatible API into the caller's target interface. |
| Decorator | Add optional behavior while keeping the component interface; order matters. |
| Proxy | Control access or creation while keeping the subject interface. |
| Facade | Offer a focused operation over subsystem APIs. |

# Behavioral Patterns

## Chain of Responsibility

Chain of Responsibility lets each handler process a request and decide whether to forward it. A chain can stop at the first handler that accepts a request, or act as a pipeline of contributing steps. Here authorization allows only `POST /data`; returning without forwarding rejects the request before validation and caching.

```java
// Handler
abstract class Middleware {
    private Middleware next;

    public Middleware setNext(Middleware next) {
        this.next = next;
        return next;
    }

    public void handle(String request) {
        if (next != null) {
            next.handle(request);
        }
    }
}

// Concrete Handlers
class LogMiddleware extends Middleware {
    @Override
    public void handle(String request) {
        System.out.println("Logging request...");
        super.handle(request);
    }
}
class AuthMiddleware extends Middleware {
    @Override
    public void handle(String request) {
        System.out.println("Auth check...");
        if (!"POST /data".equals(request)) {
            System.out.println("Authorization denied");
            return;
        }
        super.handle(request);
    }
}
class ValidationMiddleware extends Middleware {
    @Override
    public void handle(String request) {
        System.out.println("Validating payload...");
        super.handle(request);
    }
}
class CacheMiddleware extends Middleware {
    @Override
    public void handle(String request) {
        System.out.println("Checking cache...");
        super.handle(request);
    }
}

// Client code
public class ChainOfResponsibilityDemo {
    public static void main(String[] args) {
        Middleware chain = new LogMiddleware();
        chain.setNext(new AuthMiddleware())
             .setNext(new ValidationMiddleware())
             .setNext(new CacheMiddleware());
        chain.handle("POST /data");
        chain.handle("DELETE /data");
    }
}
```

Order matters: logging before authorization records rejected attempts; logging after it would not. The tail silently returns, so reaching it does not prove a business operation occurred. Model a required result explicitly and keep the chain acyclic.

## Command

Command stores a request as an object so an invoker can execute it later or keep undo history. Here each light-on request captures its receiver and records the light's prior state **when executed**, not when constructed or queued.

```java
// Command
interface Command {
    void execute();
}

interface UndoableCommand extends Command {
    void undo();
}

// Receiver
class Light {
    private boolean on;

    boolean isOn() {
        return on;
    }

    void setOn(boolean on) {
        this.on = on;
        System.out.println(on ? "Light on" : "Light off");
    }

    void on() {
        setOn(true);
    }
}

// Concrete Command
class LightOnCommand implements UndoableCommand {
    private final Light light;
    private boolean previous;
    private boolean applied;

    public LightOnCommand(Light light) {
        this.light = light;
    }

    @Override
    public void execute() {
        if (applied) {
            throw new IllegalStateException("Undo before executing this command again");
        }
        previous = light.isOn();
        light.on();
        applied = true;
    }

    @Override
    public void undo() {
        if (!applied) {
            throw new IllegalStateException("The command has not been applied");
        }
        light.setOn(previous);
        applied = false;
    }
}

// Invoker
class RemoteControl {
    private UndoableCommand command;
    private final Deque<UndoableCommand> pending = new ArrayDeque<>();
    private final Deque<UndoableCommand> history = new ArrayDeque<>();

    public void setCommand(UndoableCommand command) {
        this.command = command;
    }

    private void execute(UndoableCommand next) {
        next.execute();
        history.push(next);
    }

    public void pressButton() {
        execute(command);
    }

    public void enqueue(UndoableCommand next) {
        pending.addLast(next);
    }

    public void runQueued() {
        while (!pending.isEmpty()) {
            execute(pending.removeFirst());
        }
    }

    public boolean undo() {
        if (history.isEmpty()) {
            return false;
        }
        history.peek().undo();
        history.pop();
        return true;
    }
}

// Client code
public class CommandDemo {
    public static void main(String[] args) {
        Light light = new Light();
        UndoableCommand command = new LightOnCommand(light);
        RemoteControl remote = new RemoteControl();
        remote.setCommand(command);
        remote.pressButton();
        remote.undo();

        remote.enqueue(new LightOnCommand(light));
        remote.enqueue(new LightOnCommand(light));
        System.out.println("Before queued execution: " + light.isOn());
        remote.runQueued();
        remote.undo();
        System.out.println("After one undo: " + light.isOn());
        remote.undo();
        System.out.println("After two undos: " + light.isOn());

        Command turnOn = light::on;
        turnOn.execute();
    }
}
```

Undo restores prior state, not a presumed inverse: undoing the second of two “on” commands must leave the light on. This implementation runs its queue FIFO and undoes history LIFO; a light-on command cannot execute again while its saved state is active.

Only successful executions enter history; execution exceptions propagate. Undo removes an entry only after restoration succeeds. This assumes sequential, exclusive control of the light: an unrelated change could be overwritten by old history. Bound or clear history, which retains receivers and saved state.

Larger state can use a [Memento](#memento). Neither mechanism makes partial work transactional, and external effects such as sending email may need compensation rather than undo.

For a simple request, [a method reference](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/FunctionalInterface.html) such as `Command turnOn = light::on` avoids a dedicated class. It has no undo state, and its captured receiver remains retained. Classes remain useful for prior state, metadata, or other request lifecycle rules; lambdas do not turn requests into durable messages.

## Iterator

Iterator separates a traversal's cursor from collection storage. Each call to `iterator()` here gets an independent cursor, and enhanced `for` uses the same protocol.

```java
// Concrete Iterator
class NameIterator implements Iterator<String> {
    private final String[] names;
    private int position = 0;

    public NameIterator(String[] names) {
        this.names = names;
    }

    @Override
    public boolean hasNext() {
        return position < names.length;
    }

    @Override
    public String next() {
        if (!hasNext()) {
            throw new NoSuchElementException();
        }
        return names[position++];
    }
}

// Concrete Collection
class NameCollection implements Iterable<String> {
    private final String[] names = {"Alice", "Bob", "Charlie"};

    @Override
    public Iterator<String> iterator() {
        return new NameIterator(names);
    }
}

// Client code
public class IteratorDemo {
    public static void main(String[] args) {
        NameCollection collection = new NameCollection();

        for (String name : collection) {
            System.out.println(name);
        }

        Iterator<String> first = collection.iterator();
        Iterator<String> second = collection.iterator();
        System.out.println("First iterator: " + first.next());
        System.out.println("Second iterator: " + second.next());
        try {
            new NameIterator(new String[0]).next();
        } catch (NoSuchElementException e) {
            System.out.println("No next element");
        }
    }
}
```

`hasNext()` does not advance; [`next()`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Iterator.html#next()) advances or throws `NoSuchElementException` at exhaustion. Removal is unsupported. The iterator shares its supplied array: no snapshot, modification detection, or thread-safety guarantee. The collection's own array is private and unchanged in this example.

Use a standard collection's iterator unless custom storage or traversal requires your own.

## Mediator

Mediator puts routing and coordination in one object rather than spreading peer references through participants. Here the spouses send through their lawyer, who chooses the recipient. Both participants must be registered before sending; the implementation assumes no other sender.

```java
// Mediator
interface Mediator {
    void send(String msg, Spouse originator);
}

// Concrete Mediator
class DivorceLawyer implements Mediator {
    private Spouse husband, wife;

    public void setHusband(Spouse h) {
        this.husband = h;
    }

    public void setWife(Spouse w) {
        this.wife = w;
    }

    @Override
    public void send(String msg, Spouse originator) {
        if (originator == husband) {
            wife.receive(msg);
        } else {
            husband.receive(msg);
        }
    }
}

// Component
abstract class Spouse {
    protected final Mediator mediator;

    public Spouse(Mediator mediator) {
        this.mediator = mediator;
    }

    public abstract void receive(String msg);
}

// Concrete Component
class Husband extends Spouse {
    public Husband(Mediator mediator) {
        super(mediator);
    }

    public void send(String msg) {
        mediator.send(msg, this);
    }

    @Override
    public void receive(String msg) {
        System.out.println("Husband receives: " + msg);
    }
}

class Wife extends Spouse {
    public Wife(Mediator mediator) {
        super(mediator);
    }

    public void send(String msg) {
        mediator.send(msg, this);
    }

    @Override
    public void receive(String msg) {
        System.out.println("Wife receives: " + msg);
    }
}

// Client code
public class MediatorDemo {
    public static void main(String[] args) {
        DivorceLawyer lawyer = new DivorceLawyer();
        Husband husband = new Husband(lawyer);
        Wife wife = new Wife(lawyer);
        lawyer.setHusband(husband);
        lawyer.setWife(wife);

        husband.send("I want the car");
        wife.send("I want the house");
    }
}
```

New participants or negotiation rules may still require changing the mediator. Keeping participants independent can centralize too much policy in the coordinator; limit it to one coherent interaction.

### Mediator or Observer?

Mediator coordinates known participants and can choose recipients. [Observer](#observer) broadcasts events to current subscribers without defining their business workflow. Subscriptions can be used inside a mediator, but do not replace its routing policy.

## Memento

Memento saves restorable state without exposing its representation to the history manager. `Editor.Snapshot` is an [opaque nested snapshot](https://refactoring.guru/design-patterns/memento): clients can pass it back but cannot inspect or manufacture it. `EditorHistory` saves before each replacement and uses a stack for undo.

```java
// Originator
class Editor {
    private String content = "";

    static final class Snapshot {
        private final String content;

        private Snapshot(String content) {
            this.content = content;
        }
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getContent() {
        return content;
    }

    public Snapshot save() {
        return new Snapshot(content);
    }

    public void restore(Snapshot s) {
        content = s.content;
    }
}

class EditorHistory {
    private final Editor editor;
    private final Deque<Editor.Snapshot> history = new ArrayDeque<>();

    EditorHistory(Editor editor) {
        this.editor = editor;
    }

    public void replace(String content) {
        history.push(editor.save());
        editor.setContent(content);
    }

    public boolean undo() {
        if (history.isEmpty()) {
            return false;
        }
        editor.restore(history.pop());
        return true;
    }

    public void clear() {
        history.clear();
    }
}

// Client code
public class MementoDemo {
    public static void main(String[] args) {
        Editor editor = new Editor();
        editor.setContent("Version 1");
        Editor.Snapshot s = editor.save();
        editor.setContent("Version 2");
        editor.restore(s);
        System.out.println(editor.getContent());

        EditorHistory history = new EditorHistory(editor);
        history.replace("Version 2");
        history.replace("Version 3");
        history.undo();
        System.out.println(editor.getContent());
        history.undo();
        System.out.println(editor.getContent());
        System.out.println("Undo empty: " + history.undo());
        history.replace("Version 4");
        history.clear();
        System.out.println("Undo after clear: " + history.undo());
        System.out.println(editor.getContent());
    }
}
```

Undo restores the most recent saved content; an empty history returns `false`. Clearing history discards undo data without changing current content. Redo and branching are separate history policies.

A snapshot must remain stable after capture. Retaining the old immutable string is enough here; a mutable document graph needs copying or persistent data. These snapshots are not bound to an editor identity, so single-editor use is the caretaker's policy. They are not a durable format, and restoring content does not reverse external file writes.

Old data stays reachable through saved snapshots. Bound history to an edit count or document session. [Command](#command) can retain a memento for undo; saving one reversible value directly may be enough when opacity is unnecessary.

## Observer

Observer sends events to a changing set of subscribers without embedding their behavior in the publisher. Whoever creates a temporary subscription must also arrange its removal.

This channel delivers **synchronously, on the notifying thread, in registration order**. Each notification copies the registration list: callback-driven changes affect later notifications, not the current one. The first callback exception propagates and stops delivery. These are implementation policies, not Observer guarantees.

```java
// Subject
class Channel {
    private final List<Subscriber> subs = new ArrayList<>();

    public void subscribe(Subscriber s) {
        subs.add(s);
    }

    public void unsubscribe(Subscriber s) {
        subs.remove(s);
    }

    public void notifySubs(String msg) {
        for (Subscriber s : new ArrayList<>(subs)) {
            s.update(msg);
        }
    }
}

// Observer
interface Subscriber {
    void update(String msg);
}

// Concrete Observer
class User implements Subscriber {
    private final String name;

    public User(String name) {
        this.name = name;
    }

    @Override
    public void update(String msg) {
        System.out.println(name + " got: " + msg);
    }
}

// Client code
public class ObserverDemo {
    public static void main(String[] args) {
        Channel channel = new Channel();
        User alice = new User("Alice");
        User bob = new User("Bob");
        channel.subscribe(alice);
        channel.notifySubs("New video!");
        channel.subscribe(bob);
        channel.notifySubs("Live stream!");
        channel.unsubscribe(alice);
        channel.notifySubs("Members update!");
        channel.unsubscribe(bob);

        Channel changing = new Channel();
        Subscriber departing = new User("Leaving");
        Subscriber remover = msg -> {
            System.out.println("Removing listener");
            changing.unsubscribe(departing);
        };
        changing.subscribe(remover);
        changing.subscribe(departing);
        changing.notifySubs("Current event");
        changing.notifySubs("Next event");
        changing.unsubscribe(remover);

        Channel failing = new Channel();
        failing.subscribe(msg -> {
            throw new IllegalStateException("subscriber failed");
        });
        failing.subscribe(new User("Skipped"));
        try {
            failing.notifySubs("Failure event");
        } catch (IllegalStateException e) {
            System.out.println("Delivery stopped: " + e.getMessage());
        }
    }
}
```

Duplicate registrations cause duplicate callbacks. `unsubscribe` removes the first `equals` match; `User` uses identity equality. Keep the subscriber reference, and unsubscribe at the end of a screen, document, or session: the publisher strongly retains registered subscribers. Other references or callback captures can retain them after removal.

A slow callback blocks the caller and later subscribers. Copying `s` registrations costs `O(s)` time and space; it permits callback-driven list changes, not concurrent use of `Channel`. Reentrant notifications run immediately with their own copies and can recurse indefinitely.

## State

State delegates events to behavior objects selected by the context's current lifecycle state. The player changes state after starting or stopping playback, so the same Play button performs different operations.

```java
// State
interface State {
    void clickPlay(Player player);
    void clickNext(Player player);
}

// Concrete States
class ReadyState implements State {
    @Override
    public void clickPlay(Player player) {
        player.startPlayback();
        player.setState(new PlayingState());
    }

    @Override
    public void clickNext(Player player) {
        System.out.println("Locked: Start playback first");
    }
}

class PlayingState implements State {
    @Override
    public void clickPlay(Player player) {
        player.stopPlayback();
        player.setState(new ReadyState());
    }

    @Override
    public void clickNext(Player player) {
        player.nextTrack();
    }
}

// Context
class Player {
    private State state = new ReadyState();

    public void setState(State state) {
        this.state = state;
    }

    public void clickPlay() {
        state.clickPlay(this);
    }

    public void clickNext() {
        state.clickNext(this);
    }

    public void startPlayback() {
        System.out.println("Playback started");
    }

    public void stopPlayback() {
        System.out.println("Playback stopped");
    }

    public void nextTrack() {
        System.out.println("Next track");
    }
}

// Client code
public class StateDemo {
    public static void main(String[] args) {
        Player player = new Player();
        player.clickNext();
        player.clickPlay();
        player.clickNext();
        player.clickPlay();
    }
}
```

| Current state | Play | Next |
| --- | --- | --- |
| Ready | Start, then become Playing | Reject; remain Ready |
| Playing | Stop, then become Ready | Advance; remain Playing |

Adding an event changes `State` and every implementation; adding a state may require new incoming transitions. Here states own transitions; the context could centralize them instead. Public `setState` does not enforce allowed transitions, and operation failure is not rolled back automatically.

These states have no per-player data and could be shared. A state with player-specific mutable fields must not be shared between players. For two small, stable cases, an enum and switch may be simpler.

## Strategy

Strategy lets a prisoner's-dilemma tournament accept different move-selection policies without changing match rules or scoring. Each policy receives only the opponent's previous move; both current moves are chosen before history is updated. Moves must be `"Cooperate"` or `"Defect"`; `null` means no previous move.

The four policies:

- **RandomStrategy:** cooperate or defect with equal probability, independent of the opponent's last move.
- **TitForTat:** cooperate first, then copy the opponent's previous move.
- **JossStrategy:** defect after an opponent's defection; otherwise cooperate with probability 0.9 and defect with probability 0.1.
- **FriedmanStrategy:** cooperate until observing any defection, then defect forever for that strategy instance.

```java
// Strategy
interface Strategy {
    String getMove(String lastMove);
}

// Concrete Strategies
class RandomStrategy implements Strategy {
    private final Random random;

    public RandomStrategy() {
        this(new Random());
    }

    public RandomStrategy(Random random) {
        this.random = random;
    }

    @Override
    public String getMove(String lastMove) {
        return random.nextBoolean() ? "Cooperate" : "Defect";
    }
}
class TitForTat implements Strategy {
    @Override
    public String getMove(String lastMove) {
        return (lastMove == null || "Cooperate".equals(lastMove)) ? "Cooperate" : "Defect";
    }
}
class JossStrategy implements Strategy {
    private final Random random;

    public JossStrategy() {
        this(new Random());
    }

    public JossStrategy(Random random) {
        this.random = random;
    }

    @Override
    public String getMove(String lastMove) {
        if ("Defect".equals(lastMove)) return "Defect";
        return random.nextDouble() < 0.9 ? "Cooperate" : "Defect";
    }
}
class FriedmanStrategy implements Strategy {
    private boolean betrayed = false;
    @Override
    public String getMove(String lastMove) {
        if ("Defect".equals(lastMove)) betrayed = true;
        return betrayed ? "Defect" : "Cooperate";
    }
}

// Context
class Tournament {
    private final Strategy s1, s2;
    private int score1 = 0, score2 = 0;

    public Tournament(Strategy s1, Strategy s2) {
        this.s1 = s1;
        this.s2 = s2;
    }

    public void run(int rounds) {
        String lastMove1 = null, lastMove2 = null;
        for (int i = 0; i < rounds; i++) {
            String m1 = s1.getMove(lastMove2), m2 = s2.getMove(lastMove1);
            switch (m1 + m2) {
                case "CooperateCooperate" -> {
                    score1 += 3;
                    score2 += 3;
                }
                case "DefectCooperate" -> {
                    score1 += 5;
                    score2 += 0;
                }
                case "CooperateDefect" -> {
                    score1 += 0;
                    score2 += 5;
                }
                case "DefectDefect" -> {
                    score1 += 1;
                    score2 += 1;
                }
            }
            lastMove1 = m1;
            lastMove2 = m2;
        }
        System.out.println("Final Scores - S1: " + score1 + " | S2: " + score2);
    }
}

// Client code
public class StrategyDemo {
    public static void main(String[] args) {
        Tournament t = new Tournament(
                new RandomStrategy(new Random(42)), new TitForTat());
        t.run(10 + new Random(7).nextInt(100));

        new Tournament(new JossStrategy(new Random(12)), new FriedmanStrategy()).run(10);

        Strategy cooperate = lastMove -> "Cooperate";
        new Tournament(cooperate, new TitForTat()).run(3);

        FriedmanStrategy retained = new FriedmanStrategy();
        System.out.println("Fresh match: " + retained.getMove(null));
        System.out.println("After betrayal: " + retained.getMove("Defect"));
        System.out.println("Reused in another match: " + retained.getMove(null));
        System.out.println("New instance: " + new FriedmanStrategy().getMove(null));
    }
}
```

Round payoffs:

| S1 move | S2 move | Points to S1 / S2 |
| --- | --- | --- |
| Cooperate | Cooperate | 3 / 3 |
| Defect | Cooperate | 5 / 0 |
| Cooperate | Defect | 0 / 5 |
| Defect | Defect | 1 / 1 |

The seeds make the randomized sample matches reproducible; the first also picks a length of 10–109 rounds.

Friedman keeps a `betrayed` flag: passing `null` at a new match does **not** reset it. Use a fresh instance for each independent match, or define an explicit reset. TitForTat gets its entire history from the argument; randomized strategies retain generator state. `Tournament` also accumulates scores across `run` calls, so independent matches need fresh tournaments.

New policies need no scoring changes unless they require different input. Returning any other string falls outside the scoring cases; an enum would encode the allowed moves. Classes make policy state and configuration explicit; [lambdas](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/FunctionalInterface.html) suit simple stateless policies.

## Template Method

Template Method fixes an algorithm's order in a superclass and lets subclasses supply individual steps. `Game.play()` is `final`, so subclasses cannot reorder initialize/start/end through that entry point. Required steps are abstract; optional hooks could have defaults.

```java
// Abstract Class
abstract class Game {
    public final void play() {
        initialize();
        start();
        end();
    }
    abstract void initialize();
    abstract void start();
    abstract void end();
}

// Concrete Class
class Chess extends Game {
    @Override
    void initialize() {
        System.out.println("Chess init");
    }

    @Override
    void start() {
        System.out.println("Chess start");
    }

    @Override
    void end() {
        System.out.println("Chess end");
    }
}

// Client code
public class TemplateMethodDemo {
    public static void main(String[] args) {
        Game game = new Chess();
        game.play();
    }
}
```

Changing an abstract step affects every subclass; changing the sequence belongs to the superclass. Unlike Strategy, customization is tied to inheritance rather than a separately selected object.

The sequence is not a cleanup guarantee: if `start()` throws, `end()` is skipped. A lifecycle that requires unconditional cleanup needs an explicit `try`/`finally` contract.

### Choosing behavioral boundaries

| Pattern | Selection and control |
| --- | --- |
| State | Transitions change how the context responds to events. |
| Strategy | The caller selects an algorithm for a task. |
| Template Method | The superclass fixes step order; subclasses supply steps. |
| Command | The client captures a request; the invoker controls when it runs. |

## Visitor

Visitor adds operations to a stable family of element types without editing those elements for every operation. It favors changing operations over changing the type family.

Runtime dispatch selects the element's `accept`. Inside it, the statically known type of `this` selects a `visit` overload, then runtime dispatch selects the actual visitor's implementation. This double dispatch cannot be replaced by calling overloads through an `Element` reference.

```java
// Element
interface Element {
    void accept(Visitor visitor);
}

// Concrete Element
class ConcreteElement implements Element {
    @Override
    public void accept(Visitor visitor) {
        visitor.visit(this);
    }
}

class SecondConcreteElement implements Element {
    @Override
    public void accept(Visitor visitor) {
        visitor.visit(this);
    }
}

// Visitor
interface Visitor {
    void visit(ConcreteElement element);
    void visit(SecondConcreteElement element);
}

// Concrete Visitor
class ConcreteVisitor implements Visitor {
    @Override
    public void visit(ConcreteElement element) {
        System.out.println("Visited ConcreteElement");
    }

    @Override
    public void visit(SecondConcreteElement element) {
        System.out.println("Visited SecondConcreteElement");
    }
}

class CountingVisitor implements Visitor {
    private int first;
    private int second;

    @Override
    public void visit(ConcreteElement element) {
        first++;
    }

    @Override
    public void visit(SecondConcreteElement element) {
        second++;
    }

    public String summary() {
        return "Counts: first=" + first + ", second=" + second;
    }
}

// Client code
public class VisitorDemo {
    public static void main(String[] args) {
        Element[] elements = {new ConcreteElement(), new SecondConcreteElement()};
        Visitor visitor = new ConcreteVisitor();
        for (Element element : elements) {
            element.accept(visitor);
        }
        CountingVisitor counter = new CountingVisitor();
        for (Element element : elements) {
            element.accept(counter);
        }
        System.out.println(counter.summary());
    }
}
```

A new operation adds a visitor. A new element type changes `Visitor` and every implementation; visitors also need enough element API to do their work. If element types grow freely and operations belong naturally on them, ordinary polymorphic methods are simpler.

The counting visitor holds traversal state; create a fresh one when totals should not accumulate.

### Sealed data and exhaustive switches

For a closed data family, [record patterns](https://openjdk.org/jeps/440) and [pattern `switch`](https://openjdk.org/jeps/441) provide external operations without `accept` methods.

```java
sealed interface Geometry permits Circle, Rectangle {}

record Circle(double radius) implements Geometry {}

record Rectangle(double width, double height) implements Geometry {}

public class SealedVisitorAlternativeDemo {
    static double area(Geometry geometry) {
        return switch (geometry) {
            case Circle(double radius) -> Math.PI * radius * radius;
            case Rectangle(double width, double height) -> width * height;
        };
    }

    public static void main(String[] args) {
        Geometry circle = new Circle(2);
        Geometry rectangle = new Rectangle(3, 4);
        System.out.println(area(circle));
        System.out.println(area(rectangle));
        try {
            area(null);
        } catch (NullPointerException e) {
            System.out.println("A null geometry is not a shape");
        }
    }
}
```

The sealed hierarchy makes the switch exhaustive for non-null variants. Adding a permitted variant requires updating the switch on recompilation; a catch-all `default` would hide that check. Without `case null`, a null selector throws `NullPointerException`.

Like Visitor, this makes new operations easy and new variants affect existing operations. Visitor expresses the obligation through its shared interface; sealed switches use compiler exhaustiveness checks. This suits a type family whose variants you control, not an open-ended set of types.

---
