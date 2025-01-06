---
title: "DP - Design Patterns"
description: "Design Patterns in Java."
date: 2024-12-30T13:00:00Z
draft: false
---

Overview of the patterns described in the book *"Dive Into Design Patterns"* in Java:

**Creational**

- Factory Method
- Abstract Factory
- Builder
- Prototype
- Singleton

**Structural**

- Adapter
- Bridge
- Composite
- Decorator
- Facade
- Flyweight
- Proxy

**Behavioral**

- Chain of Responsibility
- Command
- Iterator
- Mediator
- Memento
- Observer
- State
- Strategy
- Template Method
- Visitor

# Creational Patterns

**Factory Method**:

A creational design pattern that provides an interface for creating objects in a superclass, but allows subclasses to alter the type of objects that will be created.

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

**Abstract Factory**:

A creational design pattern that lets you produce families of related objects without specifying their concrete classes.

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

**Builder**:

A creational design pattern that lets you construct complex objects step by step. The pattern allows you to produce different types and representations of an object using the same construction code.

```java
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

    // Builder
    public static class Builder {
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

// Client code
public class BuilderDemo {
    public static void main(String[] args) {
        Product p = new Product.Builder()
                .setA("A")
                .setB("B")
                .setC("C")
                .build();
    }
}
```

**Prototype**:

A creational design pattern that lets you copy existing objects without making your code dependent on their classes.

```java
// Prototype
interface Shape {
    Shape clone();
}

// Concrete Prototype
class Circle implements Shape {
    private final int radius;

    public Circle(int radius) {
        this.radius = radius;
    }

    @Override
    public Shape clone() {
        return new Circle(this.radius);
    }
}

// Client code
public class PrototypeDemo {
    public static void main(String[] args) {
        Circle original = new Circle(10);
        Circle copy = (Circle) original.clone();
    }
}
```

**Singleton**:

A creational design pattern that lets you ensure that a class has only one instance, while providing a global access point to this instance.

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

# Structural Patterns

**Adapter**:

A structural design pattern that allows objects with incompatible interfaces to collaborate.

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

**Bridge**:

A structural design pattern that lets you split a large class or a set of closely related classes into two separate hierarchies—abstraction and implementation—which can be developed independently of each other.

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

**Composite**:

A structural design pattern that lets you compose objects into tree structures and then work with these structures as if they were individual objects.

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

**Decorator**:

A structural design pattern that lets you attach new behaviors to objects by placing these objects inside special wrapper objects that contain the behaviors.

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
    }
}
```

**Facade**:

A structural design pattern that provides a simplified interface to a library, a framework, or any other complex set of classes.

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

**Flyweight**:

A structural design pattern that lets you fit more objects into the available amount of RAM by sharing common parts of state between multiple objects instead of keeping all of the data in each object.

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
    }
}
```

**Proxy**:

A structural design pattern that lets you provide a substitute or placeholder for another object. A proxy controls access to the original object, allowing you to perform something either before or after the request gets through to the original object.

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
    }
}
```

# Behavioral Patterns

**Chain of Responsibility**:

A behavioral design pattern that lets you pass requests along a chain of handlers. Upon receiving a request, each handler decides either to process the request or to pass it to the next handler in the chain.

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
    }
}
```

**Command**:

A behavioral design pattern that turns a request into a stand-alone object that contains all information about the request. This transformation lets you pass requests as a method arguments, delay or queue a request’s execution, and support undoable operations.

```java
// Command
interface Command {
    void execute();
}

// Receiver
class Light {
    void on() {
        System.out.println("Light on");
    }
}

// Concrete Command
class LightOnCommand implements Command {
    private final Light light;

    public LightOnCommand(Light light) {
        this.light = light;
    }

    @Override
    public void execute() {
        light.on();
    }
}

// Invoker
class RemoteControl {
    private Command command;

    public void setCommand(Command command) {
        this.command = command;
    }

    public void pressButton() {
        command.execute();
    }
}

// Client code
public class CommandDemo {
    public static void main(String[] args) {
        Light light = new Light();
        Command command = new LightOnCommand(light);
        RemoteControl remote = new RemoteControl();
        remote.setCommand(command);
        remote.pressButton();
    }
}
```

**Iterator**:

A behavioral design pattern that lets you traverse elements of a collection without exposing its underlying representation (list, stack, tree, etc.).

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
    }
}
```

**Mediator**:

A behavioral design pattern that lets you reduce chaotic dependencies between objects. The pattern restricts direct communications between the objects and forces them to collaborate only via a mediator object.

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

**Memento**:

A behavioral design pattern that lets you save and restore the previous state of an object without revealing the details of its implementation.

```java
// Memento
class Snapshot {
    private final String content;

    public Snapshot(String content) {
        this.content = content;
    }

    public String getContent() {
        return content;
    }
}

// Originator
class Editor {
    private String content;

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
        content = s.getContent();
    }
}

// Client code
public class MementoDemo {
    public static void main(String[] args) {
        Editor editor = new Editor();
        editor.setContent("Version 1");
        Snapshot s = editor.save();
        editor.setContent("Version 2");
        editor.restore(s);
        System.out.println(editor.getContent());
    }
}
```

**Observer**:

A behavioral design pattern that lets you define a subscription mechanism to notify multiple objects about any events that happen to the object they’re observing.

```java
// Subject
class Channel {
    private final List<Subscriber> subs = new ArrayList<>();

    public void subscribe(Subscriber s) {
        subs.add(s);
    }

    public void notifySubs(String msg) {
        for (Subscriber s : subs) {
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
        channel.subscribe(new User("Alice"));
        channel.notifySubs("New video!");
    }
}
```

**State**:

A behavioral design pattern that lets an object alter its behavior when its internal state changes. It appears as if the object changed its class.

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

**Strategy**:

A behavioral design pattern that lets you define a family of algorithms, put each of them into a separate class, and make their objects interchangeable.

```java
// Strategy
interface Strategy {
    String getMove(String lastMove);
}

// Concrete Strategies
class RandomStrategy implements Strategy {
    @Override
    public String getMove(String lastMove) {
        return new Random().nextBoolean() ? "Cooperate" : "Defect";
    }
}
class TitForTat implements Strategy {
    @Override
    public String getMove(String lastMove) {
        return (lastMove == null || "Cooperate".equals(lastMove)) ? "Cooperate" : "Defect";
    }
}
class JossStrategy implements Strategy {
    @Override
    public String getMove(String lastMove) {
        if ("Defect".equals(lastMove)) return "Defect";
        return new Random().nextDouble() < 0.9 ? "Cooperate" : "Defect";
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
        Tournament t = new Tournament(new RandomStrategy(), new TitForTat());
        t.run(10 + new Random().nextInt(100));
    }
}
```

**Template Method**:

A behavioral design pattern that defines the skeleton of an algorithm in the superclass but lets subclasses override specific steps of the algorithm without changing its structure.

```java
// Abstract Class
abstract class Game {
    public void play() {
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

**Visitor**:

A behavioral design pattern that lets you separate algorithms from the objects on which they operate.

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

// Visitor
interface Visitor {
    void visit(ConcreteElement element);
}

// Concrete Visitor
class ConcreteVisitor implements Visitor {
    @Override
    public void visit(ConcreteElement element) {
        System.out.println("Visited element");
    }
}

// Client code
public class VisitorDemo {
    public static void main(String[] args) {
        Element element = new ConcreteElement();
        Visitor visitor = new ConcreteVisitor();
        element.accept(visitor);
    }
}
```

---
