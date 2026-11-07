//
//  ProfileImagePickerView.swift
//  MoveMates
//
//  Created by Mazen Younis on 19/05/2025.
//

import SwiftUI
import PhotosUI

struct ProfileImagePicker: View {
    @Binding var image: UIImage?
    @State private var isPickerPresented = false

    var body: some View {
        VStack(spacing: 12) {
            Button(action: { isPickerPresented = true }) {
                ZStack {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.aquaBlue, lineWidth: 2))
                            .shadow(radius: 5)
                            .transition(.scale)
                    } else {
                        Circle()
                            .fill(Color.charcoalGray)
                            .frame(width: 120, height: 120)
                            .overlay(
                                VStack(spacing: 4) {
                                    Image(systemName: "camera.fill")
                                        .font(.title)
                                        .foregroundColor(.coolGray)
                                    Text("Add Photo")
                                        .foregroundColor(.coolGray)
                                        .font(.caption)
                                }
                            )
                    }
                }
            }
            .buttonStyle(PlainButtonStyle()) // Remove default tap effect

            Button(action: { isPickerPresented = true }) {
                Text("Choose Photo")
                    .foregroundColor(.aquaBlue)
                    .font(.subheadline)
            }
        }
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(image: $image)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}


#Preview {
    ProfileImagePicker(image: .constant(nil))
}
