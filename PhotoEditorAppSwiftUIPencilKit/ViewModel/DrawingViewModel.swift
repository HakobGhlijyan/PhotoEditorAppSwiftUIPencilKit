//
//  DrawingViewModel.swift
//  PhotoEditorAppSwiftUIPencilKit
//
//  Created by Hakob Ghlijyan on 21.08.2024.
//

import SwiftUI
import PencilKit

class DrawingViewModel: ObservableObject {
    @Published var showImagePicker = false
    @Published var imageData: Data = Data(count: 0)
    
    // canvas for drawing...
    @Published var canvas = PKCanvasView()
    // tool picker
    @Published var toolPicker = PKToolPicker()
    
    //List of TextBoxes
    @Published var textBoxes: [TextBox] = []
    @Published var addNewBox: Bool = false
    
    //current index
    @Published var currentIndex: Int = 0
    
    //cancel function...
    func cancelImageEditing() {
        imageData = Data(count: 0)
        canvas = PKCanvasView()
    }
    
    //cancel the text
    func cancelTextView() {
        //showing again tool bar
        toolPicker.setVisible(true, forFirstResponder: canvas)
        canvas.becomeFirstResponder()
        
        withAnimation {
            addNewBox = false
        }
        //remove if canceled
        textBoxes.removeLast()
    }
}
