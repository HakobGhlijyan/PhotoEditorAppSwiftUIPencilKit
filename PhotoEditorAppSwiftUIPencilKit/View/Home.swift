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

    var body: some View {
        NavigationStack {
            VStack {
                if let imageFile = UIImage(data: viewModel.imageData) {
                    Image(uiImage: imageFile)
                        .resizable()
                        .scaledToFit()
                } else {
                    GroupBox {
                        ContentUnavailableView (
                            "No Image",
                            systemImage: "photo",
                            description: Text("Select an image on \nphoto library or camera")
                        )
                    }
                    .frame(width: 300, height: 300).clipShape(RoundedRectangle(cornerRadius: 25.0))
                }
            }
            .navigationTitle("Image Editor")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        viewModel.showImagePicker.toggle()
                    }, label: {
                        Image(systemName: "plus")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(4)
                            .foregroundStyle(.green)
                            .frame(width: 30, height: 30)
                            .background(.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.07), radius: 5, x: 5, y: 5)
                            .shadow(color: .black.opacity(0.07), radius: 5, x: -5, y: -5)
                    })
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        viewModel.cancelImageEditing()
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(4)
                            .foregroundStyle(.red)
                            .frame(width: 30, height: 30)
                            .background(.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.07), radius: 5, x: 5, y: 5)
                            .shadow(color: .black.opacity(0.07), radius: 5, x: -5, y: -5)
                    })
                }
            }
            .sheet(isPresented: $viewModel.showImagePicker,
                   content: {
                ImagePicker(
                    showPicker: $viewModel.showImagePicker,
                    imageData: $viewModel.imageData
                )
            })
        }
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
