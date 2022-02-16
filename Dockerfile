# docker build -t mailbyms/msbuild-sonar:2019 .

# phase 0
FROM mcr.microsoft.com/windows/servercore:1903
SHELL ["powershell.exe", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ADD .\\openjdk-11+28_windows-x64_bin.zip openjdk11.zip
#ADD https://download.java.net/openjdk/jdk11/ri/openjdk-11+28_windows-x64_bin.zip openjdk11.zip

ADD .\\sonar-scanner-msbuild-5.5.2.43124-net46.zip sonar-scanner-msbuild.zip
#ADD https://github.com/SonarSource/sonar-scanner-msbuild/releases/download/5.5.2.43124/sonar-scanner-msbuild-5.5.2.43124-net46.zip sonar-scanner-msbuild.zip

RUN Expand-Archive openjdk11.zip -DestinationPath C:\openjdk;
RUN Expand-Archive sonar-scanner-msbuild.zip -DestinationPath c:\sonar-scanner-msbuild;


# phase 1
FROM mailbyms/msbuild:2019
LABEL maintainer=mailbyms@gmail.com description="MSBuild 2019 Sonar"

COPY --from=0 /openjdk /openjdk
COPY --from=0 /sonar-scanner-msbuild /sonar-scanner-msbuild

RUN SETX /M Path "%Path%;C:\\tools;C:\\openjdk\\jdk-11\\bin;C:\\sonar-scanner-msbuild" \
  && SETX /M JAVA_HOME C:\\openjdk\\jdk-11" 