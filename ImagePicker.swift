import SwiftUI
import UIKit

struct ProfileImagePicker: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage
    @Environment(\.presentationMode) private var presentationMode
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func makeUIViewController(context: Context) -> some UIViewController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing =     true
        imagePicker.sourceType =        sourceType
        imagePicker.delegate =          context.coordinator
        
        return imagePicker
        
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        //DOING NOTHING RIGHT NOW
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ProfileImagePicker
        
        init(_ parent: ProfileImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
                
                
                let shorterSide = min(image.size.width, image.size.height)
                
                let imageSize = image.size
                let xOffset = (imageSize.width - shorterSide) / 2.0
                let yOffset = (imageSize.height - shorterSide) / 2.0
                
                let cropRect = CGRect(x: xOffset, y: yOffset, width: shorterSide, height: shorterSide).integral
                
                var croppedImage = UIImage()
                
                if let exifData = readEXIFData(from: image) {
                    print(exifData)
                    if let orientation = exifData["Orientation"] {
                        print(orientation)
                        
                        if orientation as! Int == 6 {
                            //FINDING THE EXIF DATA
                            
                            let imageSize = image.size
                            let shorterSide = min(imageSize.width, imageSize.height)
                            let cropRect = CGRect(x: (imageSize.width - shorterSide) / 2, y: (imageSize.height - shorterSide) / 2, width: shorterSide, height: shorterSide)
                            
                            
                            
                            
                            if let cgImage = image.cgImage?.cropping(to: cropRect) {
                                croppedImage = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
                            }
                            
                        }
                        
                        else {
                            let imageSize = image.size
                            let shorterSide = min(imageSize.width, imageSize.height)
                            let cropRect = CGRect(x: (imageSize.width - shorterSide) / 2, y: (imageSize.height - shorterSide) / 2, width: shorterSide, height: shorterSide)
                            
                            
                            
                            if let cgImage = image.cgImage?.cropping(to: cropRect) {
                                croppedImage = UIImage(cgImage: cgImage)
                            }
                        }
                        
                    } else {print("Nothing else")}
                    
                } else {print("failed to read")}
                
                
                let newImageData = croppedImage.jpegData(compressionQuality: 0.1) ?? Data()

                //If you wish to save to UserDefaults
                print("Saving...")
                UserDefaults.standard.set(newImageData, forKey: "savedImage")
                print("Saved!")

                //If you wish to send to server - Here is a PSEUDO-CODE for that.
                /*
              parent.user.patchingProfilePicture(token: UserDefaults.standard.string(forKey: "AuthToken") ?? "", image: newImageData) { (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let avatar):
                            print(avatar)
                            print("AVATAR UPLOADS")
                            
                            
                            
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
              */
                
            }
            
            parent.presentationMode.wrappedValue.dismiss()
            
        }
        
        func readEXIFData(from image: UIImage) -> [String: Any]? {
            var metadata: [String: Any] = [:]
            
            if let imageData = image.jpegData(compressionQuality: 1.0) as CFData?,
               let imageSource = CGImageSourceCreateWithData(imageData, nil),
               let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] {
                
                
                
                metadata = imageProperties
            }
            
            return metadata
        }
        
        
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}

