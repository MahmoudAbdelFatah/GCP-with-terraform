# Terraform GCP GKE Infrastructure

## Project Overview
Creating a private Kubernetes (GKE) cluster in Google Cloud Platform (GCP) using terraform.

## Objectvies

* Create 2 subnets (management subnet & restricted subnet)
  1. Management subnet has the following:
    1. NAT gateway that allows VM inside the VPC to access the internet.
    1. Private VM (Bastion Host) that allows to access the cluster Control Plane to run `kubectl` CLI commands.
  1. Restricted subnet has the following:
    1. Private standard GKE cluster (private control plan)
* Restricted subnet not have access to internet.
* Using GCR (Artifacts registry) to deploy the docker image.
* Deployment is exposed to public internet with a public HTTP load balancer.
* Deployment on GKE done manually by kubectl tool.
* The code to be build/dockerized and pushed to GCR is [here](https://github.com/MahmoudAbdelFatah/DevOps-Challenge-Demo-Code.git).
* Using custom Service Account (SA) and attach it to node and Bastion VM.
* Only the management subnet can connect to the gke cluster.
* Using Load Balancer to route external traffic to the Worker Nodes.
* Using Load Balancer to access the dashboard of the jenkins to run pipeline.
* Run a pipeline to deployment the app.

![This is a alt text.](/images/private-gke-2.jpeg)


## Tools Used

* Docker Platform
* Kubernetes (GKE)
* Terraform
* glcoud (Google Cloud CLI)
* Jenkins


## Project Steps

1. [GCP Credentials](#Configure-GCP-Credentials)
1. [Build Infrastructure on GCP](#Build-Infrastructure-on-GCP)
1. [Build image and upload to GCR](#Build-image-and-upload-to-GCR)
1. [Connect to private GKE cluster via Bastion VM](#Connect-to-private-GKE-cluster-via-Bastion-VM)
1. [On the Bastion host](#on-the-bastion-host)
1. [Run CICD pipeline](#Run-CICD-pipeline)


### Configure GCP Credentials
```bash
# Configure default application credentials
$ gcloud auth application-default login

# Enable API service - container.googleapis.com
$ gcloud services enable container.googleapis.com

```


### Build Infrastructure on GCP
```bash
$ cd terraform/
$ terraform init
$ terraform apply --var-file dev.tfvars 
```

### Build image and upload to GCR

```bash
# Build an image with a dockerfile
$ cd DevOps-Challenge-Demo-Code/
$ docker build -t <image>:<tag> .
$ docker push gcr.io/<project-id>/<image>:<tag>
```

### Connect to private GKE cluster via Bastion VM
![This is a alt text.](/images/private-gke.png)
```bash
# Connect to the Bastion host (Start a session)
$ gcloud compute ssh management-vm --project gcp-terraform-357100 --zone us-central1-a
```

- ##### Deploy the proxy
   Deploy a proxy daemon in the host to forward traffic to the cluster control plane.
```bash
# Install Tinyproxy
$ sudo apt-get install tinyproxy
```

- ##### Change the configuration of Tinyproxy in the following file and append `Allow localhost`
```bash
$ sudo vim /etc/tinyproxy/tinyproxy.conf
```

- ##### Tinyproxy by executing
```bash
$ sudo service tinyproxy restart
```

- ##### connect to the Kubernetes cluster from the computer using the usual tools such as kubectl. This step is done on the computer where we first download credentials for the GKE cluster using:
```bash
$ gcloud container clusters get-credentials private-cluster --region us-central1 --project gcp-terraform-357100
```

- This sets-up local Kubernetes config including cluster credentials that can be used to access the cluster by kubectl and similar tools.

- ##### Lastly, we create an identity aware proxy to the bastion using:
```bash
$ gcloud compute ssh management-vm   --project gcp-terraform-357100   --zone us-central1-a   --  -L 8888:localhost:8888 -N -q -f
```

 - This creates a proxy to the bastion that we created earlier. The role of the bastion is to relay requests send to it to the request destination in this case to the Kubernetes management APIs. The command is running proxy as a background process and it has to be running when we want to communicate with the private cluster.
 
### On the Bastion host

- #####  Install gcloud-sdk and initialize gcloud:
```bash
$ curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-394.0.0-linux-x86_64.tar.gz
$ tar -xf google-cloud-cli-394.0.0-linux-x86_64.tar.gz
$ ./google-cloud-sdk/install.sh
$ ./google-cloud-sdk/bin/gcloud init
```

- ##### Install gcloud packages and update repo
```bash
$ sudo apt-get install apt-transport-https ca-certificates gnupg
$ echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
$ curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
$ sudo apt-get update
```

- ##### Install auth-plugin 
```bash
$ sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
```

- ##### Install kubectl 
```bash
$ sudo apt-get install kubectl
$ kubectl get all
```
![This is a alt text.](/images/deploy.png)

- ##### Connect to the Cluster
```bash
$ gcloud container clusters get-credentials private-cluster --region us-central1 --project gcp-terraform-357100
```

- ##### Copy my kubernetes file from local to instance 
```bash
$ gcloud compute scp --recurse kubernetes mahmoud@management-vm:~/
```

- ##### Apply Service and Deployment
```bash
$ kubectl apply -f services.yaml
$ kubectl apply -f deploy.yaml
```

![This is a alt text.](/images/image-lb.png)



### Run CICD pipeline
 - Using this [image](https://hub.docker.com/r/rizk95/jenkins_with_docker_terra_ansible_kubectl) to deploy jenkins pod which is contains the docker and kubectl installed on it.
 - Copy the deployment files into the bastion host to run `kubectl apply -f .`
 
    ```
    # run this command on the local machine...
    # gcloud compute scp --recurse <file-deployment-files-name> <host-name>:~/
    $ gcloud compute scp --recurse kubernetes mahmoud@management-vm:~/
    ```
    Check the deployment state `kubectl get all -n develop-area`
    
    ![This is a alt text.](/images/1.png)

    
 - Setup Credentials in Jenkins to Access GKE
 ```bash
    # Enter the pod jenkins
    $ kubectl exec -it <pod-name> bash -n develop-area
    # inside pod in /var/jenkins_home directory create a folder .kube
    $ mkdir .kube
    # Copy the config file inside the pod, run the following command on the bastion host
    $ kubectl cp  ~/.kube/config <pod-name>:/var/jenkins_home/.kube/config -n develop-area
 ```
 - Run the jenkins using loadbalancer **ip:8080**, get the admin password by the following commnad on the bastion host
 ```bash
 $ kubectl exec -it <pod-nam> cat /var/jenkins_home/secrets/initialAdminPassword -n develop-area
 ```
 - Create the pipeline on jenkins pod, this is the [CI/CD pipeline](https://github.com/MahmoudAbdelFatah/DevOps-Challenge-Demo-Code/blob/master/jenkinsfile)
 - Deploy the app on different namespace called `deploy-area` and expose it by loadbalancer, open the app on **ip:8000**
 
 ![This is a alt text.](/images/3.png)
 
 - Check the deployment of CI/CD pipeline by `kubectl get all -n deploy-area` 
    
    ![This is a alt text.](/images/2.png)
    ![This is a alt text.](/images/3.png)
    
- **Note**: In this Jenkins Kubernetes deployment we have used the `securityContext` for Jenkins pod to be able to write to the local persistent volume.
```
    ...
    spec:
      securityContext:
        runAsUser: 1000
        fsGroup: 1000
        privileged: true
      containers:
      - name: jenkins
      ...
```

