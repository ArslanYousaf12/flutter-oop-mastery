# OOP Flutter Mastery

A Flutter application designed to demonstrate Object-Oriented Programming (OOP) concepts in a real-world Flutter app. This project was created for educational purposes to help students understand how OOP principles are applied in Flutter development.

## Project Overview

This task management app showcases key OOP concepts within a practical Flutter application. Each component of the app is designed to clearly demonstrate specific OOP principles, making it an ideal learning resource for students and developers new to OOP in Flutter.

## OOP Concepts Demonstrated

### 1. Abstraction
- **Abstract Task Class**: The base `Task` class is abstract, defining a blueprint that all task types must follow
- **Task Repository Interface**: Defines methods that any repository implementation must provide

### 2. Inheritance
- **Task Types Hierarchy**: `QuickTask`, `ProjectTask`, and `RecurringTask` all extend the base `Task` class
- **UI Inheritance**: Screen components extend base Flutter widgets like `StatefulWidget`

### 3. Polymorphism
- **Task Rendering**: Different task types display specialized UI elements based on their type
- **Task Actions**: Tasks respond differently to actions like "complete" based on their type (especially recurring tasks)
- **Repository Implementation**: The repository interface can have multiple implementations

### 4. Encapsulation
- **Private Variables**: Data is protected with private variables (using the `_` prefix)
- **Getter/Setter Methods**: Controlled access to class properties
- **Data Hiding**: Implementation details are hidden behind clean interfaces

### 5. Composition
- **Project Tasks with Subtasks**: `ProjectTask` contains other `Task` objects, showing object composition
- **UI Composition**: Screens composed of multiple smaller widget components

### 6. Design Patterns
- **Singleton Pattern**: In the `InMemoryTaskRepository` to ensure only one instance exists
- **Factory Pattern**: The task creation process uses factory methods to instantiate specific task types
- **Dependency Injection**: Services receive their dependencies through constructors

### 7. Other OOP Features
- **Method Overriding**: Tasks override methods like `getTaskDetails()` to provide specialized behavior
- **Data Persistence**: Demonstrates serialization and deserialization with SharedPreferences

## Educational Value

This project serves as a learning resource to understand:
- How to structure a Flutter app using OOP principles
- When and where to apply different OOP concepts
- Practical examples of abstract classes, inheritance, and polymorphism
- How OOP principles improve code organization, reusability, and maintainability

## Getting Started

To run this project:

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

## Code Organization

- **models/**: Contains all data classes and their relationships
- **repositories/**: Implements data storage and retrieval
- **services/**: Contains business logic and operations
- **screens/**: User interface components
- **utils/**: Utility classes and helper methods
