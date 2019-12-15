//
//  GRPCListView.swift
//  GRPCClient
//
//  Created by 加賀江 優幸 on 2019/12/15.
//  Copyright © 2019 yuutetu. All rights reserved.
//

import SwiftUI
import Combine
import ReactorKit
import RxSwift

struct GRPCListView: SwiftUI.View {
    @ObservedObject var viewModel: GRPCListViewModel

    init(viewModel: GRPCListViewModel) {
        self.viewModel = viewModel
    }

    var body: some SwiftUI.View {
        List {
            if viewModel.isAdditionMode {
                TextField("{Service Name}/{Endpoint}", text: $viewModel.additionFormText, onCommit: {
                    self.viewModel.reactor.action.on(.next(.addEndpoint(text: self.viewModel.additionFormText)))
                })
//                KMTextField(placeholder: "{Service Name}/{Endpoint}") { text in
//                    guard let text = text else {
//                        return
//                    }
//                    self.viewModel.reactor.action.on(.next(.addEndpoint(text: text)))
//                }
            }
            ForEach(viewModel.services, id: \.self) { service in
                Section(header: Text(service.name)) {
                    ForEach(service.endpoints, id: \.self) { endpoint in
                        Text(endpoint.name)
                    }
                }
            }
        }
    }
}

class GRPCListViewModel: ObservableObject {
    @Published var isAdditionMode: Bool
    @Published var services: [GRPCListViewReactor.Service]
    @Published var additionFormText: String
    let reactor: GRPCListViewReactor
    private var disposeBag = DisposeBag()
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

    init(reactor: GRPCListViewReactor) {
        self.isAdditionMode = false
        self.services = []
        self.additionFormText = ""
        self.reactor = reactor

        self.setupReactor()
    }

    private func setupReactor() {
        reactor.state.subscribe(onNext: { [weak self] state in
            self?.isAdditionMode = state.isAdditionMode
            self?.services = state.serviceRepository.services
            self?.additionFormText = state.additionFormText
        }, onError: { error in
            // error handling
        }, onCompleted: {
            // completion
        }, onDisposed: {
            // disposed
        }).disposed(by: disposeBag)

        $additionFormText.sink(receiveValue: { [weak self] text in
            self?.reactor.action.onNext(.changeAdditionFromText(text: text))
        }).store(in: &cancellables)
    }
}

class GRPCListViewReactor: Reactor {
    var initialState = { () -> GRPCListViewReactor.State in
        var repository = ServiceRepository()
        repository.append(serviceName: "NekoService", endpointName: "CreateNeko")
        repository.append(serviceName: "DogService", endpointName: "GetDog")
        repository.append(serviceName: "NekoService", endpointName: "UpdateNeko")
        repository.append(serviceName: "DogService", endpointName: "CreateDog")
        repository.append(serviceName: "DogService", endpointName: "ListDogs")
        repository.append(serviceName: "DogService", endpointName: "UpdateDog")
        return State(
            isAdditionMode: false,
            serviceRepository: repository,
            additionFormText: ""
        )
    }()

    struct Service: Hashable {
        var name: String
        var endpoints: [Endpoint]
    }

    struct Endpoint: Hashable {
        var name: String
    }

    struct ServiceRepository {
        var serviceNames = Set<String>()
        var endpointMap = [String: Set<String>]()

        mutating func append(serviceName: String, endpointName: String) {
            self.serviceNames.insert(serviceName)
            endpointMap[serviceName] = endpointMap[serviceName] ?? Set<String>()
            endpointMap[serviceName]?.insert(endpointName)
        }

        var services: [Service] {
            serviceNames.sorted().map{ serviceName in
                let endpoints = endpointMap[serviceName]?.sorted().map{ endpointName in
                    Endpoint(name: endpointName)
                } ?? []
                return Service(name: serviceName, endpoints: endpoints)
            }
        }
    }

    enum Action {
        case additionButtonTap
        case addEndpoint(text: String)
        case changeAdditionFromText(text: String)
    }

    enum Mutation {
        case additionMode(activate: Bool)
        case insertService(name: String)
        case changeAdditionFromText(text: String)
    }

    func mutate(action: GRPCListViewReactor.Action) -> Observable<GRPCListViewReactor.Mutation> {
        switch action {
        case .additionButtonTap:
            return .just(.additionMode(activate: true))
        case .addEndpoint(let text):
            return Observable.merge(
                Observable.just(.insertService(name: text)),
                Observable.just(.additionMode(activate: false)),
                Observable.just(.changeAdditionFromText(text: ""))
            )
        case .changeAdditionFromText(let text):
            return .just(.changeAdditionFromText(text: text))
        }
    }

    func reduce(state: GRPCListViewReactor.State, mutation: GRPCListViewReactor.Mutation) -> GRPCListViewReactor.State {
        switch mutation {
        case .additionMode(let activate):
            return State(
                isAdditionMode: activate,
                serviceRepository: state.serviceRepository,
                additionFormText: state.additionFormText
            )
        case .insertService(let name):
            let splittedNames = name.split(separator: "/")
            guard splittedNames.count >= 2 else {
                return state
            }

            let serviceName = String(splittedNames[0])
            let endpointName = String(splittedNames[1])
            var repository = state.serviceRepository
            repository.append(serviceName: serviceName, endpointName: endpointName)
            return State(
                isAdditionMode: state.isAdditionMode,
                serviceRepository: repository,
                additionFormText: state.additionFormText
            )
        case .changeAdditionFromText(let text):
            return State(
                isAdditionMode: state.isAdditionMode,
                serviceRepository: state.serviceRepository,
                additionFormText: text
            )
        }
    }

    struct State {
        var isAdditionMode: Bool
        var serviceRepository: ServiceRepository
        var additionFormText: String
    }
}

//struct KMTextField: UIViewRepresentable {
//    private let textField = EnterHandlingTextField()
//    var placeholder:String?
//    var onReturnHandler:((String?)->Void)?
//
//    func makeUIView(context: UIViewRepresentableContext<KMTextField>) -> EnterHandlingTextField {
//        textField.delegate = textField
//        textField.placeholder = placeholder
//        textField.onReturnHandler = onReturnHandler
//        return textField
//    }
//
//    func updateUIView(_ uiView: EnterHandlingTextField, context: UIViewRepresentableContext<KMTextField>) {
//        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
//    }
//
//    class EnterHandlingTextField: UITextField, UITextFieldDelegate {
//        var onReturnHandler: ((String?) -> Void)?
//
//        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//            onReturnHandler?(textField.text)
//            return true
//        }
//    }
//}
