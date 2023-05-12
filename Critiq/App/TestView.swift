//
//  TestView.swift
//  Critiq
//
//  Created by Hunter Simmons on 5/10/23.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        AsyncImage(url: URL(string: "https://fastly.4sqi.net/img/general/original/524698010_PpmP8kMSRM40wycJ8z-6lfT2XNcmSrkTCkjQIcRvnU4.jpg"))
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
