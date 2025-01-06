---
title: "DP - Design Patterns"
description: "Design Patterns in Java."
date: 2024-12-30T13:00:00Z
draft: false
---

Overview of the simplest and most common design patterns according to the book *"Design Patterns Elements of Reusable Object-Oriented Software"*:

- Factory Method
- Abstract Factory
- Adapter
- Composite
- Decorator
- Observer
- Strategy
- Template Method

with additional patterns which I personally consider common as well:

- Singleton
- Builder
- Proxy
- Command
- Chain of Responsibility
- Mediator
- Visitor

# Creational Patterns

**Factory Method**:

Use when a class can't anticipate the exact type of objects it must create or when the creation logic should be delegated to subclasses.

**Signs you might need it**:

If the code is cluttered with hardcoded object creation, making it difficult to modify or extend without altering the client code.

```java
public interface Button {
    void render();
}

public class WindowsButton implements Button {
    public void render() {
        System.out.println("Rendering Windows Button");
    }
}

public class MacButton implements Button {
    public void render() {
        System.out.println("Rendering Mac Button");
    }
}

public interface ButtonFactory {
    Button createButton();
}

public class WindowsButtonFactory implements ButtonFactory {
    @Override
    public Button createButton() {
        return new WindowsButton();
    }
}

public class MacButtonFactory implements ButtonFactory {
    @Override
    public Button createButton() {
        return new MacButton();
    }
}

public class Client {
    public static void main(String[] args) {
        String platform = "Mac";
        ButtonFactory factory;

        if ("Windows".equalsIgnoreCase(platform)) {
            factory = new WindowsButtonFactory();
        } else {
            factory = new MacButtonFactory();
        }

        Button button = factory.createButton();
        button.render();
    }
}
```

**Abstract Factory**:

Use when your system needs to create families of related or dependent objects without specifying their concrete classes.

**Signs you might need it**:

If adding new families of related objects requires significant changes to client code or tight coupling to concrete classes makes the system rigid and hard to extend.

```java
public interface Button {
    void render();
}

public class WindowsButton implements Button {
    public void render() {
        System.out.println("Rendering Windows Button");
    }
}

public class MacButton implements Button {
    public void render() {
        System.out.println("Rendering Mac Button");
    }
}

public interface Checkbox {
    void render();
}

public class WindowsCheckbox implements Checkbox {
    public void render() {
        System.out.println("Rendering Windows Checkbox");
    }
}

public class MacCheckbox implements Checkbox {
    public void render() {
        System.out.println("Rendering Mac Checkbox");
    }
}

public interface AbstractFactory {
    Button createButton();
    Checkbox createCheckbox();
}

public class WindowsFactory implements AbstractFactory {
    public Button createButton() {
        return new WindowsButton();
    }

    public Checkbox createCheckbox() {
        return new WindowsCheckbox();
    }
}

public class MacFactory implements AbstractFactory {
    public Button createButton() {
        return new MacButton();
    }

    public Checkbox createCheckbox() {
        return new MacCheckbox();
    }
}

public class Application {
    private final Button button;
    private final Checkbox checkbox;

    public Application(AbstractFactory factory) {
        this.button = factory.createButton();
        this.checkbox = factory.createCheckbox();
    }

    public void render() {
        button.render();
        checkbox.render();
    }
}

public class Client {
    public static void main(String[] args) {
        String platform = "Mac";
        AbstractFactory factory;

        if ("Windows".equalsIgnoreCase(platform)) {
            factory = new WindowsFactory();
        } else {
            factory = new MacFactory();
        }

        Application app = new Application(factory);
        app.render();
    }
}
```

**Singleton**

Use when you need to ensure only one instance of a class exists and provide a global access point to it.

**Signs you might need it**:

If multiple instances of a class lead to inconsistent state or resource conflicts across the application.

```java
public class Singleton {
    private static Singleton instance;

    private Singleton() {
        // Private constructor to prevent instantiation
    }

    public static Singleton getInstance() {
        if (instance == null) {
            instance = new Singleton();
        }
        return instance;
    }
}

public class Client {
    public static void main(String[] args) {
        Singleton instance = Singleton.getInstance();
        Singleton sameInstance = Singleton.getInstance();
    }
}
```

**Builder**

Use when constructing a complex object with many optional parameters or configurations that should be constructed step-by-step.

**Signs you might need it**:

If constructors become unwieldy due to numerous optional parameters or configurations, leading to unclear and error-prone code.

