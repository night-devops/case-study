# Case Studies

- [x] AWS üzerine küçük bir Kubernetes Cluster’ı kurulması <br>
  **[aws-kubernetes-cluster](/aws-kubernetes-cluster)** altında bulabilirsiniz.
- [x] Kubernetes üzerine bir Jenkins kurulması <br>
  **[aws-kubernetes-jenkins](/aws-kubernetes-jenkins)** altında bulabilirsiniz.
- [x] Docker Container’ı üzerinde çalışan “Hello World” dönen basit bir .NET uygulaması yazılması ve GitHub üzerine koyulması <br>
  **[HelloWorld](/HelloWorld)** altında bulabilirsiniz.
- [x] Jenkins üzerinde oluşturacağımız Jenkins Job’ı ile GitHub üzerindeki basit uygulamanın build edilip Kubernetes’e deploy edilmesi <br>
  **[aws-kubernetes-jenkins-helloworld](/aws-kubernetes-jenkins-helloworld)** altında bulabilirsiniz.
- [ ] 5 Dakikada 1 çalışan Kubernetes Cron Job’ı ile Kubernetes üzerinde bulunan “Hello World” dönen uygulamamız’a yük altında bırakılması ve uygulamamızın cpu bazlı scale up - scale down olması <br>
- [ ] Sonarcube entegrasyonu ile kod kalite ve test coverage metriklerin kontrol edilmesi <br>
- [x] Süreçlerin küçük bir döküman üzerinde anlatılması, yararlandığımız araçların ve scriptlerin paylaşılması <br>
  **README.md** dosyasında yapılanları bulabilirsiniz.
- [x] Monitoring için nelere dikkat edilmeli? Alarm mekanizması nasıl kurulmalı? <br>

---

## 1. AWS üzerine Kubernetes Cluster’ı kurulması

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AWS üzerinde Kubernetes Cluster kurma işlemi boyunca yapacak olduğumuz işlemleri sırasıyla aşağıda bulabilirsiniz. Yapmış olduğum çalışma ile alakalı kodlar [aws-kubernetes-cluster](/aws-kubernetes-cluster) klasöründe bulunmaktadır.

