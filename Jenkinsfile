library(
    identifier: 'pipeline-lib@1.3.1',
    retriever: modernSCM([$class: 'GitSCMSource',
                          remote: 'https://github.com/SmartColumbusOS/pipeline-lib',
                          credentialsId: 'jenkins-github-user'])
)

def image

node ('master') {
    ansiColor('xterm') {
        stage('Checkout') {
            deleteDir()
            env.GIT_COMMIT_HASH = checkout(scm).GIT_COMMIT

            scos.addGitHubRemoteForTagging("SmartColumbusOS/streaming-metrics.git")
        }

        stage ('Build') {
            image = docker.build("scos/streaming-metrics:${env.GIT_COMMIT_HASH}")
        }
    }
}
