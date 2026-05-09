SELECT carousel_url, redirect_url FROM tb_newbee_mall_carousel;

SELECT carousel_id, carousel_url, redirect_url
FROM tb_newbee_mall_carousel;

UPDATE tb_newbee_mall_carousel
SET carousel_url = '/goods-img/banner01.jpg'
WHERE carousel_id = 1;

UPDATE tb_newbee_mall_carousel
SET carousel_url = '/goods-img/banner02.jpg'
WHERE carousel_id = 2;

UPDATE tb_newbee_mall_carousel
SET carousel_url = '/goods-img/banner03.jpg'
WHERE carousel_id = 5;





# 上架

START TRANSACTION;

-- 1. 把所有已有商品改成“已上架”
UPDATE tb_newbee_mall_goods_info
SET goods_sell_status = 1,
    update_time = NOW()
WHERE goods_sell_status <> 1;

-- 2. 给所有“没有已上架商品”的三级分类，自动补一个默认上架商品
-- 这样像 /search?goodsCategoryId=30 这种分类页也能看到商品
INSERT INTO tb_newbee_mall_goods_info
(
    goods_name,
    goods_intro,
    goods_category_id,
    goods_cover_img,
    goods_carousel,
    goods_detail_content,
    original_price,
    selling_price,
    stock_num,
    tag,
    goods_sell_status,
    create_user,
    create_time,
    update_user,
    update_time
)
SELECT
    CONCAT(c.category_name, ' 默认商品') AS goods_name,
    '系统补充商品，用于分类页展示' AS goods_intro,
    c.category_id AS goods_category_id,
    '/admin/dist/img/no-img.png' AS goods_cover_img,
    '/admin/dist/img/no-img.png' AS goods_carousel,
    '<p>商品介绍加载中...</p>' AS goods_detail_content,
    99 AS original_price,
    99 AS selling_price,
    1000 AS stock_num,
    '默认' AS tag,
    1 AS goods_sell_status,
    0 AS create_user,
    NOW() AS create_time,
    0 AS update_user,
    NOW() AS update_time
FROM tb_newbee_mall_goods_category c
WHERE c.category_level = 3
  AND c.is_deleted = 0
  AND NOT EXISTS (
    SELECT 1
    FROM tb_newbee_mall_goods_info g
    WHERE g.goods_category_id = c.category_id
      AND g.goods_sell_status = 1
);

COMMIT;

START TRANSACTION;

-- 把所有商品改成项目代码认为的“已上架”
UPDATE tb_newbee_mall_goods_info
SET goods_sell_status = 0,
    update_time = NOW();

COMMIT;

START TRANSACTION;

INSERT INTO tb_newbee_mall_goods_info
(
    goods_name,
    goods_intro,
    goods_category_id,
    goods_cover_img,
    goods_carousel,
    goods_detail_content,
    original_price,
    selling_price,
    stock_num,
    tag,
    goods_sell_status,
    create_user,
    create_time,
    update_user,
    update_time
)
SELECT
    '卷发器 默认商品',
    '分类30测试商品',
    30,
    '/goods-img/87446ec4-e534-4b49-9f7d-9bea34665284.jpg',
    '/goods-img/87446ec4-e534-4b49-9f7d-9bea34665284.jpg',
    '<p>商品介绍加载中...</p>',
    100,
    99,
    1000,
    '默认',
    0,
    0,
    NOW(),
    0,
    NOW()
WHERE NOT EXISTS (
    SELECT 1
    FROM tb_newbee_mall_goods_info
    WHERE goods_category_id = 30
      AND goods_sell_status = 0
);

COMMIT;


START TRANSACTION;

INSERT INTO tb_newbee_mall_goods_info
(
    goods_name,
    goods_intro,
    goods_category_id,
    goods_cover_img,
    goods_carousel,
    goods_detail_content,
    original_price,
    selling_price,
    stock_num,
    tag,
    goods_sell_status,
    create_user,
    create_time,
    update_user,
    update_time
)
SELECT
    CONCAT(c.category_name, ' 默认商品'),
    CONCAT(c.category_name, ' 分类测试商品'),
    c.category_id,
    '/goods-img/87446ec4-e534-4b49-9f7d-9bea34665284.jpg',
    '/goods-img/87446ec4-e534-4b49-9f7d-9bea34665284.jpg',
    '<p>商品介绍加载中...</p>',
    100,
    99,
    1000,
    '默认',
    0,
    0,
    NOW(),
    0,
    NOW()
FROM tb_newbee_mall_goods_category c
WHERE c.category_level = 3
  AND c.is_deleted = 0
  AND NOT EXISTS (
    SELECT 1
    FROM tb_newbee_mall_goods_info g
    WHERE g.goods_category_id = c.category_id
      AND g.goods_sell_status = 0
);

COMMIT;



#######最终改版
START TRANSACTION;

UPDATE tb_newbee_mall_goods_info
SET goods_sell_status = 0,
    update_time = NOW();

COMMIT;





