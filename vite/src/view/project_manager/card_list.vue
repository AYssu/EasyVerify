<template>
	<div>
		<div style="margin-top: 10px">
			<div v-if="phone_bool" style="display: flex; justify-content: space-between; margin-right: 10px">
				<div style="display: flex; align-items: center; margin-left: 10px; margin-bottom: 20px">
					<div style="background-color: rgb(128, 128, 128); width: 5px; height: 10px; margin-right: 5px"></div>
					<el-text size="small">卡密列表</el-text>
				</div>
				<div>
					<el-button color="#42b983" size="small" :icon="Search" style="color: white">搜索</el-button>
				</div>
			</div>
			<el-form :size="phone_bool ? 'small' : ''" style="margin-left: 10px; max-width: calc(100% - 20px)" :inline="!phone_bool">
				<el-form-item label="单码卡密">
					<el-input placeholder="请输入内容" />
				</el-form-item>
				<el-form-item label="归属程序">
					<el-input placeholder="请输入内容" />
				</el-form-item>
				<el-form-item label="卡密类型" style="min-width: 240px">
					<el-select clearable placeholder="请选择">
						<el-option label="天卡" :value="1" key="1" />
						<el-option label="周卡" :value="2" key="2" />
						<el-option label="月卡" :value="3" key="3" />
						<el-option label="半年卡" :value="4" key="4" />
						<el-option label="年卡" :value="5" key="5" />
						<el-option label="永久卡" :value="6" key="5" />
						<el-option label="自定义时间卡" :value="7" key="6" />
					</el-select>
				</el-form-item>
				<el-form-item label="卡密状态" style="min-width: 240px">
					<el-select clearable placeholder="请选择">
						<el-option label="未激活" :value="1" key="1" />
						<el-option label="未到期" :value="2" key="2" />
						<el-option label="已到期" :value="3" key="3" />
						<el-option label="已拉黑" :value="4" key="4" />
					</el-select>
				</el-form-item>
				<el-form-item v-if="!phone_bool">
					<el-button style="color: white" color="#42b983" :icon="Search" type="primary">搜索</el-button>
				</el-form-item>
			</el-form>
		</div>
		<el-card shadow="never" style="margin: 0 5px; box-sizing: border-box">
			<el-scrollbar :max-height="phone_bool ? '450px' : '550px'">
				<el-table
					:data="tableData"
					:height="phone_bool ? 400 : 500"
					:default-sort="{ prop: 'date', order: 'descending' }"
					:highlight-current-row="true"
					:size="phone_bool ? 'small' : ''"
					v-loading="card_loading"
					ref="multiple_table_ref"
					@selection-change="handle_selection_change"
				>
					<template #empty>
						<el-empty></el-empty>
					</template>
					<el-table-column type="selection" width="55" />

					<el-table-column width="250px">
						<template #header>
							卡密
							<a-tag color="orange" :bordered="false" size="small" style="text-align: center"> 共{{ total }}张</a-tag>
						</template>
						<template #default="scope">
							<el-link style="font-size: 11px">{{ scope.row.cardKey }}</el-link>
							<el-tag :size="phone_bool ? 'small' : ''" type="success" style="margin-left: 5px" @click="copy_text(scope.row.cardKey)">复制</el-tag>
						</template>
					</el-table-column>
					<el-table-column label="归属程序" width="150px">
						<template #default="scope">
							<el-tag>{{ scope.row.projectName }}</el-tag>
						</template>
					</el-table-column>
					<el-table-column label="卡密类型" width="100px">
						<template #default="scope">
							<el-tag :type="get_tag_type(scope.row.cardType)" round>{{ get_card_type_name(scope.row.cardType) }}</el-tag>
						</template>
					</el-table-column>
					<el-table-column label="状态/到期" width="160px" align="center">
						<template #default="scope">
							<el-tag :type="get_status_type(scope.row.cardStatus)" round>{{ get_status_name(scope.row.cardStatus, scope.row.endTime) }}</el-tag>
						</template>
					</el-table-column>
					<el-table-column label="解绑/使用" width="100px">
						<template #default="scope">
							<a-tag color="#17926c70">{{ scope.row.unbindNumber }}/{{ scope.row.useNumber }}</a-tag>
						</template>
					</el-table-column>
					<el-table-column label="使用限制" width="100px">
						<template #default="scope">
							<el-link style="font-size: 12px" :type="scope.row.limitUseNumber == 0 ? 'success' : 'danger'">{{
								scope.row.limitUseNumber == 0 ? '无限制' : scope.row.limitUseNumber + '次'
							}}</el-link>
						</template>
					</el-table-column>
					<el-table-column label="解绑限制" width="100px">
						<template #default="scope">
							<el-link style="font-size: 12px" :type="scope.row.limitUnbindNumber == 0 ? 'success' : 'danger'">{{
								scope.row.limitUnbindNumber == 0 ? '无限制' : scope.row.limitUnbindNumber + '次'
							}}</el-link>
						</template>
					</el-table-column>

					<el-table-column label="创建时间" width="160px">
						<template #default="scope">{{ scope.row.createTime }}</template>
					</el-table-column>
					<el-table-column label="启用" width="100px">
						<template #default="scope">
							<el-switch
								:size="phone_bool ? 'small' : ''"
								v-model="scope.row.state"
								style="--el-switch-on-color: #13ce66; --el-switch-off-color: #ff4949"
								:active-value="1"
								:inactive-value="2"
								disabled
								@click="card_ban_click(scope.row)"
							></el-switch>
						</template>
					</el-table-column>
					<el-table-column label="设备码" width="160px" show-overflow-tooltip>
						<template #default="scope">
							<el-text v-if="scope.row.bindImei == ''">未绑定</el-text>
							<el-text v-else>{{ scope.row.bindImei }}</el-text>
						</template>
					</el-table-column>
					<el-table-column label="IPv4/6" width="160px" show-overflow-tooltip>
						<template #default="scope">
							<el-text v-if="scope.row.bindIp == ''">未绑定</el-text>
							<el-text v-else>{{ scope.row.bindIp }}</el-text>
						</template>
					</el-table-column>

					<el-table-column label="备注" width="160px">
						<template #default="scope">
							<el-text v-if="scope.row.introduction == ''">无</el-text>
							<el-popover placement="top-start" title="卡密备注" :width="300" trigger="hover" :content="scope.row.introduction">
								<template #reference>
									<el-text size="small">{{ sort_text(scope.row.introduction) }}</el-text>
								</template>
							</el-popover>
						</template>
					</el-table-column>
					<el-table-column label="操作" width="200">
						<template #default="scoop: any">
							<el-button
								plain
								size="small"
								type="primary"
								@click="
									() => {
										edit_card_ref = JSON.parse(JSON.stringify(scoop.row));
										console.log(edit_card_ref);
										if (edit_card_ref.endTime != null) edit_data = dayjs(edit_card_ref.endTime, dateFormat);
										else edit_data = null;
										edit_card_open = true;
									}
								"
								>编辑</el-button
							>
							<el-button plain size="small" type="danger">删除</el-button>
						</template>
					</el-table-column>
				</el-table>
				<el-row style="margin-top: 10px">
					<el-select :size="phone_bool ? 'small' : ''" :style="phone_bool ? 'max-width: 140px' : 'max-width: 300px'" placeholder="批量操作">
						<el-option label="批量禁用" :value="1" />
						<el-option label="批量解禁" :value="2" />
						<el-option label="删除选中" :value="3" />
						<el-option label="加时选中" :value="4" />
						<el-option label="修改备注" :value="5" />
						<el-option label="导出选中" :value="6" />
						<el-option label="解绑选中" :value="7" />
					</el-select>
					<a-button :size="phone_bool ? 'small' : ''" style="margin-left: 5px; font-size: 12px" @click="do_some_click">确定</a-button>
				</el-row>
			</el-scrollbar>
		</el-card>
		<div style="margin-top: 20px; display: flex; justify-content: flex-end; margin-right: 20px">
			<el-pagination
				v-model:current-page="currentPage2"
				v-model:page-size="pageSize2"
				:background="background"
				:disabled="disabled"
				:page-sizes="[100, 200, 300, 400]"
				:size="size"
				:total="total"
				layout="sizes, prev, pager, next"
				@size-change="handle_size_change"
				@current-change="handle_current_change"
			/>
		</div>
		<a-drawer :open="edit_card_open" :width="phone_bool ? '80%' : '40%'" :closable="false" @close="() => (edit_card_open = false)">
			<template #title>
				<div style="display: flex; justify-content: space-between">
					<el-text>编辑卡密</el-text>
					<div>
						<a-button :loading="loading" type="primary" :size="phone_bool ? 'small' : ''" @click="card_update_click">更新</a-button>
					</div>
				</div>
			</template>
			<el-form label-position="top" :size="phone_bool ? 'small' : ''">
				<el-form-item label="卡密">
					<el-input placeholder="请输入卡密" disabled :value="edit_card_ref.cardKey"></el-input>
				</el-form-item>
				<el-form-item label="绑定新设备">
					<el-input placeholder="请输入新设备码" v-model="edit_card_ref.bindImei"></el-input>
				</el-form-item>
				<el-form-item label="绑定新IP">
					<el-input placeholder="请输入新设备码" v-model="edit_card_ref.bindIp"></el-input>
				</el-form-item>
				<el-form-item label="设备码验证">
					<el-select placeholder="请选中" v-model="edit_card_ref.imeiCheck">
						<el-option label="开启" :value="2" />
						<el-option label="关闭" :value="1" />
					</el-select>
				</el-form-item>
				<el-form-item label="IP验证">
					<el-select placeholder="请选中" v-model="edit_card_ref.ipCheck">
						<el-option label="开启" :value="2" />
						<el-option label="关闭" :value="1" />
					</el-select>
				</el-form-item>
				<el-form-item label="到期时间">
					<a-date-picker format="YYYY年MM月DD日" :size="phone_bool ? 'small' : ''" style="width: 100%" v-model:value="edit_data">
						<template #suffixIcon>
							<SmileOutlined />
						</template>
					</a-date-picker>
				</el-form-item>
				<el-form-item label="备注">
					<el-input
						placeholder="请输入备注"
						type="textarea"
						maxlength="128"
						:autosize="{ maxRows: 10, minRows: 2 }"
						show-word-limit
						v-model="edit_card_ref.introduction"
					></el-input>
				</el-form-item>
				<el-form-item label="核心数据">
					<el-input
						placeholder="请输入内容"
						type="textarea"
						maxlength="1024"
						:autosize="{ maxRows: 10, minRows: 2 }"
						show-word-limit
						v-model="edit_card_ref.coreDate"
					></el-input>
				</el-form-item>
			</el-form>
		</a-drawer>
	</div>
