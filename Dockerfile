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

# Dockerfile
# Base: OSRM từ GHCR (tag tồn tại)
FROM ghcr.io/project-osrm/osrm-backend:v5.27.1

# Cài thêm nginx + supervisor
RUN apt-get update && \
    apt-get install -y nginx supervisor && \
    rm -rf /var/lib/apt/lists/*

# Copy dữ liệu bản đồ vào container
COPY data/hanoi-latest.osm.pbf /data/hanoi-latest.osm.pbf

# Chuẩn bị dữ liệu OSRM (MLD)
RUN osrm-extract -p /opt/car.lua /data/hanoi-latest.osm.pbf && \
    osrm-partition /data/hanoi-latest.osrm && \
    osrm-customize /data/hanoi-latest.osrm

# Nginx + Supervisor config
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose HTTP
EXPOSE 80

# Chạy cả OSRM + Nginx qua supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

