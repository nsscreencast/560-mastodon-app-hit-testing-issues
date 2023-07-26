import SwiftUI
import Manfred


struct ImageGalleryView: View {
    let mediaAttachments: [MediaAttachment]

    struct LayoutItem: Identifiable {
        var id: Int { index }
        let index: Int
        let media: MediaAttachment
        let frame: CGRect

        var debugTintColor: Color {
            [Color.red, .blue, .green][index % 3].opacity(0.5)
        }
    }

    func layout(proxy: GeometryProxy) -> [LayoutItem] {
        let maxItemsPerRow = mediaAttachments.count == 1 ? 1 : 2
        let numberOfRows = Int(ceil(CGFloat(mediaAttachments.count) / CGFloat(maxItemsPerRow)))
        var x: CGFloat = 0
        var y: CGFloat = 0
        let templateWidth: CGFloat = proxy.size.width / CGFloat(maxItemsPerRow)
        let height: CGFloat = proxy.size.height / CGFloat(numberOfRows)
        var items: [LayoutItem] = []
        for index in mediaAttachments.indices {
            var width = templateWidth
            let media = mediaAttachments[index]
            if x + width > proxy.size.width {
                // new row
                y += height
                x = 0
            }

            if index == mediaAttachments.count - 1, x == 0 {
                // last item is by itself on a row, then fill it
                width = proxy.size.width
            }

            let rect = CGRect(
                x: x + width/2,
                y: y + height/2,
                width: width,
                height: height
            )
            items.append(.init(index: index, media: media, frame: rect))

            x += width
        }

        return items
    }

    var body: some View {
        GeometryReader { proxy in
            let items = layout(proxy: proxy)
            ForEach(items) { item in
                imageItem(imageURL: item.media.previewUrl!)
                    .aspectRatio(contentMode: .fill)
//                    .overlay {
//                        item.debugTintColor
//                    }
                    .frame(width: item.frame.width, height: item.frame.height)
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        GalleryWindowManager.shared.show(
                            media: self.mediaAttachments,
                            selectedIndex: item.index
                        )
                    }
                    .position(item.frame.origin)
            }
        }
    }

    private func imageItem(imageURL: URL) -> some View {
        RemoteImageView(url: imageURL) { image in
            image
                .resizable()
        } placeholder: {
            Color.gray
        }
    }
}

#if DEBUG
struct ImageGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        let post = Post.imageAspectRatios
        ImageGalleryView(mediaAttachments: post.media)
    }
}
#endif
