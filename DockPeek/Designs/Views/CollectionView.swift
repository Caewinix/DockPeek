import AppKit

/// The `CollectionView` collects all window thumbnails of an application, extending from the `StackView`, since different dock orientation leads to various arrangement.
class CollectionView : StackView {
    override func rearrangeHorizontalSubviews() {
        var maxHeight: CGFloat = 0
        for subview in super.subviews {
            let subview = subview as! ThumbnailView
            let height = subview.mainView!.frame.height
            if maxHeight < height {
                maxHeight = height
            }
        }
        for subview in super.subviews {
            let subview = subview as! ThumbnailView
            subview.mainView!.setFrameSize(NSMakeSize(subview.mainView!.frame.width, maxHeight))
        }
    }
    
    override func rearrangeVerticalSubviews() {
        var maxWidth: CGFloat = 0
        for subview in super.subviews {
            let subview = subview as! ThumbnailView
            let width = subview.mainView!.frame.width
            if maxWidth < width {
                maxWidth = width
            }
        }
        for subview in super.subviews {
            let subview = subview as! ThumbnailView
            subview.mainView!.setFrameSize(NSMakeSize(maxWidth, subview.mainView!.frame.height))
        }
    }
}
