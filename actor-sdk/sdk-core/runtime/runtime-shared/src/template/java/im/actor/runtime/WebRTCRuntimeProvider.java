package im.actor.runtime;

import org.jetbrains.annotations.NotNull;

import im.actor.runtime.promise.Promise;
import im.actor.runtime.promise.Promises;
import im.actor.runtime.webrtc.WebRTCIceServer;
import im.actor.runtime.webrtc.WebRTCMediaStream;
import im.actor.runtime.webrtc.WebRTCPeerConnection;
import im.actor.runtime.webrtc.WebRTCSettings;

public class WebRTCRuntimeProvider implements WebRTCRuntime {

    @NotNull
    @Override
    public Promise<WebRTCPeerConnection> createPeerConnection(WebRTCIceServer[] webRTCIceServers, WebRTCSettings settings) {
        return Promises.failure(new RuntimeException("Dumb"));
    }

    @NotNull
    @Override
    public Promise<WebRTCMediaStream> getUserAudio() {
        return Promises.failure(new RuntimeException("Dumb"));
    }
}
