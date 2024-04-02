acooly-parent
============

# 简介

Acooly框架统一父pom文件，核心组件最新版本也由parent统一管理，统一基础的插件配置，编译配置，基础依赖。

# 框架发布说明

针对独立发布Acooly组件库到自建的nexus仓库的完整说明

## 1. [可选] fork项目

建议从：https://github.com/acooly 去fork整套基础框架和组件库。主要包括6个仓库（其他的没有用到）：

* acooly-parent
* acooly-core
* acooly-components-feature
* acooly-components-business
* acooly-portlets
* openapi-framework

fork完成后，请切换到专用RC分支：5.2.0-202402_YS_RC1

## 2. 准备nexus服务

请准备好开发团队专用的nexus服务，建议3.x版本，请确保nexus服务已经配置好了对应的仓库，用户，角色等。 请确定好发布框架的角色定义，并赋予给对应的用户。

### 2.1 nexus服务地址

发布安装好后，建议采用https方式提供服务，这里假设您已安装配置好服务，访问地址为（nexus3）：`https://nexus.yunshang.com`
，请跟进实际情况替换，这里需要这个地址进行后续的配置。

### 2.2 nexus仓库准备

请准备好本地仓库（默认就OK有）:

1. snapshots：格式为maven2，类型为：hosted,用于发布SNAPSHOT版本的组件
2. releases：格式为maven2，类型为：hosted,用于发布RELEASE版本的组件

### 2.2 nexus账号及权限

以nexus 3.x（2.x类似）为例子(以下两个方案均可)：

1. 最简单的就是admin用户，或则赋予admin角色（`nx-admin`）的用户.
2. 建立可发布的最低权限用户，需要服用用户角色：`nx-deployment`，赋予对应的仓库的发布权限。

> 这里假设建立的账号，用户名：`nexus-deployer`，密码：`nexus-deployer`，请确保账号密码正确，用于后续配置。

## 3. 配置准备

### 3.1 配置maven的settings.xml

建议您参考（以此为基础）本项目下的`maven-settings-acooly.xml`文件，将其拷贝到您的maven的`conf`目录下或替换`settings.xml`
文件，然后修改对应的nexus的账号密码，以及nexus的地址。

关键修改项如下：

**设置账号和密码**

修改发布部署到nexus的账号密码,替换`${nexus.deployment.username}`为前面准备的nexus账号的用户名`nexus-deployer`
；替换`${nexus.deployment.password}`为前面准备的nexus账号的密码`nexus-deployer`。

> 注意：根据maven的规范，这里的账号是用于`mvn deploy`指令时的安全认证。

```xml

<servers>
    <server>
        <id>ys-releases</id>
        <username>${nexus.deployment.username}</username>
        <password>${nexus.deployment.password}</password>
    </server>
    <server>
        <id>ys-snapshots</id>
        <username>${nexus.deployment.username}</username>
        <password>${nexus.deployment.password}</password>
    </server>
</servers>
```

**设置nexus仓库地址**

替换文件中的`${neuxs_url}`为前面准备好的nexus服务地址`https://nexus.yunshang.com`（请跟进实际地址进行替换）

> 注意：该地址只是用于你的工程和本地拉取nexus上的依赖包的配置。

### 3.2 配置发布组件的nexus地址

通过`mvn deploy`打包发布组件到nexus，需要在pom文件中配置`distributionManagement`
来指定发布的nexus地址。我们所有的组件都继承`acooly-parent`的pom文件，所以只需要在`acooly-parent`的pom文件中配置即可。

请拉取`acooly-parent`项目，切换到分支：`5.2.0-202402_YS_RC1`，然后修改`pom.xml`文件，找到`distributionManagement`
节点，修改`http://nexus.acooly.cn`为前面准备好的nexus服务地址`https://nexus.yunshang.com`（请跟进实际地址进行替换）。

```xml
...
<distributionManagement>
    <repository>
        <id>ys-releases</id>
        <name>Acooly Internal Releases</name>
        <url>https://nexus.yunshang.com/repository/releases/</url>
    </repository>
    <snapshotRepository>
        <id>ys-snapshots</id>
        <name>acooly Internal snapshot</name>
        <url>https://nexus.yunshang.com/repository/snapshots/</url>
    </snapshotRepository>
</distributionManagement>
        ...
```

