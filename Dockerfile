FROM alpine:latest

# Cài đặt các phụ thuộc cần thiết
RUN apk add --no-cache --virtual .build-deps ca-certificates curl busybox unzip

# Tạo thư mục cấu hình và runtime
RUN mkdir -p /etc/v2ray /usr/bin

# Sao chép script entrypoint vào container
COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

# Thiết lập biến môi trường
ENV ID=ad806487-2d26-4636-98b6-ab85cc8521f7
ENV AID=64
ENV WSPATH=/
ENV PORT=80

# Thiết lập entrypoint
ENTRYPOINT ["sh", "-c", "/opt/entrypoint.sh"]