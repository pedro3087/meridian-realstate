# Use a lightweight web server image
FROM nginx:alpine

# Copy the HTML file to the nginx web root
COPY guide_to_facebook_comment_automation.html /usr/share/nginx/html/index.html

# Copy a custom nginx configuration if needed
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 