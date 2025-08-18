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


# Sử dụng image chính thức của OSRM (có sẵn boost và osrm-backend)
FROM osrm/osrm-backend:latest AS builder

# Copy dữ liệu bản đồ
COPY data/hanoi-latest.osm.pbf /data/hanoi.osm.pbf

# Chuẩn bị dữ liệu OSRM với profile ô tô
RUN osrm-extract -p /opt/car.lua /data/hanoi.osm.pbf && \
    osrm-partition /data/hanoi.osrm && \
    osrm-customize /data/hanoi.osrm

# Stage 2: tạo container chạy OSRM + Nginx + Supervisor
FROM debian:bullseye-slim

# Cài nginx, supervisor, osrm-backend
RUN apt-get update && \
    apt-get install -y nginx supervisor osrm-backend && \
    rm -rf /var/lib/apt/lists/*

# Copy dữ liệu OSRM từ stage builder
COPY --from=builder /data /data

# Copy cấu hình nginx và supervisor
COPY nginx/default.conf /etc/nginx/sites-enabled/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose cổng
EXPOSE 80

# Chạy supervisor (quản lý OSRM + Nginx)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

