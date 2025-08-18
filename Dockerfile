 # ============================
# # 1. Base image
# # ============================
# FROM osrm/osrm-backend:latest

# # ============================
# # 2. Copy dữ liệu bản đồ vào container
# # ============================
# WORKDIR /data
# COPY hanoi-latest.osm.pbf /data

# # ============================
# # 3. Chuẩn bị dữ liệu cho OSRM
# # ============================
# RUN osrm-extract -p /opt/car.lua /data/hanoi-latest.osm.pbf \
#  && osrm-partition /data/hanoi-latest.osrm \
#  && osrm-customize /data/hanoi-latest.osrm

# # ============================
# # 4. Chạy OSRM server
# # ============================
# EXPOSE 5000
# # CMD ["sh","-c","osrm-routed --algorithm mld -p ${PORT} -i 0.0.0.0 --cors /data/hanoi-latest.osrm"]
# CMD ["sh","-c","osrm-routed --algorithm mld -p ${PORT} -i 0.0.0.0 /data/hanoi-latest.osrm"]


# ======================
# Stage 1: Build OSRM
# ======================
FROM ubuntu:22.04 as builder

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    g++ \
    libboost-all-dev \
    lua5.2 \
    liblua5.2-dev \
    libtbb-dev \
    libstxxl-dev \
    libstxxl1v5 \
    libxml2-dev \
    libzip-dev \
    libbz2-dev \
    zlib1g-dev \
    pkg-config \
    wget \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Clone OSRM source
RUN git clone https://github.com/Project-OSRM/osrm-backend.git /osrm-backend
WORKDIR /osrm-backend
RUN git checkout v5.27.0

# Build OSRM
RUN mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release && cmake --build .

# ======================
# Stage 2: Runtime
# ======================
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    nginx supervisor \
    libtbb12 \
    liblua5.2-0 \
    libboost-system-dev \
    libboost-filesystem-dev \
    libboost-thread-dev \
    libxml2 \
    libzip4 \
    zlib1g \
    libbz2-1.0 \
    && rm -rf /var/lib/apt/lists/*

# Copy OSRM binaries + profiles
COPY --from=builder /osrm-backend/build/osrm-* /usr/local/bin/
COPY --from=builder /osrm-backend/profiles /osrm-profiles

# Copy dữ liệu bản đồ (bạn cần có file này ở context build)
COPY hanoi-latest.osm.pbf /data/hanoi.osm.pbf

# Chuẩn bị dữ liệu OSRM (car profile)
RUN osrm-extract -p /osrm-profiles/car.lua /data/hanoi.osm.pbf && \
    osrm-partition /data/hanoi.osrm && \
    osrm-customize /data/hanoi.osrm

# ======================
# Config Nginx + CORS
# ======================
COPY default.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n"]

