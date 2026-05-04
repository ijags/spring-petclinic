# Spring PetClinic — CI/CD Pipeline Assignment

## Overview

This project demonstrates a full CI/CD pipeline for the Spring PetClinic application using **Jenkins**, **Docker**, and **JFrog Artifactory**.

The pipeline automates the software delivery lifecycle: compiling source code, running tests, packaging a runnable Docker image, publishing build artifacts to JFrog Artifactory.

Repository: https://github.com/ijags/spring-petclinic

---

## Repository Structure

```
spring-petclinic/
─ Jenkinsfile
─ Dockerfile
─ pom.xml  (uses JCenter for pulling dependencies)
─ README_Jenkins.md
```

---

## Pipeline Stages

The Jenkins pipeline consists of the following stages:

1. Build : Compiles the source code using `mvnw clean compile`

2. Test : Runs unit tests and publishes JUnit results

3. Package Jar : Packages the application as a runnable JAR (`mvnw package`)

4. Configure JFrog CLI & Maven : Configures JFrog CLI with server credentials and Maven resolve/deploy repositories

5. Publish JAR to JFrog Deploys the JAR artifact to JFrog Artifactory (`sample-maven-release` / `sample-maven-snapshot`)

6. Build Docker Image Builds and tags the Docker image using the project `Dockerfile`

7. JFrog Docker Login Authenticates Docker with the JFrog container registry

8. Push Docker Image to JFrog : Pushes the tagged Docker image to `sample-docker-local` in Artifactory

9. Deploy to Dev Placeholder stage for downstream deployment to a Dev environment

10. JFrog Xray automatically scans pushed images for CVEs and block downloads based on security policies.

---

## Prerequisites

### Client (Windows)

- Jenkins installed and running on Windows
- JDK 17+
- Maven installed
- Docker Desktop installed and running
- JFrog CLI installed

### JFrog Artifactory

- A JFrog Cloud instance (trial)
- The following repositories created:
  - sample-maven-release — Maven repository for release JARs
  - sample-maven-snapshot — Maven repository for snapshot JARs
  - sample-docker-local — Docker repository for container images

### Jenkins Credentials

A Jenkins credential of type 'Username with Password':

- ID: `jfrog-creds`
- Username: email
- Password: API Token

---

## How to Run the Pipeline

1. Fork or clone this repository into your GitHub account
2. In Jenkins, create a new Pipeline job
3. Under Pipeline, set Definition to `Pipeline script from SCM`
4. Set SCM to `Git` and provide your repository URL
5. Set Script Path to `Jenkinsfile`
6. Click Save and then Build Now

---

## Running the Docker Image Locally

### Pull from JFrog Artifactory

```
# Step 1 - Docker Login
docker login trialsh57yr.jfrog.io -u <your-email> -p <your-api-token>

# Step 2 - Pull the image
docker pull trialsh57yr.jfrog.io/sample-docker-local/spring-petclinic:latest
```

### Run the Container

```
docker run -d -p 9090:8080 --name petclinic trialsh57yr.jfrog.io/sample-docker-local/spring-petclinic:latest
```

Then open your browser at: **http://localhost:9090**

Note: Port `9090` is used here to avoid conflicts with Jenkins is running on `8080` on my local. You may change this to any available port.

---
