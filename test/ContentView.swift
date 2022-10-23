//
//  ContentView.swift
//  test
//
//  Created by Daniel Livingston on 10/21/22.
//

import SwiftUI

struct FormRowView: View {
    let label: String
    let field: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(field)
                .font(.headline)
        }
    }
}

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
    
    static var defaultView: some View {
        FileSystemView(fileSystem: FileSystemAttributes(path: "/"))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Path")) {
                Text("\(fileSystem.path)")
            }
            
            Section(header: Text("Usage")) {
                FormRowView(label: "Total Size", field: fileSystem.getTotalDiskSpace())
                FormRowView(label: "Free Size", field: fileSystem.getFreeDiskSpace())
                FormRowView(label: "Used Size", field: fileSystem.getUsedDiskSpace())
            }
            
            Section(header: Text("Attributes")) {
                FormRowView(label: "Index Node (inode)", field: fileSystem.inode.formatted())
                FormRowView(label: "Nodes", field: fileSystem.nodes.formatted())
                FormRowView(label: "Free Nodes", field: fileSystem.freeNodes.formatted())
            }
            
            Section(header: Text("Debug Data")) {
                Text("Debug Data").font(.headline)
                Text(fileSystem.debugData)
            }
        }
    }
}

struct DeviceInfoView: View {
    let device: UIDevice = UIDevice.current
    
    var body: some View {
        Form {
            Section(header: Text("Info")) {
                FormRowView(label: "Name", field: device.name)
                FormRowView(label: "System Version", field: device.systemVersion)
                FormRowView(label: "Model", field: device.model)
            }
            
            Section(header: Text("Additional")) {
                FormRowView(
                    label: "Multitasking Support?",
                    field: device.isMultitaskingSupported ? "Yes" : "No")
                
                FormRowView(label: "Orientation", field: deviceOrientationState())
                FormRowView(label: "Battery Level", field: deviceBatteryLevel())
                FormRowView(label: "Proximity Sensor Active?", field: proximitySensorState())
            }
        }
    }
    
    func deviceBatteryLevel() -> String {
        device.isBatteryMonitoringEnabled = true
        
        let batteryState: String = {
            var state: String
            
            switch device.batteryState {
                case UIDevice.BatteryState.charging:
                    state = "Charging"
                    break
                case UIDevice.BatteryState.full:
                    state = "Full"
                    break
                case UIDevice.BatteryState.unplugged:
                    state = "Unplugged"
                    break
                default:
                    state = "Unknown"
                    break
            }
            
            if device.batteryLevel > 0.0 {
                return "\(device.batteryLevel.formatted()) (\(state))"
            }
            return "Unavailable"
        }()
        
        device.isBatteryMonitoringEnabled = false
        
        return batteryState
    }
    
    func proximitySensorState() -> String {
        device.isProximityMonitoringEnabled = true
        let proximityState = device.proximityState ? "Enabled" : "Disabled"
        device.isProximityMonitoringEnabled = false
        
        return proximityState
    }
    
    func deviceOrientationState() -> String {
        var orientationString: String = ""
        
        switch device.orientation {
            case UIDeviceOrientation.portrait:
                orientationString = "Portrait"
                break
            case UIDeviceOrientation.portraitUpsideDown:
                orientationString = "Portrait (upside-down)"
                break
            case UIDeviceOrientation.landscapeLeft:
                orientationString = "Landscape (left)"
                break
            case UIDeviceOrientation.landscapeRight:
                orientationString = "Landscape (right)"
                break
            case UIDeviceOrientation.faceDown:
                orientationString = "Face down"
                break
            case UIDeviceOrientation.faceUp:
                orientationString = "Face up"
                break
            default:
                orientationString = "Unknown"
                break
        }
        
        return orientationString
    }
}

struct DiagnosticsView: View {
    @State var text = "Hello"
    
    var body: some View {
        Form {
            Section(header: Text("Device Functions")) {
                Button("Play Input Click") {
                    UIDevice.current.playInputClick()
                }
            }
        }
    }
}

struct ViewInfo: Identifiable {
    let id = UUID()
    
    let name: String
    let view: AnyView
}

struct ContentView: View {
    let views = [
        ViewInfo(name: "Device Information", view: AnyView(DeviceInfoView())),
        ViewInfo(name: "Disk Information", view: AnyView(FileSystemView.defaultView)),
        ViewInfo(name: "Diagnostic Functions", view: AnyView(DiagnosticsView()))
    ]
    
    var body: some View {
        NavigationStack {
            List(views) { view in
                NavigationLink(view.name) {
                    view.view
                        .navigationTitle("\(view.name)")
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
