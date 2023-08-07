TASK 1

app.go contains the main code for the Go application, go.mod manages the application's dependencies using Go modules, and go.sum contains checksums to ensure the integrity of the dependencies. Together, these files enable the development and execution of the Go application with proper dependency management.

This Terraform configuration is designed to build a Docker image from a Dockerfile, tag it, and then push it to DockerHub. The process is automated using Terraform with the "kreuzwerker/docker" provider.

Docker: Ensure that Docker is installed and configured on the machine where Terraform will be executed.
Variables

dockerhub_username: Your DockerHub username.
dockerhub_password: Your DockerHub password.
dockerhub_repository: The name of the DockerHub repository where the image will be pushed.
local.image_tag: A local variable representing the tag to be applied to the Docker image.
Execution Steps

Ensure that you have Docker installed and configured on your machine.
Clone this Terraform configuration to your local system.
Navigate to the directory containing the Terraform files.
Set Variables
Set the required variables in one of the following ways:

Export the environment variables containing your DockerHub credentials:
arduino
Copy code
export TF_VAR_dockerhub_username="your_username"
export TF_VAR_dockerhub_password="your_password"
export TF_VAR_dockerhub_repository="your_repository"
Create a terraform.tfvars file with the following content:
makefile
Copy code
dockerhub_username = "your_username"
dockerhub_password = "your_password"
dockerhub_repository = "your_repository"
Build and Push the Docker Image

Initialize Terraform:

Copy code
terraform init
Login to DockerHub using Terraform:

terraform apply -target=null_resource.docker_login
Build the Docker image and tag it:

terraform apply -target=docker_image.build_image -var="local.image_tag=my-tag"
Push the Docker image to DockerHub:

Dockerfile

Dockerfile sets up a Go development environment in the container, copies the application source files, downloads dependencies, and builds the Go application. When you run a container using this image, it will execute the compiled "app" binary, making the Go application accessible on port 8080 inside the container. To access the application from the host machine, you need to publish the container's port 8080 using the -p option when running the container.


TASK 2

This Terraform code is used to set up an Amazon Elastic Kubernetes Service (EKS) cluster on AWS with the necessary VPC, subnets, security groups, and worker node group.


Make sure you have the AWS CLI installed and configured with necessary permissions.
Install Terraform on your local machine.
Steps to Deploy EKS Cluster:

Install Terraform: Make sure Terraform is installed on your machine. You can download it from the official website.

Configure AWS Credentials: Ensure you have configured AWS credentials (access key and secret key) with the necessary IAM permissions to create resources.

Update Variables: In the variables.tf file, set the profilename, dockerhub_username, dockerhub_password, and dockerhub_repository variables as needed.

Initialize Terraform: Run terraform init in the same directory as your .tf files to initialize the Terraform provider.

Plan the Deployment: Run terraform plan to see the execution plan, which will list the resources that will be created or modified.

Apply the Changes: Run terraform apply and confirm with 'yes' to start provisioning the resources. The EKS cluster, VPC, subnets, security groups, and worker nodes will be created.

Access the EKS Cluster: After the deployment, Terraform will output the vpc_id, public_subnet_id, private_subnet_ids, and eks_cluster_name. Use these values to access the EKS cluster.

TASK 3

Deployment.yml file

This Kubernetes deployment file creates a deployment named my-app-deployment in the namespace co-labs. The deployment ensures that five replicas of the containerized application are running.

Key Components:

apiVersion: Specifies the Kubernetes API version used in the YAML file. In this case, it uses apps/v1.

kind: Specifies the type of Kubernetes resource. Here, it is a Deployment resource.

metadata: Contains metadata about the deployment, such as the name and namespace.

spec: Contains the specifications for the deployment.

replicas: Specifies the desired number of replicas for the application. In this case, it is set to 5, meaning five replicas will be maintained.

selector: Defines how the replicas should be selected. It uses the label app: my-app to match the replicas.

template: Specifies the pod template for creating replicas.

metadata: Contains labels that are applied to the pods. The label app: my-app is used here.

spec: Contains the container specification for the pod.

containers: Lists the containers running inside the pod. In this case, there is one container.

name: Specifies the name of the container, set as my-app-container.

image: Defines the container image to use for this deployment. It uses the Docker image abhaymarwade/new-repo:latest.

ports: Specifies the ports on which the container listens. Here, it listens on port 80.

This Kubernetes deployment file ensures that five replicas of the abhaymarwade/new-repo:latest Docker image, labeled as app: my-app, are running in the co-labs namespace. The application inside the container will be accessible on port 80.


This Kubernetes service file creates a Service named my-app-service in the namespace co-labs. The Service exposes the pods that have the label app: my-app as a load-balanced endpoint.

Service.yml file

Key Components:

apiVersion: Specifies the Kubernetes API version used in the YAML file. In this case, it uses v1.

kind: Specifies the type of Kubernetes resource. Here, it is a Service resource.

metadata: Contains metadata about the Service, such as the name and namespace.

spec: Contains the specifications for the Service.

type: Specifies the type of Service. Here, it is set to LoadBalancer, meaning the Service will be exposed externally through a cloud provider's load balancer.

selector: Defines the set of pods that this Service will load balance traffic to. It uses the label app: my-app to select the matching pods.

ports: Specifies the ports on which the Service listens and forwards traffic to the pods.

protocol: Specifies the protocol used for the port. Here, it is set to TCP.

port: Specifies the port number on which the Service listens. It is set to 80.

targetPort: Specifies the port number on the pods to which traffic is forwarded. In this case, it is also set to 80.

Relationship with deployement file

Relationship with Previous File:

The my-app-service Service is created in the same namespace co-labs where the my-app-deployment deployment is running. The Service listens on port 80 and forwards traffic to the pods with the label app: my-app, which are maintained by the my-app-deployment Deployment. This combination of Service and Deployment ensures that the application replicas are load balanced and accessible through a load balancer on port 80.



