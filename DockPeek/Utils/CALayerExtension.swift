import AppKit

extension CALayer {
    func setScaleFactor(x: CGFloat, y: CGFloat, z: CGFloat) {
        self.transform.m11 = x
        self.transform.m22 = y
        self.transform.m33 = z
    }
    
    var scaleFactor: (x: CGFloat, y: CGFloat, z: CGFloat) {
        get {
            return (x: self.transform.m11, y: self.transform.m22, z: self.transform.m33)
        }
        set {
            self.setScaleFactor(x: newValue.x, y: newValue.y, z: newValue.z)
        }
    }
    
    func setScaleFactor2D(x: CGFloat, y: CGFloat) {
        self.transform.m11 = x
        self.transform.m22 = y
    }
    
    var scaleFactor2D: (x: CGFloat, y: CGFloat) {
        get {
            return (x: self.transform.m11, y: self.transform.m22)
        }
        set {
            self.setScaleFactor2D(x: newValue.x, y: newValue.y)
        }
    }
    
    func setTranslation(x: CGFloat, y: CGFloat) {
        self.transform.m41 = x
        self.transform.m42 = y
    }
    
    var translation: NSPoint {
        get { NSMakePoint(self.transform.m41, self.transform.m41) }
        set {
            self.setTranslation(x: newValue.x, y: newValue.y)
        }
    }
}

extension CATransform3D : Equatable {
    public static func == (lhs: CATransform3D, rhs: CATransform3D) -> Bool {
        return (lhs.m11 == rhs.m11) && (lhs.m12 == rhs.m12) && (lhs.m13 == rhs.m13) && (lhs.m14 == rhs.m14) && (lhs.m21 == rhs.m21) && (lhs.m22 == rhs.m22) && (lhs.m23 == rhs.m23) && (lhs.m24 == rhs.m24) && (lhs.m31 == rhs.m31) && (lhs.m32 == rhs.m32) && (lhs.m33 == rhs.m33) && (lhs.m34 == rhs.m34) && (lhs.m41 == rhs.m41) && (lhs.m42 == rhs.m42) && (lhs.m43 == rhs.m43) && (lhs.m44 == rhs.m44)
    }
}
