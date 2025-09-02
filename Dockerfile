# # Dockerfile
# # Base: OSRM chính thức
# FROM ghcr.io/project-osrm/osrm-backend:v5.27.1

# # Cài thêm nginx + supervisor
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends nginx supervisor && \
#     rm -rf /var/lib/apt/lists/*

# # Copy dữ liệu bản đồ vào container
# COPY data/hanoi-latest.osm.pbf /data/hanoi-latest.osm.pbf

# # Chuẩn bị dữ liệu OSRM (MLD)
# RUN osrm-extract -p /opt/car.lua /data/hanoi-latest.osm.pbf && \
#     osrm-partition /data/hanoi-latest.osrm && \
#     osrm-customize /data/hanoi-latest.osrm

# # Xoá toàn bộ cấu hình mặc định của Nginx (rất quan trọng)
# RUN rm -f /etc/nginx/conf.d/*.conf && rm -f /etc/nginx/sites-enabled/*

# # Copy Nginx + Supervisor config
# COPY nginx/default.conf /etc/nginx/conf.d/default.conf
# COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# # Expose port web (Nginx)
# EXPOSE 80

# # Chạy cả OSRM + Nginx qua supervisor
# CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# # Dockerfile
# Base: OSRM chính thức
FROM ghcr.io/project-osrm/osrm-backend:v5.27.1

# Cài thêm nginx + supervisor
RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx supervisor && \
    rm -rf /var/lib/apt/lists/*

# Copy dữ liệu bản đồ vào container
COPY data/hanoi-latest.osm.pbf /data/hanoi-latest.osm.pbf

# Chuẩn bị dữ liệu OSRM (MLD)
RUN osrm-extract -p /opt/car.lua /data/hanoi-latest.osm.pbf && \
    osrm-partition /data/hanoi-latest.osrm && \
    osrm-customize /data/hanoi-latest.osrm

# Xoá toàn bộ cấu hình mặc định của Nginx
RUN rm -f /etc/nginx/conf.d/*.conf && rm -f /etc/nginx/sites-enabled/*

# Copy Nginx + Supervisor config
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose port web (Nginx)
EXPOSE 80

# Start cả OSRM + Nginx qua supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
