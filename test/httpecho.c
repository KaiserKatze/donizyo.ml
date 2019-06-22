#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>

#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <unistd.h>

#define PORT_SERVER 8080
#define CRLF "\r\n"

volatile int is_closing;

void
close_ungracefully()
{
    kill(getpid(), SIGKILL);
}

void
handle_signal(int signal)
{
    switch (signal)
    {
    case (SIGINT):
        printf("Detected SIGINT, closing ...\n");
        is_closing = 1;
        close_ungracefully();
        break;
    default:
        break;
    }
}

int
main()
{
    int sock_server = 0;
    int sock_client = 0;

    socklen_t addrlen;
    struct sockaddr_in addr_server;
    struct sockaddr_in addr_client;

    const char MSG_ECHO[] = ("HTTP/1.1 200 OK" CRLF
                            CRLF
                            "OK" CRLF
                            "\0");

    printf("Starting ...\n");

    signal(SIGINT, handle_signal);

    bzero(&addr_server, sizeof(addr_server));
    addr_server.sin_family = AF_INET;
    addr_server.sin_addr.s_addr = INADDR_ANY;
    addr_server.sin_port = htons(PORT_SERVER);

    sock_server = socket(AF_INET, SOCK_STREAM, 0);
    if (sock_server < 0)
    {
        perror("socket error!\n");
        goto error;
    }

    if(bind(sock_server,
        (struct sockaddr *)&addr_server,
        sizeof(struct sockaddr)) < 0)
    {
        perror("bind error!\n");
        goto error;
    }
    if(listen(sock_server, 5) < 0)
    {
        perror("listen error!\n");
        goto error;
    }

    addrlen = sizeof(struct sockaddr_in);

    for (is_closing = 0; !is_closing;)
    {
        sock_client = accept(sock_server,
            (struct sockaddr *)&addr_client,
            &addrlen);
        if (sock_client < 0)
        {
            perror("accept error!\n");
            goto error;
        }
        printf("inbound connection from '%s' ...\n",
            inet_ntoa(addr_client.sin_addr));

        if (send(sock_client, MSG_ECHO, strlen(MSG_ECHO), 0) < 0)
        {
            perror("send error!\n");
            goto error;
        }

        shutdown(sock_client, SHUT_RDWR);
        close(sock_client);
    }

    return 0;

error:
    close(sock_server);
    close(sock_client);
    return -1;
}
