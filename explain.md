# NewBee Mall 登录与会话机制说明（小白版）

这个项目的登录是“**经典 HttpSession 方案**”，分两套：后台管理员登录、商城用户登录。

**1) 后台管理员登录（`/admin/login`）**
1. 前端提交 `userName/password/verifyCode` 到 `POST /admin/login`。  
   代码入口：[AdminController.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/admin/AdminController.java)
2. 先校验验证码：验证码对象来自 Session 里的 `verifyCode`（由验证码接口提前写入 Session）。  
   验证码生成入口：[CommonController.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/common/CommonController.java)
3. 调用服务层做账号密码校验，密码会先做 MD5 再查库。  
   服务入口：[AdminUserServiceImpl.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/service/impl/AdminUserServiceImpl.java)
4. 登录成功后写入 Session：`loginUser`、`loginUserId`。
5. 后台拦截器检查 Session 里是否有 `loginUser`，没有就重定向回 `/admin/login`。  
   拦截器：[AdminLoginInterceptor.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/interceptor/AdminLoginInterceptor.java)

**2) 商城用户登录（`/login`）**
1. 前端提交 `loginName/password/verifyCode` 到 `POST /login`。  
   入口：[PersonalController.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/mall/PersonalController.java)
2. 校验商城验证码：从 Session 的 `Constants.MALL_VERIFY_CODE_KEY` 取验证码对象比对。
3. 服务层校验用户名+MD5密码、是否被锁定。  
   服务：[NewBeeMallUserServiceImpl.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/service/impl/NewBeeMallUserServiceImpl.java)
4. 成功后写入 Session：`Constants.MALL_USER_SESSION_KEY`（实际值是 `newBeeMallUser`，保存 `NewBeeMallUserVO`）。
5. 商城登录拦截器在访问购物车/订单/个人中心等路径时检查 `newBeeMallUser`，没有就跳转 `/login`。  
   拦截器：[NewBeeMallLoginInterceptor.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/interceptor/NewBeeMallLoginInterceptor.java)

**3) 会话管理是怎么组织的**
- 核心操作就是 `setAttribute/getAttribute/removeAttribute`。
- 退出登录时删除对应 Session 键（后台删 `loginUser/loginUserId`，商城删 `newBeeMallUser`）。
- 拦截器注册在 MVC 配置中：  
  [NeeBeeMallWebMvcConfigurer.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/config/NeeBeeMallWebMvcConfigurer.java)


这份文档专门解释两件事：

1. 这个项目的登录功能到底是怎么实现的
2. 这个项目是怎么使用 `spring-session-core` 管理会话的


---

## 1. 先用大白话理解“登录”和“会话”

### 1.1 什么叫登录

登录的本质很简单：

- 用户把“账号 + 密码 + 验证码”发给服务器
- 服务器检查这些信息对不对
- 如果都对，服务器就记住“这个浏览器现在是谁”
- 以后这个浏览器再访问需要权限的页面时，服务器就知道他已经登录了

这个“服务器记住你”的过程，就要靠 **会话（Session）**。

### 1.2 什么叫 Session

你可以把 Session 理解成：

> 服务器给每个浏览器准备的一个“小柜子”

登录成功后，服务器会把“当前登录用户的信息”放进这个小柜子里。  
以后浏览器再来访问时，只要还能找到这个小柜子，服务器就知道“你就是刚才那个已经登录的人”。

---

## 2. 这个项目里有两套登录

这个项目不是只有一个登录，而是有两套：

### 2.1 后台管理员登录

- 登录页面：`/admin/login`
- 相关控制器：[`src/main/java/ltd/newbee/mall/controller/admin/AdminController.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/admin/AdminController.java)
- 相关拦截器：[`src/main/java/ltd/newbee/mall/interceptor/AdminLoginInterceptor.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/interceptor/AdminLoginInterceptor.java)

### 2.2 商城普通用户登录