</template>
<style lang="scss" scoped></style>
<script lang="ts" setup>
import { onMounted, onUnmounted, ref } from 'vue';
import { ComponentSize, ElTable } from 'element-plus';
import phone_size from '@/utils/phone_size';
import { Search } from '@element-plus/icons-vue';
import { card_ban_services, card_update_services, get_project_card_list_services } from '@/api/card';
import { SmileOutlined } from '@ant-design/icons-vue';
import dayjs, { Dayjs } from 'dayjs';
import { message, Modal } from 'ant-design-vue';
const { phone_bool, remove_phone_size } = phone_size();

const multiple_table_ref = ref<InstanceType<typeof ElTable>>();
const multiple_selection = ref<any>([]);

const edit_card_open = ref<boolean>(false);
const dateFormat = 'YYYY-MM-DD HH:mm:ss';
const edit_card_ref = ref();
const edit_data = ref<Dayjs | null>(dayjs('2012-12-12 12:12:12', dateFormat));
const loading = ref<boolean>(false);

/**
 * 更新卡密信息
 */
const card_update_click = async () => {
	loading.value = true;
	try {
		if (edit_data.value == null) edit_card_ref.value.endTime = null;
		else edit_card_ref.value.endTime = edit_data.value.format(dateFormat);
		const result = await card_update_services(edit_card_ref.value);

		if (result.data.code == 200) {
			message.success('修改成功');
			edit_card_open.value = false;
			await get_card_list();
		} else {
			message.error(result.data.message);
		}
	} catch (e) {
		console.log(e);
	}
	loading.value = false;
};
/**
 * 多选
 * @param val
 */
