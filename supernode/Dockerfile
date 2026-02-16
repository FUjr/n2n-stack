FROM ubuntu:24.04 AS n2n-builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git build-essential autoconf automake libtool pkg-config

WORKDIR /build

RUN git clone https://gh-proxy.org/https://github.com/ntop/n2n.git && \
    cd n2n && \
    ./autogen.sh && \
    ./configure && \
    make

# ---------- runtime ----------
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=n2n-builder /build/n2n/supernode /usr/sbin/supernode

COPY supernode/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
