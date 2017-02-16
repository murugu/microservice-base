node {
    def server = Artifactory.server "davita"
    def rtMaven = Artifactory.newMavenBuild()

    stage 'Build'
        git url: 'https://github.com/murugu/microservices-base.git'

    stage 'Artifactory configuration'
        rtMaven.tool = "maven" // Tool name from Jenkins configuration
        rtMaven.deployer releaseRepo:'libs-release-local', snapshotRepo:'libs-snapshot-local', server: server
        rtMaven.resolver releaseRepo:'libs-release', snapshotRepo:'libs-snapshot', server: server
        def buildInfo = Artifactory.newBuildInfo()

    stage 'Exec Maven'
        rtMaven.run pom: 'pom.xml', goals: 'clean install', buildInfo: buildInfo

    stage 'Publish build info'
        server.publishBuildInfo buildInfo
}
