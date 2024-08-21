//
//  ImagePicker.swift
//  PhotoEditorAppSwiftUIPencilKit
//
//  Created by Hakob Ghlijyan on 21.08.2024.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    //MARK: - State is Binding
    @Binding var showPicker: Bool
    @Binding var imageData: Data
    //MARK: - func coordinator is added included coordinator
    func makeCoordinator() -> Coordinator {
        return ImagePicker.Coordinator(parent: self)
    }
    //MARK: - Make
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.delegate = context.coordinator
        return controller
    }
    //MARK: - Update
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    //MARK: - Coordinator
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        //MARK: - Get image and close
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let imageData = (info[.originalImage] as? UIImage)?.pngData() {
                parent.imageData = imageData
                parent.showPicker.toggle()
            }
        }
        //MARK: - closing the view if cancelled...
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.showPicker.toggle()
        }
    }
}

