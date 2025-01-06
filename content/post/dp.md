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
    public void render() {
        System.out.println("Rendering Windows Button");
    }
}

// Concrete Product
class MacButton implements Button {
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
    Button createButton() {
        return new WindowsButton();
    }
}

// Concrete Creator
class MacDialog extends Dialog {
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
// Abstract Products
interface Button { void paint(); }
interface Checkbox { void paint(); }

// Concrete Products
class WinButton implements Button {
    public void paint() { System.out.println("Windows Button"); }
}
class WinCheckbox implements Checkbox {
    public void paint() { System.out.println("Windows Checkbox"); }
}
class MacButton implements Button {
    public void paint() { System.out.println("Mac Button"); }
}
class MacCheckbox implements Checkbox {
    public void paint() { System.out.println("Mac Checkbox"); }
}

// Abstract Factory
interface GUIFactory {
    Button createButton();
    Checkbox createCheckbox();
}

// Concrete Factories
class WinFactory implements GUIFactory {
    public Button createButton() { return new WinButton(); }
    public Checkbox createCheckbox() { return new WinCheckbox(); }
}
class MacFactory implements GUIFactory {
    public Button createButton() { return new MacButton(); }
    public Checkbox createCheckbox() { return new MacCheckbox(); }
}

// Client code
public class AbstractFactoryDemo {
    public static void main(String[] args) {
        GUIFactory factory = new WinFactory();
        Button button = factory.createButton();
        Checkbox checkbox = factory.createCheckbox();
        button.paint();
        checkbox.paint();

        factory = new MacFactory();
        button = factory.createButton();
        checkbox = factory.createCheckbox();
        button.paint();
        checkbox.paint();
    }
}
```

**Builder**:

A creational design pattern that lets you construct complex objects step by step. The pattern allows you to produce different types and representations of an object using the same construction code.

```java
// Product
class Product {
    private String partA;
    private String partB;
    public void setPartA(String partA) { this.partA = partA; }
    public void setPartB(String partB) { this.partB = partB; }
    public void show() { System.out.println(partA + ", " + partB); }
}

// Builder
interface Builder {
    void buildPartA();
    void buildPartB();
    Product getResult();
}

// Concrete Builder
class ConcreteBuilder implements Builder {
    private Product product = new Product();
    public void buildPartA() { product.setPartA("PartA"); }
    public void buildPartB() { product.setPartB("PartB"); }
    public Product getResult() { return product; }
}

// Director
class Director {
    public void construct(Builder builder) {
        builder.buildPartA();
        builder.buildPartB();
    }
}

// Client code
public class BuilderDemo {
    public static void main(String[] args) {
        Builder builder = new ConcreteBuilder();
        Director director = new Director();
        director.construct(builder);
        Product product = builder.getResult();
        product.show();
    }
}
```

**Prototype**:

A creational design pattern that lets you copy existing objects without making your code dependent on their classes.

```java
interface Prototype {
    Prototype clone();
}

// Concrete Prototype
class ConcretePrototype implements Prototype {
    private String field;
    public ConcretePrototype(String field) { this.field = field; }
    public Prototype clone() { return new ConcretePrototype(field); }
    public void show() { System.out.println("Field: " + field); }
}

// Client code
public class PrototypeDemo {
    public static void main(String[] args) {
        ConcretePrototype original = new ConcretePrototype("data");
        ConcretePrototype copy = (ConcretePrototype) original.clone();
        original.show();
        copy.show();
    }
}
```

**Singleton**:

A creational design pattern that lets you ensure that a class has only one instance, while providing a global access point to this instance.

```java
class Singleton {
    private static Singleton instance;
    private Singleton() {}
    public static Singleton getInstance() {
        if (instance == null) {
            instance = new Singleton();
        }
        return instance;
    }
    public void show() { System.out.println("Singleton instance"); }
}

// Client code
public class SingletonDemo {
    public static void main(String[] args) {
        Singleton s1 = Singleton.getInstance();
        Singleton s2 = Singleton.getInstance();
        s1.show();
        System.out.println(s1 == s2); // true
    }
}
```

# Structural Patterns

**Adapter**:

A structural design pattern that allows objects with incompatible interfaces to collaborate.

```java
// Target
interface Target {
    void request();
}

// Adaptee
class Adaptee {
    void specificRequest() {
        System.out.println("Specific request");
    }
}

// Adapter
class Adapter implements Target {
    private Adaptee adaptee;
    public Adapter(Adaptee adaptee) { this.adaptee = adaptee; }
    public void request() { adaptee.specificRequest(); }
}

// Client code
public class AdapterDemo {
    public static void main(String[] args) {
        Adaptee adaptee = new Adaptee();
        Target target = new Adapter(adaptee);
        target.request();
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
    public void turnOn() { System.out.println("TV on"); }
}
class Radio implements Device {
    public void turnOn() { System.out.println("Radio on"); }
}

// Abstraction
abstract class Remote {
    protected Device device;
    public Remote(Device device) { this.device = device; }
    abstract void pressButton();
}

// Refined Abstraction
class BasicRemote extends Remote {
    public BasicRemote(Device device) { super(device); }
    void pressButton() { device.turnOn(); }
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
interface Component {
    void operation();
}

// Leaf
class Leaf implements Component {
    public void operation() { System.out.println("Leaf"); }
}

// Composite
class Composite implements Component {
    private List<Component> children = new ArrayList<>();
    public void add(Component c) { children.add(c); }
    public void operation() {
        System.out.println("Composite");
        for (Component c : children) c.operation();
    }
}

// Client code
public class CompositeDemo {
    public static void main(String[] args) {
        Composite root = new Composite();
        root.add(new Leaf());
        Composite branch = new Composite();
        branch.add(new Leaf());
        root.add(branch);
        root.operation();
    }
}
```

**Decorator**:

A structural design pattern that lets you attach new behaviors to objects by placing these objects inside special wrapper objects that contain the behaviors.

```java
// Component
interface Component {
    void operation();
}

// Concrete Component
class ConcreteComponent implements Component {
    public void operation() { System.out.println("ConcreteComponent"); }
}

// Decorator
abstract class Decorator implements Component {
    protected Component component;
    public Decorator(Component component) { this.component = component; }
    public void operation() { component.operation(); }
}

// Concrete Decorator
class ConcreteDecorator extends Decorator {
    public ConcreteDecorator(Component component) { super(component); }
    public void operation() {
        super.operation();
        System.out.println("Decorated");
    }
}

// Client code
public class DecoratorDemo {
    public static void main(String[] args) {
        Component component = new ConcreteComponent();
        Component decorated = new ConcreteDecorator(component);
        decorated.operation();
    }
}
```

**Facade**:

A structural design pattern that provides a simplified interface to a library, a framework, or any other complex set of classes.

```java
// Subsystems
class SubsystemA { void operationA() { System.out.println("A"); } }
class SubsystemB { void operationB() { System.out.println("B"); } }

// Facade
class Facade {
    private SubsystemA a = new SubsystemA();
    private SubsystemB b = new SubsystemB();
    void operation() {
        a.operationA();
        b.operationB();
    }
}

// Client code
public class FacadeDemo {
    public static void main(String[] args) {
        Facade facade = new Facade();
        facade.operation();
    }
}
```

**Flyweight**:

A structural design pattern that lets you fit more objects into the available amount of RAM by sharing common parts of state between multiple objects instead of keeping all of the data in each object.

```java
// Flyweight
interface Shape {
    void draw(String color);
}

// Concrete Flyweight
class Circle implements Shape {
    private String type = "Circle";
    public void draw(String color) {
        System.out.println("Drawing " + type + " in " + color);
    }
}

// Flyweight Factory
class ShapeFactory {
    private static final Map<String, Shape> shapes = new HashMap<>();
    public static Shape getCircle() {
        return shapes.computeIfAbsent("circle", k -> new Circle());
    }
}

// Client code
public class FlyweightDemo {
    public static void main(String[] args) {
        Shape circle1 = ShapeFactory.getCircle();
        circle1.draw("Red");
        Shape circle2 = ShapeFactory.getCircle();
        circle2.draw("Blue");
        System.out.println(circle1 == circle2); // true
    }
}
```

**Proxy**:

A structural design pattern that lets you provide a substitute or placeholder for another object. A proxy controls access to the original object, allowing you to perform something either before or after the request gets through to the original object.

```java
// Subject
interface Service {
    void request();
}

// Real Subject
class RealService implements Service {
    public void request() { System.out.println("RealService request"); }
}

// Proxy
class ProxyService implements Service {
    private RealService realService;
    public void request() {
        if (realService == null) realService = new RealService();
        System.out.println("Proxy before");
        realService.request();
        System.out.println("Proxy after");
    }
}

// Client code
public class ProxyDemo {
    public static void main(String[] args) {
        Service service = new ProxyService();
        service.request();
    }
}
```

# Behavioral Patterns

**Chain of Responsibility**:

A behavioral design pattern that lets you pass requests along a chain of handlers. Upon receiving a request, each handler decides either to process the request or to pass it to the next handler in the chain.

```java
// Handler
abstract class Handler {
    private Handler next;
    public Handler setNext(Handler next) {
        this.next = next;
        return next;
    }
    public void handle(String request) {
        if (next != null) next.handle(request);
    }
}

// Concrete Handlers
class ConcreteHandlerA extends Handler {
    public void handle(String request) {
        if (request.equals("A")) System.out.println("Handled by A");
        else super.handle(request);
    }
}
class ConcreteHandlerB extends Handler {
    public void handle(String request) {
        if (request.equals("B")) System.out.println("Handled by B");
        else super.handle(request);
    }
}

// Client code
public class ChainDemo {
    public static void main(String[] args) {
        Handler a = new ConcreteHandlerA();
        Handler b = new ConcreteHandlerB();
        a.setNext(b);

        a.handle("A");
        a.handle("B");
        a.handle("C");
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
    void on() { System.out.println("Light on"); }
}

// Concrete Command
class LightOnCommand implements Command {
    private Light light;
    public LightOnCommand(Light light) { this.light = light; }
    public void execute() { light.on(); }
}

// Invoker
class RemoteControl {
    private Command command;
    public void setCommand(Command command) { this.command = command; }
    public void pressButton() { command.execute(); }
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
// Aggregate
class NameRepository implements Iterable<String> {
    private String[] names = {"Alice", "Bob", "Charlie"};
    public Iterator<String> iterator() {
        return Arrays.asList(names).iterator();
    }
}

// Client code
public class IteratorDemo {
    public static void main(String[] args) {
        NameRepository repo = new NameRepository();
        for (String name : repo) {
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
    void notify(Component sender, String event);
}

// Concrete Mediator
class ConcreteMediator implements Mediator {
    private Button button;
    private TextBox textBox;
    public void setButton(Button button) { this.button = button; }
    public void setTextBox(TextBox textBox) { this.textBox = textBox; }
    public void notify(Component sender, String event) {
        if (sender == button && event.equals("click")) {
            textBox.showMessage();
        }
    }
}

// Colleague
abstract class Component {
    protected Mediator mediator;
    public Component(Mediator mediator) { this.mediator = mediator; }
}

// Concrete Colleagues
class Button extends Component {
    public Button(Mediator mediator) { super(mediator); }
    public void click() { mediator.notify(this, "click"); }
}
class TextBox extends Component {
    public TextBox(Mediator mediator) { super(mediator); }
    public void showMessage() { System.out.println("Button clicked!"); }
}

// Client code
public class MediatorDemo {
    public static void main(String[] args) {
        ConcreteMediator mediator = new ConcreteMediator();
        Button button = new Button(mediator);
        TextBox textBox = new TextBox(mediator);
        mediator.setButton(button);
        mediator.setTextBox(textBox);

        button.click();
    }
}
```

**Memento**:

A behavioral design pattern that lets you save and restore the previous state of an object without revealing the details of its implementation.

```java
// Memento
class Memento {
    private String state;
    public Memento(String state) { this.state = state; }
    public String getState() { return state; }
}

// Originator
class Originator {
    private String state;
    public void setState(String state) { this.state = state; }
    public String getState() { return state; }
    public Memento save() { return new Memento(state); }
    public void restore(Memento memento) { state = memento.getState(); }
}

// Caretaker
public class MementoDemo {
    public static void main(String[] args) {
        Originator originator = new Originator();
        originator.setState("State1");
        Memento memento = originator.save();
        originator.setState("State2");
        System.out.println(originator.getState());
        originator.restore(memento);
        System.out.println(originator.getState());
    }
}
```

**Observer**:

A behavioral design pattern that lets you define a subscription mechanism to notify multiple objects about any events that happen to the object they’re observing.

```java
// Subject
class Subject {
    private List<Observer> observers = new ArrayList<>();
    private String state;
    public void attach(Observer o) { observers.add(o); }
    public void setState(String state) {
        this.state = state;
        notifyAllObservers();
    }
    private void notifyAllObservers() {
        for (Observer o : observers) o.update(state);
    }
}

// Observer
interface Observer {
    void update(String state);
}

// Concrete Observer
class ConcreteObserver implements Observer {
    private String name;
    public ConcreteObserver(String name) { this.name = name; }
    public void update(String state) {
        System.out.println(name + " received: " + state);
    }
}

// Client code
public class ObserverDemo {
    public static void main(String[] args) {
        Subject subject = new Subject();
        subject.attach(new ConcreteObserver("A"));
        subject.attach(new ConcreteObserver("B"));
        subject.setState("Hello");
    }
}
```

**State**:

A behavioral design pattern that lets an object alter its behavior when its internal state changes. It appears as if the object changed its class.

```java
// State
interface State {
    void handle(Context context);
}

// Concrete States
class StateA implements State {
    public void handle(Context context) {
        System.out.println("State A");
        context.setState(new StateB());
    }
}
class StateB implements State {
    public void handle(Context context) {
        System.out.println("State B");
        context.setState(new StateA());
    }
}

// Context
class Context {
    private State state;
    public Context(State state) { this.state = state; }
    public void setState(State state) { this.state = state; }
    public void request() { state.handle(this); }
}

// Client code
public class StateDemo {
    public static void main(String[] args) {
        Context context = new Context(new StateA());
        context.request();
        context.request();
    }
}
```

**Strategy**:

A behavioral design pattern that lets you define a family of algorithms, put each of them into a separate class, and make their objects interchangeable.

```java
// Strategy
interface Strategy {
    int execute(int a, int b);
}

// Concrete Strategies
class Add implements Strategy {
    public int execute(int a, int b) { return a + b; }
}
class Subtract implements Strategy {
    public int execute(int a, int b) { return a - b; }
}

// Context
class Context {
    private Strategy strategy;
    public Context(Strategy strategy) { this.strategy = strategy; }
    public int executeStrategy(int a, int b) {
        return strategy.execute(a, b);
    }
}

// Client code
public class StrategyDemo {
    public static void main(String[] args) {
        Context context = new Context(new Add());
        System.out.println(context.executeStrategy(3, 2));
        context = new Context(new Subtract());
        System.out.println(context.executeStrategy(3, 2));
    }
}
```

**Template Method**:

A behavioral design pattern that defines the skeleton of an algorithm in the superclass but lets subclasses override specific steps of the algorithm without changing its structure.

```java
// Abstract Class
abstract class AbstractClass {
    public void templateMethod() {
        step1();
        step2();
    }
    abstract void step1();
    abstract void step2();
}

// Concrete Class
class ConcreteClass extends AbstractClass {
    void step1() { System.out.println("Step 1"); }
    void step2() { System.out.println("Step 2"); }
}

// Client code
public class TemplateMethodDemo {
    public static void main(String[] args) {
        AbstractClass obj = new ConcreteClass();
        obj.templateMethod();
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
    public void accept(Visitor visitor) { visitor.visit(this); }
}

// Visitor
interface Visitor {
    void visit(ConcreteElement element);
}

// Concrete Visitor
class ConcreteVisitor implements Visitor {
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
