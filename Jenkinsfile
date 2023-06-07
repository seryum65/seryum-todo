pipeline {
    agent any
    tools {
        terraform 'terraform'
    }
    environment {
        PATH=sh(script:"echo $PATH:/usr/local/bin", returnStdout:true).trim()
        AWS_REGION = "us-east-1"
    }

    stages {

        stage('Create Infrastructure for the App') {
            steps {
                echo 'Creating Infrastructure for the App on AWS Cloud'
                dir('./todo_project'){
                sh 'ls -l'
                sh 'terraform init'
                sh 'terraform apply --auto-approve'
                }

            }
        }

        stage('Build App Docker Image') {
            steps {
                echo 'Building App Image'
                script {
                    env.DB_HOST = sh(script: 'terraform output -raw node_private_ip', returnStdout:true).trim()
                }
                sh 'echo ${DB_HOST}'
                sh 'envsubst < applications-properties-template > ./todoserver/src/main/resources/application.properties'
                sh 'cat ./todoserver/src/main/resources/application.properties'
                sh 'docker-compose up --build '
                sh 'docker image ls'
            }
        }

        stage('Push Image to Dockerhub') {
            steps {
                echo 'Pushing App Image to Dockerhub'

                script {
                    // Log in to Docker Hub
                    withDockerRegistry([credentialsId: 'dockerhub', url: '']) {
                    }
                sh 'docker push "seryum65/todo_app:latest"'
                sh 'docker push "seryum65/todo_server:latest"'

            }
        }
        }

        stage('wait the instance') {
            steps {
                script {
                    echo 'Waiting for the instance'
                    id = sh(script: 'aws ec2 describe-instances --filters Name=tag-value,Values=todo_CI-CD Name=instance-state-name,Values=running --query Reservations[*].Instances[*].[InstanceId] --output text',  returnStdout:true).trim()
                    sh 'aws ec2 wait instance-status-ok --instance-ids $id'
                }
            }
        }

        stage('Deploy the App') {
            steps {
                echo 'Deploy the App'
                sh 'cd todo_project'
                sh 'ls -l'
                sh 'ansible --version'
                sh 'ansible-inventory --graph'
                ansiblePlaybook become: true, colorized: true, credentialsId: 'seryum', disableHostKeyChecking: true, installation: 'ansible', inventory: 'inventory_aws_ec2.yml', playbook: 'todo_project.yml'
             }
        }

        
        // stage('Destroy the infrastructure'){
        //     steps{
        //         timeout(time:5, unit:'DAYS'){
        //             input message:'Approve terminate'
        //         }
        //         sh """
        //         docker image prune -af
        //         terraform destroy --auto-approve
        //         aws ecr delete-repository \
        //           --repository-name ${APP_REPO_NAME} \
        //           --region ${AWS_REGION} \
        //           --force
        //         """
        //     }
        // }

    }
    
    post {
        always {
            echo 'Deleting all local images'
            sh 'docker image prune -af'
        }
        failure {

            echo 'Deleting Terraform Stack due to the Failure'
                sh 'terraform destroy --auto-approve'
        }
    }
}