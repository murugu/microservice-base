node {
    def server = Artifactory.server "davita"
    def rtMaven = Artifactory.newMavenBuild()

    stage 'Compile'
        git url: 'https://github.com/murugu/microservice-base.git'
        rtMaven.tool = "maven" // Tool name from Jenkins configuration
        rtMaven.deployer releaseRepo:'libs-release-local', snapshotRepo:'libs-snapshot-local', server: server
        rtMaven.resolver releaseRepo:'libs-release', snapshotRepo:'libs-snapshot', server: server
        def buildInfo = Artifactory.newBuildInfo()
        rtMaven.run pom: 'pom.xml', goals: 'compile', buildInfo: buildInfo
		
    stage 'Unit Test'
    	rtMaven.run pom: 'pom.xml', goals: 'test', buildInfo: buildInfo
    	
    stage 'Build Docker Images'	
    	rtMaven.run pom: 'pom.xml', goals: 'clean install -Dmaven.test.skip=true', buildInfo: buildInfo
        
    stage 'Deploy Docker Images to CITest Environment'	
    	rtMaven.run pom: 'pom.xml', goals: 'clean install -Dmaven.test.skip=true', buildInfo: buildInfo        

    stage 'Run Integration Tests'	
    	server.publishBuildInfo buildInfo

    stage 'Publish Docker Images to Repository'
        server.publishBuildInfo buildInfo
}

stage('Production Deploy approval'){
    input "Deploy to production?"
}

node{
    stage 'Deploy Docker Images to Prod Environment'
        server.publishBuildInfo buildInfo
}        

