# NewBee Mall 项目接口文档

## 1. 文档说明

本文档基于当前项目源码中的全部 `Controller` 实际路由整理，覆盖：

- 后台管理页面路由
- 后台管理数据接口
- 商城前台页面路由
- 商城前台数据接口
- 通用验证码与上传接口

说明：

- 项目本身是 `Spring Boot + Thymeleaf + MyBatis` 的传统单体应用。
- 项目里部分历史接口路径如 `/save`、`/update`、`/delete`、`/list` 并不是严格意义上的 RESTful 命名。
- 本文档仍然统一按 `METHOD /path` 的 RESTful 表达方式书写，并按资源维度组织，便于查阅和联调。

## 2. 基础信息

- 项目类型：`Spring Boot 3.1.0 + Thymeleaf + MyBatis + MySQL`
- 默认端口：`28089`
- 示例访问地址：`http://localhost:28089`
- 默认数据库：`newbee_mall_db`

## 3. 认证与会话规则

### 3.1 后台管理员认证

- 登录成功后写入 Session：
  - `loginUser`
  - `loginUserId`
- 后台拦截范围：`/admin/**`
- 放行路径：
  - `/admin/login`
  - `/admin/dist/**`
  - `/admin/plugins/**`

### 3.2 商城用户认证

- 登录成功后写入 Session：
  - `newBeeMallUser`
- 商城登录拦截路径：
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

### 3.3 验证码 Session Key

- 后台验证码：`verifyCode`
- 商城验证码：`mallVerifyCode`

### 3.4 Spring Session（Redis）托管

- 当前项目已启用：`spring.session.store-type=redis`
- Session 命名空间：`spring:session:newbee-mall`
- Redis 连接配置：`spring.data.redis.*`
- 会话超时：`server.servlet.session.timeout=120m`
- 序列化：`springSessionDefaultRedisSerializer`（`GenericJackson2JsonRedisSerializer`）
- 验证码会话值：已改为字符串存储（不再把 `ShearCaptcha` 对象直接放入 Session）

## 4. 通用返回格式

### 4.1 通用 JSON 包装

大多数 JSON 接口统一返回：

```json
{
  "resultCode": 200,
  "message": "SUCCESS",
  "data": {}
}
```

### 4.2 Result 字段说明

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `resultCode` | `int` | `200` 成功，`500` 失败 |
| `message` | `string` | 返回消息 |
| `data` | `object/array/null` | 业务数据 |

### 4.3 分页结构 PageResult

分页接口的 `data` 一般为 `PageResult`：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `totalCount` | `int` | 总记录数 |
| `pageSize` | `int` | 每页条数 |
| `totalPage` | `int` | 总页数 |
| `currPage` | `int` | 当前页码 |
| `list` | `array` | 当前页数据列表 |

### 4.4 非 Result 返回

下列接口不返回 `Result`：

- 所有页面路由：返回 `text/html`
- 验证码接口：返回 `image/png`
- `POST /admin/profile/password`：返回纯文本
- `POST /admin/profile/name`：返回纯文本
- `GET /saveOrder`：返回重定向

## 5. 全局异常处理

项目存在全局异常处理器：

- 如果请求是 AJAX 或 `application/json`，返回：

```json
{
  "resultCode": 500,
  "message": "异常信息",
  "data": null
}
```

- 如果是普通页面请求，返回模板：
  - `error/error`

## 6. 后台管理接口

### 6.1 管理员登录与个人信息

#### GET `/admin/login`

- 用途：后台登录页
- 认证：否
- 返回：`text/html`

#### POST `/admin/login`

- 用途：后台管理员登录
- 认证：否
- 请求类型：`application/x-www-form-urlencoded`

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `userName` | `string` | 是 | 管理员用户名 |
| `password` | `string` | 是 | 管理员密码 |
| `verifyCode` | `string` | 是 | 后台验证码 |

- 成功结果：重定向到 `/admin/index`
- 失败结果：返回登录页并写入 `errorMsg`

#### GET `/admin`

- 用途：后台首页
- 认证：是
- 返回：`text/html`

#### GET `/admin/`

- 用途：后台首页
- 认证：是
- 返回：`text/html`

#### GET `/admin/index`

- 用途：后台首页
- 认证：是
- 返回：`text/html`

#### GET `/admin/index.html`

- 用途：后台首页
- 认证：是
- 返回：`text/html`

#### GET `/admin/test`

- 用途：后台测试页
- 认证：是
- 返回：`text/html`

#### GET `/admin/profile`

- 用途：管理员个人信息页
- 认证：是
- 返回：`text/html`

#### POST `/admin/profile/password`

- 用途：修改管理员密码
- 认证：是
- 请求类型：`application/x-www-form-urlencoded`

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `originalPassword` | `string` | 是 | 原密码 |
| `newPassword` | `string` | 是 | 新密码 |

- 成功返回：`success`
- 失败返回：纯文本错误信息

#### POST `/admin/profile/name`

- 用途：修改管理员用户名和昵称
- 认证：是
- 请求类型：`application/x-www-form-urlencoded`

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `loginUserName` | `string` | 是 | 登录用户名 |
| `nickName` | `string` | 是 | 昵称 |

- 成功返回：`success`
- 失败返回：纯文本错误信息

#### GET `/admin/logout`

- 用途：管理员退出登录
- 认证：是
- 返回：`text/html`

### 6.2 会员管理

#### GET `/admin/users`

- 用途：会员管理页面
- 认证：是
- 返回：`text/html`

