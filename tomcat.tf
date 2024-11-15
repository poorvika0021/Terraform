# Pull the latest Tomcat image from Docker Hub 
resource "docker_image" "tomcat" {
  name         = "tomcat:latest"
  keep_locally = false
}

# Create a container based on the Tomcat image 
resource "docker_container" "t1" {
  name  = "Tomcat"
  image = docker_image.tomcat.image_id
  ports {
    internal = 8080
    external = 8080
  }
  command = ["bin/catalina.sh", "run"]
}
