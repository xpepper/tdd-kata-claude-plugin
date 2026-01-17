# Object Calisthenics - Detailed Constraint Guide

Object calisthenics are coding constraints designed to improve object-oriented design. When practicing katas with these constraints, they force design patterns that lead to better encapsulation, cohesion, and maintainability.

## Overview

These nine rules push developers toward better OO design by limiting common coding patterns. While they may seem arbitrary, each constraint addresses a specific design smell and encourages specific good practices.

Apply these constraints from the first test. They're not refactoring targets—they shape how you write code from the beginning.

## The Nine Rules

### 1. One Level of Indentation Per Method

**Constraint**: Methods can have at most one level of indentation (not counting the method signature).

**Why**: Deep nesting indicates complex control flow. Extracting nested logic into well-named methods improves readability and testability.

**Example**:

```rust
// ❌ Violates constraint (2 levels of indentation)
fn process_orders(orders: Vec<Order>) {
    for order in orders {                    // Level 1
        if order.is_valid() {                // Level 2
            order.process();
        }
    }
}

// ✅ Follows constraint (1 level max)
fn process_orders(orders: Vec<Order>) {
    for order in orders {                    // Level 1
        process_if_valid(order);
    }
}

fn process_if_valid(order: Order) {
    if order.is_valid() {                    // Level 1
        order.process();
    }
}
```

**Patterns this encourages**:
- Extract Method refactoring
- Composed Method pattern
- Single Responsibility Principle

### 2. Don't Use the ELSE Keyword

**Constraint**: No `else`, `elsif`, `elif`, or similar constructs.

**Why**: Else clauses often indicate missing polymorphism or can be replaced with early returns (guard clauses). Removing them forces clearer code structure.

**Example**:

```python
# ❌ Uses else
def calculate_discount(customer):
    if customer.is_premium():
        return calculate_premium_discount(customer)
    else:
        return calculate_standard_discount(customer)

# ✅ Guard clause pattern
def calculate_discount(customer):
    if customer.is_premium():
        return calculate_premium_discount(customer)

    return calculate_standard_discount(customer)

# ✅ Polymorphism (better for complex cases)
class PremiumCustomer:
    def calculate_discount(self):
        return self.total * 0.2

class StandardCustomer:
    def calculate_discount(self):
        return self.total * 0.1
```

**Patterns this encourages**:
- Guard clauses / early returns
- Polymorphism
- Strategy pattern
- Tell, Don't Ask

### 3. Wrap All Primitives and Strings

**Constraint**: If a primitive has behavior or meaning, wrap it in a class.

**Why**: Primitives lack context and domain meaning. Wrapping creates value objects with validation, behavior, and clear semantics.

**Example**:

```java
// ❌ Primitive obsession
public class Order {
    private String email;
    private int amount;

    public void setEmail(String email) {
        this.email = email;
    }
}

// ✅ Wrapped in value objects
public class Order {
    private Email email;
    private Money amount;

    public void setEmail(Email email) {
        this.email = email;
    }
}

public class Email {
    private final String value;

    public Email(String value) {
        if (!isValid(value)) {
            throw new IllegalArgumentException("Invalid email");
        }
        this.value = value;
    }

    private boolean isValid(String email) {
        return email.contains("@");
    }
}

public class Money {
    private final int cents;

    public Money(int cents) {
        if (cents < 0) {
            throw new IllegalArgumentException("Money cannot be negative");
        }
        this.cents = cents;
    }

    public Money add(Money other) {
        return new Money(this.cents + other.cents);
    }
}
```

**Patterns this encourages**:
- Value Object pattern
- Domain-Driven Design
- Type safety
- Encapsulated validation

**When to wrap**: Wrap primitives that have:
- Domain meaning (Email, Money, Temperature)
- Validation rules
- Behavior beyond simple storage
- Units or constraints (non-negative, bounded)

### 4. First Class Collections

**Constraint**: Any class containing a collection should contain no other member variables.

**Why**: Collections with behavior should be wrapped in domain-specific classes. This encapsulates collection manipulation logic and provides meaningful operations.

**Example**:

```typescript
// ❌ Collection mixed with other state
class Team {
    name: string;
    members: Player[];

    addMember(player: Player) {
        this.members.push(player);
    }

    getAverageScore(): number {
        return this.members.reduce((sum, p) => sum + p.score, 0) / this.members.length;
    }
}

// ✅ First class collection
class Team {
    name: string;
    members: PlayerCollection;
}

class PlayerCollection {
    private players: Player[];

    add(player: Player) {
        this.players.push(player);
    }

    getAverageScore(): number {
        return this.players.reduce((sum, p) => sum + p.score, 0) / this.players.length;
    }

    filter(predicate: (p: Player) => boolean): PlayerCollection {
        return new PlayerCollection(this.players.filter(predicate));
    }
}
```

