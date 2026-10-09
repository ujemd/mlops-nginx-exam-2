FROM nginx:stable

# Replace the default config and add the auth file and certificates
COPY deployments/nginx/nginx.conf /etc/nginx/nginx.conf
COPY deployments/nginx/.htpasswd /etc/nginx/.htpasswd
COPY deployments/nginx/certs/nginx.crt /etc/nginx/certs/nginx.crt
COPY deployments/nginx/certs/nginx.key /etc/nginx/certs/nginx.key

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]