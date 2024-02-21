# Terraform-Ansible-Jenkins Provisioner

This repository contains Terraform scripts to provision a Jenkins server on AWS as an EC2 instance. Ansible playbook is executed as a Terraform "local-exec" provisioner during `terraform apply`. After provisioning, the output will provide you with the link to access the Jenkins server.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

- **Terraform**: Download and install Terraform from [Terraform's official website](https://www.terraform.io/downloads.html).
- **Ansible**: Ensure Ansible is installed and available in your system environment.
- **AWS Account**: You need an AWS account with appropriate permissions to create EC2 instances, IAM roles, security groups, and key pairs.

## Usage

Follow these steps to provision a Jenkins server on AWS:

1. **Clone the Repository**: Clone this repository to your local machine using the following command:
    ```bash
    git clone https://github.com/your-username/terraform-ansible-jenkins.git
    ```

2. **Update Variables**: Navigate to the `terraform` directory and update the variables in the `variables.tf` file as per your requirements. You may want to adjust variables such as `aws_region`, `instance_type`, and `key_name` according to your AWS setup.

3. **Create Key Pair in AWS**: Before running Terraform, create a key pair in AWS EC2 console. Ensure you have the private key corresponding to the key pair saved on your local machine.

4. **Execute Terraform Apply**: Run the following command inside the `terraform` directory:
    ```bash
    terraform apply -var 'private_key_path=/path/to/your/private/key.pem'
    ```

    Make sure to replace `/path/to/your/private/key.pem` with the path to your private key file.

5. **Access Jenkins**: Once the Terraform and Ansible provisioning completes successfully, you will see the URL to access Jenkins in the output. Open the provided URL in your web browser to access the Jenkins dashboard.

6. **Destroy Resources**: After you are done using the Jenkins server, remember to destroy the AWS resources to avoid incurring unnecessary charges:
    ```bash
    terraform destroy -var 'private_key_path=/path/to/your/private/key.pem'
    ```

    Make sure to replace `/path/to/your/private/key.pem` with the path to your private key file.

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please feel free to open an issue or create a pull request.

## License

This project is licensed under the [MIT License](LICENSE). Feel free to modify and distribute it as needed.

---