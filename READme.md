###################################################################
This document provides you with the information to deploy the K8s infrastructure.

In my local, I have used Minikube and used the Kubernetes 1.23 version. You may use the same to deploy or you can choose to go with a different version if not installed. 
There shall not be much dependancies and the applications should work fine.

**Steps to deploy:**
--> Assuming that you already have your cluster up and running. Please go to the environment folder and run the namespace.yaml file in your cluster
 **kubectl apply -f namespace.yaml**  This will deploy the different envs like staging and other 5 dev envs.
 
--> Make sure you have the aws cli installed and the aws access_key and secret_access_key configured and then run this command:
  aws secretsmanager create-secret --name MySecret --secret-string '{"username":"$username", "password":"$password"}'
--> a shellscript has been created in my case and saved in mysql folder which has the policy for the secret created.

--> Create the IAM OIDC provider for the cluster if you have not already done so:
**eksctl utils associate-iam-oidc-provider --region="$REGION" --cluster="$CLUSTERNAME" --approve** 

--> after that, run this: This will create a service account for mysql and attach the policy to the service account which we defined in our shellscript file.
**"eksctl create iamserviceaccount --name mysql-deployment-sa --region="$REGION" --cluster "$CLUSTERNAME" --attach-policy-arn "$POLICY_ARN" --approve --override-existing-serviceaccounts"**

--> Now, apply the secretproviderclass file in the mysql folder. 
--> After applying the mysql-aws-secretprovider file, we can now deploy our mysql deployment.

**Note:** I couldn't perform the above steps as I deploying everything in my minikube cluster, all the above steps are applicable if you're using aws EKS to deploy.

--> Next, go to mysql folder and apply the mysql-configmap.yaml using: **kubectl apply -f <filename>**. This will have your secrets and configmap required for mysql db deployment in every namespaces
--> Now, apply the mysql.yaml file, which has the deployment, pvc and service details for mysql-db.
--> After deploying, check to make sure that you have pods running. Note: You need to mention the namespace to have it deployed onto particular env.
  ex: kubectl apply -f mysql.yaml <namespace>, could be staging or any dev env
--> Exec into the mysql pod using, kubectl exec -it <mysql.pod.name> /bin/bash. This will let you login to the mysql pod. 
  Run mysql -h mysql -u root- p and enter, this will ask you to enter the pwd. You can find the password in the secrets, you need decode the base64 code and enter the password.
--> After logged-in, run these commands and replace the placeholders with the microservices name: 
CREATE DATABASE <your_database_name>;

CREATE USER <your_username>@'%' IDENTIFIED BY <decoded base64>;

GRANT ALL PRIVILEGES ON <your_database_name.>* TO <your_username>@'%';

FLUSH PRIVILEGES;
  
This will have the datasources created for all of your microservices up and running.
  
--> Now, please direct yourself to the microservices folder, there are different folders for each env. And within those are the microservices defined, for the application manifest, the db env variables and the service.
  To deploy them together, run kubectl apply -f ./<foldername>. ex: kubectl apply -f ./staging.
The namespaces have been defined in the manifest, so you can directly run them and it'll be deployed onto their respective namespaces. Repeat this each folder.
  To check if our application is up and running, run **kubectl port-forward <podname> <local-port>:<pod-port>**
  
--> Now, need to deploy, grafana and prometheus for monitoring purpose. The prometheus folder has all the manifests defined, so all you need to do is, run:
  kubectl apply -f ./prometheus/manifests. This will deploy and monitoring application in the monitoring namespace, and the exporter to export metrics.
  **kubectl port-forward <grafana-pod-name> <local-port>:3000 -n monitoring**. After running this, you should be able to access grafana.
--> The datasource for Prometheus should already be added, if run into an error, edit the URL to "http://prometheus-operated.monitoring.svc:9090". Go to explore, select Prometheus datasource and from there you can navigate to different namespaces available and check pod healths and other metrics.
  
