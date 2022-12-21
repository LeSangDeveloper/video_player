package com.example.video_player;

import java.io.IOException;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;

import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;

public class CustomSSLSocketFactory extends SSLSocketFactory {
    private SSLSocketFactory sslSocketFactory;

    public CustomSSLSocketFactory() throws NoSuchAlgorithmException, KeyManagementException {
        SSLContext context = SSLContext.getInstance("TLS");
        context.init(null, null, null);
        sslSocketFactory = context.getSocketFactory();
    }

    @Override
    public String[] getDefaultCipherSuites() {
        return sslSocketFactory.getDefaultCipherSuites();
    }

    @Override
    public String[] getSupportedCipherSuites() {
        return sslSocketFactory.getSupportedCipherSuites();
    }

    @Override
    public Socket createSocket() throws IOException {
        return enableProtocols(sslSocketFactory.createSocket());
    }

    @Override
    public Socket createSocket(Socket socket, String s, int i, boolean b) throws IOException {
        return enableProtocols(sslSocketFactory.createSocket(socket, s, i, b));
    }

    @Override
    public Socket createSocket(String s, int i) throws IOException {
        return enableProtocols(sslSocketFactory.createSocket(s, i));
    }

    @Override
    public Socket createSocket(String s, int i, InetAddress inetAddress, int i1) throws IOException {
        return enableProtocols(sslSocketFactory.createSocket(s, i, inetAddress, i1));
    }

    @Override
    public Socket createSocket(InetAddress inetAddress, int i) throws IOException {
        return enableProtocols(sslSocketFactory.createSocket(inetAddress, i));
    }

    @Override
    public Socket createSocket(InetAddress inetAddress, int i, InetAddress inetAddress1, int i1) throws IOException {
        return enableProtocols(sslSocketFactory.createSocket(inetAddress, i, inetAddress1, i1));
    }

    private Socket enableProtocols(Socket socket) {
        if (socket instanceof SSLSocket) {
            ((SSLSocket) socket).setEnabledProtocols(new String[] {"TLSv1.1", "TLSv1.2"});
        }
        return socket;
    }
}
