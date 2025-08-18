# FROM osrm/osrm-backend:latest

# # Copy file bản đồ vào đúng path trong container
# # COPY hanoi-latest.osm.pbf /data/hanoi.osm.pbf
# COPY osrm-backend/hanoi-latest.osm.pbf /data/hanoi.osm.pbf

# # Chuẩn bị dữ liệu cho thuật toán MLD
# RUN osrm-extract -p /opt/car.lua /data/hanoi.osm.pbf && \
#     osrm-partition /data/hanoi.osrm && \
#     osrm-customize /data/hanoi.osrm

# # Mở cổng 5000
# EXPOSE 5000

# # Chạy OSRM server
# CMD ["osrm-routed", "--algorithm", "mld", "/data/hanoi.osrm"]


# ============================
# 1. Base image
# ============================
FROM osrm/osrm-backend:latest

# ============================
# 2. Copy dữ liệu bản đồ vào container
# ============================
WORKDIR /data
COPY hanoi-latest.osm.pbf /data

# ============================
# 3. Chuẩn bị dữ liệu cho OSRM
# ============================
RUN osrm-extract -p /opt/car.lua /data/hanoi-latest.osm.pbf \
 && osrm-partition /data/hanoi-latest.osrm \
 && osrm-customize /data/hanoi-latest.osrm

# ============================
# 4. Chạy OSRM server
# ============================
EXPOSE 5000
# CMD ["osrm-routed", "--algorithm", "mld", "/data/hanoi-latest.osrm"]
CMD ["sh","-c","osrm-routed --algorithm mld -p ${PORT} -i 0.0.0.0 --cors /data/hanoi-latest.osrm"]

