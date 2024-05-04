FROM gradle:7.2.0-jdk17 as build
# FROM openjdk:17-slim-buster

# Update base
RUN apt update && apt -y upgrade && apt -y install curl unzip git gettext-base
RUN update-ca-certificates

# Install Docker (script may not be good practice)
RUN curl -fsSL https://get.docker.com -o get-docker.sh
RUN sh get-docker.sh

# Install kubectl binary with curl
RUN apt update
RUN apt install -y curl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

# Install sonar-scanner
ENV SONAR_SCANNER_VERSION=4.7.0.2747
RUN mkdir /downloads/sonarqube -p
RUN cd /downloads/sonarqube
RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip
RUN unzip sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip
RUN mv sonar-scanner-${SONAR_SCANNER_VERSION}-linux /opt/sonar-scanner

ENV PATH $PATH:/opt/sonar-scanner/bin


FROM build AS vulnscan
COPY --from=aquasec/trivy:latest /usr/local/bin/trivy /usr/local/bin/trivy

