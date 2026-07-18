FROM tomcat:11-jre21

# ROOT.war => app chạy ở context gốc "/", không còn tiền tố /BE.
COPY target/BE-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