#### GET `/admin/users/list`

- 用途：会员分页列表
- 认证：是
- 返回：`Result<PageResult<MallUser>>`

| Query 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `page` | `int` | 是 | 当前页 |
| `limit` | `int` | 是 | 每页条数 |

#### POST `/admin/users/lock/{lockStatus}`

- 用途：批量禁用/解除禁用会员
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

| Path 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `lockStatus` | `int` | 是 | `0` 解除禁用，`1` 禁用 |

请求体：

```json
[1, 2, 3]
```

### 6.3 轮播图管理

#### GET `/admin/carousels`

- 用途：轮播图管理页面
- 认证：是
- 返回：`text/html`

#### GET `/admin/carousels/list`

- 用途：轮播图分页列表
- 认证：是
- 返回：`Result<PageResult<Carousel>>`

| Query 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `page` | `int` | 是 | 当前页 |
| `limit` | `int` | 是 | 每页条数 |

#### POST `/admin/carousels/save`

- 用途：新增轮播图
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
{
  "carouselUrl": "https://example.com/banner.png",
  "redirectUrl": "https://example.com",
  "carouselRank": 1
}
```

#### POST `/admin/carousels/update`

- 用途：修改轮播图
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
{
  "carouselId": 1,
  "carouselUrl": "https://example.com/banner.png",
  "redirectUrl": "https://example.com",
  "carouselRank": 1
}
```

#### GET `/admin/carousels/info/{id}`

- 用途：查询轮播图详情
- 认证：是
- 返回：`Result<Carousel>`

| Path 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `id` | `int` | 是 | 轮播图 ID |

#### POST `/admin/carousels/delete`

- 用途：批量删除轮播图
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
[1, 2, 3]
```

### 6.4 商品分类管理

#### GET `/admin/categories`

- 用途：分类管理页面
- 认证：是
- 返回：`text/html`

| Query 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `categoryLevel` | `byte` | 是 | 分类级别，`1/2/3` |
| `parentId` | `long` | 是 | 父级分类 ID |
| `backParentId` | `long` | 是 | 返回上级分类时使用的父 ID |

#### GET `/admin/categories/list`

- 用途：分类分页列表
- 认证：是
- 返回：`Result<PageResult<GoodsCategory>>`

| Query 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `page` | `int` | 是 | 当前页 |
| `limit` | `int` | 是 | 每页条数 |
| `categoryLevel` | `byte` | 是 | 分类级别，`1/2/3` |
| `parentId` | `long` | 是 | 父级 ID |

#### GET `/admin/categories/listForSelect`

- 用途：商品编辑页级联分类查询
- 认证：是
- 返回：`Result<object>`

| Query 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `categoryId` | `long` | 是 | 当前分类 ID |

返回 `data` 结构：

```json
{
  "secondLevelCategories": [],
  "thirdLevelCategories": []
}
```

#### POST `/admin/categories/save`

- 用途：新增分类
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
{
  "categoryLevel": 1,
  "parentId": 0,
  "categoryName": "家电数码",
  "categoryRank": 100
}
```

#### POST `/admin/categories/update`

- 用途：修改分类
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
{
  "categoryId": 15,
  "categoryLevel": 1,
  "parentId": 0,
  "categoryName": "家电数码",
  "categoryRank": 100
}
```

#### GET `/admin/categories/info/{id}`

- 用途：分类详情
- 认证：是
- 返回：`Result<GoodsCategory>`

| Path 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `id` | `long` | 是 | 分类 ID |

#### POST `/admin/categories/delete`

- 用途：批量删除分类
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
[15, 16]
```

### 6.5 商品管理

#### GET `/admin/goods`

- 用途：商品管理页面
- 认证：是
- 返回：`text/html`

#### GET `/admin/goods/edit`

- 用途：新增商品页面
- 认证：是
- 返回：`text/html`

#### GET `/admin/goods/edit/{goodsId}`

- 用途：编辑商品页面
- 认证：是
- 返回：`text/html`

| Path 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `goodsId` | `long` | 是 | 商品 ID |

#### GET `/admin/goods/list`

- 用途：商品分页列表
- 认证：是
- 返回：`Result<PageResult<NewBeeMallGoods>>`

| Query 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `page` | `int` | 是 | 当前页 |
| `limit` | `int` | 是 | 每页条数 |
| `goodsName` | `string` | 否 | 商品名筛选 |
| `goodsSellStatus` | `int` | 否 | 上下架状态筛选 |

#### POST `/admin/goods/save`

- 用途：新增商品
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
{
  "goodsName": "iPhone 15",
  "goodsIntro": "128G 黑色",
  "goodsCategoryId": 47,
  "goodsCoverImg": "/upload/demo.png",
  "goodsCarousel": "/upload/demo1.png,/upload/demo2.png",
  "originalPrice": 6999,
  "sellingPrice": 6499,
  "stockNum": 100,
  "tag": "新品",
  "goodsSellStatus": 0,
  "goodsDetailContent": "<p>商品详情</p>"
}
```

#### POST `/admin/goods/update`

- 用途：修改商品
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
{
  "goodsId": 10001,
  "goodsName": "iPhone 15",
  "goodsIntro": "128G 黑色",
  "goodsCategoryId": 47,
  "goodsCoverImg": "/upload/demo.png",
  "goodsCarousel": "/upload/demo1.png,/upload/demo2.png",
  "originalPrice": 6999,
  "sellingPrice": 6499,
  "stockNum": 100,
  "tag": "新品",
  "goodsSellStatus": 0,
  "goodsDetailContent": "<p>商品详情</p>"
}
```

