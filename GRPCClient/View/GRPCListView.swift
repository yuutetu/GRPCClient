//
//  GRPCListView.swift
//  GRPCClient
//
//  Created by 加賀江 優幸 on 2019/12/15.
//  Copyright © 2019 yuutetu. All rights reserved.
//

import SwiftUI
import ReactorKit
import RxSwift

struct GRPCListView: SwiftUI.View {
    @ObservedObject var viewModel: GRPCListViewModel

    init(viewModel: GRPCListViewModel) {
        self.viewModel = viewModel
    }

    var body: some SwiftUI.View {
        List {
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
    @Published var services: [GRPCListViewReactor.Service]
    private var reactor: GRPCListViewReactor
    private var disposeBag = DisposeBag()

    init() {
        self.services = []
        self.reactor = GRPCListViewReactor()

        self.setupReactor()
    }

    private func setupReactor() {
        reactor.state.subscribe(onNext: { [weak self] state in
            self?.services = state.services
        }, onError: { error in
            // error handling
        }, onCompleted: {
            // completion
        }, onDisposed: {
            // disposed
        }).disposed(by: disposeBag)
    }
}

class GRPCListViewReactor: Reactor {
    var initialState = State(services: [
        GRPCListViewReactor.Service(name: "NekoService", endpoints: [
            GRPCListViewReactor.Endpoint(name: "CreateNeko"),
            GRPCListViewReactor.Endpoint(name: "UpdateNeko")
        ]),
        GRPCListViewReactor.Service(name: "DogService", endpoints: [
            GRPCListViewReactor.Endpoint(name: "CreateDog"),
            GRPCListViewReactor.Endpoint(name: "UpdateDog"),
            GRPCListViewReactor.Endpoint(name: "GetDog"),
            GRPCListViewReactor.Endpoint(name: "ListDogs")
        ])
    ])

    struct Service: Hashable {
        var name: String
        var endpoints: [Endpoint]
    }

    struct Endpoint: Hashable {
        var name: String
    }

    enum Action {
        case create(serviceName: String, endpointName: String)
    }

    struct State {
        var services: [Service]
    }
}
