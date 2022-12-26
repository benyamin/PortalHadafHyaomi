//
//  Array+Extras.swift
//  TravelSystems
//
//  Created by Binyamin Trachtman on 1/25/16.
//  Copyright © 2016 Binyamin Trachtman. All rights reserved.
//

import Foundation

public extension Array
{
    mutating func removeObject<U: Equatable>(_ object: U) -> Bool {
        for (idx, objectToCompare) in self.enumerated() {  //in old swift use enumerate(self)
            if let to = objectToCompare as? U {
                if object == to {
                    self.remove(at: idx)
                    return true
                }
            }
        }
        return false
    }
    
    mutating func reverse()
    {
        let array = Array(self)
        self.removeAll()
        
        for i in ((-1 + 1)...array.count-1).reversed()
        {
            self.append(array[i])
        }
    }
    
    mutating func remove (_ object: AnyObject)
    {
        for index in 0 ..< self.count {
            
            if (self[index] as AnyObject) === object
            {
                 self.remove(at: index)
                break
            }
        }
    }
    
    mutating func index (of object: AnyObject) -> Int?
    {
        for index in 0 ..< self.count {
            
            if (self[index] as AnyObject) === object
            {
                return index
            }
        }
        
        return nil
    }
    
    mutating func removeLast()
    {
        self.remove(at: self.count-1)
    }
    
    mutating func remove(at indexes: [Int]) {
        for index in indexes.sorted(by: >) {
            remove(at: index)
        }
    }
    
    subscript (randomPick n: Int) -> [Element] {
        var indices = [Int](0..<count)
        var randoms = [Int]()
        for _ in 0..<n {
            randoms.append(indices.remove(at: Int(arc4random_uniform(UInt32(indices.count)))))
        }
        return randoms.map { self[$0] }
    }
    
}
