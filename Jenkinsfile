pipeline {
    agent any
    
    environment {
        GOOGLE_APPLICATION_CREDENTIALS = "/var/jenkins_home/gcp-creds.json"
        PROJECT_ID = 'project-f78241dc-4480-4159-8d6'
        REGION = 'us-central1'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/Ghemarc-star/Devops-ansible.git'
                echo "✅ Code checked out"
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
                echo "✅ Terraform init"
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh """
                        terraform apply -auto-approve \
                            -var="project_id=${PROJECT_ID}" \
                            -var="region=${REGION}"
                    """
                }
                echo "✅ GKE cluster created"
            }
        }
        
        stage('Get Node IPs') {
            steps {
                script {
                    sh """
                        gcloud container clusters get-credentials ansible-cluster \
                            --region ${REGION} \
                            --project ${PROJECT_ID}
                        kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}' | tr ' ' '\n' > ansible/inventories/hosts
                    """
                }
                echo "✅ Node IPs saved to Ansible inventory"
            }
        }
        
        stage('Ansible Configure') {
            steps {
                dir('ansible') {
                    sh 'cat inventories/hosts'
                    sh 'ansible-playbook -i inventories/hosts playbooks/install-nginx.yml'
                }
                echo "✅ Ansible configuration complete"
            }
        }
        
        stage('Verify') {
            steps {
                script {
                    def ip = sh(
                        script: "head -1 ansible/inventories/hosts",
                        returnStdout: true
                    ).trim()
                    
                    sh """
                        echo "Waiting for Nginx..."
                        sleep 60
                        curl -s http://${ip} | grep "Hello from Ansible"
                    """
                }
                echo "✅ Website verified!"
            }
        }
    }
    
    post {
        success {
            echo "🎉 Terraform + Ansible pipeline SUCCESS!"
        }
        failure {
            echo "❌ Pipeline FAILED!"
        }
    }
}
