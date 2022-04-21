# MULTIPASS VM

##### VM: Main Cluster (1x Master, 1x Worker)
```
multipass launch --name mc-master 20.04 -c 2 -m 2G -d 10G
multipass launch --name mc-node1 20.04 -c 1 -m 512M -d 10G

multipass shell mc-master
multipass shell mc-node1

multipass delete mc-master
multipass delete mc-node1
multipass purge
```

##### VM: Backup Cluster (1x Master, 1x Worker)
```
multipass launch --name bc-master 20.04 -c 2 -m 2G -d 10G
multipass launch --name bc-node1 20.04 -c 1 -m 512M -d 10G

multipass shell bc-master
multipass shell bc-node1

multipass delete bc-master
multipass delete bc-node1
multipass purge
```

##### VM: Main Cluster (1x Master, 1x Worker)
```
multipass launch --name geo-master 20.04 -c 2 -m 2G -d 10G
multipass launch --name geo-node1 20.04 -c 1 -m 512M -d 10G

multipass shell geo-master
multipass shell geo-node1

multipass delete geo-master
multipass delete geo-node1
multipass purge
```

##### IP Adresses:
```
ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'
```
##### Replace All IP Addresses in Document
- bc-master: 172.30.67.245
- bc-node1: 172.30.71.219
- mc-master: 172.30.73.2
- mc-node1: 172.30.78.130

# INSTALLATIONS
##### Configure Master Nodes
```
sudo curl -LJO https://raw.githubusercontent.com/srtlkn35/k8s_notes/main/cluster_setup/kubeadm_master.sh
sudo chmod 777 kubeadm_master.sh
sed -i -e 's/\r$//' kubeadm_master.sh
./kubeadm_master.sh

# GENERATE TOKEN
kubeadm token create --print-join-command
```

##### Configure Worker Nodes
```
sudo curl -LJO https://raw.githubusercontent.com/srtlkn35/k8s_notes/main/cluster_setup/kubeadm_worker.sh
sudo chmod 777 kubeadm_worker.sh
sed -i -e 's/\r$//' kubeadm_worker.sh
./kubeadm_worker.sh

# USE GENERATED TOKEN
sudo kubeadm join 172.29.243.125:6443 --token kefjio.nchw1usz7qz684ym --discovery-token-ca-cert-hash sha256:27ff04d988d2e4201b86e583dd5e86df8121ab4a174e98327a7c04bb5eabac70
```

##### Configure POSTGRESQL on Master Nodes
```
sudo curl -LJO https://raw.githubusercontent.com/srtlkn35/k8s_notes/main/postresql_setup/postresql_setup.sh
sudo chmod 777 postresql_setup.sh
sed -i -e 's/\r$//' postresql_setup.sh
./postresql_setup.sh
```

##### Connect POSTGRESQL (1Gi)
```
sudo adduser postgres
sudo usermod -aG sudo postgres

# CONNECT POSTGRESQL POD ON MAIN KUBERNETES CLUSTER
multipass shell mc-master
kubectl exec -it $(kubectl get pods --sort-by=.metadata.creationTimestamp -o jsonpath="{.items[0].metadata.name}") -- /bin/bash
# Connect PSQL
# psql -h localhost -U admin --password -p 5432 postgresdb

# CONNECT POSTGRESQL POD ON BACKUP KUBERNETES CLUSTER
multipass shell bc-master
kubectl exec -it $(kubectl get pods --sort-by=.metadata.creationTimestamp -o jsonpath="{.items[0].metadata.name}") -- /bin/bash
# Connect PSQL
# psql -h localhost -U admin --password -p 5432 postgresdb

# CONNECT POSTGRESQL POD ON GEOBACKUP KUBERNETES CLUSTER
multipass shell geo-master
kubectl exec -it $(kubectl get pods --sort-by=.metadata.creationTimestamp -o jsonpath="{.items[0].metadata.name}") -- /bin/bash
# Connect PSQL
# psql -h localhost -U admin --password -p 5432 postgresdb
```

##### Insert Tables to POSTGRESQL DB
```
# USERNAME: admin
# PASSWORD: test123
kubectl exec -it $(kubectl get pods --sort-by=.metadata.creationTimestamp -o jsonpath="{.items[0].metadata.name}") --  psql -h localhost -U admin --password -p 5432 postgresdb
Password: test123
\q

# SOME SQL COMMANDS (postgres=# )
create table dummy_table(name varchar(20),address text,age int);
insert into dummy_table values('XYZ','location-A',25);
insert into dummy_table values('ABC','location-B',35);
insert into dummy_table values('DEF','location-C',40);
insert into dummy_table values('PQR','location-D',54);
select * from dummy_table;
# update dummy_table set age=50 where name='PQR';
# update dummy_table set age=54,address='location-X';
# update dummy_table set age=30 where name='XYZ' returning age as age_no;
# delete from dummy_table where age=65;
# select * from dummy_table where age <=100;
# drop table if exists dummy_table;
```

##### Barman
```
sudo curl -LJO https://raw.githubusercontent.com/srtlkn35/k8s_notes/main/barman_setup/barman_setup.sh
sudo chmod 777 barman_setup.sh
sed -i -e 's/\r$//' barman_setup.sh
./barman_setup.sh

# Run on Main Cluster Master Node 
# (bmuser@bserver, username: bmuser, password: test123)
# VAR BACKUP_SERVER: bmuser@172.30.67.245
sudo adduser postgres
sudo usermod -aG sudo postgres
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y 2>&1 >/dev/null
ssh-copy-id -i ~/.ssh/id_rsa.pub bmuser@172.30.67.245
ssh bmuser@172.30.67.245 "chmod 600 ~/.ssh/authorized_keys"

# RUN ON BACKUP KUBERNETES CLUSTER MASTER (bmuser@bserver, username: bmuser, password: test123)
# VAR MAIN_SERVER: postgres@172.30.73.2
sudo adduser bmuser
sudo usermod -aG sudo bmuser
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y 2>&1 >/dev/null
ssh-copy-id -i ~/.ssh/id_rsa.pub postgres@172.30.73.2
ssh postgres@172.30.73.2 "chmod 600 ~/.ssh/authorized_keys"

# RUN ON GEOBACKUP KUBERNETES CLUSTER MASTER (bmuser@geobserver)
# VAR BACKUP_SERVER: bmuser@172.30.67.245
sudo adduser bmuser
sudo usermod -aG sudo bmuser
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y 2>&1 >/dev/null
ssh-copy-id -i ~/.ssh/id_rsa.pub bmuser@172.30.67.245
ssh bmuser@172.30.67.245 "chmod 600 ~/.ssh/authorized_keys"
```
