package com.easyverify.springboot.interceptor;


import com.easyverify.springboot.utils.FileHeaderHelper;
import com.easyverify.springboot.utils.JwtUtil;
import com.easyverify.springboot.vo.ResponseResult;
import com.easyverify.springboot.utils.ThreadLocalUtil;
import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.HandlerInterceptor;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@Component
@Slf4j
public class EasyInterceptor implements HandlerInterceptor {


    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

        response.setContentType("application/json;charset=utf-8");
        String authorization = request.getHeader("Authorization");
        try {
            String s = redisTemplate.opsForValue().get(authorization);
            if (s == null) {
                throw new RuntimeException("Token expired");
            }
            Map<String, Object> map = JwtUtil.parseToken(authorization);
            ThreadLocalUtil.set(map);
        } catch (Exception e) {
            log.error("Authentication failed", e);
            response.setStatus(401);
            ResponseResult<Object> result = ResponseResult.builder().code(401).message("身份过期").build();
            response.getWriter().write(new ObjectMapper().writeValueAsString(result));
            return false;
        }

        if (isMultipartRequest(request)) {
            if (!isValidFileHeader(request)) {
                response.setContentType("application/json;charset=utf-8");
                ResponseResult<Object> result = ResponseResult.builder().code(402).message("请上传正确文件").build();
                response.getWriter().write(new ObjectMapper().writeValueAsString(result));
                return false;
            }
        }

        return true;
    }


    private boolean isMultipartRequest(HttpServletRequest request) {
        return request instanceof MultipartHttpServletRequest;
    }

    private boolean isValidFileHeader(HttpServletRequest request) throws IOException {
        MultipartHttpServletRequest multipartRequest = (MultipartHttpServletRequest) request;
        Map<String, MultipartFile> files = multipartRequest.getFileMap();
        for (MultipartFile multipartFile : files.values()) {
            if (!checkFileHeader(multipartFile)) {
                return false;
            }
        }
        return true;
    }

    private boolean checkFileHeader(MultipartFile multipartFile) throws IOException {
        byte[] file = multipartFile.getBytes();
        if (file.length > 8) {
            String fileHead = bytesToHex(file, 8).toUpperCase();
            log.info("文件头:"+fileHead);
            List<String> headerList = FileHeaderHelper.getInstance().getBinList();
            return headerList.stream().anyMatch(fileHead::startsWith);
        }
        return true;
    }

    private String bytesToHex(byte[] bytes, int length) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < length; i++) {
            String hv = Integer.toHexString(bytes[i] & 0xFF);
            sb.append((hv.length() == 1) ? "0" + hv : hv);
        }
        return sb.toString();
    }


    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        ThreadLocalUtil.remove();
    }
}