//
// Non-Export Controlled Information
//
//####################################################################
//## The MIT License
//## 
//## Copyright (c) 2010 Harris Corporation
//## 
//## Permission is hereby granted, free of charge, to any person
//## obtaining a copy of this software and associated documentation
//## files (the "Software"), to deal in the Software without
//## restriction, including without limitation the rights to use,
//## copy, modify, merge, publish, distribute, sublicense, and/or sell
//## copies of the Software, and to permit persons to whom the
//## Software is furnished to do so, subject to the following conditions:
//## 
//## The above copyright notice and this permission notice shall be
//## included in all copies or substantial portions of the Software.
//## 
//## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//## EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//## NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//## HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//## WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//## FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//## OTHER DEALINGS IN THE SOFTWARE.
//## 
//####################################################################
//********************************************************************
// FILE: ClientConnector.java
//
// Copyright (C) 2010 Harris Corporation. All rights reserved.
//
// CLASSIFICATION: Unclassified
//
// DESCRIPTION: ClientConnector.java 
//              
//
// LIMITATIONS: None
//
// SOFTWARE HISTORY:
//
//> Feb 24, 2010 PTR#  - R. Robinson
// Initial Coding.
//<
//********************************************************************
package gov.hhs.fha.nhinc.lift.proxy.client;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

import gov.hhs.fha.nhinc.lift.proxy.util.Connector;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class ClientConnector implements Runnable {

    private Log log = null;
    private final ServerSocket server;
    private final Client proxyConnection;
    private final int bufferSize;

    public ClientConnector(ServerSocket server, Client proxyConnection, int bufferSize) {
        super();
        this.server = server;
        this.proxyConnection = proxyConnection;
        this.bufferSize = bufferSize;
        log = createLogger();
    }

    protected Log createLogger() {
        return ((log != null) ? log : LogFactory.getLog(getClass()));
    }

    @Override
    public void run() {
        /*
         * Accept a connection and tunnel messages through the proxy system.
         *
         * May want to have some time out defined so this does not wait around
         * for too long.
         */
        try {
            Thread toProxyThread, fromProxyThread;

            Socket socket = server.accept();

            try {
                Connector toProxy = new Connector(socket.getInputStream(), proxyConnection.getOutStream(), bufferSize);
                log.debug("Starting Connector TO proxy");
                Connector fromProxy = new Connector(proxyConnection.getInStream(), socket.getOutputStream(), bufferSize);
                log.debug("Starting Connector FROM proxy");
                toProxyThread = new Thread(toProxy);
                fromProxyThread = new Thread(fromProxy);

                toProxyThread.start();
                fromProxyThread.start();

                toProxyThread.join();
                log.debug("Connector TO proxy complete");

//				System.out.println("Closing socket because to proxy connector joined.");
//				socket.close();
//				System.out.println("Closing connection between proxies.");
//				proxyConnection.close();

                fromProxyThread.join();
                log.debug("Connector FROM proxy complete");
            } catch (IOException e) {
                e.printStackTrace();
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                socket.close();
            }

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                log.debug("Closing connection between proxies (if not yet closed).");
                proxyConnection.close();
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

            try {
                log.debug("Stopping temporary server server.");
                server.close();
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
    }
}