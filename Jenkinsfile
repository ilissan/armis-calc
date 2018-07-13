node {
    def mvnHome
    stage('Checkout') { // for display purposes
        // Get some code from a GitHub repository
        git 'https://github.com/ilissan/armis-calc.git'
        // Get the Maven tool.         
        mvnHome = tool 'maven-3.5'
        // Get version from pom
        //def version = pom.version.replace("-SNAPSHOT", ".${currentBuild.number}")
    }
    stage('Build') {
        // Run the maven build
        if (isUnix()) {
            sh "'${mvnHome}/bin/mvn' -Dmaven.test.failure.ignore clean package"
        } else {
            bat(/"${mvnHome}\bin\mvn" -Dmaven.test.failure.ignore clean package/)
        }
    }
    stage('Results') {
        junit '**/target/surefire-reports/TEST-*.xml'
        archive 'target/*.jar'
    }
}