#include <windows.h>
#include <winsock2.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc,char *argv[]) {
	int i = 1;
	// decode arguments
	if(argc < 4) {
		printf("You must provide the following arguments: ip port message\n");
		return(0);
	}

    WSADATA t_wsa; // WSADATA structure
    WORD wVers; // version number
    int iError; // error number

    //p rintf("starting\n");
    wVers = MAKEWORD(2, 2); // Set the version number to 2.2
    iError = WSAStartup(wVers, &t_wsa); // Start the WSADATA

    if(iError != NO_ERROR || iError == 1){
        MessageBox(NULL, (LPCTSTR)"Error at WSAStartup()", (LPCTSTR)"Client::Error", MB_OK|MB_ICONERROR);
        WSACleanup();
        return 0;
    }
    /* Correct version? */
    if(LOBYTE(t_wsa.wVersion) != 2 || HIBYTE(t_wsa.wVersion) != 2){
        MessageBox(NULL, (LPCTSTR)"Error at WSAStartup()", (LPCTSTR)"Client::Error", MB_OK|MB_ICONERROR);
        WSACleanup();
        return 0;
    }
    SOCKET sClient;
    sClient = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if(sClient == INVALID_SOCKET || iError == 1){
        MessageBox(NULL, (LPCTSTR)"Invalid Socket!", (LPCTSTR)"Client::Error", MB_OK|MB_ICONERROR);
        WSACleanup();
        return 0;
    }
    SOCKADDR_IN sinClient;
    memset(&sinClient, 0, sizeof(sinClient));

    struct hostent *host;
    host = gethostbyname(argv[1]);

    sinClient.sin_family = AF_INET;
    sinClient.sin_addr.s_addr = *((unsigned long*)host->h_addr);

    int port = atoi(argv[2]);
    sinClient.sin_port = htons(port); // Port
    if(connect(sClient, (LPSOCKADDR)&sinClient, sizeof(sinClient)) == SOCKET_ERROR){
        /* failed at starting server */
        printf((LPCTSTR)"Could not connect to the server!");
        //MessageBox(NULL, (LPCTSTR)"Could not connect to the server!", (LPCTSTR)"Client::Error", MB_OK|MB_ICONERROR);
        WSACleanup();
        return 0;
    }
    // Now we can send/recv data!
    int iRet;
    char cBuffer[600];
    //MessageBox(NULL, (LPCTSTR)"You are connected! Sending a message to the server (less than 599 characters)!", (LPCTSTR)"Client::Server", MB_OK|MB_ICONEXCLAMATION);
    char buffer[200];
    strcpy(buffer, argv[3]);
    iRet = send(sClient, buffer, strlen(buffer), 0);
    if(iRet == SOCKET_ERROR){
        //MessageBox(NULL, (LPCTSTR)"Could not send data!", (LPCTSTR)"Client::Error", MB_OK|MB_ICONERROR);
        printf((LPCTSTR)"Could not send data!");
        WSACleanup();
        return 0;
    }
    int bytes;
    bytes = SOCKET_ERROR;
    char *cServerMessage;

    cServerMessage = new char[600];
    while(bytes = recv(sClient, cServerMessage, 599, 0)){
        if(bytes == SOCKET_ERROR){
            char cError[500];
            //sprintf(cError, "Connection failed, WINSOCK error code: %d", WSAGetLastError());
            //MessageBox(NULL, (LPCTSTR)cError, (LPCTSTR)"Client::Error", MB_OK|MB_ICONERROR);
            printf((LPCTSTR)"Connection failed");
            closesocket(sClient);
            // Shutdown Winsock
            WSACleanup();
            return 0;
        }
        if (bytes == 0 || bytes == WSAECONNRESET) {
            //MessageBox(NULL, (LPCTSTR)"Connection Disconnected!", (LPCTSTR)"Client::Error", MB_OK|MB_ICONERROR);
            printf((LPCTSTR)cServerMessage);
            closesocket(sClient);
            // Shutdown Winsock
            WSACleanup();
            return 0;
        }
        if(bytes < 1){
            //Sleep(300);
            continue;
        }
        //MessageBox(NULL, (LPCTSTR)cServerMessage, (LPCTSTR)"Client::Server Response", MB_OK);
        printf((LPCTSTR)cServerMessage);
        delete [] cServerMessage;
        cServerMessage = new char[600];
        //Sleep(100); // Don't consume too much CPU power.
    }
    delete [] cServerMessage;
    // Cleanup
    closesocket(sClient);
    // Shutdown Winsock
    WSACleanup();
    return 0;
}