### Vagrant

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Yapacak olduğumuz bütün çalışmalarda uygun geliştirme ortamı sağlamak ve bu ortamın tekrardan kullanılabilir olmasını sağlamak için çalışmalarımızı [Vagrant](https://www.vagrantup.com/) kullanarak gerçekleştireceğiz.
- Kullanılacak Default VagrantBox <br>
<img src="/notes-img/vagrant-box-list.png"/>

- Paket güncelleme veya yükleme işlemlerinden sonra *Vagrant* file içerisinden VM Restart işlemi için [Vagrant Reload Plugin](https://github.com/aidanns/vagrant-reload) kullanılacaktır.

### KOPS

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Yapmış olduğum araştırmalar sonucunda AWS üzerinde Kubernetes yönetimi için 16 farklı araç bulunmakta --> [Kubernetes on Amazon Web Services](https://github.com/kubernetes/community/blob/master/sig-aws/kubernetes-on-aws.md). Fakat bu araçları karşılaştırdığımda sektörde en çok kullanılan, kullanımı rahat ve topluluğu geniş olan [KOps](https://github.com/kubernetes/community/blob/master/sig-aws/kubernetes-on-aws.md) ile işlemlerimizi gerçekleştireceğiz.

- [Kubernetes Picking the Right Solution](https://kubernetes.io/docs/setup/pick-right-solution/)

**KOps**'u yüklemeye ve kullanmaya başlamadan önce ***AWSCLI*** ve ***KUBECTL*** araçlarını yüklememiz gerekiyor.

- [Install AWSCLI via pip](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- [Install Kubernetes Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Install KOps](https://github.com/kubernetes/kops/blob/master/docs/install.md)

Ek olarak KOps için AWS üzerinde kullanacak olduğumuz servisler için AWSCLI kullanmak yerine Terraform ile ilerleyeceğiz.

- [Install Terraform](https://github.com/robertpeteuil/terraform-installer)

Yukarıdaki kurulum işlemleri tamamlandıktan sonra(*Vagrant ile otomatik olarak kurulacaktır*) AWS Hesabı üzerinden ***trendyol.kops*** adında erişim tipi *Programmatic Access* olan bir **IAM USER** oluşturulur. **KOps** ile *AWS Hesabı* üzerinde işlem yapabilmek için ***trendyol.kops*** kullanıcısının aşağıdaki yetkiler tanımlanmalıdır. [KOps Setup IAM User](https://github.com/kubernetes/kops/blob/master/docs/aws.md#setup-iam-user)

    AmazonEC2FullAccess
    AmazonRoute53FullAccess
    AmazonS3FullAccess
    IAMFullAccess
    AmazonVPCFullAccess

**Not** : Yukarıdaki IAM User oluşturma işlemleri *Terraform* veya *awscli* üzerinden gerçekleştirilebilir, fakat tek kullanım olacağından console üzerinden yapılmıştır.

Kullanıcı oluşturulduktan sonra *[aws-kubernetes-cluster/aws-kops](/aws-kubernetes-cluster/aws-kops)* klasörü altında **trendyol.kops** *access-key* ve *access-secret-key* bilgilerini içeren **.aws** klasörü oluşturulur. <br>

Tüm bu işlemler tamamlandıktan sonra `baris@barislinux:~/aws-kubernetes-cluster$ vagrant up` ile çalışma ortamı ayağı kaldırılır.
> Vagrant ile oluşturulan VM'de
> 1. AWSCLI yüklenip, VM içerisinde `/home/vagrant` altına ***/aws-kubernetes-cluster/aws-kops*** atındaki **.aws** klasörü kopyalanmıştır.
> 2. Kubectl yüklenmiştir.
> 3. KOps yüklenmiştir.
> 4. Terraform yüklenip, VM içerisinde `/vagrant` altına ***/aws-kubernetes-cluster/aws-kops*** altındaki **terraform-scripts** klasörü kopyalanmıştır.
> 5. VM ayağa kalktıktan sonra `baris@barislinux:~/aws-kubernetes-cluster$ vagrant ssh` ile VM'e bağlanılır.

1. **KOps** kullanarak oluşturcak olduğumuz Kubernetes Cluster'ın durumunu(State) kayıt altına almak için **AWS S3** Servisi üzerinde 1 tane **S3 Bucket** oluşturacağız.

```sh
# Terraform Kullanarak
vagrant@ubuntu-xenial:~$ cd /vagrant/terraform_scripts
vagrant@ubuntu-xenial:/vagrant/terraform_scripts$ terraform init
vagrant@ubuntu-xenial:/vagrant/terraform_scripts$ terraform plan
vagrant@ubuntu-xenial:/vagrant/terraform_scripts$ terraform apply -var 'user_name=barisgece' -auto-approve

# KOPS_STATE için oluşturmuş olduğumuz S3 Bucket bilgisi ortam değişkenlerine eklenir
vagrant@ubuntu-xenial:/vagrant/terraform_scripts$ export KOPS_STATE_STORE=s3://$(sed -e 's#.*=\ \(\)#\1#' <<< `terraform output`)
vagrant@ubuntu-xenial:/vagrant/terraform_scripts$ cd ~

# Bütün islemler tamamlanip VM'i kapatacağımız zaman KOps delete işleminden sonra  `terraform destroy -auto-approve` ile S3 Bucket silinir.

# NOT: terraform_scripts'i shared folder altından kaldırmadık. Çünkü işimiz tamamlandığında VM'i kapatsak bile tfstate file lokalimizde bulunur.
```

```sh
# AWSCLI ile Bucket oluşturmak 
vagrant@ubuntu-xenial:~$ aws s3api create-bucket \
    --bucket trendyol-aws-k8s-poc-state-store \
    --region us-east-1

# AWSCLI ile S3 Bucket Versioning aktif hale getirmek
vagrant@ubuntu-xenial:~$ aws s3api put-bucket-versioning \
    --bucket trendyol-aws-k8s-poc-state-store \
    --versioning-configuration Status=Enabled

# KOPS_STATE için oluşturmuş olduğumuz S3 Bucket bilgisi ortam değişkenlerine eklenir
vagrant@ubuntu-xenial:~$ export KOPS_STATE_STORE=s3://trendyol-aws-k8s-poc-state-store
```

1. Cluster için yeni bir SSH Private key oluşturmalıyız. Aşağıdaki işlem sonrası **~/.ssh** altında **id_rsa** dosyası oluşur.

```sh
vagrant@ubuntu-xenial:~$ echo -e "\n" | ssh-keygen -t rsa -q -N ""
# Veya
vagrant@ubuntu-xenial:~$ ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -q -N ""
```

2. KOps 1.6.2 sürümünden itibaren, node keşiflerinde **gossip-based cluster** desteği gelmiştir. Bizde DNS tanımlamaları yapmadan bu altyapı ile ilerleyeceğiz. Burada dikkat edilmesi gereken kısım cluster ismiminiz sonu **k8s.local** ile bitmeli.

3. Yukarıdaki işlemlerden sonra Cluster oluşturmamız için gerekli adımlar tamamlanmış olup, aşağıdaki komut ile kubernetes cluster oluşturulur.

```sh
vagrant@ubuntu-xenial:~$ kops create cluster \
                --name trendyol.k8s.local \
                --node-count 2 \
                --zones us-east-1a \
                --node-size m4.large \
                --master-size m4.large \
                --state ${KOPS_STATE_STORE} \
                --topology private \
                --networking weave \
                --yes
```

4. KOps create cluster işlemi bitidikten sonra aşağıdaki gibi bir sonuç alacağız.<br>
<img src="/notes-img/kops_create_cluster.png"/>

5. AWS Console üzerinden oluşturalan EC2 Instances<br>
<img src="/notes-img/kops_aws_instance.png"/>

6. `vagrant@ubuntu-xenial:~$ kubectl get nodes` ile nodeları kontrol edebilirsiniz.(*EC2 Status passed olana kadar beklemeliyiz*)<br>
<img src="/notes-img/kops_kubectl_get_nodes.png"/>

7. `vagrant@ubuntu-xenial:~$ kops validate cluster` ile cluster'ımızın istenilen şekilde oluşup oluşmadığını kontrol edebilirsiniz.<br>
<img src="/notes-img/kops_validate_cluster.png"/>

8. `vagrant@ubuntu-xenial:~$ kubectl -n kube-system get po` ile bütün sistem komponentlerini listeleyebilirsiniz.<br>
<img src="/notes-img/kops_kubesystem_get_po.png"/>

9. Default olarak Kubernetes Dashboard UI yüklü değildir. Oluşturmuş olduğumuz Cluster'a Web arayüzü üzerinden erişmek için aşağıdaki komut ile UI deployment işlemini gerçekleştiririz.

```sh
vagrant@ubuntu-xenial:~$ kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
```

10. **gossip-based cluster** oluşturduğumuzdan `kubectl cluster-info` komutu ile hostname bilgisini buluruz. https://hostname/ui ile erişim sağlarız. Erişimi ELB üzerinden tanımlanmış public IP(DNS) ile erişiriz.<br>
<img src="/notes-img/kubectl_cluster_info.png"/>

11. Dashboard UI login işlemi yapabilmek için aşağıdaki KOps komutu çalıştırılır. Kullanıcı: Admin
<img src="/notes-img/kube_ui.png"/>

```sh
vagrant@ubuntu-xenial:~$ kops get secrets kube --type secret -oplaintext
Using cluster from kubectl context: trendyol.k8s.local
#Admin Pass
MDHl2vRMy5fkuYiMiPHKLKCNU339hrxRExsfsrse
```

12. Dashboard UI login olabilmek için aşağıdaki KOps komutu çalıştırılır.
<img src="/notes-img/Kube_dash_token.png"/>

```sh
vagrant@ubuntu-xenial:~$ kops get secrets admin --type secret -oplaintext
Using cluster from kubectl context: trendyol.k8s.local
#Token
nCpDFkb7XR3pkty5fkuYiMiPHKLKCNU339hrxRExsfsrse
```

13. Kubernetes Cluster
<img src="/notes-img/kube_dash_cluster.png"/>

14. `kops get trendyol.k8s.local -o yaml` ile oluşturulmuş olan cluster'ın yaml dosyası çıkarılır.<br>
Not : cluster.yaml hakkında daha detaylı bilgi için benim destek aldığım dokumanlar -- > [cluster.go](https://github.com/kubernetes/kops/blob/master/pkg/apis/kops/cluster.go) - [cluster_spec.md](https://github.com/kubernetes/kops/blob/master/docs/cluster_spec.md) - [cluster-example.yaml](https://github.com/kubernetes/kops/blob/master/docs/apireference/examples/cluster/cluster.yaml) - [manifest](https://github.com/kubernetes/kops/blob/master/docs/manifests_and_customizing_via_api.md)

15. Oluşturduğumuz Cluster'ı silmek için aşağıdaki komut çalıştırılır. **Dikkat!!!** - KOps ile oluşturulan herşey silinir.
 
```sh
vagrant@ubuntu-xenial:~$ kops delete cluster --name trendyol.k8s.local --yes
```

16. Cluster State için oluşturulan S3 Bucket'ı silmek için aşağıdaki komut çalıştırılır. 

```sh
vagrant@ubuntu-xenial:~$ cd /vagrant/terraform_scripts
vagrant@ubuntu-xenial:~$ terraform destroy -auto-approve
```

17. Bütün silme işlemlerinden sonra VM'den çıkılır. Aşağıdaki komut ile VM kapatılır veya silinir. 

```ssh
# Kapat
baris@barislinux:~/aws-kubernetes-cluster$ vagrant halt
# Sil
baris@barislinux:~/aws-kubernetes-cluster$ vagrant destroy
```

---

## 2. Jenkins on Kubernetes

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Kubernetes üzerinde Jenkins çalıştırma işlemi boyunca yapacak olduğumuz işlemleri sırasıyla aşağıda bulabilirsiniz. Yapmış olduğum çalışma ile alakalı kodlar [aws-kubernetes-jenkins](/aws-kubernetes-jenkins) klasöründe bulunmaktadır.

:warning: Birinci Case Study(Kubernetes on AWS)'de yapılan manuel işlemlerin hepsi burada da yapılmalı, yukarıdaki işlemler yapıldıktan sonra aşağıdakiler yapılır.

### Install Docker

- [Install Docker from a Package](https://docs.docker.com/install/linux/docker-ce/ubuntu/#upgrade-docker-ce) <br> 
https://download.docker.com/linux/ubuntu/dists/ sayfasına erişilerek kullanılan Ubuntu Versiyonu seçilir. Biz Vagrant Base Box olarak Ubuntu - **Xenial** kullanıyoruz. Xenial seçildikten sonra **pool/stable/** sayfasına erişilir ve işlemci mimarimize uygun olan paket(*amd64*) seçilerek, Vagrantfile içerisindeki **InstallDocker** scriptinde olduğu gibi yükleme işlemi gerçekleştirilir. *Not: Vagrant ile otomatik olarak yükleniyor*

### Terraform ile AWS IAM_User oluşturulur

**create_iam_user.tf** ile AWS üzerinde **trendyol-ecr** adında **AmazonEC2ContainerRegistryFullAccess** yetkisi olan bir kullanıcı oluşturulacak ve  *terrafom local-exec* ile *aws_access_key_id* ve *aws_secret_access_key* bilgileri *.aws* klasörü altındaki *config* ve *credentials* dosyalarına eklenecektir.

```sh
vagrant@ubuntu-xenial:/vagrant/terraform_scripts/1_iam_user$ terraform init
vagrant@ubuntu-xenial:/vagrant/terraform_scripts/1_iam_user$ terraform plan
vagrant@ubuntu-xenial:/vagrant/terraform_scripts/1_iam_user$ terraform apply -var 'user_name=barisgece' -auto-approve

# Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
# Outputs:
# access_key = AKIAIIJJRTY
# access_secret_key = JONqeeesiidXZ3DIy

# NOT : Bütün islemler tamamlanip VM'i kapatacağımız zaman KOps delete işleminden sonra sırası ile 2_ecr_repo, 1_iam_user, 0_s3_bucket
# klasörleri altında `terraform destroy -auto-approve` ile terraform ile oluşturulan servisler silinir.
```

### Terraform ile AWS ECR Repo oluşturulur

**create_ecr_repo** ile AWS üzerinde **trendyol-jenkins** adında bir Docker Repository oluşturulacak ve *terrafom local-exec* ile **Docker Login** işlemleri yapılacaktır.

```sh
# Get - Login Key : aws ecr get-login --no-include-email --region us-east-1 --profile trendyol-ecr
# Login : sudo docker login -u AWS -p $KEY
```

```sh
vagrant@ubuntu-xenial:/vagrant/terraform_scripts/2_ecr_repo$ terraform init
vagrant@ubuntu-xenial:/vagrant/terraform_scripts/2_ecr_repo$ terraform plan
vagrant@ubuntu-xenial:/vagrant/terraform_scripts/2_ecr_repo$ terraform apply -var 'user_name=barisgece' -auto-approve

# Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
# Outputs:
# ecr_repository_arn = arn:aws:ecr:us-east-1:765584129419:repository/trendyol-jenkins
# ecr_repository_name = trendyol-jenkins
# ecr_repository_register_id = 765584129419
# ecr_repository_url = 765584129419.dkr.ecr.us-east-1.amazonaws.com/trendyol-jenkins

# NOT : Bütün islemler tamamlanip VM'i kapatacağımız zaman KOps delete işleminden sonra sırası ile 2_ecr_repo, 1_iam_user, 0_s3_bucket
# klasörleri altında `terraform destroy -auto-approve` ile terraform ile oluşturulan servisler silinir.
```

Terraform ile dosya hiyerarşisini aşağıdaki gibi kurup çalıştırabilirsiniz, fakat terraform bir planda bir provider'a izin vermekte. 

```sh
Error: provider.aws: multiple configurations present; only one configuration is allowed per provider
```

```sh
├── aws-kubernetes-jenkins
└── terraform_scripts
    ├── create_0tf_s3_bucket.tf
    ├── create_1tf_iam_user.tf
    ├── create_2tf_ecr_repo.tf
    ├── output.tf
    ├── variable.tf
...
```

Biz **iam_user** oluştururken kullanacağımız *profile* ile **ECR** oluşturuken kullanacağımız *profile* farklı olacağından aşağıdaki şekilde ilerleyeceğiz.

```sh
├── aws-kubernetes-jenkins
└── terraform_scripts
    └── 0_s3_bucket
        ├── create_s3_bucket.tf
        ├── output.tf
        ├── variable.tf
    └── 1_iam_user
        ├── create_iam_user.tf
        ├── output.tf
        ├── variable.tf
    └── 2_ecr_repo
        ├── create_ecr_repo.tf
        ├── output.tf
        ├── variable.tf
...
```

- NOT : Yüklediğiniz Kubernetes versiyon 1.3.0 altında ise Deployment YAML içinde Docker Login Secret için IMAGEPULLSECRET kullanmalısınız.
[Create ECR Image Pull Secret](https://github.com/whereisaaron/kubernetes-aws-scripts/blob/master/create-ecr-imagepullsecret.sh)

### Trendyol-Jenkins Docker image oluşturulur.

Jenkins klasörü altındaki Dockerfile kullanılarak, yeni bir docker image build edeceğiz sonrasında oluşturduğumuz image'ı AWS ECR'a push edeceğiz.

```sh
# Daha önceden terraform ile oluşturulan ecr_repo bilgileri alınmadıysa, aşağıdaki komut ile çekilir.
vagrant@ubuntu-xenial:/vagrant/terraform_scripts/2_ecr_repo$ terraform output
# ecr_repository_arn = arn:aws:ecr:us-east-1:765584129419:repository/trendyol-jenkins
# ecr_repository_name = trendyol-jenkins
# ecr_repository_register_id = 765584129419
# ecr_repository_url = 765584129419.dkr.ecr.us-east-1.amazonaws.com/trendyol-jenkins
```

```sh
# Dockerfile dizinine ulasilir
vagrant@ubuntu-xenial:/vagrant/terraform_scripts/2_ecr_repo$ cd /vagrant/jenkins/

# Asagidaki komut ile Docker Image Build edilir
vagrant@ubuntu-xenial:/vagrant/jenkins$ sudo docker build -t trendyol-jenkins .
vagrant@ubuntu-xenial:/vagrant/jenkins$ sudo docker images

# Build islemi tamamladiktan sonra olusan image tag'lenir.
vagrant@ubuntu-xenial:/vagrant/jenkins$ sudo docker tag trendyol-jenkins:latest 765584129419.dkr.ecr.us-east-1.amazonaws.com/trendyol-jenkins:latest
vagrant@ubuntu-xenial:/vagrant/jenkins$ sudo docker images

#  Asagidaki komut ile Docker Image AWS ECR'a push edilir.
vagrant@ubuntu-xenial:/vagrant/jenkins$ sudo docker push 765584129419.dkr.ecr.us-east-1.amazonaws.com/trendyol-jenkins:latest
```

Docker Push işlemi sonrası AWS Consol üzerinden image kontrolü yapılır.
<img src="/notes-img/docker_ecr_image.png"/>

:warning: Eğer 1.Case'de bulunan KOps ile Cluster oluşturma ile ilgili adımlar gerçekleştirilmediyse, aşağıdaki şekilde ilerleyebilirsiniz.

```sh
# KOPS_STATE için olusturmus oldugumuz S3 Bucket bilgisi ortam degiskenlerine eklenir
vagrant@ubuntu-xenial:~$ cd /vagrant/terraform_scripts/0_s3_bucket
vagrant@ubuntu-xenial:/vagrant/terraform_scripts/0_s3_bucket$ export KOPS_STATE_STORE=s3://$(sed -e 's#.*=\ \(\)#\1#' <<< `terraform output`)
vagrant@ubuntu-xenial:/vagrant/terraform_scripts$ cd ~
```

```sh
# Cluster için yeni bir SSH Private key oluşturmaliyiz. Asağidaki islem sonrasi ~/.ssh altinda id_rsa dosyasi olusur
vagrant@ubuntu-xenial:~$ ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -q -N ""
```

```sh
# KOps ile cluster oluşturun
vagrant@ubuntu-xenial:~$ kops create cluster \
                --name trendyol-jenkins.k8s.local \
                --node-count 1 \
                --zones us-east-1a \
                --node-size m4.large \
                --master-size m4.large \
                --state ${KOPS_STATE_STORE} \
                --topology public \
                --yes

# NOTE : 1.Case'de private network yapmıştık. Burada Public kullandık
```

### Deploy Jenkins

```sh
vagrant@ubuntu-xenial:~$ cd /vagrant/jenkins/
vagrant@ubuntu-xenial:/vagrant/jenkins$ kubectl apply -f jenkins-deployment.yaml
```

### Jenkins Servis oluştur

```sh
vagrant@ubuntu-xenial:/vagrant/jenkins$ kubectl create -f jenkins-service.yaml
```

### Cluster & Node Kontrolü

```sh
# Asagidaki komut ile nodelari kontrol edebilirsiniz.(EC2 Status passed olana kadar beklemeliyiz)
vagrant@ubuntu-xenial:/vagrant/jenkins$ kubectl get nodes

# NAME                            STATUS    ROLES     AGE       VERSION
# ip-172-20-37-163.ec2.internal   Ready     node      50m       v1.9.6
# ip-172-20-41-174.ec2.internal   Ready     node      50m       v1.9.6
# ip-172-20-63-196.ec2.internal   Ready     master    50m       v1.9.6
```

```sh
# Asagidaki komut ile oluturmak istedigimiz Cluster'imizin istenilen sekilde olusup olusmadigini kontrol edebilirsiniz.
vagrant@ubuntu-xenial:/vagrant/jenkins$ kops validate cluster
```

```sh
# Asagidaki komut ile servisleri listeleyebilirsiniz
vagrant@ubuntu-xenial:/vagrant/jenkins$ kubectl get service

# NAME              TYPE           CLUSTER-IP       EXTERNAL-IP        PORT(S)          AGE
# jenkins-service   LoadBalancer   100.65.171.168   a14202eeb8d91...   8080:32519/TCP   43m
# kubernetes        ClusterIP      100.64.0.1       <none>             443/TCP          55m
```

```sh
# Servisleri listeledikten sonra, bir servis hakkinda daha detayli bir bilgi almak icin asagidaki komut calistirilir
vagrant@ubuntu-xenial:/vagrant/jenkins$ kubectl describe services jenkins-service

# Name:                     jenkins-service
# Namespace:                default
# Labels:                   app=jenkins-service
# Annotations:              <none>
# Selector:                 app=jenkins
# Type:                     LoadBalancer
# IP:                       100.65.171.168
# LoadBalancer Ingress:     a14202eeb8d9111e8a1b60e85f35ae58-1902710109.us-east-1.elb.amazonaws.com
# Port:                     <unset>  8080/TCP
# TargetPort:               8080/TCP
# NodePort:                 <unset>  32519/TCP
# Endpoints:                100.96.1.4:8080,100.96.2.3:8080
# Session Affinity:         None
# External Traffic Policy:  Cluster
# Events:
#   Type    Reason                Age   From                Message
#   ----    ------                ----  ----                -------
#   Normal  EnsuringLoadBalancer  45m   service-controller  Ensuring load balancer
#   Normal  EnsuredLoadBalancer   45m   service-controller  Ensured load balancer
```

### Jenkins Erisim

**jenkins-service** describe edildikten sonra http://a14202eeb8d9111e8a1b60e85f35ae58-1902710109.us-east-1.elb.amazonaws.com:8080 üzerinden *Jenkins* erişim sağlanır.
<img src="/notes-img/jenkins.png"/>

```sh
# Default olarak Kubernetes Dashboard UI ve Monitoring yüklü degildir.  

vagrant@ubuntu-xenial:/vagrant/jenkins$ kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

vagrant@ubuntu-xenial:/vagrant/jenkins$ kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/monitoring-standalone/v1.7.0.yaml
```

```sh
# gossip-based cluster olusturdugumuzdan komutu ile hostname bilgisini buluruz ve https://hostname/ui ile Dasboard'a erişim saglariz. Erişimi ELB üzerinden tanımlanmış public IP(DNS) ile erişiriz.

vagrant@ubuntu-xenial:/vagrant/jenkins$ kubectl cluster-info
# Kubernetes master is running at https://api-trendyol-jenkins-k8s--ji1bgh-1287530381.us-east-1.elb.amazonaws.com
# Heapster is running at https://api-trendyol-jenkins-k8s--ji1bgh-1287530381.us-east-1.elb.amazonaws.com/api/v1/namespaces/kube-system/services/heapster/proxy
# KubeDNS is running at https://api-trendyol-jenkins-k8s--ji1bgh-1287530381.us-east-1.elb.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

```sh
# Dashboard ve Heapster erisim icin gerekli keyleri cekmek icin asagidaki komut kullanilir
vagrant@ubuntu-xenial:/vagrant/jenkins$ kops get secrets kube --type secret -oplaintext
# Using cluster from kubectl context: trendyol-jenkins.k8s.local
# Admin Pass
# RsQlbpNh6q5fqcQToNmI3UGw4daImFkF

vagrant@ubuntu-xenial:/vagrant/jenkins$  kops get secrets admin --type secret -oplaintext
# Using cluster from kubectl context: trendyol-jenkins.k8s.local
# Token
# 6IU55evQRW9upjAo3xhFU5J26z5wdfA2
```

### Destroying

- AWS üzerinde oluşturduğumuz Cluster silinir. <br>

```sh
vagrant@ubuntu-xenial:~$ kops delete cluster --name trendyol-jenkins.k8s.local --yes
```

- Terraform ile olusturula **ecr_repo**, **iam_user** ve **s3_bucket** yazildigi sırada silinir.<br>

```sh
vagrant@ubuntu-xenial:~$ cd /vagrant/terraform_scripts/2_ecr_repo/
vagrant@ubuntu-xenial:/vagrant/terraform_scripts/2_ecr_repo$  terraform destroy -auto-approve

vagrant@ubuntu-xenial:/vagrant/terraform_scripts/2_ecr_repo$ cd /vagrant/terraform_scripts/1_iam_user/
vagrant@ubuntu-xenial:/vagrant/terraform_scripts/1_iam_user$ terraform destroy -auto-approve

vagrant@ubuntu-xenial:/vagrant/terraform_scripts/1_iam_user$ cd /vagrant/terraform_scripts/0_s3_bucket/
vagrant@ubuntu-xenial:/vagrant/terraform_scripts/0_s3_bucket$ terraform destroy -auto-approve
```

- Vagrant VM Kapat ve Sil <br>

```sh
# Kapat
baris@barislinux:~CaseStudy/aws-kubernetes-jenkins$ vagrant halt

# Sil
baris@barislinux:~CaseStudy/aws-kubernetes-jenkins$ vagrant destroy
```

---

## 3. Hello World App

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Uygulama, 32 karakterli Random 100000 string üretiyor, daha sonra paralel olarak bu 100000 stringi işleyip onların MD5 özetini alıyor. Bir amacı olan program değil, kubernetes scale-up, scale-down işlemlerini rahat yapabilmek için CPU tüketiminin fazla olması hedeflenerek geliştirilmiştir.

- [HelloWorld GitHub Repo](https://github.com/night-devops/HelloWorld)
- [Bu Projedeki Link](/HelloWorld)

### Pre-Requests

- [.NET Core 2.1 SDK or later](https://www.microsoft.com/net/download/archives)
- [Visual Studio Code](https://code.visualstudio.com/download)
- [C# for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-vscode.csharp)

```sh
# HelloWord.csproj dizinine erişildikten sonra aşağıdaki komut ile uygulamayı çalıştırabilirsiniz
dotnet run HelloWorld.csproj
```

---

## 4. Jenkins Job Deployment

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Jenkins üzerinde oluşturacağımız **Jenkins Job’ı** ile GitHub Repo'da bulunan *HelloWorld* uygulamasının *build* edilip *Kubernetes’e deploy* edilmesi süreci boyunca yapılan işlemleri aşağıda bulabilirsiniz. Yapmış olduğum çalışma ile alakalı kodlar [aws-kubernetes-jenkins-helloworld](/aws-kubernetes-jenkins-helloworld) klasöründe bulunmaktadır.

### Vagrantfile içersine eklenenler

- Java 8 yükleme
- Mono - CakeBuild çalıştırabilmek için bağımlı olunan paketler
- Jenkins yükleme ve çalıştırma
- Jenkins initialAdminPassword'ün /app klasörü altına JenkinsPass.txt içerisine atanması

### Jenkins Configuration

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;VM oluştuktan sonra http://localhost:8080 linkine erişim sağlanarak Jenkins aşağıdaki resimdeki gibi bir sayfa gelip gelmediği kontrol edilir.<br>
<img src="/notes-img/jenkins/unlock-jenkins.png"/>

Eğer yukarıdaki resimdeki gibi ekran geliyorsa `baris@barislinux:~/aws-kubernetes-jenkins-helloworld$ vagrant ssh` yapıp VM'e bağlanılır. Aşağıdaki komut ile Jenkins baslangıç şifresi /var/lib/jenkins/secrets/initialAdminPassword altından çekilir. *Not : Vagrant yüklenirken Jenkins initialAdminPassword'ünü /app klasörü altına JenkinsPass.txt içerisine atacaktır*

```sh
vagrant@ubuntu-xenial:~$ sudo cat /var/lib/jenkins/secrets/initialAdminPassword
# 24063ec2df1346a0b108e2005fe33b26
```

Bir sonraki adımda gelen ekranda suggested plugin seçilerek popüler pluginler yüklenir.<br>
<img src="/notes-img/jenkins/jenkins-customize.png"/> <br>
<img src="/notes-img/jenkins/suggested_plugins.png"/> 

Sonraki adımda gelen ekran ile Admin kullanıcısı oluşturulur.<br>
<img src="/notes-img/jenkins/jenkins_create_admin.png"/> 

Bu işlemler sonrası Jenkins Kullanıma hazır olacaktır.<br>
<img src="/notes-img/jenkins/jenkins_ready.png"/> 

Daha sonra http://localhost:8080/pluginManager/ sayfasına erişilerek aşağıdaki pluginler indirilir ve VM Restart edilir.

- Blue Ocean
- Blue Ocean Pipeline Editor
- Blue Ocean Core JS

```sh
# Restart VM
vagrant@ubuntu-xenial:~$ sudo shutdown -r now
```

Jenkins Hazır <br>
<img src="/notes-img/jenkins/welcome_jenkins.png"/> 

Jenkins Build Deploy işlemlerini Jenkinsfile üzerinden yöneteceğiz ve Jenkinsfile içersinde node bilgisini trendyol-hello-world olarak set ettiğimizden Jenkins Master Node'a aşağıdaki gibi label ekleriz.
<img src="/notes-img/jenkins/jenkins_node_label_1.png"/> <br>
<img src="/notes-img/jenkins/jenkins_node_label_2.png"/> <br>
<img src="/notes-img/jenkins/jenkins_node_label_3.png"/> 

Jenkins kurulurken oluşturulan *jenkins* user'ın sudo ile yapmış olduğu işlemler sırasında sorun yaşamamsı için aşağıdaki işlemlerin yapılması gereklidir.

```sh
vagrant@ubuntu-xenial:~$ sudo visudo

# Yukarıdaki komut /etc/sudoers dosyasını açacaktır. Dosya aşağıdaki gibi editlenir.

# ...
# # User privilege specification
# root    ALL=(ALL:ALL) ALL
# jenkins ALL=(ALL) NOPASSWD: ALL
# ...
```

Bütün bu işlemler sonrası **Create New Jobs**'a tıklayara HelloWord App Job oluşturabiliriz.
<img src="/notes-img/jenkins/create_multibranch_pipeline.png"/> <br>
<img src="/notes-img/jenkins/helloworld-branch-sources.png"/>

Bu işlem sonra Jenkins Github ile sync olup ilk seferde otomatik olarak build alır.
<img src="/notes-img/jenkins/jenkins_stage_view.png"/>

:star: Geliştirdiğimiz Uygulama ve Planlanan Uygulama Deployment işlemi aşağıdaki gibidir.

Jenkins üzerinde Job tetiklendiğinde

- Jenkinsfile : Jenkins remote repo üzerinden belirtilen branch'in son durumunu Jenkins Sunucusuna çeker.
- Jenkinsfile : build.sh scriptini çalıştırır.
- build.sh : CakeBuild için gerekli komponentleri yükler ve CakeBuild'i çalıştırır.
- build.cake : Uygulamayı build eder ve artifact file oluşturur.
- Jenkinsfile : Yazmış olduğumuz Dockerfile'ı kullanarak yeni Docker Image oluşturur.
- Jenkinsfile : Oluşturulan Image AWS ECR üzerine push edilir.
- Kubernetes Image Update olduğu için AutoDeploy işlemini gerçekleştirir.

<img src="/notes-img/jenkins/jenkins_success.png"/> <br>
<img src="/notes-img/jenkins/ecr_success.png"/>

:warning: Eğer AWS üzerinde ECR_Repo, IAM_USER, S3_Bucket, Kubernetes Cluster oluşmamışsa aşağıdaki şekilde oluşturabilirsiniz.

#### Terraform Scriptleri çalıştırılır

Case 1 ve Case 2 de uyguladığımız gibi sırasıyla **create_s3_bucket.tf** **create_iam_user.tf** **create_ecr_repo.tf** terraform scriptleri çalıştırılır.

#### Kubernetes Cluster oluşturulur

Case 1 ve Case 2 de uyguladığımız gibi fakat burada [HelloWorld/kubernetes](/kubernetes) altında bulunan yaml dosyaları kullanılarak yaratılır.

---

## 5 Kubernetes Cron Job’ı Scale up - Scale down olması

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Konu hakkında araştırmalarımı ve denemelerimi yaptım fakat tam olarak sonuca ulaşamadığım için akışı paylaşmadım.

Destek aldığım dokümanlar

- [Jobs - Run to Completion](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/)
- [Running automated tasks with cron jobs](https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/)
- [Kubernetes App Auto-scaling](https://github.com/aws-samples/aws-workshop-for-kubernetes/tree/master/03-path-application-development/304-app-scaling)
- [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Use a Service to Access an Application in a Cluster](https://kubernetes.io/docs/tasks/access-application-cluster/service-access-application-cluster/)

---

## 6. Sonarcube

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bu konuyu yetiştiremedim.

---

## 7. Monitoring için nelere dikkat edilmeli? Alarm mekanizması nasıl kurulmalı ?

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sistemlerde monitoring altyapısı application ve infrastructre seviyesinde 2'ye ayırabiliriz. Application seviyesinde uygulamanın anlık aldığı istek sayısı, yapılan işlem süreleri, throw exception saayıları, yaşanan hatalar ve sayıları gibi metrikler toplanarak ElasticSearch, NLog gibi altyapılarda loglanıp merkezi bir alarm sistemi üzerinden belirlenen durumlara göre alarmlar üretilmeli. Infrastructure seviyesinde bakıldığında CPU, MEMORY, Network Input-Output ve Disk IO gibi metrikler incelenerek anlık olarak Prometheus+Graphana gibi altyapılarla anlık monitoring imkanı sağlanmalıdır. Ayrıca bu ortamlarda da belli thresholdlar belirlenip merkezi alarm sistemi üzerinden alarmlar üretilmeli.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Alarm mekanizmaları oluşan alarmları alarm tipine göre kolaylıkla sorumlu ekibe escale edebileceğiniz. Aynı tip hataları gruplayabileceğiniz ve hata tiplerine göre korelasyon yapabileceğiniz bir alt yapı olmalıdır. Ayrıca, birden fazla farklı platformları incelemek için log mekanızmalarınız olabilir. Alarm sisteminin bu tip araçlarla kolay entegrasyon sağlayabiliyor olması lazım.