#### GET `/admin/goods/info/{id}`

- 用途：查询商品详情
- 认证：是
- 返回：`Result<NewBeeMallGoods>`

| Path 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `id` | `long` | 是 | 商品 ID |

#### PUT `/admin/goods/status/{sellStatus}`

- 用途：批量修改商品上下架状态
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

| Path 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `sellStatus` | `int` | 是 | `0` 上架，`1` 下架 |

请求体：

```json
[10001, 10002]
```

### 6.6 首页配置管理

#### GET `/admin/indexConfigs`

- 用途：首页配置管理页面
- 认证：是
- 返回：`text/html`

| Query 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `configType` | `int` | 是 | `3` 热门商品，`4` 新品上线，`5` 推荐商品 |

#### GET `/admin/indexConfigs/list`

- 用途：首页配置分页列表
- 认证：是
- 返回：`Result<PageResult<IndexConfig>>`

| Query 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `page` | `int` | 是 | 当前页 |
| `limit` | `int` | 是 | 每页条数 |
| `configType` | `int` | 否 | 配置类型筛选 |

#### POST `/admin/indexConfigs/save`

- 用途：新增首页配置
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
{
  "configName": "热销商品 iPhone",
  "configType": 3,
  "goodsId": 10001,
  "redirectUrl": "##",
  "configRank": 1
}
```

#### POST `/admin/indexConfigs/update`

- 用途：修改首页配置
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
{
  "configId": 1,
  "configName": "热销商品 iPhone",
  "configType": 3,
  "goodsId": 10001,
  "redirectUrl": "##",
  "configRank": 1
}
```

#### GET `/admin/indexConfigs/info/{id}`

- 用途：首页配置详情
- 认证：是
- 返回：`Result<IndexConfig>`

| Path 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `id` | `long` | 是 | 配置 ID |

#### POST `/admin/indexConfigs/delete`

- 用途：批量删除首页配置
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
[1, 2, 3]
```

### 6.7 订单管理

#### GET `/admin/orders`

- 用途：订单管理页面
- 认证：是
- 返回：`text/html`

#### GET `/admin/orders/list`

- 用途：订单分页列表
- 认证：是
- 返回：`Result<PageResult<NewBeeMallOrder>>`

| Query 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `page` | `int` | 是 | 当前页 |
| `limit` | `int` | 是 | 每页条数 |
| `orderNo` | `string` | 否 | 订单号筛选 |
| `orderStatus` | `int` | 否 | 订单状态筛选 |

#### POST `/admin/orders/update`

- 用途：修改订单基础信息
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
{
  "orderId": 1,
  "totalPrice": 2499,
  "userAddress": "上海市浦东新区..."
}
```

#### GET `/admin/order-items/{id}`

- 用途：查询订单项列表
- 认证：是
- 返回：`Result<Array<NewBeeMallOrderItemVO>>`

| Path 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `id` | `long` | 是 | 订单 ID |

#### POST `/admin/orders/checkDone`

- 用途：批量配货完成
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
[1, 2, 3]
```

#### POST `/admin/orders/checkOut`

- 用途：批量出库
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
[1, 2, 3]
```

#### POST `/admin/orders/close`

- 用途：批量关闭订单
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
[1, 2, 3]
```

### 6.8 文件上传

#### POST `/admin/upload/file`

- 用途：上传单张图片
- 认证：是
- 请求类型：`multipart/form-data`
- 返回：`Result<string>`

表单字段：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `file` | `file` | 是 | 图片文件 |

成功时 `data` 示例：

```json
"http://localhost:28089/upload/20260508_12345688.png"
```

#### POST `/admin/upload/files`

- 用途：批量上传图片，最多 5 张
- 认证：是
- 请求类型：`multipart/form-data`
- 返回：`Result<Array<string>>`

表单字段：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `file` | `file` | 是 | 可重复上传多个图片字段 |

## 7. 商城前台接口

### 7.1 首页与搜索

#### GET `/`

- 用途：商城首页
- 认证：否
- 返回：`text/html`

#### GET `/index`

- 用途：商城首页
- 认证：否
- 返回：`text/html`

#### GET `/index.html`

- 用途：商城首页
- 认证：否
- 返回：`text/html`

#### GET `/search`

- 用途：商品搜索页
- 认证：否
- 返回：`text/html`

| Query 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `page` | `int` | 否 | 页码，默认 `1` |
| `keyword` | `string` | 否 | 搜索关键词 |
| `goodsCategoryId` | `long` | 否 | 分类 ID |
| `orderBy` | `string` | 否 | 排序字段 |

#### GET `/search.html`

- 用途：商品搜索页
- 认证：否
- 返回：`text/html`

| Query 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `page` | `int` | 否 | 页码，默认 `1` |
| `keyword` | `string` | 否 | 搜索关键词 |
| `goodsCategoryId` | `long` | 否 | 分类 ID |
| `orderBy` | `string` | 否 | 排序字段 |

#### GET `/goods/detail/{goodsId}`

- 用途：商品详情页
- 认证：是
- 返回：`text/html`

| Path 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `goodsId` | `long` | 是 | 商品 ID |

### 7.2 用户注册、登录、个人中心

#### GET `/login`

- 用途：商城登录页
- 认证：否
- 返回：`text/html`

#### GET `/login.html`

- 用途：商城登录页
- 认证：否
- 返回：`text/html`

#### POST `/login`

- 用途：商城用户登录
- 认证：否
- 请求类型：`application/x-www-form-urlencoded`
- 返回：`Result<Void>`

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `loginName` | `string` | 是 | 登录名 |
| `password` | `string` | 是 | 明文密码，后端会做 MD5 |
| `verifyCode` | `string` | 是 | 商城验证码 |

#### GET `/register`

- 用途：商城注册页
- 认证：否
- 返回：`text/html`

#### GET `/register.html`

- 用途：商城注册页
- 认证：否
- 返回：`text/html`

#### POST `/register`

- 用途：商城用户注册
- 认证：否
- 请求类型：`application/x-www-form-urlencoded`
- 返回：`Result<Void>`

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `loginName` | `string` | 是 | 登录名 |
| `password` | `string` | 是 | 明文密码 |
| `verifyCode` | `string` | 是 | 商城验证码 |

#### GET `/personal`

- 用途：个人中心页
- 认证：是
- 返回：`text/html`

#### GET `/personal/addresses`

- 用途：收货地址页
- 认证：控制器未强制校验，但前端流程默认登录后访问
- 返回：`text/html`

#### POST `/personal/updateInfo`

- 用途：修改个人资料
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
{
  "nickName": "张三",
  "introduceSign": "你好",
  "address": "上海市浦东新区"
}
```

