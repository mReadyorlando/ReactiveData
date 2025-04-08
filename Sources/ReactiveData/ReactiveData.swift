// The Swift Programming Language
// https://docs.swift.org/swift-book

import Combine
import Foundation

public enum DataState<T> {
    case loading
    case ready(T)
    case failure(Error)
    
    public var value: T? {
        if case let .ready(t) = self {
            return t
        }
        return nil
    }
    
    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    public var error: Error? {
        if case let .failure(error) = self {
            return error
        }
        return nil
    }
    
    func map<NewT>(transform: ((T) -> NewT) ) -> DataState<NewT> {
        switch self {
        case .loading:
            return .loading
        case .ready(let t):
            return .ready(transform(t))
        case .failure(let error):
            return .failure(error)
        }
    }
}

public class ReactiveData<T> {
    
    private var cancellables = Set<AnyCancellable>()
    
    private var publisherClosure: () -> (AnyPublisher<T, Error>?)
    private var inFlightPublisher: AnyPublisher<T, Error>?
    private var stateSubject = CurrentValueSubject<DataState<T>, Never>(.loading)
    
    private let queue = DispatchQueue(label: "ReactiveData.Queue.\(UUID().uuidString)")
    
    init(publisherClosure: @escaping () -> (AnyPublisher<T, Error>?)) {
        self.publisherClosure = publisherClosure
    }
    
    public var currentValue: T? {
        self.stateSubject.value.value
    }
    
    public func getPublisher(silentReload: Bool = false) -> AnyPublisher<T, Error> {
        queue.sync {
            if let inFlightPublisher = inFlightPublisher {
                return inFlightPublisher
            }
            inFlightPublisher = publisherClosure()?
                .receive(on: queue)
                .handleEvents { [weak self] _ in
                    if !silentReload {
                        self?.stateSubject.value = .loading
                    }
                } receiveOutput: { [weak self] t in
                    guard let self = self else {return}
                    self.stateSubject.value = .ready(t)
                } receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.stateSubject.value = .failure(error)
                    }
                    self?.inFlightPublisher = nil
                }.share()
                .eraseToAnyPublisher()
            return inFlightPublisher!
        }
    }
    
    public func reload(silentReload: Bool = false) {
        getPublisher(silentReload: silentReload).sink { _ in } receiveValue: { _ in }.store(in: &self.cancellables)
    }
    
    public func getStateSubject() -> AnyPublisher<DataState<T>, Never> {
        switch stateSubject.value {
        case .ready(_):
            break
        case .failure(_):
            reload()
        case .loading:
            reload()
        }
        return stateSubject.eraseToAnyPublisher()
    }
    
    public func getValuesSubject() -> AnyPublisher<T, Never> {
        switch stateSubject.value {
        case .ready(_):
            break
        case .failure(_):
            break
        case .loading:
            reload()
        }
        return stateSubject
            .compactMap {$0.value}
            .eraseToAnyPublisher()
    }
    
    public func awaitValue() -> AnyPublisher<T, Never> {
        return getStateSubject()
            .compactMap {$0.value}
            .first()
            .eraseToAnyPublisher()
    }
    
    public func requireValue() -> AnyPublisher<T, Error> {
        return getStateSubject()
            .filter { state in
                switch state {
                case .ready(_):
                    return true
                case .failure(_):
                    return true
                case .loading:
                    return false
                }
            }.first()
            .tryMap { state in
                switch state {
                case .loading:
                    fatalError()
                case .ready(let value):
                    return value
                case .failure(let error):
                    throw error
                }
            }.eraseToAnyPublisher()
    }
    
    public func uninitialize() {
        self.stateSubject.value = .loading
    }
    
    public func pushValue(value: T) {
        self.stateSubject.value = .ready(value)
    }
}
