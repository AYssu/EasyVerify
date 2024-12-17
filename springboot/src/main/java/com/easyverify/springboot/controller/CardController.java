package com.easyverify.springboot.controller;

import com.easyverify.springboot.dto.CardListDTO;
import com.easyverify.springboot.dto.CardUpdateDTO;
import com.easyverify.springboot.service.CardService;
import com.easyverify.springboot.vo.CardVo;
import com.easyverify.springboot.vo.PageBean;
import com.easyverify.springboot.vo.ResponseResult;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/card")
@Slf4j
public class CardController {

    @Autowired
    private CardService cardService;
    @PostMapping("/get_card_list")
    public ResponseResult<?> get_card_list(@RequestBody @Validated CardListDTO cardListDTO)
    {
        log.info("card_list_form: {}", cardListDTO);
        PageBean<CardVo> pageBean = cardService.get_card_list(cardListDTO.getCurrentPage(), cardListDTO.getPageSize());
        return ResponseResult.success("查询成功",pageBean);
    }

    @PostMapping("/card_update")
    public ResponseResult<?> card_update(@RequestBody @Validated CardUpdateDTO cardUpdateDTO)
    {
        log.info("card_update_form: {}", cardUpdateDTO);
        boolean success = cardService.update_card_info(cardUpdateDTO.getCid(), cardUpdateDTO.getBindImei(), cardUpdateDTO.getBindIp(), cardUpdateDTO.getImeiCheck(),cardUpdateDTO.getIpCheck(), cardUpdateDTO.getEndTime(), cardUpdateDTO.getIntroduction(), cardUpdateDTO.getCoreDate());
        if (!success)
            return ResponseResult.fail("修改失败");
        return ResponseResult.success("修改成功");
    }

    @PostMapping("/card_ban")
    public ResponseResult<?> card_ban(@RequestParam Integer cid )
    {
        log.info("card_ban_form: {}", cid);
        boolean success = cardService.card_ban(cid);
        if (!success)
            return ResponseResult.fail("设置失败");
        return ResponseResult.success("设置成功");
    }
    
}