#### GET `/logout`

- 用途：商城用户退出登录
- 认证：否
- 返回：`text/html`

### 7.3 购物车

#### GET `/shop-cart`

- 用途：购物车页面
- 认证：是
- 返回：`text/html`

#### POST `/shop-cart`

- 用途：加入购物车
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
{
  "goodsId": 10001,
  "goodsCount": 1
}
```

#### PUT `/shop-cart`

- 用途：修改购物车商品数量
- 认证：是
- 请求类型：`application/json`
- 返回：`Result<Void>`

请求体：

```json
{
  "cartItemId": 1,
  "goodsCount": 2
}
```

#### DELETE `/shop-cart/{newBeeMallShoppingCartItemId}`

- 用途：删除购物车单项
- 认证：是
- 返回：`Result<Void>`

| Path 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `newBeeMallShoppingCartItemId` | `long` | 是 | 购物车项 ID |

#### GET `/shop-cart/settle`

- 用途：订单结算页
- 认证：是
- 返回：`text/html`

### 7.4 订单与支付

#### GET `/orders`

- 用途：我的订单页
- 认证：是
- 返回：`text/html`

| Query 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `page` | `int` | 否 | 页码，默认 `1` |

#### GET `/orders/{orderNo}`

- 用途：订单详情页
- 认证：是
- 返回：`text/html`

| Path 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `orderNo` | `string` | 是 | 订单号 |

#### GET `/saveOrder`

- 用途：从当前购物车生成订单，并重定向到订单详情页
- 认证：是
- 返回：`302 redirect`

说明：

- 必须存在收货地址
- 购物车不能为空
- 成功后会重定向到 `/orders/{orderNo}`

#### PUT `/orders/{orderNo}/cancel`

- 用途：取消订单
- 认证：是
- 返回：`Result<Void>`

| Path 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `orderNo` | `string` | 是 | 订单号 |

#### PUT `/orders/{orderNo}/finish`

- 用途：确认收货/完成订单
- 认证：是
- 返回：`Result<Void>`

| Path 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `orderNo` | `string` | 是 | 订单号 |

#### GET `/selectPayType`

- 用途：选择支付方式页面
- 认证：是
- 返回：`text/html`

| Query 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `orderNo` | `string` | 是 | 订单号 |

#### GET `/payPage`

- 用途：支付页
- 认证：是
- 返回：`text/html`

| Query 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `orderNo` | `string` | 是 | 订单号 |
| `payType` | `int` | 是 | `1` 支付宝，其它值走微信支付页 |

#### GET `/paySuccess`

- 用途：支付成功回调接口
- 认证：控制器未强制登录校验，但应在订单支付流程中调用
- 返回：`Result<Void>`

| Query 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `orderNo` | `string` | 是 | 订单号 |
| `payType` | `int` | 是 | 支付方式 |

## 8. 通用接口

### 8.1 验证码

#### GET `/common/kaptcha`

- 用途：后台登录验证码图片
- 认证：否
- 返回：`image/png`
- 副作用：向 Session 写入 `verifyCode`

#### GET `/common/mall/kaptcha`

- 用途：商城登录/注册验证码图片
- 认证：否
- 返回：`image/png`
- 副作用：向 Session 写入 `mallVerifyCode`

## 9. 数据模型

### 9.1 AdminUser

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `adminUserId` | `int` | 管理员 ID |
| `loginUserName` | `string` | 登录用户名 |
| `loginPassword` | `string` | 登录密码 |
| `nickName` | `string` | 昵称 |
| `locked` | `byte` | 锁定状态 |

### 9.2 Carousel

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `carouselId` | `int` | 轮播图 ID |
| `carouselUrl` | `string` | 轮播图地址 |
| `redirectUrl` | `string` | 跳转地址 |
| `carouselRank` | `int` | 排序值 |
| `isDeleted` | `byte` | 删除标记 |
| `createTime` | `date` | 创建时间 |
| `createUser` | `int` | 创建人 |
| `updateTime` | `date` | 更新时间 |
| `updateUser` | `int` | 更新人 |

### 9.3 GoodsCategory

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `categoryId` | `long` | 分类 ID |
| `categoryLevel` | `byte` | 分类级别 |
| `parentId` | `long` | 父级 ID |
| `categoryName` | `string` | 分类名称 |
| `categoryRank` | `int` | 排序值 |
| `isDeleted` | `byte` | 删除标记 |
| `createTime` | `date` | 创建时间 |
| `createUser` | `int` | 创建人 |
| `updateTime` | `date` | 更新时间 |
| `updateUser` | `int` | 更新人 |

### 9.4 IndexConfig

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `configId` | `long` | 配置 ID |
| `configName` | `string` | 配置名称 |
| `configType` | `byte` | 配置类型 |
| `goodsId` | `long` | 绑定商品 ID |
| `redirectUrl` | `string` | 跳转地址 |
| `configRank` | `int` | 排序值 |
| `isDeleted` | `byte` | 删除标记 |
| `createTime` | `date` | 创建时间 |
| `createUser` | `int` | 创建人 |
| `updateTime` | `date` | 更新时间 |
| `updateUser` | `int` | 更新人 |

### 9.5 MallUser

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `userId` | `long` | 用户 ID |
| `nickName` | `string` | 昵称 |
| `loginName` | `string` | 登录名 |
| `passwordMd5` | `string` | MD5 密码 |
| `introduceSign` | `string` | 个性签名 |
| `address` | `string` | 收货地址 |
| `isDeleted` | `byte` | 删除标记 |
| `lockedFlag` | `byte` | 锁定标记 |
| `createTime` | `date` | 创建时间 |

### 9.6 NewBeeMallUserVO

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `userId` | `long` | 用户 ID |
| `nickName` | `string` | 昵称 |
| `loginName` | `string` | 登录名 |
| `introduceSign` | `string` | 个性签名 |
| `address` | `string` | 收货地址 |
| `shopCartItemCount` | `int` | 购物车商品数量 |

### 9.7 NewBeeMallGoods

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `goodsId` | `long` | 商品 ID |
| `goodsName` | `string` | 商品名称 |
| `goodsIntro` | `string` | 商品简介 |
| `goodsCategoryId` | `long` | 分类 ID |
| `goodsCoverImg` | `string` | 封面图 |
| `goodsCarousel` | `string` | 轮播图，逗号分隔 |
| `originalPrice` | `int` | 原价 |
| `sellingPrice` | `int` | 售价 |
| `stockNum` | `int` | 库存 |
| `tag` | `string` | 标签 |
| `goodsSellStatus` | `byte` | 上下架状态 |
| `createUser` | `int` | 创建人 |
| `createTime` | `date` | 创建时间 |
| `updateUser` | `int` | 更新人 |
| `updateTime` | `date` | 更新时间 |
| `goodsDetailContent` | `string` | 商品富文本详情 |

### 9.8 NewBeeMallGoodsDetailVO

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `goodsId` | `long` | 商品 ID |
| `goodsName` | `string` | 商品名称 |
| `goodsIntro` | `string` | 商品简介 |
| `goodsCoverImg` | `string` | 商品封面图 |
| `goodsCarouselList` | `array` | 轮播图数组 |
| `sellingPrice` | `int` | 售价 |
| `originalPrice` | `int` | 原价 |
| `goodsDetailContent` | `string` | 富文本详情 |

### 9.9 NewBeeMallSearchGoodsVO

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `goodsId` | `long` | 商品 ID |
| `goodsName` | `string` | 商品名称 |
| `goodsIntro` | `string` | 商品简介 |
| `goodsCoverImg` | `string` | 商品封面图 |
| `sellingPrice` | `int` | 售价 |

### 9.10 NewBeeMallIndexCarouselVO

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `carouselUrl` | `string` | 轮播图地址 |
| `redirectUrl` | `string` | 跳转地址 |

### 9.11 NewBeeMallIndexConfigGoodsVO

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `goodsId` | `long` | 商品 ID |
| `goodsName` | `string` | 商品名称 |
| `goodsIntro` | `string` | 商品简介 |
| `goodsCoverImg` | `string` | 商品封面图 |
| `sellingPrice` | `int` | 售价 |
| `tag` | `string` | 标签 |

### 9.12 NewBeeMallIndexCategoryVO

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `categoryId` | `long` | 一级分类 ID |
| `categoryLevel` | `byte` | 分类级别 |
| `categoryName` | `string` | 分类名称 |
| `secondLevelCategoryVOS` | `array` | 二级分类列表 |

### 9.13 SecondLevelCategoryVO

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `categoryId` | `long` | 分类 ID |
| `parentId` | `long` | 父级 ID |
| `categoryLevel` | `byte` | 分类级别 |
| `categoryName` | `string` | 分类名称 |
| `thirdLevelCategoryVOS` | `array` | 三级分类列表 |

### 9.14 ThirdLevelCategoryVO

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `categoryId` | `long` | 分类 ID |
| `categoryLevel` | `byte` | 分类级别 |
| `categoryName` | `string` | 分类名称 |

### 9.15 SearchPageCategoryVO

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `firstLevelCategoryName` | `string` | 一级分类名称 |
| `secondLevelCategoryList` | `array` | 二级分类列表 |
| `secondLevelCategoryName` | `string` | 二级分类名称 |
| `thirdLevelCategoryList` | `array` | 三级分类列表 |
| `currentCategoryName` | `string` | 当前分类名称 |

### 9.16 NewBeeMallShoppingCartItem

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `cartItemId` | `long` | 购物车项 ID |
| `userId` | `long` | 用户 ID |
| `goodsId` | `long` | 商品 ID |
| `goodsCount` | `int` | 购买数量 |
| `isDeleted` | `byte` | 删除标记 |
| `createTime` | `date` | 创建时间 |
| `updateTime` | `date` | 更新时间 |

### 9.17 NewBeeMallShoppingCartItemVO

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `cartItemId` | `long` | 购物车项 ID |
| `goodsId` | `long` | 商品 ID |
| `goodsCount` | `int` | 购买数量 |
| `goodsName` | `string` | 商品名称 |
| `goodsCoverImg` | `string` | 商品封面图 |
| `sellingPrice` | `int` | 商品售价 |

### 9.18 NewBeeMallOrder

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `orderId` | `long` | 订单 ID |
| `orderNo` | `string` | 订单号 |
| `userId` | `long` | 用户 ID |
| `totalPrice` | `int` | 订单总价 |
| `payStatus` | `byte` | 支付状态 |
| `payType` | `byte` | 支付方式 |
| `payTime` | `date` | 支付时间 |
| `orderStatus` | `byte` | 订单状态 |
| `extraInfo` | `string` | 扩展信息 |
| `userAddress` | `string` | 收货地址 |
| `isDeleted` | `byte` | 删除标记 |
| `createTime` | `date` | 创建时间 |
| `updateTime` | `date` | 更新时间 |

### 9.19 NewBeeMallOrderItem

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `orderItemId` | `long` | 订单项 ID |
| `orderId` | `long` | 订单 ID |
| `goodsId` | `long` | 商品 ID |
| `goodsName` | `string` | 商品快照名称 |
| `goodsCoverImg` | `string` | 商品快照图片 |
| `sellingPrice` | `int` | 商品快照售价 |
| `goodsCount` | `int` | 购买数量 |
| `createTime` | `date` | 创建时间 |

### 9.20 NewBeeMallOrderItemVO

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `goodsId` | `long` | 商品 ID |
| `goodsCount` | `int` | 购买数量 |
| `goodsName` | `string` | 商品名称 |
| `goodsCoverImg` | `string` | 商品封面图 |
| `sellingPrice` | `int` | 商品售价 |

### 9.21 NewBeeMallOrderListVO

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `orderId` | `long` | 订单 ID |
| `orderNo` | `string` | 订单号 |
| `totalPrice` | `int` | 订单总价 |
| `payType` | `byte` | 支付方式 |
| `orderStatus` | `byte` | 订单状态 |
| `orderStatusString` | `string` | 订单状态中文描述 |
| `userAddress` | `string` | 收货地址 |
| `createTime` | `date` | 创建时间 |
| `newBeeMallOrderItemVOS` | `array` | 订单项列表 |

### 9.22 NewBeeMallOrderDetailVO

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `orderNo` | `string` | 订单号 |
| `totalPrice` | `int` | 订单总价 |
| `payStatus` | `byte` | 支付状态 |
| `payStatusString` | `string` | 支付状态中文描述 |
| `payType` | `byte` | 支付方式 |
| `payTypeString` | `string` | 支付方式中文描述 |
| `payTime` | `date` | 支付时间 |
| `orderStatus` | `byte` | 订单状态 |
| `orderStatusString` | `string` | 订单状态中文描述 |
| `userAddress` | `string` | 收货地址 |
| `createTime` | `date` | 创建时间 |
| `newBeeMallOrderItemVOS` | `array` | 订单项列表 |

## 10. 业务常量

### 10.1 商品上下架状态

| 值 | 含义 |
| --- | --- |
| `0` | 上架 |
| `1` | 下架 |

### 10.2 首页配置类型

| 值 | 含义 |
| --- | --- |
| `3` | 热门商品 |
| `4` | 新品上线 |
| `5` | 推荐商品 |

### 10.3 支付状态

| 值 | 含义 |
| --- | --- |
| `0` | 支付中 |
| `1` | 支付成功 |

### 10.4 订单状态

| 值 | 含义 |
| --- | --- |
| `0` | 待支付 |
| `1` | 已支付 |
| `2` | 配货完成 |
| `3` | 出库成功 |
| `4` | 交易成功 |
| `-1` | 用户手动关闭 |
| `-2` | 超时关闭 |
| `-3` | 商家关闭 |

### 10.5 购物车限制

| 常量 | 值 | 含义 |
| --- | --- | --- |
| `SHOPPING_CART_ITEM_TOTAL_NUMBER` | `13` | 购物车最大商品种类数 |
| `SHOPPING_CART_ITEM_LIMIT_NUMBER` | `5` | 单个商品最大购买数量 |

## 11. 常见错误消息

项目主要使用 `ServiceResultEnum` 与控制器自定义文案。常见返回消息如下：

| 含义 | 典型消息 |
| --- | --- |
| 成功 | `success` / `SUCCESS` |
| 未查到数据 | `未查询到记录！` |
| 同级同名分类已存在 | `已存在同级同名的分类！` |
| 用户名已存在 | `用户名已存在！` |
| 验证码错误 | `验证码错误！` |
| 分类数据异常 | `分类数据异常！` |
| 商品不存在 | `商品不存在！` |
| 商品已下架 | `商品已下架！` |
| 超出单个商品最大购买数量 | `超出单个商品的最大购买数量！` |
| 超出购物车最大容量 | `超出购物车最大容量！` |
| 登录失败 | `登录失败！` |
| 用户已被禁止登录 | `用户已被禁止登录！` |
| 订单不存在 | `订单不存在！` |
| 订单项不存在 | `订单项不存在！` |
| 地址不能为空 | `地址不能为空！` |
| 订单价格异常 | `订单价格异常！` |
| 购物车数据异常 | `购物车数据异常！` |
| 库存不足 | `库存不足！` |
| 订单状态异常 | `订单状态异常！` |
| 关闭订单失败 | `关闭订单失败！` |
| 无权限 | `无权限！` |
| 数据库异常 | `database error` |

## 12. 登录功能与会话机制说明（小白版）

这一节不再只列接口，而是专门解释：

- 这个项目的登录功能是怎么跑起来的
- 用户登录后，信息被放到了哪里
- 后续请求为什么能识别“你已经登录了”
- `spring-session-core` 在这个项目里到底起了什么作用

### 12.1 先理解两个核心概念

#### 1. 什么是登录

登录本质上做了两件事：

1. 校验你输入的账号、密码、验证码是不是对的
2. 如果对，就在服务器里记住“这个浏览器现在属于谁”

项目里“记住你是谁”的方式，就是 **Session 会话**。

#### 2. 什么是 Session

可以把 Session 理解成：

- 服务器给每个浏览器开了一个“小柜子”
- 柜子里可以放当前用户的登录信息
- 浏览器以后每次请求，都带着自己的柜子编号过来
- 服务器根据这个编号找到柜子，就知道你是谁

这个“柜子编号”通常通过 Cookie 传递，默认名字一般是 `JSESSIONID`。

### 12.2 这个项目的登录分成两套

项目里有两种登录：

- 后台管理员登录
- 商城普通用户登录

它们都使用 Session，但保存的数据不一样。

### 12.3 后台管理员登录是怎么实现的

后台登录入口控制器在 [AdminController.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/admin/AdminController.java)。

#### 登录流程

1. 用户先访问 `GET /admin/login`
2. 页面加载验证码图片 `GET /common/kaptcha`
3. 验证码对象 `ShearCaptcha` 被放进 Session，键名是 `verifyCode`
4. 用户提交用户名、密码、验证码到 `POST /admin/login`
5. 后端先检查：
   - 验证码是否为空
   - 用户名密码是否为空
   - Session 里的验证码对象是否存在
   - 验证码是否正确
6. 如果验证码通过，就调用 `adminUserService.login(userName, password)`
7. `AdminUserServiceImpl` 会把前端明文密码做一次 MD5，再去数据库查管理员账号
8. 如果数据库能查到管理员，就说明登录成功
9. 登录成功后，后端把下面两个值存进 Session：
   - `loginUser`：管理员昵称
   - `loginUserId`：管理员 ID
10. 然后重定向到 `/admin/index`

#### 后台登录成功后 Session 中保存了什么

| Session Key | 说明 |
| --- | --- |
| `loginUser` | 当前管理员昵称 |
| `loginUserId` | 当前管理员主键 ID |
| `verifyCode` | 后台验证码对象，登录前会用到 |
| `errorMsg` | 登录失败时的错误提示 |

#### 后台是怎么判断“你是否已经登录”的

判断逻辑在 [AdminLoginInterceptor.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/interceptor/AdminLoginInterceptor.java)。

它会拦截 `/admin/**` 请求，然后做这个判断：

- 如果当前请求是后台路径
- 并且 Session 里没有 `loginUser`
- 就认为你没登录，强制跳转回 `/admin/login`

也就是说：

- `loginUser` 存在：认为你已登录
- `loginUser` 不存在：认为你未登录

#### 后台退出登录怎么做

访问 `GET /admin/logout` 时，会从 Session 里删除：

- `loginUserId`
- `loginUser`
- `errorMsg`

删除之后，再访问后台受保护页面，就会被拦截器拦回登录页。

### 12.4 商城普通用户登录是怎么实现的

商城登录入口控制器在 [PersonalController.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/mall/PersonalController.java)。

#### 登录流程

1. 用户访问 `GET /login`
2. 页面加载商城验证码图片 `GET /common/mall/kaptcha`
3. 验证码对象 `ShearCaptcha` 被放进 Session，键名是 `mallVerifyCode`
4. 用户提交 `loginName`、`password`、`verifyCode` 到 `POST /login`
5. 后端先检查：
   - 登录名是否为空
   - 密码是否为空
   - 验证码是否为空
   - Session 中的商城验证码是否存在
   - 验证码是否正确
6. 如果验证码通过，控制器会先把密码做 MD5
7. 然后调用 `newBeeMallUserService.login(...)`
8. Service 层去数据库按“登录名 + MD5 密码”查询用户
9. 如果查到用户，再检查该用户是否被禁用
10. 如果用户正常，就把数据库用户对象复制成 `NewBeeMallUserVO`
11. 最后把这个 `NewBeeMallUserVO` 放进 Session，键名是 `newBeeMallUser`

#### 商城登录成功后 Session 中保存了什么

| Session Key | 说明 |
| --- | --- |
| `newBeeMallUser` | 当前商城用户信息对象 |
| `mallVerifyCode` | 商城验证码对象 |

`newBeeMallUser` 这个对象里主要有：

- `userId`
- `nickName`
- `loginName`
- `introduceSign`
- `address`
- `shopCartItemCount`

#### 商城是怎么判断“你是否已经登录”的

判断逻辑在 [NewBeeMallLoginInterceptor.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/interceptor/NewBeeMallLoginInterceptor.java)。

它会检查：

- Session 里是否存在 `Constants.MALL_USER_SESSION_KEY`
- 这个常量的值就是 `newBeeMallUser`

如果没有，就跳转到 `/login`。

#### 商城退出登录怎么做

访问 `GET /logout` 时，会从 Session 删除：

- `newBeeMallUser`

删掉后，购物车、下单、个人中心这些需要登录的页面就会重新要求登录。

### 12.5 登录后，为什么购物车数量还能跟着变

项目里还有一个拦截器 [NewBeeMallCartNumberInterceptor.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/interceptor/NewBeeMallCartNumberInterceptor.java)。

它的作用是：

- 每次请求来到商城时
- 如果 Session 里已经有 `newBeeMallUser`
- 就根据 `userId` 去数据库重新查购物车数量
- 再把最新数量写回 `newBeeMallUser.shopCartItemCount`

所以页面顶部的购物车数量，看起来像“自动更新”，本质上是：

- 用户信息存在 Session
- 购物车数量每次请求都重新同步一次

### 12.6 注册功能和登录功能的关系

商城注册并不会直接创建登录态。

注册接口 `POST /register` 做的是：

1. 校验验证码
2. 检查用户名是否已存在
3. 把密码做 MD5
4. 新增用户到数据库

注册成功后只是“有账号了”，并没有把 `newBeeMallUser` 放进 Session。

也就是说：

- 注册成功 ≠ 自动登录
- 注册成功后还需要再调用一次登录接口

### 12.7 密码是怎么校验的

项目里的密码校验方式比较传统，走的是 **MD5 摘要**。

后台管理员：

- 在 [AdminUserServiceImpl.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/service/impl/AdminUserServiceImpl.java) 中
- 把明文密码做 `MD5Encode(password, "UTF-8")`
- 再拿 MD5 结果去数据库查询

商城用户：

- 控制器里先对明文密码做 MD5
- 再调用用户 Service 查询数据库

这意味着数据库里保存的不是明文密码，而是 MD5 结果。

补充说明：

- 这是一种老项目里很常见的做法
- 从现代安全角度看，**单独 MD5 并不够安全**
- 更推荐使用 `BCrypt`、`Argon2`、`PBKDF2` 这种带盐的密码方案

### 12.8 这个项目是如何使用 `spring-session-core` 的（已实现）

当前项目已完成 Spring Session 落地，采用的是 **Spring Session + Redis**。

依赖层（已更新）：

- `spring-boot-starter-data-redis`
- `spring-session-data-redis`

见 [pom.xml](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/pom.xml)。

配置层（已更新）：

- `spring.session.store-type=redis`
- `spring.session.redis.namespace=spring:session:newbee-mall`
- `spring.session.redis.flush-mode=on_save`
- `server.servlet.session.timeout=120m`
- `spring.data.redis.host/port/password/database`

见 [application.properties](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/resources/application.properties)。

序列化层（已更新）：

- 新增 `springSessionDefaultRedisSerializer`
- 使用 `GenericJackson2JsonRedisSerializer`

见 [SessionRedisConfig.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/config/SessionRedisConfig.java)。

验证码会话（已更新）：

- 验证码由“对象存 Session”改为“字符串存 Session”
- 目的是提高 Redis Session 的序列化稳定性

相关代码：

- [CommonController.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/common/CommonController.java)
- [AdminController.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/admin/AdminController.java)
- [PersonalController.java](E:/J2EE/newbee-mall-spring-boot-3.x/newbee-mall-spring-boot-3.x/src/main/java/ltd/newbee/mall/controller/mall/PersonalController.java)

说明：

- 业务代码仍使用 `HttpSession` API，这不是问题
- Spring Session 的关键是“底层存储”已切换到 Redis
- 所以写法可保持不变，但会话管理能力已升级

### 12.9 小白可以这样理解整个登录过程

你可以把它想成一个小区门禁系统：

1. 你先在门口输入账号、密码、验证码
2. 门卫查数据库，确认你是不是住户
3. 确认无误后，门卫给你发一张“临时通行卡”
4. 这张卡的编号，就是浏览器保存的 Session 标识
5. 门卫室里还留着一份登记信息，这就是服务器端 Session 数据
6. 以后你每次进门，只要刷这张卡，门卫就知道你是谁

在这个项目里：

- 门卫：后端控制器 + Service
- 门禁卡编号：浏览器 Cookie 里的 Session ID
- 门卫室登记本：服务器端 Session
- 登记内容：
  - 后台放 `loginUser`、`loginUserId`
  - 商城放 `newBeeMallUser`

### 12.10 当前实现的优点和局限

#### 优点

- 实现简单
- 对单机项目很容易理解
- 适合教学和入门
- Session 已托管到 Redis，重启后会话更稳
- 为多实例部署提供会话共享能力

#### 局限

- 仍依赖 Redis 可用性与网络可达性
- 生产环境建议增加 Redis 高可用和监控
- 单独使用 MD5 做密码摘要，安全性偏弱

### 12.11 如何验证改造成功

建议至少通过以下验证：

1. 登录后，Redis 出现 `spring:session:newbee-mall:*` 键
2. 应用重启后，不关闭浏览器仍保持登录态
3. 登录验证码正确/错误分支都正常
4. 退出登录后，受保护页面会重新要求登录

以上通过即可判定 Spring Session 改造生效。
