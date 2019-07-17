//
//  Anchor.swift
//  AnimalAbuse
//
//  Created by Spence on 7/17/19.
//  Copyright © 2019 Olly. All rights reserved.
//

import ARKit

enum NodeType: String {
    case Bunny = "Bo"
    case cure = "antidote"
}

class Anchor: ARAnchor
{
    var type: NodeType?
}
