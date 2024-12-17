package com.easyverify.springboot.utils;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.Map;

@Component
@Slf4j
public class JwtUtil {

    @Value("${encrypt.jwt}")
    private String key;

    public static String KEY;
	//接收业务数据,生成token并返回

    @PostConstruct
    public void init() {
        log.info("JwtUtil init key:{}", key);
        JwtUtil.KEY = key; // 设置静态字段
    }

    public static String genToken(Map<String, Object> claims) {

        return JWT.create()
                .withClaim("claims", claims)
                .withExpiresAt(new Date(System.currentTimeMillis() + 1000 * 60 * 60 * 24))
                .sign(Algorithm.HMAC256(KEY));
    }


	//接收token,验证token,并返回业务数据
    public static Map<String, Object> parseToken(String token) {
        return JWT.require(Algorithm.HMAC256(KEY))
                .build()
                .verify(token)
                .getClaim("claims")
                .asMap();
    }

}
