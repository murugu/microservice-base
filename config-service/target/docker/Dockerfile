FROM anapsix/alpine-java:8
VOLUME /tmp
## add git ssh private key
#RUN mkdir -p /root/.ssh
#ADD git-key/davita-config /root/.ssh/id_rsa
#RUN chmod 700 /root/.ssh/id_rsa
##TODO make git repo url more generic, externalize
#RUN echo -e "Host bitbucket.org\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config
ADD config-service-0.0.1-SNAPSHOT.jar app.jar
RUN bash -c 'touch /app.jar'
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]