**Patterns this encourages**:
- Collection encapsulation
- Domain-specific collection operations
- Composite pattern
- Specification pattern (for filtering)

### 5. One Dot Per Line

**Constraint**: Avoid method chaining (except fluent interfaces on the same object).

**Why**: Chaining across different objects indicates Law of Demeter violations and tight coupling.

**Example**:

```java
// ❌ Multiple dots (violates Law of Demeter)
customer.getAddress().getCity().getZipCode();

// ✅ Tell, Don't Ask
customer.getZipCode();

// Inside Customer class:
public String getZipCode() {
    return address.getZipCode();
}

// ✅ Fluent interface on same object is OK
query.select("*")
     .from("users")
     .where("age > 18")
     .orderBy("name");
```

**Patterns this encourages**:
- Law of Demeter
- Tell, Don't Ask
- Facade pattern
- Delegation

### 6. Don't Abbreviate

**Constraint**: Use full, descriptive names for classes, methods, and variables.

**Why**: Abbreviations reduce clarity and create ambiguity. Full names make code self-documenting.

**Example**:

```rust
// ❌ Abbreviated names
fn proc_ord(o: Ord) -> Res {
    let qty = o.get_q();
    let amt = calc_amt(qty);
    Res::new(amt)
}

// ✅ Full names
fn process_order(order: Order) -> OrderResult {
    let quantity = order.get_quantity();
    let amount = calculate_amount(quantity);
    OrderResult::new(amount)
}
```

**Guidelines**:
- Class names: Nouns describing what they represent
- Method names: Verbs describing what they do
- Variable names: Descriptive nouns
- Boolean names: Questions (is_valid, has_items, can_process)

**Exceptions**:
- Loop indices (i, j, k) for simple loops
- Well-known abbreviations (HTML, URL, API)
- Variables with very limited scope (1-2 lines)

### 7. Keep All Entities Small

**Constraint**:
- Classes: 50 lines max
- Packages/Modules: 10 files max
- Methods: 5-10 lines max (some say 3)

**Why**: Small units are easier to understand, test, and maintain. Size limits force proper decomposition.

**Example**:

```python
# ❌ Large class (100+ lines)
class OrderProcessor:
    # ... 20 methods, 100+ lines

# ✅ Decomposed into small classes
class OrderValidator:
    def validate(self, order):
        # 5 lines

class OrderPricer:
    def calculate_total(self, order):
        # 7 lines

class OrderPersistence:
    def save(self, order):
        # 6 lines
```

**Patterns this encourages**:
- Single Responsibility Principle
- Composed Method pattern
- Extract Class refactoring
- Module decomposition

### 8. No Classes with More Than Two Instance Variables

**Constraint**: Classes should have at most two instance variables.

**Why**: Many instance variables indicate the class has multiple responsibilities. This is the most controversial rule but forces high cohesion.

**Example**:

```typescript
// ❌ Too many instance variables
class Order {
    id: string;
    customerId: string;
    items: Item[];
    total: Money;
    status: OrderStatus;
    shippingAddress: Address;
    billingAddress: Address;
}

// ✅ Decomposed (max 2 variables each)
class Order {
    details: OrderDetails;
    fulfillment: OrderFulfillment;
}

class OrderDetails {
    id: OrderId;
    customer: Customer;
}

class OrderFulfillment {
    items: ItemCollection;
    shipping: ShippingInfo;
}

class ShippingInfo {
    address: Address;
    status: OrderStatus;
}
```

**Patterns this encourages**:
- High cohesion
- Composition over large classes
- Value Objects
- Aggregates (DDD)

**Note**: This is the hardest constraint. Consider relaxing to 3-4 variables if 2 is too restrictive for your kata.

### 9. No Getters/Setters/Properties

**Constraint**: Don't expose internal state. Objects should have behavior, not just data.

**Why**: Getters/setters break encapsulation and lead to procedural code. Objects should do things, not just hold data.

**Example**:

```java
// ❌ Getters expose state, logic lives elsewhere
class BankAccount {
    private Money balance;

    public Money getBalance() {
        return balance;
    }

    public void setBalance(Money balance) {
        this.balance = balance;
    }
}

// Elsewhere:
Money newBalance = account.getBalance().add(deposit);
account.setBalance(newBalance);

// ✅ Tell, Don't Ask - behavior in object
class BankAccount {
    private Money balance;

    public void deposit(Money amount) {
        balance = balance.add(amount);
    }

    public void withdraw(Money amount) {
        if (balance.isLessThan(amount)) {
            throw new InsufficientFundsException();
        }
        balance = balance.subtract(amount);
    }

    public boolean canAfford(Money amount) {
        return balance.isGreaterThanOrEqual(amount);
    }
}
```