```java
public class House {
    private int rooms;
    private boolean hasGarage;
    private boolean hasGarden;

    private House(Builder builder) {
        this.rooms = builder.rooms;
        this.hasGarage = builder.hasGarage;
        this.hasGarden = builder.hasGarden;
    }

    public static class Builder {
        private int rooms;
        private boolean hasGarage;
        private boolean hasGarden;

        public Builder setRooms(int rooms) {
            this.rooms = rooms;
            return this;
        }

        public Builder setGarage(boolean hasGarage) {
            this.hasGarage = hasGarage;
            return this;
        }

        public Builder setGarden(boolean hasGarden) {
            this.hasGarden = hasGarden;
            return this;
        }

        public House build() {
            return new House(this);
        }
    }
}

public class Client {
    public static void main(String[] args) {
        House house = new House.Builder()
                .setRooms(3)
                .setGarage(true)
                .setGarden(false)
                .build();
    }
}
```

# Structural Patterns

**Adapter**:

Use when you need to make two incompatible interfaces work together without altering their source code.

**Signs you might need it**:

If incompatible interfaces prevent the integration of existing components or systems, forcing duplication or rewriting of code.

```java
public interface Celsius {
    double getCelsiusTemperature();
}

public class Fahrenheit {
    private double temperature;

    public Fahrenheit(double temperature) {
        this.temperature = temperature;
    }

    public double getFahrenheitTemperature() {
        return temperature;
    }
}

public class FahrenheitToCelsiusAdapter implements Celsius {
    private Fahrenheit device;

    public FahrenheitToCelsiusAdapter(Fahrenheit device) {
        this.device = device;
    }

    @Override
    public double getCelsiusTemperature() {
        double fahrenheit = device.getFahrenheitTemperature();
        return (fahrenheit - 32) * 5 / 9;
    }
}

public class Client {
    public static void main(String[] args) {
        Fahrenheit fahrenheitDevice = new Fahrenheit(98.6);
        Celsius temperatureAdapter = new FahrenheitToCelsiusAdapter(fahrenheitDevice);

        System.out.println("Temperature in Celsius: " + temperatureAdapter.getCelsiusTemperature());
    }
}
```

**Composite**:

Use when you need to represent a part-whole hierarchy and treat individual objects and groups of objects uniformly.

**Signs you might need it**:

If managing hierarchies of objects results in duplicated logic or complicated client code that treats individual and composite objects differently.

```java
public interface JSONElement {
    String toJSONString();
}

public class JSONValue implements JSONElement {
    private Object value;

    public JSONValue(Object value) {
        this.value = value;
    }

    @Override
    public String toJSONString() {
        return (value instanceof String) ? "\"" + value + "\"" : value.toString();
    }
}

public class JSONArray implements JSONElement {
    private List<JSONElement> elements = new ArrayList<>();

    public void add(JSONElement element) {
        elements.add(element);
    }

    @Override
    public String toJSONString() {
        return elements.stream()
            .map(JSONElement::toJSONString)
            .collect(Collectors.joining(", ", "[", "]"));
    }
}

public class JSONObject implements JSONElement {
    private Map<String, JSONElement> elements = new HashMap<>();

    public void add(String key, JSONElement element) {
        elements.put(key, element);
    }

    @Override
    public String toJSONString() {
        return elements.entrySet().stream()
            .map(e -> "\"" + e.getKey() + "\": " + e.getValue().toJSONString())
            .collect(Collectors.joining(", ", "{", "}"));
    }
}

public class Client {
    public static void main(String[] args) {
        JSONObject root = new JSONObject();
        root.add("title", new JSONValue("Design Patterns"));

        JSONArray authors = new JSONArray();
        authors.add(new JSONValue("Gamma"));
        authors.add(new JSONValue("Helm"));
        authors.add(new JSONValue("Johnson"));
        authors.add(new JSONValue("Vlissides"));
        root.add("authors", authors);

        System.out.println(root.toJSONString());
    }
}
```

**Decorator**:

Use when you need to dynamically add or modify behavior to an object without affecting others.

**Signs you might need it**:

If extending the functionality of a class leads to an explosion of subclasses for every possible variation.

