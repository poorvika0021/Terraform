# Define the Nginx Docker image
resource "docker_image" "nginx_image" {
  name = "nginx:latest"
}

# Create the Nginx container
resource "docker_container" "nginx_container" {
  name  = "nginx_server"
  image = docker_image.nginx_image.image_id
  ports {
    internal = 80
    external = 8083
  }
}
