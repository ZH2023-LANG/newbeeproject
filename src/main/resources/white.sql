
# 检查空白

SELECT
    goods_id,
    goods_name,
    goods_category_id,
    goods_cover_img,
    goods_carousel,
    goods_sell_status
FROM tb_newbee_mall_goods_info
WHERE goods_cover_img = '/admin/dist/img/no-img.png'
   OR goods_carousel = '/admin/dist/img/no-img.png';




START TRANSACTION;

UPDATE tb_newbee_mall_goods_info
SET
    goods_cover_img = CASE goods_id
                          WHEN 10953 THEN '/goods-img/e1300835-d703-4257-a548-5cb9303fa483.png'
                          WHEN 10954 THEN '/goods-img/f7b7ce9c-fe2a-4510-a90a-077423c18db7.png'
                          WHEN 10949 THEN '/goods-img/273138ce-bb7e-4569-92ea-ea163a8f364d.png'
                          WHEN 10926 THEN '/goods-img/f533a9fb-4a0c-4138-8d9c-f0eb4ac022de.png'
                          WHEN 10945 THEN '/goods-img/0697d232-da20-4db1-9710-b9b915d8ad83.png'
                          WHEN 10944 THEN '/goods-img/3afa12b6-2893-44a5-9054-5a72b1141770.png'
                          WHEN 10942 THEN '/goods-img/013d0796-2d12-4234-aa2a-e458008ef923.png'
                          WHEN 10911 THEN '/goods-img/b16f1e1a-ae84-4c46-bdcd-abeeee41dc56.png'
                          WHEN 10914 THEN '/goods-img/84b79ef4-a03e-4e39-a4ce-8e3407439ef7.png'
                          WHEN 10921 THEN '/goods-img/10f04ac4-a36c-4877-8f0a-a6ee9f33fdf75.png'
        END,
    goods_carousel = CASE goods_id
                         WHEN 10953 THEN '/goods-img/e1300835-d703-4257-a548-5cb9303fa483.png'
                         WHEN 10954 THEN '/goods-img/f7b7ce9c-fe2a-4510-a90a-077423c18db7.png'
                         WHEN 10949 THEN '/goods-img/273138ce-bb7e-4569-92ea-ea163a8f364d.png'
                         WHEN 10926 THEN '/goods-img/f533a9fb-4a0c-4138-8d9c-f0eb4ac022de.png'
                         WHEN 10945 THEN '/goods-img/0697d232-da20-4db1-9710-b9b915d8ad83.png'
                         WHEN 10944 THEN '/goods-img/3afa12b6-2893-44a5-9054-5a72b1141770.png'
                         WHEN 10942 THEN '/goods-img/013d0796-2d12-4234-aa2a-e458008ef923.png'
                         WHEN 10911 THEN '/goods-img/b16f1e1a-ae84-4c46-bdcd-abeeee41dc56.png'
                         WHEN 10914 THEN '/goods-img/84b79ef4-a03e-4e39-a4ce-8e3407439ef7.png'
                         WHEN 10921 THEN '/goods-img/10f04ac4-a36c-4877-8f0a-a6ee9f33fdf75.png'
        END,
    update_time = NOW()
WHERE goods_id IN (
                   10953, 10954, 10949, 10926, 10945,
                   10944, 10942, 10911, 10914, 10921
    );

COMMIT;



START TRANSACTION;

UPDATE tb_newbee_mall_goods_info
SET
    goods_cover_img = CASE goods_id
        -- 10745 华为 HUAWEI P30 Pro
                          WHEN 10745 THEN '/goods-img/a8949d93-d72f-4e98-8be0-9aca47c5b90e.png'

        -- 10882 小米8 游戏手机 全面屏 蓝色
                          WHEN 10882 THEN '/goods-img/c5b21557-2753-463d-b2b1-f75c6673289f.png'

        -- 10883 小米8 游戏手机 全面屏 金色
                          WHEN 10883 THEN '/goods-img/8541effd-7ecb-427c-99b3-3289038bb825.png'

        -- 10884 小米8 游戏手机 全面屏 白色
                          WHEN 10884 THEN '/goods-img/0ffd0cab-b203-4f65-bebb-2ee555b8a7c3.png'

        -- 10885 小米8 游戏手机 全面屏 蓝色
                          WHEN 10885 THEN '/goods-img/b4508f68-208e-4ba8-9e86-5fa6a7f84810.png'

        -- 10886 小米8 游戏手机 全面屏 黑色
                          WHEN 10886 THEN '/goods-img/3c33b5db-df0e-4ed2-bb0d-0b19ff3cd3ea.png'

        -- 10887 小米8 游戏手机 全面屏 透明探索版
                          WHEN 10887 THEN '/goods-img/f40f929e-b0f4-4b38-a0ba-4a56b0aec1fa.png'

        -- 10888 小米8 游戏手机 全面屏 屏幕指纹版
                          WHEN 10888 THEN '/goods-img/08778c2c-fafe-407c-b2a4-3c090e68cd8c.png'

        -- 10889 小米8 游戏手机 全面屏 蓝色
                          WHEN 10889 THEN '/goods-img/f1973f2d-5b82-4737-986f-fa582106de17.png'

        -- 10907 厨房电器 默认商品
                          WHEN 10907 THEN '/goods-img/f0f17672-b81a-464b-a0fd-0755b74a0d64.png'
        END,
    goods_carousel = CASE goods_id
                         WHEN 10745 THEN '/goods-img/a8949d93-d72f-4e98-8be0-9aca47c5b90e.png'
                         WHEN 10882 THEN '/goods-img/c5b21557-2753-463d-b2b1-f75c6673289f.png'
                         WHEN 10883 THEN '/goods-img/8541effd-7ecb-427c-99b3-3289038bb825.png'
                         WHEN 10884 THEN '/goods-img/0ffd0cab-b203-4f65-bebb-2ee555b8a7c3.png'
                         WHEN 10885 THEN '/goods-img/b4508f68-208e-4ba8-9e86-5fa6a7f84810.png'
                         WHEN 10886 THEN '/goods-img/3c33b5db-df0e-4ed2-bb0d-0b19ff3cd3ea.png'
                         WHEN 10887 THEN '/goods-img/f40f929e-b0f4-4b38-a0ba-4a56b0aec1fa.png'
                         WHEN 10888 THEN '/goods-img/08778c2c-fafe-407c-b2a4-3c090e68cd8c.png'
                         WHEN 10889 THEN '/goods-img/f1973f2d-5b82-4737-986f-fa582106de17.png'
                         WHEN 10907 THEN '/goods-img/f0f17672-b81a-464b-a0fd-0755b74a0d64.png'
        END,
    update_time = NOW()