- 登录页面：`/login`
- 注册页面：`/register`
- 相关控制器：[`src/main/java/ltd/newbee/mall/controller/mall/PersonalController.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/mall/PersonalController.java)
- 相关服务：[`src/main/java/ltd/newbee/mall/service/impl/NewBeeMallUserServiceImpl.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/service/impl/NewBeeMallUserServiceImpl.java)
- 相关拦截器：[`src/main/java/ltd/newbee/mall/interceptor/NewBeeMallLoginInterceptor.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/interceptor/NewBeeMallLoginInterceptor.java)

也就是说：

- `/admin/**` 是后台管理员体系
- `/login`、`/personal`、`/orders`、`/shop-cart` 这些是商城用户体系

它们虽然都用了 Session，但保存的数据键名不同，互不混淆。

---

## 3. 验证码是怎么配合登录工作的

验证码相关代码在：

- [`src/main/java/ltd/newbee/mall/controller/common/CommonController.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/common/CommonController.java)

项目里有两个验证码接口：

- 后台验证码：`GET /common/kaptcha`
- 商城验证码：`GET /common/mall/kaptcha`

处理流程是这样的：

1. 浏览器请求验证码图片
2. 服务器生成一个 `ShearCaptcha` 对象
3. 把这个验证码对象放进 Session
4. 再把图片输出给浏览器显示

后台登录时验证码放入：

- `session.setAttribute("verifyCode", shearCaptcha)`

商城登录/注册时验证码放入：

- `session.setAttribute(Constants.MALL_VERIFY_CODE_KEY, shearCaptcha)`

所以验证码并不是只画在页面上，它还被保存在服务器端 Session 里。  
用户提交登录表单时，服务器会把“用户输入的验证码”和“Session 里保存的验证码”做比对。

---

## 4. 后台管理员登录是怎么实现的

这一部分的主入口在：

- [`src/main/java/ltd/newbee/mall/controller/admin/AdminController.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/admin/AdminController.java)

### 4.1 登录接口

后台登录接口是：

- `POST /admin/login`

提交参数有 3 个：

- `userName`
- `password`
- `verifyCode`

### 4.2 后台登录的完整流程

#### 第一步：检查验证码是否为空

如果 `verifyCode` 没传，系统直接返回登录页，并在 Session 里放一个错误信息：

- `errorMsg`

#### 第二步：检查用户名和密码是否为空

如果用户名或密码为空，也直接返回登录页。

#### 第三步：从 Session 里取出验证码并校验

代码会从 Session 中拿到：

- `verifyCode`

然后调用验证码对象的 `verify()` 方法检查用户输入是否正确。

如果不正确，就把错误信息写入 Session，再返回登录页。

#### 第四步：查询管理员账号密码

控制器会调用：

- [`src/main/java/ltd/newbee/mall/service/impl/AdminUserServiceImpl.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/service/impl/AdminUserServiceImpl.java)

它的逻辑是：

1. 先把前端传来的明文密码做 MD5 加密
2. 再去数据库查有没有匹配的管理员

也就是说，数据库里对比的不是原始密码，而是密码的 MD5 值。

#### 第五步：登录成功后，把管理员信息放进 Session

如果数据库中找到了管理员，系统会执行：

- `session.setAttribute("loginUser", adminUser.getNickName())`
- `session.setAttribute("loginUserId", adminUser.getAdminUserId())`

这就表示：

- `loginUser` 保存当前管理员昵称
- `loginUserId` 保存当前管理员主键 ID

从这一刻开始，服务器就认为这个浏览器已经登录后台了。

#### 第六步：重定向到后台首页

成功后跳转到：

- `/admin/index`

如果失败，则把 `errorMsg` 放进 Session，返回登录页。

---

## 5. 后台是怎么判断“你已经登录了”的

相关代码在：

- [`src/main/java/ltd/newbee/mall/interceptor/AdminLoginInterceptor.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/interceptor/AdminLoginInterceptor.java)

这个类是一个 **拦截器**。  
你可以把拦截器理解成：

> 请求真正进入 Controller 之前的门卫

它会检查：

- 当前访问路径是不是 `/admin/**`
- Session 里有没有 `loginUser`

如果没有 `loginUser`，它就认为你没登录，然后：

1. 往 Session 放入 `errorMsg=请登陆`
2. 重定向到 `/admin/login`
3. 阻止后续业务执行

如果有 `loginUser`，就放行。

### 5.1 后台哪些路径会被拦截

拦截器注册在：

- [`src/main/java/ltd/newbee/mall/config/NeeBeeMallWebMvcConfigurer.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/config/NeeBeeMallWebMvcConfigurer.java)

管理员拦截规则大致是：

- 拦截：`/admin/**`
- 放过：`/admin/login`
- 放过静态资源：`/admin/dist/**`、`/admin/plugins/**`

这意味着后台绝大多数页面都要求管理员先登录。

---

## 6. 后台退出登录是怎么实现的

后台退出接口是：

- `GET /admin/logout`

它没有调用 `session.invalidate()`，而是手动删除 Session 中的几个关键字段：

- `loginUserId`
- `loginUser`
- `errorMsg`

删除后，后台拦截器下次再检查 Session，就会发现没有 `loginUser`，于是要求重新登录。

这就是“退出登录”生效的原因。

---

## 7. 商城用户登录是怎么实现的

相关入口在：

- [`src/main/java/ltd/newbee/mall/controller/mall/PersonalController.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/mall/PersonalController.java)

### 7.1 商城登录接口

- `POST /login`

提交参数有：

- `loginName`
- `password`
- `verifyCode`

### 7.2 商城登录的完整流程

#### 第一步：校验参数是否为空

系统会分别检查：

- 用户名是否为空
- 密码是否为空
- 验证码是否为空

这些检查失败时，返回的是统一 JSON 结果，而不是直接跳页面。

#### 第二步：从 Session 中取出商城验证码

控制器会从 Session 读取：

- `Constants.MALL_VERIFY_CODE_KEY`

然后验证用户输入的验证码。

#### 第三步：密码先做 MD5，再去数据库查询用户

控制器调用：

- `MD5Util.MD5Encode(password, "UTF-8")`

再调用用户服务的 `login()` 方法。

真正的登录逻辑在：

- [`src/main/java/ltd/newbee/mall/service/impl/NewBeeMallUserServiceImpl.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/service/impl/NewBeeMallUserServiceImpl.java)

#### 第四步：检查账号是否存在、密码是否正确、账号是否被锁定

服务层会：

1. 用登录名 + MD5 密码查数据库
2. 如果查不到，返回登录失败
3. 如果查到了，但 `lockedFlag == 1`，返回“账号已被锁定”

#### 第五步：把商城用户信息放入 Session

如果登录成功，系统不会直接把数据库实体 `MallUser` 原封不动塞进 Session，  
而是先复制成一个更适合前端展示的对象：

- `NewBeeMallUserVO`

然后放入 Session：

- `httpSession.setAttribute(Constants.MALL_USER_SESSION_KEY, newBeeMallUserVO)`

根据常量定义：

- `Constants.MALL_USER_SESSION_KEY = "newBeeMallUser"`

所以你可以把它理解为：

- Session 中的 `newBeeMallUser` 就代表当前登录的商城用户

#### 第六步：删除验证码 Session

商城登录成功后，代码会把验证码从 Session 中移除，避免重复使用：

- `httpSession.removeAttribute(Constants.MALL_VERIFY_CODE_KEY)`

---

## 8. 商城注册是怎么实现的

商城注册接口是：

- `POST /register`

注册流程和登录很像，也会做这些事：

1. 检查参数
2. 校验验证码
3. 检查用户名是否已存在
4. 密码做 MD5
5. 插入数据库
6. 注册成功后删除验证码 Session

注意一件事：

**注册成功并不等于自动登录。**

也就是说，注册成功后，系统只是把用户存进数据库，并没有自动往 Session 里塞 `newBeeMallUser`。

---

## 9. 商城里是怎么判断用户有没有登录的

相关代码在：

- [`src/main/java/ltd/newbee/mall/interceptor/NewBeeMallLoginInterceptor.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/interceptor/NewBeeMallLoginInterceptor.java)

它检查的是：

- `request.getSession().getAttribute(Constants.MALL_USER_SESSION_KEY)`

也就是检查 Session 里有没有：

- `newBeeMallUser`

如果没有，就重定向到：

- `/login`

如果有，就放行。

### 9.1 商城哪些接口需要登录

在 [`src/main/java/ltd/newbee/mall/config/NeeBeeMallWebMvcConfigurer.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/config/NeeBeeMallWebMvcConfigurer.java) 中配置了拦截范围，主要包括：

- `/goods/detail/**`
- `/shop-cart`
- `/shop-cart/**`
- `/saveOrder`
- `/orders`
- `/orders/**`
- `/personal`
- `/personal/updateInfo`
- `/selectPayType`
- `/payPage`

也就是说，像购物车、下单、订单、个人中心这些操作，都要求用户先登录。

---

## 10. 商城退出登录是怎么实现的

商城退出接口是：

- `GET /logout`

逻辑非常直接：

- `httpSession.removeAttribute(Constants.MALL_USER_SESSION_KEY)`

也就是把 `newBeeMallUser` 从 Session 里删掉。

删掉以后，商城登录拦截器再检查 Session，就会发现没有登录用户，于是把人重定向回登录页。

---

## 11. 为什么购物车数量能“跟着登录状态走”

这部分不是登录本身，但和 Session 很相关。

相关代码在：

- [`src/main/java/ltd/newbee/mall/interceptor/NewBeeMallCartNumberInterceptor.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/interceptor/NewBeeMallCartNumberInterceptor.java)

它做的事情是：

1. 先看当前 Session 里有没有 `newBeeMallUser`
2. 如果有，说明用户已登录
3. 然后去数据库重新查询当前用户购物车商品数量
4. 再把新的数量回写到 Session 里的 `NewBeeMallUserVO`

这样页面上显示的购物车数量就能保持最新。

你可以把它理解成：

> 登录用户信息不只是“有没有登录”，还顺便带了一点页面展示要用的状态数据

---

## 12. 这个项目的 Session 里到底存了什么

### 12.1 后台管理员相关

- `verifyCode`：后台验证码对象
- `loginUser`：管理员昵称
- `loginUserId`：管理员 ID
- `errorMsg`：后台登录失败提示信息

### 12.2 商城用户相关

- `Constants.MALL_VERIFY_CODE_KEY`：商城验证码对象
- `Constants.MALL_USER_SESSION_KEY`：商城当前登录用户对象，实际键名是 `newBeeMallUser`

---

## 13. 这个项目真正使用了 `spring-session-core` 吗

先说结论：

**这个项目引入了 `spring-session-core` 依赖，但从当前代码看，并没有把 Spring Session 的完整能力真正启用起来。**

### 13.1 为什么这么说

我在项目里确认到：

- `pom.xml` 里确实有 `spring-session-core`
- 代码里大量使用的是 `jakarta.servlet.http.HttpSession`

但是我没有看到这些典型 Spring Session 落地配置：

- 没有 `@EnableSpringHttpSession`
- 没有 `SessionRepository` Bean
- 没有 Redis Session 配置
- 没有 JDBC Session 配置
- 没有 `spring.session.store-type=redis` 之类的配置
- 没有 `spring-session-data-redis`、`spring-session-jdbc` 这种更完整的存储实现依赖

所以这个项目目前更像是：

> 引入了 `spring-session-core`，但实际登录态管理仍然主要依赖标准 Servlet 的 `HttpSession`

---

## 14. 那它现在到底是谁在管理 Session

从现有代码行为看，当前项目的会话管理方式是：

### 14.1 由 Servlet 容器提供基础 Session 能力

Spring Boot Web 项目运行时，底层会有 Servlet 容器参与处理请求。  
`request.getSession()`、`HttpSession` 这些能力，本来就是 Servlet 标准的一部分。

换句话说，当前项目的核心做法是：

1. Controller 或 Interceptor 通过 `request.getSession()` 取得会话
2. 用 `setAttribute()` 往里放登录用户信息
3. 用 `getAttribute()` 读取登录用户信息
4. 用 `removeAttribute()` 删除登录用户信息

这是一种非常常见、也很传统的登录方案。

### 14.2 浏览器如何记住这是同一个 Session

虽然代码里没有手写 Cookie 逻辑，但标准 Session 机制通常会依赖浏览器保存一个会话标识，比如常见的 `JSESSIONID`。

你可以简单理解为：

- 服务器给浏览器发一个“会话编号”
- 浏览器下次请求再把这个编号带回来
- 服务器就能找到原来那个 Session

所以，真正“记住登录状态”的不是页面本身，而是：

- 浏览器保存的会话标识
- 服务器保存的 Session 数据

---

## 15. `spring-session-core` 如果真的用起来，会是什么样

如果项目想真正发挥 Spring Session 的作用，通常会这样做：

### 15.1 把 Session 存到外部介质

例如：

- Redis
- 数据库

这样做的好处通常是：

- 服务重启后会话不容易丢
- 多台服务器可以共享登录状态
- 更适合分布式部署

### 15.2 引入对应实现

常见做法不是只引 `spring-session-core`，而是配合这些组件：

- `spring-session-data-redis`
- 或 `spring-session-jdbc`

### 15.3 增加相关配置

例如会有：

- Redis 连接配置
- Spring Session 存储方式配置
- 必要时的 Session 过期时间配置

### 15.4 代码层面通常仍然可以继续用 `HttpSession`

这一点很容易让初学者困惑：

> 真正用了 Spring Session 后，业务代码里依然可能还是写 `HttpSession`

区别不在于 Controller 代码长什么样，  
而在于 **`HttpSession` 背后的存储实现已经被 Spring Session 接管了**。

当前这个项目还没有走到这一步。

---

## 16. 用一句话概括这个项目当前的登录机制

可以记成下面这句话：

> 用户登录成功后，系统把用户信息放进 `HttpSession`；拦截器再通过读取 Session 中的用户信息判断是否已登录。

再补一句关于 `spring-session-core`：

> 项目虽然引入了 `spring-session-core` 依赖，但目前没有看到它被完整配置为 Redis Session 或 JDBC Session，因此当前实际使用的仍然是传统 `HttpSession` 登录态方案。

---

## 17. 给小白的源码阅读顺序

如果你想自己顺着代码继续看，建议按这个顺序：

1. [`src/main/java/ltd/newbee/mall/controller/common/CommonController.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/common/CommonController.java)
2. [`src/main/java/ltd/newbee/mall/controller/admin/AdminController.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/admin/AdminController.java)
3. [`src/main/java/ltd/newbee/mall/service/impl/AdminUserServiceImpl.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/service/impl/AdminUserServiceImpl.java)
4. [`src/main/java/ltd/newbee/mall/interceptor/AdminLoginInterceptor.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/interceptor/AdminLoginInterceptor.java)
5. [`src/main/java/ltd/newbee/mall/controller/mall/PersonalController.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/mall/PersonalController.java)
6. [`src/main/java/ltd/newbee/mall/service/impl/NewBeeMallUserServiceImpl.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/service/impl/NewBeeMallUserServiceImpl.java)
7. [`src/main/java/ltd/newbee/mall/interceptor/NewBeeMallLoginInterceptor.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/interceptor/NewBeeMallLoginInterceptor.java)
8. [`src/main/java/ltd/newbee/mall/interceptor/NewBeeMallCartNumberInterceptor.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/interceptor/NewBeeMallCartNumberInterceptor.java)
9. [`src/main/java/ltd/newbee/mall/config/NeeBeeMallWebMvcConfigurer.java`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/config/NeeBeeMallWebMvcConfigurer.java)
10. [`pom.xml`](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/pom.xml)

---

## 18. 最后帮你做个判断题

如果以后你看到下面这种代码：

```java
httpSession.setAttribute("newBeeMallUser", userVO);
```

你就可以直接理解成：

> 登录成功后，服务器把“当前用户是谁”记进会话里了。

如果你再看到拦截器里有这种代码：

```java
request.getSession().getAttribute("newBeeMallUser")
```

你就可以理解成：

> 系统正在检查这个人有没有登录。

这就是这个项目登录功能最核心的思想。

