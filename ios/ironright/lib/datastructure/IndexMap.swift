//
//  IndexMap.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/20.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//

import Foundation

struct IndexMap<V> : Sequence, IteratorProtocol
{
    var map:[String:V] = [String:V]()
    var index:[String] = []
    var currentIndex = 0
    
    var count:Int
    {
        set {}
        get { return index.count }
    }
    var isEmpty:Bool
    {
        set {}
        get { return index.isEmpty }
    }
    
    var first:V?
    {
        set {}
        get {
            if index.isEmpty { return nil }
            return map[ index[0] ] }
    }
    var last:V?
    {
        set {}
        get {
            if index.isEmpty { return nil }
            return map[ index[ index.count-1 ] ]
        }
    }
    
    mutating func makeIterator() -> Iterator
    {
        currentIndex = 0
        return self
    }
    
    mutating func next() -> V?
    {
        let idx = currentIndex
        currentIndex += 1
        return get(idx:idx)
    }
    
    func get(idx:Int)->V?
    {
        if idx < 0 || idx >= count {return nil}
        let key = index[idx]
        return map[key]
    }
    
    func get(key:String)->V?
    {
        return map[key]
    }
    
    mutating func clear()
    {
        index.removeAll()
        map.removeAll()
    }
    
    mutating func remove(idx:Int)
    {
        let key = index[idx]
        remove(key: key)
    }
    mutating func remove(key:String)
    {
        guard let pos = map.index(forKey: key) else {return}
        map.remove(at: pos)
        guard let idx = index.firstIndex(of: key) else {return}
        index.remove(at: idx)
    }
    
    mutating func put(key:String,value:V)
    {
        map.updateValue(value, forKey: key)
        index.append(key)
    }
    
    @discardableResult
    mutating func poll()->V?
    {
        guard let key = index.first else {return nil}
        let v = get(key:key)
        remove(key:key)
        return v
    }
    
    @discardableResult
    mutating func pop()->V?
    {
        guard let key = index.last else {return nil}
        let v = get(key:key)
        remove(key:key)
        return v
    }
    
    
    
}

