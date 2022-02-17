
在 [mailbyms/msbuild](https://github.com/mailbyms/docker-msbuild) 基础上增加 sonar-scanner(增加 openjdk 11)
> Visual Studio (2019) 对应的 MSBuild 工具，.NET Framework, .NET Core, C#, F#, C++, and web 项目

## 注意
- Dockerfile 里从网络 ADD 文件太慢，可以下载到本地后，直接 ADD 本地文件
- 没有自定义 CMD，不保存后台运行，没有 docker-compose.yml

## 独立运行
`docker run --rm -it -v c:\src:c:\src mailbyms/msbuild-sonar:2019 cmd`

# drone 流水线配置
commands 说明：
> 1. 镜像带的 .net Framework 版本是 4.7.2。先把项目原来的 .net Framework 版本定义，由 4.6.2 改为 镜像里的 4.7.2
> 2. nuget 安装项目的依赖库  
> 3. SonarScanner 的 begin，`YOUR_PROJECT_KEY` 和 `YOUR_PROJECT_REPO_SHORT_NAME` 要替换为实际值；custom_ding_token 是可选的，用于 SonarQube 回调发送钉钉消息；  
> 4. MSBuild 编译项目  
> 5. SonarScanner 的 end

```
steps:
  - name: 编译及 Sonar 代码分析
    image: mailbyms/msbuild-sonar:2019
    pull: if-not-exists
    settings:
      sonar_host:
        from_secret: sonar_host
      sonar_token:
        from_secret: sonar_token
      # optional, for sonarqube webhook
      custom_ding_token:
        from_secret: dingtalk_token
    commands:
      - gci -r -include "App.config","*.csproj"| foreach-object { $a = $_.fullname; ( get-content $a ) | foreach-object { $_ -replace "4.6.2","4.7.2" }  | set-content $a }
      - nuget restore
      - SonarScanner.MSBuild.exe begin /k:"YOUR_PROJECT_KEY" /n:"YOUR_PROJECT_REPO_SHORT_NAME" /d:sonar.login=$env:PLUGIN_SONAR_TOKEN /d:sonar.host.url=$env:PLUGIN_SONAR_HOST /d:sonar.analysis.dingtalktoken=$env:PLUGIN_CUSTOM_DING_TOKEN
      - MSBuild.exe  /t:Rebuild
      - SonarScanner.MSBuild.exe end /d:sonar.login=$env:PLUGIN_SONAR_TOKEN
```
