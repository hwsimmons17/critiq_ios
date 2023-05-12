//
//  SearchView.swift
//  Critiq
//
//  Created by Hunter Simmons on 5/10/23.
//

import SwiftUI
import MapKit
import Combine

struct SearchView: View {
    @StateObject var debounceObject = DebounceObject()
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(locationManager.searchResults, id: \.self) { searchResult in
                        VStack(alignment: .leading) {
                                Text(searchResult.name)
                                    .font(.headline)
                            Text(searchResult.address.address)
                        }
                    }
                }
            }
            .navigationTitle("Add Restaurant")
            .searchable(text: $debounceObject.text)
            .onChange(of: debounceObject.debouncedText) { text in
                locationManager.searchForRestaruant(searchString: text)
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}


public final class DebounceObject: ObservableObject {
    @Published var text: String = ""
    @Published var debouncedText: String = ""
    private var bag = Set<AnyCancellable>()

    public init(dueTime: TimeInterval = 0.2) {
        $text
            .removeDuplicates()
            .debounce(for: .seconds(dueTime), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.debouncedText = value
            })
            .store(in: &bag)
    }
}
