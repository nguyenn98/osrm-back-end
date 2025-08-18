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



# ================================
# Stage 1: Build OSRM data
# ================================
FROM osrm/osrm-backend:latest AS osrm-builder

WORKDIR /data
# Copy file bản đồ OSM vào container
COPY hanoi-latest.osm.pbf /data/

# Chuẩn bị dữ liệu cho OSRM
RUN osrm-extract -p /opt/car.lua /data/hanoi-latest.osm.pbf && \
    osrm-partition /data/hanoi-latest.osrm && \
    osrm-customize /data/hanoi-latest.osrm

# ================================
# Stage 2: Final container with OSRM + Nginx
# ================================
FROM ubuntu:22.04

# Cài OSRM + Nginx + supervisor
RUN apt-get update && \
    apt-get install -y osrm-backend nginx supervisor && \
    rm -rf /var/lib/apt/lists/*

# Copy dữ liệu OSRM từ stage 1
COPY --from=osrm-builder /data /data

# Copy file cấu hình Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy file cấu hình Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose cổng HTTP
EXPOSE 80

# Start cả OSRM + Nginx thông qua Supervisor
CMD ["/usr/bin/supervisord", "-n"]
