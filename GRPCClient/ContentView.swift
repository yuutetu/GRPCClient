//
//  ContentView.swift
//  GRPCClient
//
//  Created by 加賀江 優幸 on 2019/12/15.
//  Copyright © 2019 yuutetu. All rights reserved.
//

import SwiftUI

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()

struct ContentView: View {
    let masterReactor = GRPCListViewReactor()

    var body: some View {
        NavigationView {
            GRPCListView(viewModel: GRPCListViewModel(reactor: masterReactor))
                .navigationBarTitle(Text("Services"))
                .navigationBarItems(trailing:
                    Button(action: {
                        self.masterReactor.action.on(.next(.changeToAdditionMode))
                    }, label: {
                        Image.init(systemName: "plus")
                    }))
            DetailView()
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct MasterView: View {
    @Binding var dates: [Date]

    var body: some View {
        List {
            ForEach(dates, id: \.self) { date in
                NavigationLink(
                    destination: DetailView(selectedDate: date)
                ) {
                    Text("\(date, formatter: dateFormatter)")
                }
            }.onDelete { indices in
                indices.forEach { self.dates.remove(at: $0) }
            }
        }
    }
}

struct DetailView: View {
    var selectedDate: Date?

    var body: some View {
        Group {
            if selectedDate != nil {
                Text("\(selectedDate!, formatter: dateFormatter)")
            } else {
                Text("Detail view content goes here")
            }
        }.navigationBarTitle(Text("Detail"))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
