



import Foundation
import RealityKit

extension Float {
    public func toDegrees() -> Float {
        return 180 / Float.pi * self
    }
}


extension matrix_float4x4 {
    /// Retrieve euler angles from a quaternion matrix
    public var eulerAngleRadians: SIMD3<Float> {
        get {
            //first we get the quaternion from m00...m22
            //see http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm
            let qw = sqrt(1 + self.columns.0.x + self.columns.1.y + self.columns.2.z) / 2.0
            let qx = (self.columns.2.y - self.columns.1.z) / (qw * 4.0)
            let qy = (self.columns.0.z - self.columns.2.x) / (qw * 4.0)
            let qz = (self.columns.1.x - self.columns.0.y) / (qw * 4.0)

            //then we deduce euler angles with some cosines
            //see https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
            // pitch (x-axis rotation)
            let sinr = +2.0 * (qw * qx + qy * qz)
            let cosr = +1.0 - 2.0 * (qx * qx + qy * qy)
            let pitch = atan2(sinr, cosr)

            // yaw (y-axis rotation)
            let sinp = +2.0 * (qw * qy - qz * qx)
            var yaw: Float
            if abs(sinp) >= 1 {
                 yaw = copysign(Float.pi / 2, sinp)
            } else {
                yaw = asin(sinp)
            }

            // roll (z-axis rotation)
            let siny = +2.0 * (qw * qz + qx * qy)
            let cosy = +1.0 - 2.0 * (qy * qy + qz * qz)
            let roll = atan2(siny, cosy)

            // result in radians
            return SIMD3<Float>(pitch, yaw, roll)
        }
    }
    
    public var eulerAngleDegrees: SIMD3<Float> {
        get {
            //first we get the quaternion from m00...m22
            //see http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm
            let qw = sqrt(1 + self.columns.0.x + self.columns.1.y + self.columns.2.z) / 2.0
            let qx = (self.columns.2.y - self.columns.1.z) / (qw * 4.0)
            let qy = (self.columns.0.z - self.columns.2.x) / (qw * 4.0)
            let qz = (self.columns.1.x - self.columns.0.y) / (qw * 4.0)

            //then we deduce euler angles with some cosines
            //see https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
            // pitch (x-axis rotation)
            let sinr = +2.0 * (qw * qx + qy * qz)
            let cosr = +1.0 - 2.0 * (qx * qx + qy * qy)
            let pitch = atan2(sinr, cosr) * 180 / Float.pi

            // yaw (y-axis rotation)
            let sinp = +2.0 * (qw * qy - qz * qx)
            var yaw: Float
            if abs(sinp) >= 1 {
                 yaw = copysign(Float.pi / 2, sinp) * 180 / Float.pi
            } else {
                yaw = asin(sinp) * 180 / Float.pi
            }

            // roll (z-axis rotation)
            let siny = +2.0 * (qw * qz + qx * qy)
            let cosy = +1.0 - 2.0 * (qy * qy + qz * qz)
            let roll = atan2(siny, cosy)  * 180 / Float.pi

            // result in radians
            return SIMD3<Float>(pitch, yaw, roll)
        }
    }

}


extension simd_quatf {
    
    init(angleDegrees: Float, axis: SIMD3<Float>) {
        let angleRadians = angleDegrees * Float.pi / 180
        self.init(angle: angleRadians, axis: axis)
    }
    
    
    private func toDegrees(rad: Float) -> Float {
        return rad * 180 / Float.pi
    }
    
    
    public func printDebugDetails () {
        print("ORIGINAL QUAT: ", self.debugDescription)
        print("\n\nQUAT DETAILS: \n")
        print("ANGLE: ", self.angle)
        print("ANGLE DEGREES: ", self.toDegrees(rad: self.angle))
        print("AXIS: ", self.axis)
        print("LENGTH: ", self.length)

        print("EULER ANGLES (pitch,yaw,roll): ", self.eulerRadians)
        
        print("EULER ANGLES (pitch,yaw,roll): ", self.eulerDegrees)
    }

    
    public var eulerRadians: SIMD3<Float> {
        get {
            
        let qx = self.imag.x
        let qy = self.imag.y
        let qz = self.imag.z
        let qw = self.real
            
        //then we deduce euler angles with some cosines
        //see https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
        // pitch (x-axis rotation)
            
        let sinr = +2.0 * (qw * qx + qy * qz)
        let cosr = +1.0 - 2.0 * (qx * qx + qy * qy)
        let pitch = atan2(sinr, cosr)

        // yaw (y-axis rotation)
        let sinp = +2.0 * (qw * qy - qz * qx)
        var yaw: Float
        if abs(sinp) >= 1 {
             yaw = copysign(Float.pi / 2, sinp)
        } else {
            yaw = asin(sinp)
        }

        // roll (z-axis rotation)
        let siny = +2.0 * (qw * qz + qx * qy)
        let cosy = +1.0 - 2.0 * (qy * qy + qz * qz)
        let roll = atan2(siny, cosy)

        return SIMD3<Float>(pitch, yaw, roll)
    } // end get
    }
    
    
    public var eulerDegrees: SIMD3<Float> {
        get {
            let qx = self.imag.x
            let qy = self.imag.y
            let qz = self.imag.z
            let qw = self.real
                
            //then we deduce euler angles with some cosines
            //see https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
            // pitch (x-axis rotation)
                
            let sinr = +2.0 * (qw * qx + qy * qz)
            let cosr = +1.0 - 2.0 * (qx * qx + qy * qy)
            let pitch = atan2(sinr, cosr)  * 180 / Float.pi

            // yaw (y-axis rotation)
            let sinp = +2.0 * (qw * qy - qz * qx)
            var yaw: Float
            if abs(sinp) >= 1 {
                 yaw = copysign(Float.pi / 2, sinp) * 180 / Float.pi
            } else {
                yaw = asin(sinp)  * 180 / Float.pi
            }

            // roll (z-axis rotation)
            let siny = +2.0 * (qw * qz + qx * qy)
            let cosy = +1.0 - 2.0 * (qy * qy + qz * qz)
                let roll = atan2(siny, cosy) * 180 / Float.pi

            return SIMD3<Float>(pitch, yaw, roll)
        } // end get
    }
}


extension Transform {
    
    public mutating func setRotationEulers(xDeg pitchXDegrees: Float, yDeg yawYDegrees: Float, zDeg rollZDegrees: Float ) {
        
        let rotX = simd_quatf(angleDegrees: pitchXDegrees, axis: [1,0,0])
        let rotY = simd_quatf(angleDegrees: yawYDegrees, axis: [0,1,0])
        let rotZ = simd_quatf(angleDegrees: rollZDegrees, axis: [0,0,1])
        let newRotation = rotX * rotY * rotZ
        self.rotation = newRotation
    }
}
