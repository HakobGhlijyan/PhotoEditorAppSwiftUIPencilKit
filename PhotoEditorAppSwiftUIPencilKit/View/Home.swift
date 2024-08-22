//
//  Home.swift
//  PhotoEditorAppSwiftUIPencilKit
//
//  Created by Hakob Ghlijyan on 21.08.2024.
//

import SwiftUI
import CoreImage
import PhotosUI

struct Home: View {
    @StateObject private var viewModel = DrawingViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    if let _ = UIImage(data: viewModel.imageData) {
                        DrawingScreen()
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Button(action: {
                                        viewModel.cancelImageEditing()
                                    }, label: {
                                        Image(systemName: "xmark")
                                            .buttonStyleCustom()
                                    })
                                }
                            }
                           
                    } else {
                        VStack {
                            Spacer()
                            
                            GroupBox {
                                ContentUnavailableView (
                                    "No Image",
                                    systemImage: "photo",
                                    description: Text("Select an image on \nphoto library or camera \nPress + button")
                                )
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 25.0))
                            .padding()
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.showImagePicker.toggle()
                            }, label: {
                                Image(systemName: "plus")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(4)
                                    .tint(.primary)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(10)
                                    .padding(.vertical, 10)
                                    .background(.ultraThinMaterial)
                            })
                        }
                    }
                }
                .navigationTitle("Image Editor")
                .environmentObject(viewModel)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        
                    }
                }
            }
            
            if viewModel.addNewBox {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                
                //TextField
                TextField("Type Here", text: $viewModel.textBoxes[viewModel.currentIndex].text)
                    .font(.system(size: 35, weight: viewModel.textBoxes[viewModel.currentIndex].isBold ? .bold : .regular))
                    .preferredColorScheme(.dark)
                    .foregroundStyle(viewModel.textBoxes[viewModel.currentIndex].textColor)
                    .padding()
                
                //add and cancel button
                HStack {
                    Button {
                        viewModel.textBoxes[viewModel.currentIndex].isAdded = true
                        viewModel.toolPicker.setVisible(true, forFirstResponder: viewModel.canvas)
                        viewModel.canvas.becomeFirstResponder()
                        //closing view
                        withAnimation {
                            viewModel.addNewBox = false
                        }
                    } label: {
                        Text("Add")
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                            .padding()
                    }
                    Spacer()
                    Button {
                        viewModel.cancelTextView()
                    } label: {
                        Text("Cancel")
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
                .overlay {
                    HStack {
                        ColorPicker("", selection: $viewModel.textBoxes[viewModel.currentIndex].textColor)
                            .labelsHidden()
                        
                        Button(action: {
                            viewModel.textBoxes[viewModel.currentIndex].isBold.toggle()
                        }, label: {
                            Text(viewModel.textBoxes[viewModel.currentIndex].isBold ? "Normal" : "Bold")
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        })
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .sheet(isPresented: $viewModel.showImagePicker,
               content: {
            ImagePicker(
                showPicker: $viewModel.showImagePicker,
                imageData: $viewModel.imageData
            )
            .ignoresSafeArea()
        })
        .alert(isPresented: $viewModel.showAlert, content: {
            Alert(title: Text("Message"),
                  message: Text(viewModel.message),
                  dismissButton: .destructive(Text("OK"))
            )
        })
    }
}

#Preview {
    Home()
}


struct PhotoPicker: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showCamera = false
    
    @State private var inputImage: Image?
    @State private var scale: CGFloat = 1.0
    @State private var angle: Angle = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var lastAngle: Angle = .zero
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .scaleEffect(scale)
                        .rotationEffect(angle)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value
                                }
                                .onEnded { value in
                                    lastScale = scale
                                }
                                .simultaneously(with: RotationGesture()
                                    .onChanged { value in
                                        angle = lastAngle + value
                                    }
                                    .onEnded { value in
                                        lastAngle = angle
                                    }
                                )
                        )
                    
                    
                } else {
                    GroupBox {
                        ContentUnavailableView (
                            "No Image",
                            systemImage: "photo",
                            description: Text("Select an image on \nphoto library or camera")
                        )
                    }
                }
            }
            .frame(height: 400)
            .frame(maxWidth: .infinity)
            .clipped()
            .padding()
            
            Spacer()
            
            PhotosPicker("Select an image", selection: $selectedItem, matching: .images)
                .onChange(of: selectedItem) {
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                            selectedImage = UIImage(data: data)
                        }
                        print("Failed to load the image")
                    }
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: selectedImage) {
            _ in loadImage()
        }
       
    }
    
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        inputImage = Image(uiImage: selectedImage)
        scale = 1.0
        angle = .zero
        lastScale = 1.0
        lastAngle = .zero
    }
}
