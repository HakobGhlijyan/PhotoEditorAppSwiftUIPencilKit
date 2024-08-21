//
//  DrawingViewModel.swift
//  PhotoEditorAppSwiftUIPencilKit
//
//  Created by Hakob Ghlijyan on 21.08.2024.
//

import SwiftUI

class DrawingViewModel: ObservableObject {
    @Published var showImagePicker = false
    @Published var imageData: Data = Data(count: 0)
    
    //cancel
    func cancelImageEditing() {
        imageData = Data(count: 0)
    }
}
