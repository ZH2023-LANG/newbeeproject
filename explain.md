# NewBee Mall 登录与会话机制说明（已更新）

本文是最新版本说明，结论基于当前代码与已完成联调结果：  
项目已经实现 **Spring Session + Redis** 会话托管。

---

## 1. 登录功能怎么实现

项目有两套登录：

1. 后台管理员登录（`/admin/login`）
2. 商城用户登录（`/login`）

两套流程本质一致：

1. 前端提交账号、密码、验证码。
2. 后端先校验验证码。
3. 密码做 MD5 后查库校验身份。
4. 登录成功后把用户信息写入 `HttpSession`。
5. 后续请求由拦截器检查 Session 中是否存在登录标记。

关键代码：

- 后台登录入口：[AdminController.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/admin/AdminController.java)
- 商城登录入口：[PersonalController.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/mall/PersonalController.java)
- 后台拦截器：[AdminLoginInterceptor.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/interceptor/AdminLoginInterceptor.java)
- 商城拦截器：[NewBeeMallLoginInterceptor.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/interceptor/NewBeeMallLoginInterceptor.java)

---

## 2. Session 里存了什么

后台管理员会话：

- `loginUser`：管理员昵称
- `loginUserId`：管理员 ID
- `verifyCode`：后台验证码文本
- `errorMsg`：登录失败提示

商城用户会话：

- `newBeeMallUser`：商城用户 VO（登录态）
- `mallVerifyCode`：商城验证码文本

注意：验证码现在存的是 **字符串**，不是 `ShearCaptcha` 对象。  
这样在 Redis Session 下序列化更稳定。

验证码代码：

- [CommonController.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/common/CommonController.java)

---

## 3. 项目如何使用 spring-session-core 管理会话

### 3.1 依赖层

当前项目通过以下依赖实现 Redis 会话托管：

- `spring-boot-starter-data-redis`
- `spring-session-data-redis`

配置文件：

- [pom.xml](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/pom.xml)

### 3.2 配置层

会话改造关键配置：

- `spring.session.store-type=redis`
- `spring.session.redis.namespace=spring:session:newbee-mall`
- `spring.session.redis.flush-mode=on_save`
- `server.servlet.session.timeout=120m`
- Redis 连接参数：`spring.data.redis.*`

配置文件：

- [application.properties](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/resources/application.properties)

### 3.3 序列化层

新增了 Spring Session 默认 Redis 序列化器：

- Bean 名：`springSessionDefaultRedisSerializer`
- 实现：`GenericJackson2JsonRedisSerializer`

代码文件：

- [SessionRedisConfig.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/config/SessionRedisConfig.java)

### 3.4 业务层理解

业务代码仍使用 `HttpSession` API（`setAttribute/getAttribute/removeAttribute`），  
但底层存储已由 Spring Session 接管到 Redis。  
这就是 Spring Session 的典型用法。

---

## 4. 怎么证明改造真的成功

只“能登录”不够，需要满足下面几项：

1. 登录后 Redis 出现 `spring:session:newbee-mall:*` 键。
2. 应用重启后，不关闭浏览器仍能保持登录态。
3. 验证码错误分支和正确分支都正常。
4. 退出登录后受保护页面会被重定向到登录页。

你这次反馈“验证成功”，说明改造链路已经跑通。

---

## 5. 一句话总结（答辩可用）

本项目登录功能采用“验证码 + 账号密码校验 + 拦截器鉴权”的标准流程；  
会话管理已从默认容器 Session 升级为 Spring Session + Redis，业务层继续使用 `HttpSession` 接口，底层会话数据由 Redis 持久化与共享。

