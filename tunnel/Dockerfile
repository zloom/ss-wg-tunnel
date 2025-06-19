FROM golang:1.23.4 as builder

WORKDIR /src

RUN git clone --depth 1 --branch v2.5.3 https://github.com/zloom/tun2socks.git
RUN git clone --depth 1 --branch v0.1.5 https://github.com/shadowsocks/go-shadowsocks2.git

RUN go build -C go-shadowsocks2
RUN go build -C tun2socks

FROM ubuntu:24.04 as runtime

RUN apt update && apt install -y iproute2 iptables curl traceroute tcpdump inetutils-ping net-tools

COPY --from=builder /src/tun2socks/tun2socks /usr/bin/tun2socks
COPY --from=builder /src/go-shadowsocks2/go-shadowsocks2 /usr/bin/go-shadowsocks2

COPY entrypoint.sh .

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
