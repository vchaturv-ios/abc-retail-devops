FROM tomcat:9.0-jdk11-openjdk

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file to webapps folder
COPY target/abc-retail.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
