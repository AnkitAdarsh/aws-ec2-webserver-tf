pipeline {

    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('jenkins-aws-secret-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-access-key')
    }

    options {
        ansiColor('xterm')
        timeout(time: 20, unit: 'MINUTES')
    }

    stages {

        stage('Notify Start'){
            steps{
                slackSend color: "good", message: "Started applying the Terraform Change with Action as ${action}"
            }
        }

        stage('Code Checkout') {
            steps {
                checkout scm
            }
        }
    
        stage ("Terraform Init") {
            steps {
                sh ("terraform init -reconfigure") 
            }
        }
        
        stage ("Terraform Plan") {
            steps {
                sh ('terraform plan') 
            }
        }

        stage ("Terraform Action") {
            steps {
                echo "Terraform action is --> ${action}"
                sh ('terraform ${action} --auto-approve') 
           }
        }
    }
    post {
	 success{
                slackSend color: "good", message: "Completed applying the Terraform Change with Action as ${action}"
         }
	 failure{
        	slackSend color: "bad", message: "Job Failed while applying the Terraform Change with Action as ${action}" 
	 }
	 aborted{
		slackSend color: "bad", message: "Job was aborted while applying the Terraform Change with Action as ${action}"
	 }
	 cleanup{
		cleanWs()
	 }
    }
}