```java
public interface DataSource {
    void writeData(String data);
    String readData();
}

public class FileDataSource implements DataSource {
    private String filename;

    public FileDataSource(String filename) {
        this.filename = filename;
    }

    @Override
    public void writeData(String data) {
        System.out.println("Writing data to " + filename);
    }

    @Override
    public String readData() {
        return "Reading data from " + filename;
    }
}

public class CompressionDecorator implements DataSource {
    private DataSource source;

    public CompressionDecorator(DataSource source) {
        this.source = source;
    }

    @Override
    public void writeData(String data) {
        source.writeData(compress(data));
    }

    @Override
    public String readData() {
        return decompress(source.readData());
    }

    private String compress(String data) {
        return "Compressed[" + data + "]";
    }

    private String decompress(String data) {
        return data.replace("Compressed[", "").replace("]", "");
    }
}

public class EncryptionDecorator implements DataSource {
    private DataSource source;

    public EncryptionDecorator(DataSource source) {
        this.source = source;
    }

    @Override
    public void writeData(String data) {
        source.writeData(encrypt(data));
    }

    @Override
    public String readData() {
        return decrypt(source.readData());
    }

    private String encrypt(String data) {
        return "Encrypted[" + data + "]";
    }

    private String decrypt(String data) {
        return data.replace("Encrypted[", "").replace("]", "");
    }
}

public class Client {
    public static void main(String[] args) {
        DataSource dataSource = new FileDataSource("data.txt");
        DataSource wrapper = new EncryptionDecorator(new CompressionDecorator(dataSource));

        wrapper.writeData("Important Data");
        System.out.println(wrapper.readData());
    }
}
```

**Proxy**:

Use when you need to control access to an object, for purposes like lazy initialization, logging, or access control.

**Signs you might need it**:

If direct access to resource-intensive or sensitive objects causes performance issues or security risks.

```java
public interface Database {
    void query(String sql);
}

public class RealDatabase implements Database {
    public RealDatabase() {
        connectToDatabase();
    }

    private void connectToDatabase() {
        System.out.println("Connecting to the database...");
    }

    @Override
    public void query(String sql) {
        System.out.println("Executing query: " + sql);
    }
}

public class DatabaseProxy implements Database {
    private RealDatabase realDatabase;

    @Override
    public void query(String sql) {
        if (realDatabase == null) {
            realDatabase = new RealDatabase();
        }
        realDatabase.query(sql);
    }
}

public class Client {
    public static void main(String[] args) {
        Database db = new DatabaseProxy();
        db.query("SELECT * FROM Users");
    }
}
```

# Behavioral Patterns

**Observer**:

Use when an object needs to notify multiple dependent objects of state changes, maintaining a one-to-many relationship.

**Signs you might need it**:

If manually updating multiple dependent objects becomes error-prone and leads to tight coupling between the subject and its observers.

```java
public interface Observer {
    void update(String message);
}

public class Subscriber implements Observer {
    private String name;

    public Subscriber(String name) {
        this.name = name;
    }

    @Override
    public void update(String message) {
        System.out.println(name + " received update: " + message);
    }
}

public class Publisher {
    private List<Observer> observers = new ArrayList<>();

    public void subscribe(Observer observer) {
        observers.add(observer);
    }

    public void unsubscribe(Observer observer) {
        observers.remove(observer);
    }

    public void notifyObservers(String message) {
        for (Observer observer : observers) {
            observer.update(message);
        }
    }
}

public class Client {
    public static void main(String[] args) {
        Publisher newsPublisher = new Publisher();

        Observer alice = new Subscriber("Alice");
        Observer bob = new Subscriber("Bob");

        newsPublisher.subscribe(alice);
        newsPublisher.subscribe(bob);

        newsPublisher.notifyObservers("Breaking News: Design Patterns Book is Awesome!");
    }
}
```

**Strategy**:

Use when you want to define a family of algorithms, encapsulate them, and make them interchangeable at runtime.

**Signs you might need it**:

If hardcoded algorithms or behaviors make the system inflexible and difficult to extend or modify.

```java
public interface PaymentStrategy {
    void pay(int amount);
}

public class CreditCardPayment implements PaymentStrategy {
    @Override
    public void pay(int amount) {
        System.out.println("Paid " + amount + " using credit card.");
    }
}

public class BankTransferPayment implements PaymentStrategy {
    @Override
    public void pay(int amount) {
        System.out.println("Paid " + amount + " using bank transfer.");
    }
}

public class Client {
    public static void main(String[] args) {
        PaymentStrategy paymentStrategy;
        int totalAmount = 1200;

        if (totalAmount > 1000) {
            paymentStrategy = new BankTransferPayment();
        } else {
            paymentStrategy = new CreditCardPayment();
        }

        paymentStrategy.pay(totalAmount);
    }
}
```

**Template Method**:

Use when you need to define the skeleton of an algorithm but allow subclasses to override specific steps.

**Signs you might need it**:

If duplicated logic for similar algorithms creates maintenance challenges and increases the likelihood of inconsistencies.

