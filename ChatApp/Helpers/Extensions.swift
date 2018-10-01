// Extensions.swift
// ChatApp (Caching)

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView
{
    func imgCache(_ urlString: String){
        
        // During cache, a white flash appears. This line makes sure that it doesn't happen
        self.image = nil
        
        // Check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }
        // Otherwise start a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (d, r, e) in
            if e != nil{ // Download Image Error
                print(e as Any)
                return
            }
            // Profile image of each registered user
            DispatchQueue.main.async{
                // Successful Image Download
                if let downloadedImage = UIImage(data: d!){
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
        }.resume()
    }
}

extension String
{
    func trunc(length: Int, trailing: String = "…") -> String{
        return (self.count > length) ? self.prefix(length) + trailing: self
    }
}
