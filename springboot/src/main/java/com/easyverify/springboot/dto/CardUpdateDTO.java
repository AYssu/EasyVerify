package com.easyverify.springboot.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CardUpdateDTO {

    @NotNull(message = "cid不能为空")
    private Integer cid; // 卡密id
    private String bindImei; // 绑定设备号
    private String bindIp; // 绑定ip
    @NotNull(message = "是否绑定设备不能为空")
    @Max(value = 2 , message = "参数值最大为2")
    @Min(value = 1, message = "参数值最小为1")
    private Integer imeiCheck; // 是否需要绑定设备号
    @NotNull(message = "是否绑定IP不能为空")
    @Max(value = 2 , message = "参数值最大为2")
    @Min(value = 1, message = "参数值最小为1")
    private Integer ipCheck; // 是否需要绑定ip
    private String endTime;// 有效期
    private String introduction; // 描述
    private String coreDate;// 核心数据
}
