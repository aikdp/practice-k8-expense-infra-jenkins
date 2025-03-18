## Create Custom VPC
* VPC
* EIP
* Subnets (Public, Private, DB)
* NAT GateWay (Public Subnet)
* IGW with attache VPC
* RouteTables (Public, Private, DB)
* Routes (Public, Private, DB)
* Routes with internet access: Public Subnet Route Table routes with IGW
* Routes with internet access: Private Subnet Route Table routes with NAT GW
* Routetable associations with Public and Private subnets

## Create SG groups and Rules to allow traffic only restricted resources.
* Bastion_Public_22
* Ingress_LB_Public_443
* MySQL_WorkerNodes_443
* MySQL_Bastion_3306
* WorkrNodes_EKS_Control_Plane(it is Internal private, so allow all traffic form Control Plane)
* EKS_Control_Plane_WorkrNodes (it is Internal private, so allow all traffic form Nodes)
* WorkerNodes_Ingress_ALB_30000-32767 (NodePOrt)
* EKS_Control_Plane_Bastion_443 (to access Cluster--JumpHost)
* Pods should communicate with eachOther, so WorkerNodes_VPC_CIDR (10.0.0.0/16)
* WorkerNodes_Bastion_22

## Create Bastion
* Install all tools to access our application inside kubernetes
* Docker
* Kubectl
* eksctl
* kubens
* helm
* k9s
* mysql for SSH to mysql, etc

## Create RDS
* Use RDS instead mysql pods

## Create EKS cluster
* Cluster with Blue-Green Deployment

## Create ACM 
* Create Certificate manger for domain with name is: *.telugudevops.online

## Create Web LB (ALB)
* Create AWS ALB
* Create Listeners
* Create Listener rules
* Craete Traget Group (check, wether nginx is listens on 8080 or 80 ) with TargetType is "IP" (In VM it it "Instances")
* Create Route53 records for ALB (expense-dev.telugudevops.online)

* Once all the above infra ready. 
* aws configure (take bastion host)

## Install AWS Load Balancer Controller to communicate with application inside kubernetes
* OIDC Provider
* IAM Policy
* Service Account
* Helm repo
* install AWS LB controler using helm

Check with command:
```
kubectl get pods -n kube-system
```

## Target Group Binding:
* If you are using AWS Application Load Balancer which is creating mannually or provisioing with terraform. You can use Target Group Binding resource.
* Add the AWS target group arn in yaml file and run
```
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: alb-tgb
  namespace: expense
spec:
  serviceRef:
    name: frontend # route traffic to the frontend service
    port: 8080
  targetGroupARN: arn:aws:elasticloadbalancing:us-east-1:537124943253:targetgroup/expense-dev-frontend/acda3c710fda1014
  targetType: ip
```

## Ingress (AWS Load balancer Controller)
* If you are using Ingress resource for Load Balancing, Then Skip ALB provisioning.
* Provide all the configs to the Ingress resource of kubernetes YAML file for frontend to expose to internet. (Specify Annotations: scheme, tags, targetType, ports, acm arn, group name, host path, service, service port, etc)


* If you are in using kubernetes Ingress resource created Load Balancer, You can provide inside kubernetes ingress resource with Listeners, rules, targetType, Ports, scheme, tags, ACM ARN, Group name, etc. 
* Skip Step 07-web-alb configuartion.
* Add kubernetes Ingress created ALB URL to Route53 records. For example: expense-dev.telugudevops.online.
* Check applcaition are accessing using AWS LB controller or not.
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: expense-alb
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/tags: Environment=dev,Team=test
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:537124943253:certificate/8fcb2e18-8547-458e-ba11-83750dd3280a
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/group.name: expense   #expense namespace
spec:
  ingressClassName: alb 
  rules:
  - host: "expense.telugudevops.online"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: frontend  #LB selects frontend service, and service will connects to pod and target IP
            port:
              number: 8080      #nginx lisetens on 8080
```

## EKS Cluster Upgrade
* Announce downtime and do not let the team to deployment when eks upgradation.
* Present Blue Node Groups are runnning. We wanted to update the eks cluster to 1.32.
1. Create same capapcity of Green Nodes by uncommenting in the TF code, and Apply it
2. Cordon Green Nodes to not schedule any pods to those nodes.
3. Upgrade to 1.32 in AWS console (Previous version is 1.31)
4. Once updated to 1.32, Upgarde the Green nodes to 1.32 in AWS Console.
5. Cordon Blue Nodes and uncordon Green nodes
6. Now drain Blue Nodes, so all pods that are running in the Blue will go to Green Nodes. (ignore daemonsets)
7. Now delete Blue Nodes by uncommenting in the TF code, Before deleting the Blue Nodes, Check terraform code with version has changed to 1.32. Then apply changes
8. Niw check in AWS console, Blue Nodes are deletes and Green Nodes are up and running.

Check our application. It is up and running even at the EKS cluster upgradation.



## Export Environment Varibles:

```
export TF_VAR_db_password="<PASSWORD>"
printenv | grep TF_VAR_<PASSWORD>
```

# Note:
* You should configure RDS DB, Run expense application inside EKS nodes.
1. You can use Target Group Binding, if you are using Application LoadBalancer or
2. You can try Kuberetes Ingress Resource as well. (For this we need OIDC Proviude, IAM Policy, SA and Helm repo to install AWS lB COntroller, etc)