# ReactiveData

**ReactiveData** is a lightweight Swift utility that manages asynchronous data reactively using [Combine](https://developer.apple.com/documentation/combine). It’s designed for apps that need a clear data state model: `.loading`, `.ready`, `.failure`.

## Features

- ✅ Wraps any `AnyPublisher<T, Error>`
- 🔁 Prevents redundant reloads with in-flight tracking
- 📡 Exposes data state via `CurrentValueSubject`
- 🔄 Supports reload, manual injection, and reset
- 🧪 Easy to test and integrate with MVVM / SwiftUI

## Installation

Use Swift Package Manager:

```swift
.package(url: "https://github.com/mReadyorlando/ReactiveData.git", from: "1.0.0")
