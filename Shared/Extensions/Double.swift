//
//  Double.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 10/17/22.
//

import Foundation

extension Double {
    
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

}