const handle_selection_change = (val: any) => {
	multiple_selection.value = val;
};

const card_loading = ref<boolean>(false);
const tableData = ref();

const currentPage2 = ref(1);
const pageSize2 = ref(100);
const total = ref(0);
const size = ref<ComponentSize>('small');
const background = ref(false);
const disabled = ref(false);

/**
 * 旧版复制 某些浏览器对新版本的复制支持不咋好 比如手机端的某ia
 * @param text
 */
const old_copy = (text: string) => {
	const textArea = document.createElement('textarea');
	textArea.value = text;
	textArea.style.top = '0';
	textArea.style.left = '0';
	textArea.style.position = 'fixed'; // 防止在页面上显示
	document.body.appendChild(textArea);
	textArea.focus();
	textArea.select();
	try {
		const successful = document.execCommand('copy');
		if (successful) {
			message.success('复制成功');
		} else {
			message.error('复制失败，请手动复制');
		}
	} catch (err) {
		message.error('复制失败，请手动复制');
		console.error('无法复制文本: ', err);
	}

	document.body.removeChild(textArea);
};

/**
 * 复制文本
 * @param key 文本
 */
const copy_text = (key: string) => {
	if (key == '' || key == undefined) {
		Modal.error({
			title: '复制失败',
			zIndex: 99999999999,
			content: '复制失败，内容为空',
			maskClosable: true,
		});
		return;
	}
	// 检查 key 的长度，如果超过20个字符，则截断并添加省略号
	const display_key = key.length > 40 ? key.substring(0, 40) + '...' : key;
	console.log('copy', key);
	Modal.success({
		title: '复制文本',
		content: display_key,
		okText: '复制',
		cancelText: '取消',
		maskClosable: true,
		okCancel: true,
		zIndex: 999999999,
		onOk: () => {
			// 复制文本到剪贴板
			if (navigator.clipboard) {
				navigator.clipboard
					.writeText(key)
					.then(() => {
						message.success('复制成功');
					})
					.catch((error) => {
						message.error('复制失败，请手动复制');
						console.error('复制失败:', error);
					});
			} else {
				old_copy(key);
			}
		},
		onCancel: () => {},
	});
};

