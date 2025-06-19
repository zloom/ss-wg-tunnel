FROM golang:1.22 as builder

WORKDIR /src

RUN git clone --depth 1 --branch 0.0.20230223 https://github.com/WireGuard/wireguard-go.git
RUN git clone --depth 1 --branch 2023.09.27 https://github.com/seud0nym/wg-go.git

RUN go build -C wireguard-go
RUN go build -C wg-go

FROM ubuntu:24.04

RUN apt update && apt install -y iproute2 iptables curl traceroute tcpdump inetutils-ping net-tools conntrack

COPY --from=builder /src/wireguard-go/wireguard /usr/bin/wireguard
COPY --from=builder /src/wg-go/wg-go /usr/bin/wg

COPY entrypoint.sh ./

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]