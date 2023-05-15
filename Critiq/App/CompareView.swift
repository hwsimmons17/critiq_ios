//
//  CompareView.swift
//  Critiq
//
//  Created by Hunter Simmons on 5/12/23.
//

import SwiftUI

struct CompareView: View {
    var body: some View {
        VStack {
            ZStack {
                AsyncImage(url: URL(string: "https://fastly.4sqi.net/img/general/original/501794_rj5gKxlDFPCwV38XpDx6lJwDQMaROOF1XqR-Vk7xHZQ.jpg")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable()
                             .aspectRatio(contentMode: .fit)
                             .cornerRadius(15)
                             .frame(width: 300, height: 300)
                    case .failure:
                        Image(systemName: "photo")
                    @unknown default:
                        // Since the AsyncImagePhase enum isn't frozen,
                        // we need to add this currently unused fallback
                        // to handle any new cases that might be added
                        // in the future:
                        EmptyView()
                    }
                }
                Text("Arlo")
                    .frame(maxWidth: 100)
                    .multilineTextAlignment(.center)
                    .font(.custom("Ubuntu", size: 20))
                    .padding()
                    .background(Color("Green White"))
                    .cornerRadius(15)
            }
            Text("or")
            ZStack {
                AsyncImage(url: URL(string: "https://fastly.4sqi.net/img/general/original/501794_rj5gKxlDFPCwV38XpDx6lJwDQMaROOF1XqR-Vk7xHZQ.jpg")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable()
                             .aspectRatio(contentMode: .fit)
                             .cornerRadius(15)
                             .frame(width: 300, height: 300)
                    case .failure:
                        Image(systemName: "photo")
                    @unknown default:
                        // Since the AsyncImagePhase enum isn't frozen,
                        // we need to add this currently unused fallback
                        // to handle any new cases that might be added
                        // in the future:
                        EmptyView()
                    }
                }
                Text("Trolley Wing Co")
                    .frame(maxWidth: 100)
                    .multilineTextAlignment(.center)
                    .font(.custom("Ubuntu", size: 20))
                    .padding()
                    .background(Color("Green White"))
                    .cornerRadius(15)
            }
        
            }
    }
}

struct CompareView_Previews: PreviewProvider {
    static var previews: some View {
        CompareView()
    }
}
