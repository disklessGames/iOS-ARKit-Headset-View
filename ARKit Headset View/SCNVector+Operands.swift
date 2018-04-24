
import SceneKit

func +(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
    return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}

func -(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
    return left + (right * -1.0)
}

func +=(left: inout SCNVector3, right:SCNVector3) {
    left = SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}

func -=(left: inout SCNVector3, right:SCNVector3) {
    left = SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
}

func *(vector:SCNVector3, multiplier:SCNFloat) -> SCNVector3 {
    return SCNVector3(vector.x * multiplier, vector.y * multiplier, vector.z * multiplier)
}

func *=(vector: inout SCNVector3, multiplier:SCNFloat) {
    vector = vector * multiplier
}


extension SCNVector3 {

    var magnitude:SCNFloat {
        get {
            return sqrt(dotProduct(self))
        }
    }

    var normalized:SCNVector3 {
        get {
            let localMagnitude = magnitude
            let localX = x / localMagnitude
            let localY = y / localMagnitude
            let localZ = z / localMagnitude

            return SCNVector3(localX, localY, localZ)
        }
    }

    func dotProduct(_ vectorB:SCNVector3) -> SCNFloat {
        return (x * vectorB.x) + (y * vectorB.y) + (z * vectorB.z)
    }

    func crossProduct(_ vectorB:SCNVector3) -> SCNVector3 {
        let computedX = (y * vectorB.z) - (z * vectorB.y)
        let computedY = (z * vectorB.x) - (x * vectorB.z)
        let computedZ = (x * vectorB.y) - (y * vectorB.x)

        return SCNVector3(computedX, computedY, computedZ)
    }

    func angleBetweenVectors(_ vectorB:SCNVector3) -> SCNFloat {
        let cosineAngle = (dotProduct(vectorB) / (magnitude * vectorB.magnitude))
        return SCNFloat(acos(cosineAngle))
    }
}
