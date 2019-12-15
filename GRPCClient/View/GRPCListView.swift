//
//  GRPCListView.swift
//  GRPCClient
//
//  Created by 加賀江 優幸 on 2019/12/15.
//  Copyright © 2019 yuutetu. All rights reserved.
//

import SwiftUI

struct GRPCListView: View {
    @ObservedObject var viewModel: GRPCListViewModel

    init(viewModel: GRPCListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
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
    struct Service: Hashable {
        var name: String
        var endpoints: [Endpoint]
    }

    struct Endpoint: Hashable {
        var name: String
    }
    
    @Published var services: [Service]

    init() {
        self.services = [
            Service(name: "NekoService", endpoints: [
                Endpoint(name: "CreateNeko"),
                Endpoint(name: "UpdateNeko")
            ])
        ]
    }
}
