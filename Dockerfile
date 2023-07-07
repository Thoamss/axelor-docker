#
#Building the WAR
#
FROM gradle:6.9.4-jdk8 AS builder
RUN apt-get update && apt-get -y install vim
RUN mkdir open-suite-webapp
COPY . /open-suite-webapp
COPY build.gradle /open-suite-webapp
WORKDIR /open-suite-webapp
RUN sed -i 's/\r$//' gradlew
RUN vim gradlew -c 'set fileformat=unix' -c 'wq' 
RUN ./gradlew clean build

#
#Using the WAR with Tomcat
#
FROM tomcat:8.5-jdk8
WORKDIR /usr/local/tomcat/webapps
COPY --from=builder open-suite-webapp/build/libs/axelor-erp-6.4.17.war ROOT.war
WORKDIR /home
RUN mkdir open-suite-webapp
WORKDIR /home/open-suite-webapp
COPY --from=builder open-suite-webapp/src/main/resources/application.properties application.properties
WORKDIR /usr/local/tomcat/bin
RUN set JAVA_OPTS=%JAVA_OPTS% -Daxelor.config=/home/open-suite-webapp/application.properties
EXPOSE 8080
#CMD ["startup.sh"]