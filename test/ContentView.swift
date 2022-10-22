//
//  ContentView.swift
//  test
//
//  Created by Daniel Livingston on 10/21/22.
//

import SwiftUI
import CoreData

struct FileSystemAttributes {
    let path: String
    let size: Int // bytes
    let freeSize: Int // bytes
    let usedSize: Int // bytes
    let inode: Int // Index Node (inode)
    let nodes: Int
    let freeNodes: Int
    
    let debugData: String
    
    init(path: String) {
        let fileSystem = try! FileManager
            .default
            .attributesOfFileSystem(forPath: path)
        
        let getAttribute = { (_ keyName: String) -> Int in
            let key = FileAttributeKey(rawValue: keyName)
            return Int((fileSystem[key] as? NSNumber)!.int64Value)
        }
        
        self.path = path
        
        self.size = getAttribute("NSFileSystemSize")
        self.freeSize = getAttribute("NSFileSystemFreeSize")
        self.usedSize = self.size - self.freeSize
        
        self.inode = getAttribute("NSFileSystemNumber")
        self.nodes = getAttribute("NSFileSystemNodes")
        self.freeNodes = getAttribute("NSFileSystemFreeNodes")
        
        self.debugData = "\(String(describing: FileManager.default.componentsToDisplay(forPath: path)))" + "\n\n" + "\(fileSystem)"
    }
    
    func getFreeDiskSpace() -> String {
        return ByteCountFormatter.string(
            fromByteCount: Int64(freeSize),
            countStyle: ByteCountFormatter.CountStyle.file
        )
    }
    
    func getUsedDiskSpace() -> String {
        return ByteCountFormatter.string(
            fromByteCount: Int64(usedSize),
            countStyle: ByteCountFormatter.CountStyle.file
        )
    }
    
    func getTotalDiskSpace() -> String {
        return ByteCountFormatter.string(
            fromByteCount: Int64(size),
            countStyle: ByteCountFormatter.CountStyle.file
        )
    }
}

struct FileSystemView: View {
    let fileSystem: FileSystemAttributes
    
    var body: some View {
        Form {
            Section(header: Text("Path")) {
                Text("\(fileSystem.path)")
            }
            
            Section(header: Text("Usage")) {
                Text("Total Size").font(.headline)
                Text("\(fileSystem.getTotalDiskSpace())")
                
                Text("Free Size").font(.headline)
                Text("\(fileSystem.getFreeDiskSpace())")
                
                Text("Used Size").font(.headline)
                Text("\(fileSystem.getUsedDiskSpace())")
            }
            
            Section(header: Text("Attributes")) {
                Text("Index Node (inode)").font(.headline)
                Text("\(fileSystem.inode)")
                
                Text("Nodes").font(.headline)
                Text("\(fileSystem.nodes)")
                
                Text("Free Nodes").font(.headline)
                Text("\(fileSystem.freeNodes)")
            }
            
            Section(header: Text("Debug Data")) {
                Text("Debug Data").font(.headline)
                Text(fileSystem.debugData)
            }
        }
    }
}

struct SystemPath: Identifiable {
    let id = UUID()
    
    let name: String
    let path: String
    
    static func collect() -> [SystemPath] {
        return [
            SystemPath(name: "/", path: "/"),
            SystemPath(name: "NSHomeDirectory", path: NSHomeDirectory()),
            SystemPath(name: "NSTemporaryDirectory", path: NSTemporaryDirectory())
        ]
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List(SystemPath.collect()) { path in
                NavigationLink(path.name) {
                    FileSystemView(
                        fileSystem: FileSystemAttributes(path: path.path)
                    )
                    .navigationTitle("Attributes: \(path.name)")
                }
            }
            .navigationTitle("iOS Device Monitor")
        }
    }


}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
