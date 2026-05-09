# Spring Session (Redis) 改造计划与执行清单

## 目标

把当前项目从“默认 HttpSession（容器内存）”升级为“Spring Session + Redis 托管会话”，并保证后台与商城登录流程可用。

## 当前现状

1. 项目依赖里有 `spring-session-core`，但没有 Redis/JDBC 存储配置。
2. 登录态通过 `HttpSession` 读写，拦截器通过 Session 键判断是否登录。
3. 验证码当前直接把 `ShearCaptcha` 对象存进 Session，这在 Redis Session 场景下不够稳健。

## 详细步骤

### 步骤 1：依赖改造

1. 在 `pom.xml` 引入 `spring-boot-starter-data-redis`。
2. 在 `pom.xml` 引入 `spring-boot-starter-session-data-redis`。
3. 移除单独 `spring-session-core` 直接依赖（由 starter 统一管理版本与传递依赖）。

### 步骤 2：配置改造

1. 在 `application.properties` 增加 Redis 连接配置：
   `spring.data.redis.host`、`spring.data.redis.port`、`spring.data.redis.password`（可空）、`spring.data.redis.database`。
2. 启用 Spring Session Redis 存储：
   `spring.session.store-type=redis`。
3. 配置 Session 生命周期与命名空间：
   `server.servlet.session.timeout`、`spring.session.redis.namespace`、`spring.session.redis.flush-mode`。

### 步骤 3：Session 序列化配置

1. 新增配置类（`SessionRedisConfig`）。
2. 声明 `springSessionDefaultRedisSerializer` Bean，使用 `GenericJackson2JsonRedisSerializer`。
3. 目标是避免默认 JDK 序列化带来的可读性与兼容性问题。

### 步骤 4：验证码会话改造（关键）

1. `CommonController` 不再把 `ShearCaptcha` 对象存到 Session。
2. 改为只存验证码字符串（`captcha.getCode()`）。
3. `AdminController` 与 `PersonalController` 登录/注册校验改为字符串比对（`equalsIgnoreCase`）。
4. 这样在 Redis Session 中更稳定，减少对象序列化风险。

### 步骤 5：登录态流程保持不变

1. 继续使用现有 `HttpSession` API（`setAttribute/getAttribute/removeAttribute`）。
2. 拦截器逻辑无需大改，重点是会话存储后端由容器内存切换到 Redis。

### 步骤 6：验证与回归

1. 编译验证：`mvn -DskipTests compile`。
2. 功能验证：
   - 后台登录、登出
   - 商城登录、注册、登出
   - 拦截器重定向逻辑
   - 验证码正确/错误分支
3. Redis 验证：检查是否出现 `spring:session:*` 键。

### 步骤 7：回滚方案

1. 回退 `pom.xml` 的 Redis Session 依赖。
2. 删除 `application.properties` 的 `spring.session.*` 与 `spring.data.redis.*`。
3. 删除 `SessionRedisConfig` 类。
4. 验证恢复默认 HttpSession 行为。

## 执行状态

- [x] 已写入计划文档
- [x] 依赖改造
- [x] 配置改造
- [x] 序列化配置
- [x] 验证码会话改造
- [ ] 编译验证（受本机 Maven 仓库权限与外网下载限制影响，未完成）
- [x] 结果复盘
