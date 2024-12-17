package com.easyverify.springboot.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class OpenAPIDTO {
    @NotBlank(message = "前端配置异常")
    private String pid; // 程序ID

    private String version; // 程序版本
    private String kami;//卡密
    private String imei;//设备码

    @NotBlank(message = "前端配置异常")
    private String time; // 时间戳
    @NotBlank(message = "前端配置异常")
    private String sign; // 签名
}
