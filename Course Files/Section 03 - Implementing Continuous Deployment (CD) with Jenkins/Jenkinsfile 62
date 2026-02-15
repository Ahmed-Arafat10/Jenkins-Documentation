pipeline {
    agent any

    stages {
        stage('Deploy') {
            steps {
                echo 'Deploying ...'
                script {
                    env.MY_VAR = sh(script: 'date', returnStdout: true)
                }
            }
        }

        stage('E2E') {
            steps {
                echo 'E2E ...'
                echo "MY_VAR is: ${env.MY_VAR}"
                echo "MY_VAR is: $env.MY_VAR" // This syntax should work as well
            }
        }
    }
}
