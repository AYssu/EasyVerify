package com.easyverify.springboot.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.easyverify.springboot.entity.EasyCard;
import com.easyverify.springboot.entity.EasyProject;
import com.easyverify.springboot.vo.CardVo;
import com.easyverify.springboot.vo.PageBean;

public interface CardService extends IService<EasyCard> {
    /**
     * 分页查询 卡片列表
     * @param currentPage 当前页码
     * @param pageSize 每页显示条数
     * @return PageBean
     */
    PageBean<CardVo> get_card_list(Integer currentPage, Integer pageSize);

    /**
     * 根据项目id获取项目信息
     * @param id 项目id
     * @return EasyProject
     */
    EasyProject get_project_by_id(Integer id);

    /**
     * 更新卡片信息
     * @param cid 卡片id
     * @param bindImei 绑定设备号
     * @param bindIp 绑定ip
     * @param imeiCheck 是否绑定设备
     * @param ipCheck 是否绑定ip
     * @param endTime 卡片有效期
     * @param introduction 卡片介绍
     * @param coreDate 卡片核心数据
     * @return boolean
     */
    boolean update_card_info(Integer cid, String bindImei, String bindIp, Integer imeiCheck,Integer ipCheck, String endTime, String introduction, String coreDate);

    /**
     * 卡片封禁
     * @param cid 卡片id
     * @return boolean
     */
    boolean card_ban(Integer cid);
}
