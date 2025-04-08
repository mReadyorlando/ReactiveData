# 📦 ReactiveData

**ReactiveData** este un utilitar generic Swift care gestionează surse de date asincrone într-un mod reactiv, folosind framework-ul [Combine](https://developer.apple.com/documentation/combine). Este ideal pentru aplicații iOS/macOS care consumă date din rețea, baze de date sau alte surse asincrone.

---

## ✨ Caracteristici

- ✅ Interfață reactivă peste orice `AnyPublisher<T, Error>`
- 🔁 Evită reîncărcarea redundantă (în cazul unui fetch deja în curs)
- ⚠️ Expune stări clare: `.loading`, `.ready`, `.failure`
- 📦 Simplu de integrat în MVVM, SwiftUI, UIKit
- 🧪 Ușor de testat și reutilizat

---

## 📦 Instalare

### Swift Package Manager

Adaugă următoarea dependență în fișierul `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mReadyorlando/ReactiveData.git", from: "1.0.0")
]
