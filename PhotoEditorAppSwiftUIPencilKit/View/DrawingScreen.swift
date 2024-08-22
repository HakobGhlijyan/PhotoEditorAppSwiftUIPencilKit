//
//  DrawingScreen.swift
//  PhotoEditorAppSwiftUIPencilKit
//
//  Created by Hakob Ghlijyan on 21.08.2024.
//

import SwiftUI
import PencilKit

struct DrawingScreen: View {
    @EnvironmentObject var viewModel: DrawingViewModel
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let size = geometry.size
                
                DispatchQueue.main.async {
                    if viewModel.rect == .zero {
                        viewModel.rect = geometry.frame(in: .global)
                    }
                }
                
                return ZStack {
                    // UIKIT Pensic Kit Drawing view...
                    CanvasView(
                        canvas: $viewModel.canvas,
                        imageData: $viewModel.imageData,
                        toolPicker: $viewModel.toolPicker,
                        rect: size
                    )
                    
                    //Custom Text...
                    
                    //Displaying textbox
                    ForEach(viewModel.textBoxes) { box in
                        Text(viewModel.textBoxes[viewModel.currentIndex].id == box.id && viewModel.addNewBox ? "" : box.text)
                            .font(.system(size: 30))
                            .fontWeight(box.isBold ? .bold : .none)
                            .foregroundStyle(box.textColor)
                            .offset(box.offset)
                            .gesture(
                                DragGesture()
                                    .onChanged({ value in
                                        let current = value.translation
                                        //adding with last offset...
                                        let lastOffset = box.lastOffset
                                        let newTranslation = CGSize(width: lastOffset.width + current.width, height: lastOffset.height + current.height)
                                        
                                        viewModel.textBoxes[getIndex(textBox: box)].offset = newTranslation
                                    })
                                    .onEnded({ value in
                                        viewModel.textBoxes[getIndex(textBox: box)].lastOffset = value.translation
                                    })
                            )
                            .onLongPressGesture {
                                //close toolbar
                                viewModel.toolPicker.setVisible(false, forFirstResponder: viewModel.canvas)
                                viewModel.canvas.resignFirstResponder()
                                //editing the typed one
                                viewModel.currentIndex = getIndex(textBox: box)
                                withAnimation {
                                    viewModel.addNewBox = true
                                }
                            }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.saveImage()
                }, label: {
                    Text("Save")
                        .buttonStyleCustom()
                })
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    //creating one new text box . add on view
                    viewModel.textBoxes.append(TextBox())
                    
                    //updating index
                    viewModel.currentIndex = viewModel.textBoxes.count - 1
                    
                    withAnimation {
                        viewModel.addNewBox.toggle()
                    }
                    viewModel.toolPicker.setVisible(false, forFirstResponder: viewModel.canvas)
                    viewModel.canvas.resignFirstResponder()
                }, label: {
                    Image(systemName: "plus")
                        .buttonStyleCustom()
                })
            }
        }
    }
    
    func getIndex(textBox: TextBox) -> Int {
        let index = viewModel.textBoxes.firstIndex { box -> Bool in
            return textBox.id == box.id
        } ?? 0
        
        return index
    }
}

#Preview {
    Home()
}

struct CanvasView: UIViewRepresentable {
    @Binding var canvas: PKCanvasView
    @Binding var imageData: Data
    @Binding var toolPicker: PKToolPicker
    
    // View Size
    var rect: CGSize
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
        canvas.drawingPolicy = .anyInput
        
        //appending the image in subview...
        if let image = UIImage(data: imageData) {
            // Image View
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            
            // basically were setting image to the back of canvas...
            let subView = canvas.subviews[0]
            subView.addSubview(imageView)
            subView.sendSubviewToBack(imageView)
            
            // showing tool picker
            // were setting it as first responder and making it as visible...
            toolPicker.setVisible(true, forFirstResponder: canvas)
            toolPicker.addObserver(canvas)
            canvas.becomeFirstResponder()
        }
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        //Update UI will update for each actions...
    }
    
}
