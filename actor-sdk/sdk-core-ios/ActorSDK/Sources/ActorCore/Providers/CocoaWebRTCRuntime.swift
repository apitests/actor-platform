//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation

class CocoaWebRTCRuntime: NSObject, ARWebRTCRuntime {
    
    private let peerConnectionFactory = RTCPeerConnectionFactory()
    
    override init() {
        RTCPeerConnectionFactory.initializeSSL()
    }
    
    func createPeerConnectionWithServers(webRTCIceServers: IOSObjectArray!, withSettings settings: ARWebRTCSettings!) -> ARPromise {
        let servers: [ARWebRTCIceServer] = webRTCIceServers.toSwiftArray()
        return ARPromise { (resolver) -> () in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
                resolver.result(CocoaWebRTCPeerConnection(servers: servers, peerConnectionFactory: self.peerConnectionFactory))
            }
        }
    }
    
    func getUserAudio() -> ARPromise {
        print("📱getUserAudio")
        let audio = peerConnectionFactory.audioTrackWithID("audio0")
        let mediaStream = peerConnectionFactory.mediaStreamWithLabel("ARDAMSa0")
        mediaStream.addAudioTrack(audio)
        return ARPromises.success(MediaStream(stream: mediaStream))
    }
}

class MediaStream: NSObject, ARWebRTCMediaStream {
    
    let stream: RTCMediaStream
    
    init(stream: RTCMediaStream){
        self.stream = stream
    }
    
    func isEnabled() -> jboolean {
        return true
    }
    
    func setEnabledWithBoolean(isEnabled: jboolean) {
        for i in stream.audioTracks {
            (i as? RTCMediaStreamTrack)?.setEnabled(isEnabled)
        }
        for i in stream.videoTracks {
            (i as? RTCMediaStreamTrack)?.setEnabled(isEnabled)
        }
    }
    
    func close() {
        for i in stream.audioTracks {
            (i as? RTCMediaStreamTrack)?.setEnabled(false)
        }
        for i in stream.videoTracks {
            (i as? RTCMediaStreamTrack)?.setEnabled(false)
        }
    }
}

class CocoaWebRTCPeerConnection: NSObject, ARWebRTCPeerConnection, RTCPeerConnectionDelegate {
    
    private var peerConnection: RTCPeerConnection!
    private var callbacks = [ARWebRTCPeerConnectionCallback]()
    private let peerConnectionFactory: RTCPeerConnectionFactory
    init(servers: [ARWebRTCIceServer], peerConnectionFactory: RTCPeerConnectionFactory) {
        self.peerConnectionFactory = peerConnectionFactory
        super.init()
        
        let iceServers = servers.map { (src) -> RTCICEServer in
            if (src.username == nil || src.credential == nil) {
                return RTCICEServer(URI: NSURL(string: src.url), username: "", password: "")
            } else {
                return RTCICEServer(URI: NSURL(string: src.url), username: src.username, password: src.credential)
            }
        }
        peerConnection = peerConnectionFactory.peerConnectionWithICEServers(iceServers, constraints: RTCMediaConstraints(), delegate: self)
    }
    
    func addCallback(callback: ARWebRTCPeerConnectionCallback) {
        if !callbacks.contains({ callback.isEqual($0) }) {
            callbacks.append(callback)
        }
    }
    
    func removeCallback(callback: ARWebRTCPeerConnectionCallback) {
        let index = callbacks.indexOf({ callback.isEqual($0) })
        if index != nil {
            callbacks.removeAtIndex(index!)
        }
    }
    func addCandidateWithIndex(index: jint, withId id_: String, withSDP sdp: String) {
        peerConnection.addICECandidate(RTCICECandidate(mid: id_, index: Int(index), sdp: sdp))
    }
    
    func addOwnStream(stream: ARWebRTCMediaStream) {
        if let str = stream as? MediaStream {
            peerConnection.addStream(str.stream)
        }
    }
    
    func createAnswer() -> ARPromise {
        return ARPromise(closure: { (resolver) -> () in
            self.peerConnection.createAnswer(RTCMediaConstraints(), didCreate: { (desc, error) -> () in
                if error == nil {
                    resolver.result(ARWebRTCSessionDescription(type: "answer", withSDP: desc.description))
                } else {
                    resolver.error(JavaLangException(NSString: "Error \(error.description)"))
                }
            })
        })
    }
    
    func creteOffer() -> ARPromise {
        return ARPromise(closure: { (resolver) -> () in
            self.peerConnection.createOffer(RTCMediaConstraints(), didCreate: { (desc, error) -> () in
                if error == nil {
                    resolver.result(ARWebRTCSessionDescription(type: "offer", withSDP: desc.description))
                } else {
                    resolver.error(JavaLangException(NSString: "Error \(error.description)"))
                }
            })
        })
    }
    
    func setRemoteDescription(description_: ARWebRTCSessionDescription) -> ARPromise {
        return ARPromise(executor: AAPromiseFunc(closure: { (resolver) -> () in
            self.peerConnection.setRemoteDescription(RTCSessionDescription(type: description_.type, sdp: description_.sdp), didSet: { (error) -> () in
                if (error == nil) {
                    resolver.result(description_)
                } else {
                    resolver.error(JavaLangException(NSString: "Error \(error.description)"))
                }
            })
        }))
    }
    
    func setLocalDescription(description_: ARWebRTCSessionDescription) -> ARPromise {
        return ARPromise(executor: AAPromiseFunc(closure: { (resolver) -> () in
            self.peerConnection.setLocalDescription(RTCSessionDescription(type: description_.type, sdp: description_.sdp), didSet: { (error) -> () in
                if (error == nil) {
                    resolver.result(description_)
                } else {
                    resolver.error(JavaLangException(NSString: "Error \(error.description)"))
                }
            })
        }))

    }
    
    func close() {
        peerConnection.close()
    }
    
    
    //
    // RTCPeerConnectionDelegate
    //
    
    func peerConnection(peerConnection: RTCPeerConnection!, signalingStateChanged stateChanged: RTCSignalingState) {
        print("📱signalingStateChanged \(stateChanged)")
    }
    
    func peerConnection(peerConnection: RTCPeerConnection!, addedStream stream: RTCMediaStream!) {
        print("📱onStreamAdded")
        for c in callbacks {
            c.onStreamAdded(MediaStream(stream: stream!))
        }
    }
    
    func peerConnection(peerConnection: RTCPeerConnection!, removedStream stream: RTCMediaStream!) {
        print("📱onStreamRemoved")
        for c in callbacks {
            c.onStreamRemoved(MediaStream(stream: stream!))
        }
    }
    
    func peerConnectionOnRenegotiationNeeded(peerConnection: RTCPeerConnection!) {
        print("📱onRenegotiationNeeded")
    }
    
    func peerConnection(peerConnection: RTCPeerConnection!, iceConnectionChanged newState: RTCICEConnectionState) {
        print("📱iceConnectionChanged \(newState)")
    }
    
    func peerConnection(peerConnection: RTCPeerConnection!, iceGatheringChanged newState: RTCICEGatheringState) {
        print("📱iceGatheringChanged \(newState)")
    }
    
    func peerConnection(peerConnection: RTCPeerConnection!, gotICECandidate candidate: RTCICECandidate!) {
        print("📱gotICECandidate \(candidate)")
        for c in callbacks {
            c.onCandidateWithLabel(jint(candidate.sdpMLineIndex), withId: candidate.sdpMid, withCandidate: candidate.sdp)
        }
    }
    
    func peerConnection(peerConnection: RTCPeerConnection!, didOpenDataChannel dataChannel: RTCDataChannel!) {
        
    }
}