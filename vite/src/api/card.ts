import request from '@/utils/request';

/**
 * 获取卡密列表
 * @param params
 */
export const get_project_card_list_services = (params: any) => {
	return request.post('/card/get_card_list', params);
};

/**
 * 更新卡密
 * @param params
 */
export const card_update_services = (params: any) => {
	return request.post('/card/card_update', params);
};

/**
 * 禁用卡密/启用卡密
 * @param params
 */
export const card_ban_services = (params: any) => {
	return request.post('/card/card_ban', params);
};
