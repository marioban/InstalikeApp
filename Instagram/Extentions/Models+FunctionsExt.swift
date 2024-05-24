//
//  Models+FunctionsExt.swift
//  Instagram
//
//  Created by Mario Ban on 13.05.2024..
//

import SwiftUI
import MapKit
import UIKit
import Firebase
import FirebaseStorage

class UserService {
    
    @Published var currentUser: User?
    
    static let shared = UserService()
    
    @MainActor
    func fetchCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.currentUser = try await FirebaseConstants.UsersCollection.document(uid).getDocument(as: User.self)
    }
    
    static func fetchUser(withUid uid: String) async throws -> User {
        let snapshot = try await FirebaseConstants.UsersCollection.document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    static func fetchAllUsers() async throws -> [User]{
        let snapshot = try await FirebaseConstants.UsersCollection.getDocuments()
        return snapshot.documents.compactMap({ try? $0.data(as: User.self)})
    }
    
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update action needed
    }
}

struct IdentifiableAnnotation: Identifiable {
    let id: UUID
    var annotation: MKPointAnnotation
    
    init(annotation: MKPointAnnotation) {
        self.id = UUID()
        self.annotation = annotation
    }
}


enum ImageType {
    case system(name: String)
    case asset(name: String)
}


struct ImageUploader {
    static func uploadImage(image: UIImage) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return nil }
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        
        do {
            let _ = try await ref.putDataAsync(imageData)
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            print("DEBUG: Failed to upload image with error \(error.localizedDescription)")
            return nil
        }
    }
}

struct PostService {
    
    //MARK: Fetch
    static func fetchFeedPosts() async throws -> [Post] {
        let snapshot = try await FirebaseConstants.PostCollection.order(by: "timeStamp", descending: true).getDocuments()
        var posts = try snapshot.documents.compactMap({try $0.data(as: Post.self)})
        
        for i in 0..<posts.count {
            let post = posts[i]
            let ownerUid = post.ownerUid
            if let postUser = try? await UserService.fetchUser(withUid: ownerUid) {
                posts[i].user = postUser
            } else {
                print("Failed to fetch user for post \(i)")
            }
        }
        
        return posts
    }
    
    
    static func fetchUserPosts(uid: String) async throws -> [Post] {
        let snapshot = try await FirebaseConstants.PostCollection.whereField("ownerUid", isEqualTo: uid).getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Post.self) }
    }
    
    //MARK: Likes
    
    static func likePost(_ post: Post) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        async let _ = try await FirebaseConstants.PostCollection.document(post.id).collection("post-likes").document(uid).setData([:])
        async let _ = try await FirebaseConstants.PostCollection.document(post.id).updateData(["likes" : post.likes + 1])
        async let _ = FirebaseConstants.UsersCollection.document(uid).collection("user-likes").document(post.id).setData([:])
    }
    
    static func unlikePost(_ post: Post) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        async let _ = try await FirebaseConstants.PostCollection.document(post.id).collection("post-likes").document(uid).delete()
        async let _ = try await FirebaseConstants.PostCollection.document(post.id).updateData(["likes" : post.likes - 1])
        async let _ = FirebaseConstants.UsersCollection.document(uid).collection("user-likes").document(post.id).delete()
    }
    
    static func checkIfUserLikedPost(_ post: Post) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        
        let snapshot = try await FirebaseConstants.UsersCollection.document(uid).collection("user-likes").document(post.id).getDocument()
        return snapshot.exists
    }
}


struct CommentService {
    
    let postId: String
    
    func uploadComment(_ comment: Comment) async throws {
        guard let commentData = try? Firestore.Encoder().encode(comment) else { return }
        
        try await FirebaseConstants.PostCollection.document(postId).collection("post-comments").addDocument(data: commentData)
    }
    
    func fetchComments() async throws -> [Comment] {
        let snapshot = try await FirebaseConstants.PostCollection.document(postId).collection("post-comments").order(by: "timestamp", descending: false).getDocuments()
        
        return snapshot.documents.compactMap({ try? $0.data(as: Comment.self)})
    }
}