//
//  APIHelper.swift
//  Hausbrandt
//
//  Created by Rohit Saini on 18/09/20.
//  Copyright © 2020 AccessDenied. All rights reserved.
//

import Foundation

struct API{
    struct Diary {
        static let notes = "https://private-ba0842-gary23.apiary-mock.com/notes"
    }
}

struct GCD {
    struct Diary {
        static let notes = DispatchQueue(label: "com.app.notes", qos: DispatchQoS.utility, attributes: DispatchQueue.Attributes.concurrent) //1
    }
}
