//
//  PostGridView.swift
//  Instagram
//
//  Created by Mario Ban on 13.02.2024..
//

import SwiftUI
import Kingfisher

struct PostGridView: View {
    private let imageDimension: CGFloat = (UIScreen.main.bounds.width / 3) - 4
    @StateObject var viewModel: PostGridViewModel
    
    init(user: User) {
        self._viewModel = StateObject(wrappedValue: PostGridViewModel(user: user))
    }
    
    
   // private let gridItems: [GridItem] = [
   //     .init(.flexible(), spacing: 1),
   //     .init(.flexible(), spacing: 1),
   //     .init(.flexible(), spacing: 1)
   // ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 2), count: 3), spacing: 2) {
            ForEach(viewModel.posts) { post in
                KFImage(URL(string: post.imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageDimension, height: imageDimension)
                    .clipped()
                    .cornerRadius(5)
                    .shadow(radius: 2)
            }
        }
        .padding(2)
    }
}

#Preview {
    PostGridView(user: User.MOCK_USERS[0])
}
