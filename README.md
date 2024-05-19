# kubernetes-aws-azure-hello-world

## Required toolset

* `terraform`
* `op` (1password cli)
* `pmv` (gitlab's pmv)

## Repository structure

Repository directories:

* `/bin/`- directory consists of useful scripts that make working with the code a bit easier:
  * `/bin/aws/creds.sh`- script using `op` and `pmv` binaries to read and use AWS credentials along with MFA token to create MFA authenticated session in AWS
  * `/bin/aws/assume_role.sh`- script assuming AWS IAM role- helps out assuming role allowing for various access levels in EKS cluster
* `/charts/` consists of helm chart used in the project, that are not available in any official chart registry
* `/terraform/`- directory with terraform code used in this project
  * `/terraform/aws/`- terraform root module managing AWS EKS along with underlying network
  * `/terraform/azure/`- terraform root module managing Azure AKS along with underlying network
  * `/terraform/remote_state_bucket/`- terraform root module managing S3 state bucket along with DynamoDB lock table (it also manages itself- meaning it's remote state is also being kept in the bucket it manages)
* `/values/`- directory with helm chart value files structured in similar fashion as Puppet's hiera (allows to deduplicate configuration by grouping data from most generic to most specific configuration aspects)
  * `/values/common.yaml`- common settings for `hello-world` helm release
  * `/values/aws/common.yaml`- setting specific only for AWS EKS `hello-world` deployment
  * `/values/azure/common.yaml`- setting specific only for Azure AKS `hello-world` deployment

## Solution Architecture

### Remote state `/terraform/remote_state_bucket/`

The code allows to create secure S3 state bucket encrypted with customer managed KMS key along with DynamoDB database for terraform state locking.

### Networking structure (both `/terraform/azure/` and `/terraform/aws/`)

The networking structure consists of something that could be called as 2 tier application. The subnets are grouped into two types:

* public ones - subnets where application is getting exposed to open world
* private ones - subnets where chosen kubernetes solution resides

Because of the differences between AWS and Azure networking, both implementations are different.

* in AWS VPC consists of 3 public and 3 private subnets (6 in total), each out of 3 in different Availability Zone. Public subnets are connected to AWS Internet Gateway, private subnets are connected to NAT Gateway. Traffic gets directed into VPC or into gateways with two routing tables (public and private for each of the types of subnets).
* in Azure VirtualNetwork consists only of two subnets - web and app, that's because Azure doesn't have concept of Availability Zone. With this said, the design principle is similar to AWS. Web subnets are exposed to public internet, app are supposed to be hidden and resources in them shouldn't be reachable from external network. Traffic coming from app subnets is routed through NAT gateway assigned to them. Security is enforced on SecurityGroup level, where web subnet is allowing access over 443 and 80 port from all sources and app is allowing access only from web.

### AWS `/terraform/aws/`

The private subnets described above are utilised by the EKS cluster spanned across all 3 AZs and 3 private networks. In order to limit credit usage, cluster uses spot instances as the worker nodes.

Application Loadbalancer is created on demand based on the Ingress resources needs. This is happening with aws-application-loadbalancer controller, which is granted access to AWS APIs, uses tagged public subnets to create application gateway exposing traffic from EKS.

Cluster uses RBAC to IAM integration allowing mapping IAM accesses to entities in cluster (e.g. ServiceAccounts).

Cluster uses customer managed KMS key for Secret (kubernetes resources) encryption.

Cluster is reachable through dedicated role named `hello-world`.

### Azure `/terraform/azure/`

The app subnet is used to host AKS cluster.

Application Gateway resides in web subnet.
