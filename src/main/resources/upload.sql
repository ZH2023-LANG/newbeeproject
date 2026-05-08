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