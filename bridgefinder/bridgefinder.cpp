//
//  main.c
//  findhue
//
//  Created by kyb on 25/11/15.
//  Copyright © 2015 kyb. All rights reserved.
//

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <map>
#include <string>
#include <dispatch/dispatch.h>
#include <dispatch/queue.h>
#include <errno.h>
#include <netinet/tcp.h>
#include <sys/socket.h>

bool break_loop(const char c) {
    return (c == 0x00 || c == ':' || c == '\r' || c == '\n' || c == '/');
}

void dump_bridge_info(std::string description_url) {
    std::string ip;
    std::string port = "80"; //we just assume here
    const char *ptr_ip = strstr(description_url.c_str(), "http://");
    if (ptr_ip != 0) {
        ptr_ip += strlen("http://");
        for (;;) {
            if (break_loop(*ptr_ip)) {
                break;
            }
            ip += *ptr_ip;
            ptr_ip++;
        }
    }
    sockaddr_in server_address;
    
    int on = 1;
    int sock_fd = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sock_fd < 0) {
        printf("couldn't create socket\n");
        return;
    }
    int succ = setsockopt(sock_fd, IPPROTO_TCP, TCP_NODELAY, (const char *)&on, sizeof(int));
    if (succ < 0)  {
        printf("couldn't setsockopt: %i\n", errno);
        return;
    }
    
    memset(&server_address, 0, sizeof(struct sockaddr_in));
    inet_pton(AF_INET, ip.c_str(), &server_address.sin_addr);
    server_address.sin_family = AF_INET;
    server_address.sin_port = htons(80);
    int conn = connect(sock_fd, (struct sockaddr *) &server_address, sizeof(server_address));
    if (conn < 0) {
        printf("couldn't connect: %i\n", errno);
        return;
    }
    
    const size_t BUFFER_SIZE = 1024 * 1024;
    char *buffer = (char *)malloc(BUFFER_SIZE);
    bzero(buffer, BUFFER_SIZE);
    
    std::string request = "GET /description.xml\r\n";
    
    write(sock_fd, request.c_str(), request.size());
    bzero(buffer, BUFFER_SIZE);
    
    std::string data;
    
    while(read(sock_fd, buffer, BUFFER_SIZE - 1) != 0){
        data += std::string(buffer);
        bzero(buffer, BUFFER_SIZE);
    }
    
    shutdown(sock_fd, SHUT_RDWR);
    close(sock_fd);
    
    std::string name;
    char *ptr_name = strstr(data.c_str(), "<friendlyName>");
    if (ptr_name != nullptr) {
        ptr_name += strlen("<friendlyName>");
        for (;;) {
            if (break_loop(*ptr_name) || *ptr_name == '<') {
                break;
            }
            name += *ptr_name;
            ptr_name++;
        }
    }
    free(buffer);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        printf("%s @ %s\n", name.c_str(), ip.c_str());
    });
}

void listen_for_bridges() {
    struct in_addr localInterface;
    struct sockaddr_in groupSock;
    struct sockaddr_in localSock;
    struct ip_mreq group;
    
    // Create the Socket
    int udpSocket = socket(AF_INET, SOCK_DGRAM, 0);
    
    // Enable SO_REUSEADDR to allow multiple instances of this application to receive copies of the multicast datagrams.
    int reuse = 1;
    
    setsockopt(udpSocket, SOL_SOCKET, SO_REUSEADDR, (char *)&reuse, sizeof(reuse));
    
    // Initialize the group sockaddr structure with a group address of 239.255.255.250 and port 1900.
    memset((char *) &groupSock, 0, sizeof(groupSock));
    
    groupSock.sin_family = AF_INET;
    groupSock.sin_addr.s_addr = inet_addr("239.255.255.250");
    groupSock.sin_port = htons(1900);
    
    // Disable loopback so you do not receive your own datagrams.
    char loopch = 0;
    
    setsockopt(udpSocket, IPPROTO_IP, IP_MULTICAST_LOOP, (char *)&loopch, sizeof(loopch));
    
    // Set local interface for outbound multicast datagrams. The IP address specified must be associated with a local, multicast capable interface.
    localInterface.s_addr = inet_addr("192.168.0.1");
    
    setsockopt(udpSocket, IPPROTO_IP, IP_MULTICAST_IF, (char *)&localInterface, sizeof(localInterface));
    
    // Bind to the proper port number with the IP address specified as INADDR_ANY.
    memset((char *) &localSock, 0, sizeof(localSock));
    localSock.sin_family = AF_INET;
    localSock.sin_port = htons(1900);
    localSock.sin_addr.s_addr = INADDR_ANY;
    
    bind(udpSocket, (struct sockaddr*)&localSock, sizeof(localSock));
    
    // Join the multicast group on the local interface. Note that this IP_ADD_MEMBERSHIP option must be called for each local interface over which the multicast datagrams are to be received.
    group.imr_multiaddr.s_addr = inet_addr("239.255.255.250");
    group.imr_interface.s_addr = inet_addr("192.168.0.1");
    
    setsockopt(udpSocket, IPPROTO_IP, IP_ADD_MEMBERSHIP, (char *)&group, sizeof(group));
    
    const char *message = "M-SEARCH * HTTP/1.1\r\nHOST:239.255.255.250:1900\r\nMAN:\"ssdp:discover\"\r\nST:ssdp:all\r\nMX:1\r\n\r\n";
    int64_t message_length = strlen(message);
    
    ssize_t ret = sendto(udpSocket, message, message_length, 0, (struct sockaddr*)&groupSock, sizeof(groupSock));
    if (ret < 0) {
        printf("failed to send M-SEARCH request.\n");
        exit(127);
    }
    
    
    struct sockaddr_in si_other;
    socklen_t slen = sizeof(si_other);
    char buffer[1024];
    for (;;) {
        ssize_t recvlen = recvfrom(udpSocket, buffer, 1024, 0, (struct sockaddr *) &si_other, &slen);
        
        if (recvlen > 0) {
            buffer[recvlen] = 0x00;
            const char *ptr = strstr(buffer, "description.xml");
            if (ptr != 0) {
                ptr = strstr(buffer, "LOCATION: http://");
                if (ptr != 0) {
                    std::string bridge_desc_url;
                    ptr += strlen("LOCATION: ");
                    for (;;) {
                        if (*ptr == '\r' || *ptr == '\n' || *ptr == 0x00) {
                            break;
                        }
                        bridge_desc_url += *ptr;
                        ptr++;
                    }
                    
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
                        dump_bridge_info(bridge_desc_url);
                    });
                }
            }
        }
        
    }
    
}

int main(int argc, const char * argv[]) {
    // Structs needed
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        listen_for_bridges();
    });
    dispatch_main();
    
    return 0;
}
