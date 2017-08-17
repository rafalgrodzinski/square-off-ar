//
//  SCNMatrix4Extension.swift
//  Square Off AR
//
//  Created by Rafal Grodzinski on 13/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import SceneKit

extension SCNMatrix4
{
    init(simdMatrix: simd_float4x4)
    {
        self.init(m11: simdMatrix.columns.0.x, m12: simdMatrix.columns.0.y, m13: simdMatrix.columns.0.z, m14: simdMatrix.columns.0.w,
                  m21: simdMatrix.columns.1.x, m22: simdMatrix.columns.1.y, m23: simdMatrix.columns.1.z, m24: simdMatrix.columns.1.w,
                  m31: simdMatrix.columns.2.x, m32: simdMatrix.columns.2.y, m33: simdMatrix.columns.2.z, m34: simdMatrix.columns.2.w,
                  m41: simdMatrix.columns.3.x, m42: simdMatrix.columns.3.y, m43: simdMatrix.columns.3.z, m44: simdMatrix.columns.3.w)
    }

    var translationMatrix: SCNMatrix4 {
        return SCNMatrix4MakeTranslation(m41, m42, m43)
    }
}
