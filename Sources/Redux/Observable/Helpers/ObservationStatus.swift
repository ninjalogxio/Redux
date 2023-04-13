//
//  ObservationStatus.swift
//  
//
//  Created by Kinglets on 2023/4/12.
//

import Foundation

internal enum ObservationStatus {
    
    case awaiting
    case observed(Observation)
    case completed
}
