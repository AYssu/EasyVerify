package com.easyverify.springboot.controller;

import cn.hutool.core.codec.Base64;
import cn.hutool.crypto.asymmetric.KeyType;
import cn.hutool.crypto.asymmetric.RSA;
import com.easyverify.springboot.dto.OpenAPIDTO;
import com.easyverify.springboot.dto.UserProjectBindDTO;
import com.easyverify.springboot.entity.EasyLink;
import com.easyverify.springboot.entity.EasyProject;
import com.easyverify.springboot.service.OpenAPIService;
import com.easyverify.springboot.service.ProjectService;
import com.easyverify.springboot.utils.IpUtil;
import com.easyverify.springboot.utils.Sutils;
import com.easyverify.springboot.vo.ResponseResult;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


@Slf4j
@RestController
public class OpenAPIController {

    @Autowired
    private OpenAPIService openAPIService;
    @Autowired
    private ProjectService projectService;

    private static final String EMAIL_REGEX = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";

    /**
     * 验证邮箱格式
     * @param email 邮箱地址
     * @return boolean
     */
    public static boolean isValidEmail(String email) {
        if (email == null || email.length() < 5) {
            return false;
        }
        Pattern pattern = Pattern.compile(EMAIL_REGEX);
        Matcher matcher = pattern.matcher(email);
        return matcher.matches();
    }

    @GetMapping("/open/export_txt")
    public ResponseEntity<Resource> export_txt_file(HttpServletResponse response, @RequestParam String txt) {
        try {
            // 设置HTTP响应头
            response.setContentType("text/plain");
            response.setHeader(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=export.txt");

            // 要导出的字符串
            String content = Base64.decodeStr(txt);

            // 写入字符串到响应输出流
            try (PrintWriter writer = response.getWriter()) {
                writer.write(content);
            }

        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
        return ResponseEntity.ok().build();
    }
    /**
     * 发送注册验证码
     * @param email 邮箱地址
     * @return 返回数据
     */
    @GetMapping("/open/send_register_code")
    public ResponseResult<?> send_code(@RequestParam String email)
    {
        if (!isValidEmail(email))
        {
            return ResponseResult.fail("邮箱格式不正确");
        }
        log.info("send_code email: {}",email);
        boolean success = openAPIService.send_register_code_mail(email);
        if (!success)
            return ResponseResult.fail("发送失败");
        return ResponseResult.success("发送成功");
    }

    /**
     * 用户绑定项目
     * @param userProjectBindDTO 绑定信息
     * @return 返回数据
     */
    @PostMapping("/open/user_project_bind")
    public ResponseResult<?> user_project_bind(@RequestBody @Validated UserProjectBindDTO userProjectBindDTO)
    {
        log.info("user_project_bind form: {}",userProjectBindDTO);

        boolean success = openAPIService.user_project_bind(userProjectBindDTO);
        if (success)
            return ResponseResult.success("注册成功");
        return ResponseResult.fail("注册失败");
    }

    @PostMapping("/{base}")
    public ResponseResult<?> open_api(@PathVariable String base, @RequestBody @Validated OpenAPIDTO openAPIDTO, HttpServletRequest request)
    {
        String ip = IpUtil.getIpAddr(request);
        log.info("open_api object: {}",openAPIDTO);
        // 还原pid
        try {
            String pid = Sutils.hex_to_string(Sutils.base64_decode(Sutils.hex_to_string(openAPIDTO.getPid())));
            log.info("解析项目pid: {}",pid);
            EasyLink link = openAPIService.open_link_type(Integer.parseInt(pid),base);
            if (link == null)
                return ResponseResult.fail("客户端接口异常");

            log.info("open_api type: {}",projectService.get_link_name(link.getType()));

            EasyProject project = projectService.get_project_by_id(Integer.parseInt(pid));
            long now_time = System.currentTimeMillis() / 1000;
            String send_time = "";

            // 初始化rsa
            RSA rsa = null;

            if (project.getProjectEncryption()==2)
            {
                // 如果是rsa 那就初始化Rsa
                String public_key_base64 = project.getProjectRsaPublic().replace("-----BEGIN PUBLIC KEY-----", "")
                        .replace("-----END PUBLIC KEY-----", "")
                        .replaceAll("\\s+", "");

                String private_key_base64 = project.getProjectRsaPrivate().replace("-----BEGIN PRIVATE KEY-----", "")
                        .replace("-----END PRIVATE KEY-----", "")
                        .replaceAll("\\s+", "");

                rsa= new RSA(private_key_base64, public_key_base64);
            }

            // 分开的目的是简化后续添加其他加密的逻辑
            if(project.getProjectEncryption()==1)
                send_time = Sutils.base64_decode(Sutils.hex_to_string(openAPIDTO.getTime()),project.getProjectBase64());
            else if (project.getProjectEncryption()==2)
                send_time = rsa.decryptStr(Sutils.hex_to_string(openAPIDTO.getTime()), KeyType.PrivateKey);

            long alive_time = Math.abs(now_time - Long.parseLong(send_time));
            if (alive_time > 10)
            {
                return ResponseResult.fail("客户端请求超时");
            }

            // 以上为基础信息校验 基础信息
            switch(link.getType()) {
                case 1:
                {
                    return openAPIService.check_card(project,openAPIDTO,link,rsa,ip);
                }
                case 2:
                {
                }
                break;
                case 3:
                {
                }
                break;
                case 4:
                {
                    return openAPIService.get_project_notice(project,openAPIDTO,link,rsa);
                }
                case 5:
                {
                    return openAPIService.get_project_update(project,openAPIDTO,link,rsa);
                }
                case 6:
                {
                    return openAPIService.get_project_variable(project,openAPIDTO,link,rsa);
                }
                case 7:
                {
                }
                break;
                default:
                {
                    // 前面已经判断 这边是可能后期新增接口忘记实现功能了
                    return ResponseResult.fail("客户端未知接口异常");
                }
            }
        }catch (Exception exception){
            exception.printStackTrace();
            return ResponseResult.fail("客户端解析异常");
        }

        return ResponseResult.fail("客户端异常");
    }

}