```java
public interface GameSteps {
    void initialize();
    void startPlay();
    void endPlay();
}

public class Game {
    private final GameSteps steps;

    public Game(GameSteps steps) {
        this.steps = steps;
    }

    public void play() {
        steps.initialize();
        steps.startPlay();
        steps.endPlay();
    }
}

public class Chess implements GameSteps {
    @Override
    public void initialize() {
        System.out.println("Chess Game Initialized!");
    }

    @Override
    public void startPlay() {
        System.out.println("Chess Game Started!");
    }

    @Override
    public void endPlay() {
        System.out.println("Chess Game Finished!");
    }
}

public class Client {
    public static void main(String[] args) {
        Game chess = new Game(new Chess());
        chess.play();
    }
}
```

**Command**:

Use when you need to encapsulate requests as objects, enabling parameterization, queuing, or undo operations.

**Signs you might need it**:

If request handling logic is tightly coupled to specific actions, making it hard to implement features like queuing, logging, or undo.

```java
public interface Command {
    void execute();
}

public class Light {
    public void turnOn() {
        System.out.println("Light is ON");
    }

    public void turnOff() {
        System.out.println("Light is OFF");
    }
}

public class TurnOnLightCommand implements Command {
    private Light light;

    public TurnOnLightCommand(Light light) {
        this.light = light;
    }

    @Override
    public void execute() {
        light.turnOn();
    }
}

public class TurnOffLightCommand implements Command {
    private Light light;

    public TurnOffLightCommand(Light light) {
        this.light = light;
    }

    @Override
    public void execute() {
        light.turnOff();
    }
}

public class Client {
    public static void main(String[] args) {
        Light light = new Light();

        Command[] commands = new Command[] {
            new TurnOnLightCommand(light),
            new TurnOffLightCommand(light)
        };

        for (Command command : commands) {
            command.execute();
        }
    }
}
```

**Chain of Responsibility**:

Use when multiple objects might handle a request, but the specific handler is determined at runtime.

**Signs you might need it**:

If request handling becomes rigid and changes to handlers require altering the request-sender code.

```java
public abstract class Handler {
    private Handler next;

    public void setNext(Handler next) {
        this.next = next;
    }

    public void handleRequest(String request) {
        process(request);
        if (next != null) {
            next.handleRequest(request);
        }
    }

    protected abstract void process(String request);
}

public class LoggingHandler extends Handler {
    @Override
    protected void process(String request) {
        System.out.println("Logging request: " + request);
    }
}

public class AuthenticationHandler extends Handler {
    @Override
    protected void process(String request) {
        System.out.println("Authentication successful.");
    }
}

public class AuthorizationHandler extends Handler {
    @Override
    protected void process(String request) {
        System.out.println("Authorization successful.");
    }
}

public class Client {
    public static void main(String[] args) {
        List<Handler> middleware = new ArrayList<>();

        middleware.add(new LoggingHandler());
        middleware.add(new AuthenticationHandler());
        middleware.add(new AuthorizationHandler());

        for (int i = 0; i < middleware.size() - 1; i++) {
            middleware.get(i).setNext(middleware.get(i + 1));
        }

        middleware.get(0).handleRequest("Request data");
    }
}
```

**Mediator**:

Use when you need to reduce the direct communication dependencies between objects by centralizing interactions.

**Signs you might need it**:

If direct communication between objects leads to overly complex and tightly coupled dependencies.

