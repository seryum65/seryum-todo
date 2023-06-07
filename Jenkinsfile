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

        stage('Build App Docker Image') {
            steps {
                echo 'Building App Image'
                sh 'cat ./todoserver/src/main/resources/application.properties'
                sh 'docker-compose up -d '
                sh 'docker image ls'
                sh 'docker ps'
            }
        }

        stage('Push Image to Dockerhub') {
            steps {
                echo 'Pushing App Image to Dockerhub'

                script {
                    // Log in to Docker Hub
                withDockerRegistry(credentialsId: 'dockerhub') {// some block 
                    }
                sh 'docker push "seryum65/todo_app:latest"'
                sh 'docker push "seryum65/todo_server:latest"'
                sh 'docker stop $(docker ps -a -q)'                
                sh 'docker rm $(docker ps -a -q)'
                sh 'docker image prune -af'

            }
        }
        }

        stage('wait the instance') {
            steps {
                script {
                    echo 'Waiting for the instance'
                    id = sh(script: 'aws ec2 describe-instances --filters Name=tag-value,Values=todo_project Name=instance-state-name,Values=running --query Reservations[*].Instances[*].[InstanceId] --output text',  returnStdout:true).trim()
                    sh 'aws ec2 wait instance-status-ok --instance-ids $id'
                }
            }
        }

        stage('Deploy the App') {
            steps {
                echo 'Deploy the App'
                sh 'ls -l'
                sh 'ansible --version'
                sh 'ansible-inventory --graph'
                ansiblePlaybook become: true, colorized: true, credentialsId: 'seryum', disableHostKeyChecking: true, installation: 'ansible', inventory: 'inventory.txt', playbook: 'todo_project.yml'
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
    
}