extension CGFloat {
    func clamp(from: CGFloat, to: CGFloat) -> CGFloat {
        if self < from {
            return from
        } else if self > to {
            return to
        } else {
            return self
        }
    }
}
