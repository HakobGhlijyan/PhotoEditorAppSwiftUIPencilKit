//
//  TextBox.swift
//  PhotoEditorAppSwiftUIPencilKit
//
//  Created by Hakob Ghlijyan on 22.08.2024.
//

import SwiftUI
import PencilKit

struct TextBox: Identifiable {
    var id = UUID().uuidString
    var text: String = ""
    var isBold: Bool = false
    //For Offset
    var offset: CGSize = .zero
    var lastOffset: CGSize = .zero
    var textColor: Color = .white
}