WHERE goods_id IN (
                   10745,
                   10882, 10883, 10884, 10885, 10886, 10887, 10888, 10889,
                   10907
    );

COMMIT;



START TRANSACTION;

UPDATE tb_newbee_mall_goods_info
SET
    goods_cover_img = CASE goods_id
        -- 10908 扫地机器人 默认商品
                          WHEN 10908 THEN '/goods-img/342148e1-14c2-400e-b3fa-147fe1e13d55.png'

        -- 10909 吸尘器 默认商品
                          WHEN 10909 THEN '/goods-img/7626b31f-5ca2-4611-bd4b-4c760ab2498e.png'

        -- 10910 取暖器 默认商品
                          WHEN 10910 THEN '/goods-img/5250b74f-1d71-4178-88f4-9c297d9cd812.png'

        -- 10912 暖风机 默认商品
                          WHEN 10912 THEN '/goods-img/33c021f0-2dc6-404f-8932-731f988396e3.png'

        -- 10913 加湿器 默认商品
                          WHEN 10913 THEN '/goods-img/8b8c4cb2-7626-4b29-9945-90b653763efe.png'

        -- 10915 烤箱 默认商品
                          WHEN 10915 THEN '/goods-img/0dca9127-72d3-4bcd-bf0b-725a00f538a0.png'

        -- 10916 卷发器 默认商品
                          WHEN 10916 THEN '/goods-img/e008e15f-488c-45e4-b183-8cf45eb7543b.png'

        -- 10917 空气净化器 默认商品
                          WHEN 10917 THEN '/goods-img/d00b7fc2-7236-4bee-88a0-a805f46a261d.png'

        -- 10918 游戏主机 默认商品
                          WHEN 10918 THEN '/goods-img/97a9f0d1-ae33-4492-a8e8-56ff3a156d2e.png'

        -- 10919 数码精选 默认商品
                          WHEN 10919 THEN '/goods-img/809341c5-6a81-4d64-ab2b-fec220ba5f65.png'

                          ELSE goods_cover_img
        END,

    goods_carousel = CASE goods_id
                         WHEN 10908 THEN '/goods-img/342148e1-14c2-400e-b3fa-147fe1e13d55.png'
                         WHEN 10909 THEN '/goods-img/7626b31f-5ca2-4611-bd4b-4c760ab2498e.png'
                         WHEN 10910 THEN '/goods-img/5250b74f-1d71-4178-88f4-9c297d9cd812.png'
                         WHEN 10912 THEN '/goods-img/33c021f0-2dc6-404f-8932-731f988396e3.png'
                         WHEN 10913 THEN '/goods-img/8b8c4cb2-7626-4b29-9945-90b653763efe.png'
                         WHEN 10915 THEN '/goods-img/0dca9127-72d3-4bcd-bf0b-725a00f538a0.png'
                         WHEN 10916 THEN '/goods-img/e008e15f-488c-45e4-b183-8cf45eb7543b.png'
                         WHEN 10917 THEN '/goods-img/d00b7fc2-7236-4bee-88a0-a805f46a261d.png'
                         WHEN 10918 THEN '/goods-img/97a9f0d1-ae33-4492-a8e8-56ff3a156d2e.png'
                         WHEN 10919 THEN '/goods-img/809341c5-6a81-4d64-ab2b-fec220ba5f65.png'

                         ELSE goods_carousel
        END,

    update_time = NOW()
WHERE goods_id IN (
                   10908, 10909, 10910, 10912, 10913,
                   10915, 10916, 10917, 10918, 10919
    );

COMMIT;