> 特别注意: 请确保上面配置中的repository的id：`ys-releases`和`ys-snapshots`与前面`maven-settings-acooly.xml`中的`server`
> 的`id`一致，否则在发布的时候找不到对应的账号和密码，会认证失败。

完成对`acooly-parent`的修改后，提交到您的fork的`5.2.0-202402_YS_RC1`分支，然后准备发布。

## 4. 发布组件

上面的准备完成后，你就可以发布各组件库到你的nexus仓库了。首次发布时，需要先发布`acooly-parent`，然后发布`acooly-core`,再发布其他组件。

发布的脚本如下（请提前配置好JAVA_HOME,M2_HOME及对应的PATH环境变量，让mvn命令可正常运行）：

环境变量（windows和MAC类似）：

```properties
# java home,替换为你的JDK主目录
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home
# 替换为你的maven主目录
export M2_HOME=/Users/zhangpu/software/apache-maven-3.3.9
export MAVEN_OPTS="-Xms1024M -Xmx2048m -XX:PermSize=256m -XX:MaxPermSize=512m"
export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH
```

发布脚本：

```shell
mvn -T 1C clean deploy -P acooly -Dmaven.test.skip=true -Dopt=deploy -s /Users/zhangpu/software/apache-maven-3.3.9/conf/settings-acooly.xml'
```

> 注意：-s参数是指定maven的settings.xml文件，这里如果你是maven/conf目录下的名称为`settings.xml`的文件，可以不用指定,否则请指定绝对路径。

至此，你可以拉取各组件工程代码，然后再根目录下执行上面的发布脚本，即可发布到你的nexus仓库。

> 注意：
> 1. 如果存现test模块原因造成发布失败，请在工程根目录下先使用`mvn -N clean install -Dmaven.test.skip=true`命令发布根POM，然后再发布。
> 2. 也可以单独发布某个组件库下面的组件，进入其目录，一样的命令（但需要确保其父POM已经发布过）。

# 版本记录

## v5.2.0-SNAPSHOT.20231208

* 升级部署的nexus仓库地址为nexus3.x的新地址

## v5.2.0-SNAPSHOT

* JDK版本及编译：1.8
* Spring Boot版本：2.3.12.RELEASE

## v5.0.0-SNAPSHOT

* JDK版本及编译：1.8
* Spring Boot版本：2.1.5.RELEASE

## v4.x

* JDK版本及编译：1.8
* Spring Boot版本：1.5.1.RELEASE

## v3.1.0-SNAPSHOT

acooly框架较大功能升级，整合兼容freemarker+jsp作为自适应兼容视图层解决方案，所有组件可封装视图到组件jar包中。

> 所有组件只要是3.1.x版本的即规划为已封装视图到组件中。

* 2015-10-02:发布3.1.0-SNAPSHOT, 升级core为3.1.0,acooly-module-app为1.1.0，升级module-security为3.3.1,升级openapi为2.0.1版本
* 2015-10-15：升级acooly-core为3.1.2版本

## v3.0.0-SNAPSHOT

升级parent版本为SNAPSHOT,以便通过parent动态控制所有组件的升级发布。

* 升级acooly-module-siteim版本为1.0.1；升级acooly-module-lottery版本为1.0.1
* 2015-05-30: 升级siteim为1.0.2（兼容）
* 2015-06-23 升级siteim为1.0.3(兼容)
* 2015-07-07: 升级core为3.0.1(兼容)
* 2015-07-08: 升级siteim为1.0.4(兼容)
* 2015-07-14: 升级core为3.0.2(兼容)
* 2015-07-23: 升级olog为1.2.1(首次加入)
* 2015-08-28: 升级sms为1.4.0(兼容)
* 2015-07-07: 升级core为3.0.3(兼容)
* 2015-09-02: 新增组件acooly-module-caches-v1.0.0
* 2015-09-02: 新增组件acooly-module-app-v1.01
* 2015-09-02: 升级acooly-openapi-sdk版本为v1.1.0
* 2015-09-17: 升级app组件为v1.0.2
* 2015-09-26: 升级core为v3.0.4

## v3.0.0

升级所有的依赖有parent统一使用manage管理；核心组件最新版本也由parent统一管理。