**Patterns this encourages**:
- Tell, Don't Ask
- Command-Query Separation
- Information Hiding
- Object-oriented design over procedural

**Exceptions**:
- Value Objects can expose their value (they're immutable)
- Read-only queries for display purposes (CQS query side)
- Framework requirements (serialization, ORMs)

## Applying Constraints in Katas

### Start Immediately

Apply constraints from the first test, not as a refactoring exercise. This shapes design from the beginning.

**Wrong approach**:
1. Write code without constraints
2. Refactor to apply constraints later

**Right approach**:
1. Read kata constraints
2. Write test considering constraints
3. Implement following constraints from first line

### Constraint Conflicts

Some constraints may conflict. Use judgment:
- **"No getters" + "No else"**: May need queries for guard clauses—prefer queries over setters
- **"Two instance variables" + "Wrap primitives"**: Wrapping helps reduce variable count

### Learning from Constraints

Each constraint teaches something:
- **One indentation**: Method extraction and naming
- **No else**: Polymorphism and guard clauses
- **Wrap primitives**: Domain modeling and value objects
- **First class collections**: Encapsulation and domain operations
- **No getters**: Tell, Don't Ask and behavior location

Document in lessons learned how constraints affected your design decisions.

## Common Patterns Emerging from Constraints

### Guard Clauses (from "No Else")

```python
def process(order):
    if not order.is_valid():
        return

    if order.is_cancelled():
        return

    # Main processing
    order.ship()
```

### Composed Method (from "One Indentation" + "Small Entities")

```rust
fn process_order(order: Order) {
    validate_order(&order);
    calculate_total(&order);
    apply_discounts(&order);
    save_order(&order);
}
```

### Value Objects (from "Wrap Primitives")

```typescript
class Temperature {
    constructor(private celsius: number) {
        if (celsius < -273.15) {
            throw new Error("Below absolute zero");
        }
    }

    toFahrenheit(): number {
        return this.celsius * 9/5 + 32;
    }

    isFreezingWater(): boolean {
        return this.celsius <= 0;
    }
}
```

### Domain Collections (from "First Class Collections")

```java
class OrderItems {
    private List<OrderItem> items;

    public Money calculateTotal() {
        return items.stream()
            .map(OrderItem::getPrice)
            .reduce(Money.zero(), Money::add);
    }

    public OrderItems filterByCategory(Category category) {
        return new OrderItems(
            items.stream()
                .filter(item -> item.hasCategory(category))
                .collect(toList())
        );
    }
}
```

## Troubleshooting Constraints

### "My class needs more than 2 variables"

**Solutions**:
- Extract cohesive groups into new classes
- Use composition to build from smaller pieces
- Create value objects to group related primitives
- Consider if class has multiple responsibilities

### "I need a getter for this property"

**Solutions**:
- Add a behavior method that uses the property internally
- Return a computed result instead of raw state
- Use command-query separation (queries for read-only info)
- Create a value object to represent the concept

### "Guard clauses need else-like logic"

**Solutions**:
- Return early from guard clauses
- Use polymorphism for complex conditional logic
- Chain guard clauses for multiple conditions
- Extract decision logic into strategy objects

### "One indentation makes too many tiny methods"

**Solutions**:
- This is actually good—embrace small, well-named methods
- Methods should fit in your head
- Each method has one clear purpose
- Tests become easier to write and understand

## Kata-Specific Considerations

### Choosing Constraints

Not every kata needs all nine constraints. Choose based on:
- **Learning goals**: Focus on constraints you want to practice
- **Kata complexity**: Simple katas may not need all constraints
- **Time available**: More constraints = more challenge

**Recommended starter set**:
1. One level of indentation
2. Don't use else
3. Wrap primitives
4. Don't abbreviate

**Advanced set**: Add constraints 4-9 as you gain proficiency.

### Documenting Constraint Application

In TODO.md lessons learned, note:
- Which constraints affected design decisions
- Where constraints led to better design
- Where constraints felt forced or awkward
- Patterns that emerged from constraints

**Example**:
```markdown
## Lessons Learned
- "No else" constraint led to guard clause pattern in validate() method
- Wrapping primitive score in Score value object enabled comparison methods
- "One indentation" forced extract of filter logic to separate method, improved naming
```

## Further Reading

Object calisthenics were introduced by Jeff Bay in "The ThoughtWorks Anthology" (2008). The constraints codify design principles:
- Single Responsibility Principle (SRP)
- Law of Demeter (LoD)
- Tell, Don't Ask (TDA)
- Composed Method pattern
- Value Object pattern

Practice these constraints in katas to internalize the patterns, then apply judgment about when to use them in production code.
