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
    
    // Saving the view Frame size
    @Published var rect: CGRect = .zero
    
    //Alert
    @Published var showAlert: Bool = false
    @Published var message: String = ""
    
    
    //cancel function...
    func cancelImageEditing() {
        imageData = Data(count: 0)
        canvas = PKCanvasView()
        textBoxes.removeAll()
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
        // avoiding the remove of already added...
        if !textBoxes[currentIndex].isAdded {
            textBoxes.removeLast()
        }
    }
    
    // Save
    func saveImage() {
        // generating image from both canvas and text and pencil view
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        //canvas
        canvas.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        
        //drawing text boxes...
        let SwiftUIView = ZStack {
            ForEach(textBoxes) { [self] box in
                Text(
                    textBoxes[currentIndex].id == box.id && addNewBox ? "" : box.text
                )
                    .font(.system(size: 30))
                    .fontWeight(box.isBold ? .bold : .none)
                    .foregroundStyle(box.textColor)
                    .offset(box.offset)
            }
        }
        
        let controler = UIHostingController(rootView: SwiftUIView).view!
        controler.frame = rect
        
        //clearing bg
        controler.backgroundColor = .clear
        canvas.backgroundColor = .clear
        
        controler.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        
        //getting image
        let generatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        //endeing render
        UIGraphicsEndImageContext()
        
        if let image = generatedImage?.pngData() {
            // Saving
            UIImageWriteToSavedPhotosAlbum(UIImage(data: image)!, nil, nil, nil)
            print("Success...")
            self.message = "Success: Image Saved"
            self.showAlert.toggle()
        }
    }
}
