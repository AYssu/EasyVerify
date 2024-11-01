package com.easyverify.springboot.controller;

import com.easyverify.springboot.dto.ProjectCreateDTO;
import com.easyverify.springboot.dto.ProjectListDTO;
import com.easyverify.springboot.vo.ResponseResult;
import com.easyverify.springboot.service.ProjectService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("project")
@Slf4j
public class ProjectController {

    // 自动装配
    @Autowired
    private ProjectService projectService;
    @PostMapping("project_create")
    public ResponseResult<?> project_create(@RequestBody @Validated ProjectCreateDTO projectCreateDTO){
        log.info("project_create_form: {}", projectCreateDTO);
        // 调用service层 创建项目
        boolean create_success = projectService.create_project(projectCreateDTO);
        if (!create_success) {
            return ResponseResult.fail("创建失败");
        }
        return ResponseResult.success("创建成功");
    }

    @PostMapping("project_list")
    public ResponseResult<?> project_list(@RequestBody @Validated ProjectListDTO projectListDTO){
        log.info("project_list_form: {}", projectListDTO);
        // 调用service层
        return ResponseResult.success("查询成功", projectService.get_project_list(projectListDTO));
    }


    @GetMapping("project_set_status")
    public ResponseResult<?> project_set_status(@RequestParam Integer id){
        log.info("project_set_status_form: {}", id);
        boolean set_success = projectService.set_project_status(id);
        if (!set_success)
            return ResponseResult.fail("设置失败");
        return ResponseResult.success("设置成功");
    }
}