```java
public interface Mediator {
    void addConsumer(Consumer consumer);
    void addProducer(Producer producer);
    void sendMessage(Producer producer, String message);
    String readMessage(Consumer consumer);
}

public class MessageQueue implements Mediator {
    private final List<Consumer> consumers = new ArrayList<>();
    private final List<Producer> producers = new ArrayList<>();
    private final Queue<String> messageQueue = new ArrayDeque<>();

    @Override
    public void addConsumer(Consumer consumer) {
        consumers.add(consumer);
    }

    @Override
    public void addProducer(Producer producer) {
        producers.add(producer);
    }

    @Override
    public void sendMessage(Producer producer, String message) {
        if (!producers.contains(producer)) {
            System.out.println("Producer not registered with the messaging queue.");
            return;
        }

        System.out.println("MessageQueue received message: " + message);
        messageQueue.offer(message);
    }

    @Override
    public String readMessage(Consumer consumer) {
        if (!consumers.contains(consumer)) {
            System.out.println("Consumer not registered with the messaging queue.");
            return null;
        }

        System.out.println("MessageQueue sent message: " + message);
        return messageQueue.poll();
    }
}

public class Producer {
    private final Mediator messageQueue;
    private final String name;

    public Producer(Mediator messageQueue, String name) {
        this.messageQueue = messageQueue;
        this.name = name;
    }

    public void produceMessage(String message) {
        System.out.println(name + " sending: " + message);
        messageQueue.sendMessage(this, message);
    }
}

public class Consumer {
    private final Mediator messageQueue;
    private final String name;

    public Consumer(Mediator messageQueue, String name) {
        this.messageQueue = messageQueue;
        this.name = name;
    }

    public void readMessage() {
        String message = messageQueue.readMessage(this);

        if (message) {
            System.out.println(name + " read: " + message);
        } else {
            System.out.println(name + " found no messages to read.");
        }
    }
}

public class Client {
    public static void main(String[] args) {
        MessageQueue queue = new MessageQueue();

        Producer producer = new Producer(queue, "Producer");
        queue.addProducer(producer);

        Consumer consumer1 = new Consumer(queue, "Consumer1");
        Consumer consumer2 = new Consumer(queue, "Consumer2");

        queue.addConsumer(consumer1);
        queue.addConsumer(consumer2);

        producer.produceMessage("Message 1");
        producer.produceMessage("Message 2");

        consumer1.readMessage();
        consumer2.readMessage();
    }
}
```

**Visitor**:

Use when you need to perform new operations on elements of a complex object structure without modifying the elements.

**Signs you might need it**:

If adding new operations to a structure of objects requires modifying the objects themselves, breaking encapsulation and increasing rigidity.

```java
public interface Visitor {
    void visit(Book book);
    void visit(Game game);
}

public interface ShoppingItem {
    void accept(Visitor visitor);
}

public class Book implements ShoppingItem {
    private String title;
    private double price;

    public Book(String title, double price) {
        this.title = title;
        this.price = price;
    }

    public String getTitle() {
        return title;
    }

    public double getPrice() {
        return price;
    }

    @Override
    public void accept(Visitor visitor) {
        visitor.visit(this);
    }
}

public class Game implements ShoppingItem {
    private String name;
    private double price;

    public Game(String name, double price) {
        this.name = name;
        this.price = price;
    }

    public String getName() {
        return name;
    }

    public double getPrice() {
        return price;
    }

    @Override
    public void accept(Visitor visitor) {
        visitor.visit(this);
    }
}

public class CheckoutVisitor implements Visitor {
    private double totalCost = 0;

    @Override
    public void visit(Book book) {
        totalCost += book.getPrice();
        System.out.println("Book added to cart: " + book.getTitle() + " (Price: " + book.getPrice() + ")");
    }

    @Override
    public void visit(Game game) {
        totalCost += game.getPrice();
        System.out.println("Game added to cart: " + game.getName() + " (Price: " + game.getPrice() + ")");
    }

    public double getTotalCost() {
        return totalCost;
    }
}

public class DiscountVisitor implements Visitor {
    private double totalDiscount = 0;

    @Override
    public void visit(Book book) {
        double discount = calculateBookDiscount(book);
        totalDiscount += discount;
        System.out.println("Book: " + book.getTitle() + " - Discount applied: " + discount);
    }

    @Override
    public void visit(Game game) {
        double discount = calculateGameDiscount(game);
        totalDiscount += discount;
        System.out.println("Game: " + game.getName() + " - Discount applied: " + discount);
    }

    private double calculateBookDiscount(Book book) {
        if (book.getPrice() > 30) {
            return book.getPrice() * 0.10;
        }
        return 0;
    }

    private double calculateGameDiscount(Game game) {
        if (game.getPrice() > 50) {
            return game.getPrice() * 0.15;
        }
        return 0;
    }

    public double getTotalDiscount() {
        return totalDiscount;
    }
}

public class Client {
    public static void main(String[] args) {
        ShoppingItem[] shoppingCart = new ShoppingItem[]{
            new Book("Design Patterns", 45.99),
            new Game("Chess", 19.99)
        };

        CheckoutVisitor checkoutVisitor = new CheckoutVisitor();
        for (ShoppingItem item : shoppingCart) {
            item.accept(checkoutVisitor);
        }
        System.out.println("Total cost: " + checkoutVisitor.getTotalCost());

        DiscountVisitor discountVisitor = new DiscountVisitor();
        for (ShoppingItem item : shoppingCart) {
            item.accept(discountVisitor);
        }
        System.out.println("Total discount: " + discountVisitor.getTotalDiscount());
    }
}
```
