````
-----------------------------------
GitHub Actions : See 47:25 in Video
-> No Need To write anything
-----------------------------------

- Some advanced topics in Jenkins -> shared libraries {not included in internship content}


========
Project:
========

for Booster_CI_CD_Project -> Create CI/CD pipeline using jenkinsfile to deploy simple django web app
                             as a microservice running on docker container locally

    -Requirements:
    -> Create a dockerfile to create a modified image from ubuntu {See Line #160}
    -> Check that everything in Docker container of modified ubuntu image is working fine
    -> Create a salve node in Jenkins Server then link it with Ubuntu Docker container
    -> Create dockerfile in GitHub repo of project that will create a Django image from ubuntu base image
    -> Create a Jenkinsfile that will execute 5 stages {in Readme file of repo}
        Note: Each pipeline from them will have different port (change jenkinsfile $ docker run -p porting for each branch)
    -> Create a multibranch and link it with GitHub repo using git
    -> Create two pipelines {From multibranch} then make sure that they are deployed successfully
    -> check two Django Web apps
    -> Check that created Django docker image is pushed into your Docker Hub Account
    -> Check that a message is sent to slack
    -> Install a plug-in to show statistics of builds in Jenkins Server

    - How to present project -> in a PDF file :
                            -> Put link of repo in your GitHub Account
                            -> Screenshot of successfully pipelines created
                            -> Screenshot of statistics plug-ins
                            -> Screenshot of slack notification when pipelines are deployed
                            -> Screenshot of working Django website
````
