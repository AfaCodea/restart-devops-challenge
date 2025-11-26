# AWS Restart DevOps Challenge

Project untuk deployment web server di EC2 menggunakan Terraform sebagai Infrastructure as Code (IaC).

## 📋 Struktur Proyek

```
restart-devops-challenge/
├── main.tf          # Definisi EC2, security group, dan outputs
├── terraform.tf     # Required providers dan versi Terraform
├── user_data.sh     # Script bootstrap untuk EC2 instance
└── hello.html       # File HTML yang akan di-deploy
```

## 🔧 Spesifikasi Teknis

- **AMI**: Amazon Linux 2023 kernel-6.1 (`ami-0559665adb3f0e333`)
- **Instance Type**: t3.micro
- **Region**: ap-southeast-3 (Jakarta)
- **Web Server**: Apache HTTP Server (httpd)
- **IaC Tool**: Terraform

## 🚀 Cara Deployment

### 1. Inisialisasi Terraform

```bash
terraform init
```

### 2. Review Perubahan

```bash
terraform plan
```

### 3. Deploy Infrastructure

```bash
terraform apply
```

### 4. Akses Website

Setelah deployment selesai, Terraform akan menampilkan public IP address:

```
Outputs:
instance_public_ip = "x.x.x.x"
```

Akses website di browser: `http://x.x.x.x`

## 📦 Komponen Utama

### main.tf
- **Provider AWS**: Konfigurasi region dan profile
- **Data Source**: AMI Amazon Linux 2023
- **Security Group**: Mengizinkan traffik HTTP (port 80) dan SSH (port 22)
- **EC2 Instance**: Instance dengan user_data untuk setup otomatis
- **Output**: Public IP address instance

### terraform.tf
- Required Terraform version: >= 1.0
- AWS Provider version: ~> 5.0

### user_data.sh
Script yang dijalankan saat instance pertama kali dibuat:
1. Update system packages
2. Install Apache web server
3. Deploy hello.html sebagai index.html
4. Start dan enable Apache service

### hello.html
Landing page yang menampilkan informasi deployment dengan design modern dan responsive.

## 🔐 Security Group Rules

**Inbound:**
- Port 22 (SSH): 0.0.0.0/0
- Port 80 (HTTP): 0.0.0.0/0

**Outbound:**
- All traffic: 0.0.0.0/0

> ⚠️ **Note**: Untuk production, sebaiknya batasi SSH access hanya dari IP tertentu.

## 🧹 Cleanup

Untuk menghapus semua resources yang telah dibuat:

```bash
terraform destroy
```

## 📝 Notes

- Instance akan otomatis menginstall dan mengkonfigurasi web server saat pertama kali dibuat
- File `hello.html` di-embed langsung ke dalam user_data script
- Perubahan pada `hello.html` akan trigger replacement instance (karena `user_data_replace_on_change = true`)

## 👤 Author

AWS Restart - DevOps Challenge 2025
