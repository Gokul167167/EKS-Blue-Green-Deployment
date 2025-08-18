pipeline {
    agent any

    environment {
        STATE_FILE = "${WORKSPACE}/active_cluster.txt"
    }

    stages {
        stage('Switch Traffic via Route53 (Test)') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS Access Key']]) {
                    sh """
                        echo '🔄 Testing traffic switch via Route53'
                        ansible-playbook -i ansible/hosts ansible/route53-switch.yaml
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Route53 traffic switch test completed."
        }
        failure {
            echo "❌ Route53 traffic switch test failed."
        }
    }
}
