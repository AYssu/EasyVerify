package com.easyverify.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.easyverify.springboot.entity.EasyUser;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper extends BaseMapper<EasyUser> {
}
