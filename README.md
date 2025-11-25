# AWS Restart DevOps Challenge

Infrastructure as Code (IaC) menggunakan Terraform untuk deploy EC2 instance dengan Apache web server.

## 📋 Prerequisites

- AWS CLI terinstall dan terkonfigurasi
- Terraform terinstall
- Git & GitHub account
- SSH key pair

## 🚀 Setup

### 1. AWS Configuration

```bash
aws configure --profile restart
```

Masukkan:
- AWS Access Key ID
- AWS Secret Access Key
- Region: `ap-southeast-1`

### 2. Terraform Deployment

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply infrastructure
terraform apply
```

### 3. SSH Setup

Generate SSH key pair (jika belum ada):
```bash
ssh-keygen -t rsa -b 2048 -f restart-devops -N ""
```

Daftarkan public key ke EC2:
1. Login ke AWS Console
2. EC2 → Instances → Pilih `restart-web-server`
3. Connect → EC2 Instance Connect
4. Jalankan:
```bash
mkdir -p ~/.ssh
echo "YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

Test SSH:
```bash
ssh -i restart-devops ec2-user@YOUR_EC2_IP
```

## 🔄 GitHub Actions CI/CD

### Setup GitHub Secrets

Untuk mengaktifkan automated deployment, tambahkan secrets berikut di GitHub repository:

**Settings → Secrets and variables → Actions → New repository secret**

1. **SSH_PRIVATE_KEY**
   ```bash
   cat restart-devops
   ```
   Copy seluruh isi private key (termasuk `-----BEGIN` dan `-----END`)

2. **EC2_HOST**
   ```
   47.129.186.51
   ```
   (Ganti dengan IP EC2 Anda)

3. **EC2_USER**
   ```
   ec2-user
   ```

### Workflow

Workflow akan otomatis berjalan ketika:
- Push ke branch `main`
- Manual trigger via GitHub Actions tab

Workflow akan:
1. Checkout code
2. Setup SSH connection
3. Deploy `hello.html` ke EC2
4. Restart Apache web server
5. Verify deployment

## 📁 Struktur Proyek

```
.
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions workflow
├── main.tf                     # Terraform main configuration
├── terraform.tf                # Terraform provider configuration
├── hello.html                  # Web content
├── restart-devops              # SSH private key (jangan commit!)
└── restart-devops.pub          # SSH public key
```

## 🌐 Resources Created

- **Security Group**: `restart-web-server-sg`
  - Port 80 (HTTP)
  - Port 22 (SSH)
  
- **EC2 Instance**: `restart-web-server`
  - Type: t3.micro
  - AMI: Amazon Linux 2
  - Web Server: Apache (httpd)

## 📝 Useful Commands

```bash
# Get EC2 public IP
terraform output instance_public_ip

# Get all outputs
terraform output

# Test web server
curl http://$(terraform output -raw instance_public_ip)

# SSH to EC2
ssh -i restart-devops ec2-user@$(terraform output -raw instance_public_ip)

# Destroy infrastructure
terraform destroy
```

## 🔒 Security Notes

**JANGAN commit file berikut ke Git:**
- `restart-devops` (private key)
- `*.tfstate` (Terraform state files)
- `.terraform/` directory
- AWS credentials

Pastikan file `.gitignore` sudah mencakup:
```
# Terraform
.terraform/
*.tfstate
*.tfstate.backup
.terraform.lock.hcl

# SSH Keys
restart-devops
*.pem

# AWS
.aws/
keyscsv/
```

## 📊 Outputs

Setelah `terraform apply`, Anda akan mendapatkan:
- `instance_id`: EC2 instance ID
- `instance_public_ip`: Public IP address
- `instance_public_dns`: Public DNS name
- `web_url`: URL untuk akses web server

## 🎯 Testing

1. **Test Web Server**
   ```bash
   curl http://YOUR_EC2_IP
   ```

2. **Test SSH**
   ```bash
   ssh -i restart-devops ec2-user@YOUR_EC2_IP
   ```

3. **Test GitHub Actions**
   - Edit `hello.html`
   - Commit & push ke branch `main`
   - Cek GitHub Actions tab untuk melihat deployment progress

## 📚 Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