/**
 * 禁用/启用
 * @param scoop
 */
const card_ban_click = async (scoop: any) => {
	Modal.confirm({
		title: '提示',
		content: '是否禁用/启用该卡密?',
		onOk: async () => {
			const params = new URLSearchParams();
			params.append('cid', scoop.cid);
			const result = await card_ban_services(params);
			try {
				if (result.data.code == 200) {
					message.success('操作成功');
					scoop.state = scoop.state == 1 ? 2 : 1;
				} else {
					message.error(result.data.message);
				}
			} catch (e) {
				console.log(e);
			}
		},
	});
};
/**
 * 获取卡密列表
 */
const handle_size_change = () => {
	get_card_list();
};

/**
 * 获取卡密列表
 */
const handle_current_change = () => {
	get_card_list();
};

/**
 * 截取字符串
 * @param text
 */
const sort_text = (text: string) => {
	// 如果文本为空或未定义，返回空字符串
	if (text === '' || text == undefined) return '';

	// 去掉文本中的所有换行符
	text = text.replace(/(\r\n|\n|\r)/gm, '');

	// 如果处理后的文本长度小于或等于14，返回前14个字符
	if (text.length <= 7) return text;

	// 否则返回前14个字符并附加'...'
	return text.slice(0, 7) + '...';
};

/**
 * 批量操作
 */
const do_some_click = () => {
	console.log(multiple_selection.value);
};

/**
 * 获取卡密类型名称
 * @param card_type
 */
const get_card_type_name = (card_type: number) => {
	const card_types: any = {
		1: '天卡',
		2: '周卡',
		3: '月卡',
		4: '半年卡',
		5: '年卡',
		6: '永久卡',
		7: '自定义卡',
	};
	return card_types[card_type] || '未知卡类型';
};

/**
 * 获取标签类型
 * @param card_type
 */
const get_tag_type = (card_type: number) => {
	const tag_types: any = {
		1: 'info',
		2: 'warning',
		3: 'primary',
		4: 'danger',
		5: 'success',
		6: 'danger',
		7: 'success',
	};
	return tag_types[card_type] || 'info'; // 默认返回 info 类型
};

/**
 * 获取状态类型
 * @param status
 */
const get_status_type = (status: number) => {
	const tag_types: any = {
		1: 'info',
		2: 'danger',
		3: 'success',
	};
	return tag_types[status] || 'info'; // 默认返回 info 类型
};

/**
 * 获取状态名称
 * @param status
 * @param end_time
 */
const get_status_name = (status: number, end_time: string) => {
	const card_types: any = {
		1: '未激活',
		2: '已到期',
		3: end_time,
	};
	return card_types[status] || '未知';
};

/**
 * 获取卡密列表
 */
const get_card_list = async () => {
	card_loading.value = true;
	const params = {
		currentPage: currentPage2.value,
		pageSize: pageSize2.value,
	};
	const result = await get_project_card_list_services(params);
	try {
		tableData.value = result.data.data.items;
		total.value = result.data.data.total;
	} catch (e) {
		console.log(e);
	}
	card_loading.value = false;
};
onMounted(() => {
	get_card_list();
});
onUnmounted(() => {
	remove_phone_size();
});
</script>
