/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 80036 (8.0.36)
 Source Host           : localhost:3306
 Source Schema         : easy_verify

 Target Server Type    : MySQL
 Target Server Version : 80036 (8.0.36)
 File Encoding         : 65001

 Date: 17/12/2024 22:01:48
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for easy_card
-- ----------------------------
DROP TABLE IF EXISTS `easy_card`;
CREATE TABLE `easy_card`  (
  `cid` int NOT NULL AUTO_INCREMENT COMMENT '卡密ID',
  `pid` int NOT NULL COMMENT '程序ID',
  `uid` int NOT NULL COMMENT '创建用户ID',
  `card_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '卡密字段',
  `card_type` int NULL DEFAULT 1 COMMENT '卡密类型\r\n1.天卡\r\n2.周卡\r\n3.月卡\r\n4.半年卡\r\n5.年卡\r\n6.永久卡\r\n7.自定义时间卡',
  `card_time` int NOT NULL DEFAULT 1 COMMENT '卡密倍率',
  `bind_imei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '绑定设备标识',
  `bind_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最后登录IP',
  `first_bind_time` datetime NULL DEFAULT NULL COMMENT '第一次登录时间',
  `create_time` datetime NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '第一次创建卡密时间',
  `last_use_time` datetime NULL DEFAULT NULL COMMENT '最后一次登录时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '到期时间',
  `use_number` int NOT NULL DEFAULT 0 COMMENT '使用次数',
  `unbind_number` int NOT NULL DEFAULT 0 COMMENT '解绑次数',
  `imei_check` int NULL DEFAULT 2 COMMENT '是否开启设备码验证',
  `ip_check` int NULL DEFAULT 1 COMMENT '是否开启网络IP验证',
  `introduction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '卡密备注',
  `core_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '核心数据，卡密标记内容',
  `limit_use_number` int NOT NULL DEFAULT 0 COMMENT '限制使用次数',
  `limit_unbind_number` int NOT NULL DEFAULT 0 COMMENT '限制解绑次数',
  `need_imei` int NOT NULL DEFAULT 1 COMMENT '是否需要设备码',
  `state` int NULL DEFAULT 1 COMMENT '是否拉黑',
  `deleted` int NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`cid`, `card_key`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 224 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for easy_link
-- ----------------------------
DROP TABLE IF EXISTS `easy_link`;
CREATE TABLE `easy_link`  (
  `aid` int NOT NULL AUTO_INCREMENT COMMENT 'API ID',
  `link` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '链接',
  `project_id` int NOT NULL COMMENT '程序ID',
  `type` int NOT NULL COMMENT '链接格式 \r\n1.单码卡密登录 \r\n2.解绑或换机器码 \r\n3.用户登录 \r\n4.获取程序公告 \r\n5.更新查询 \r\n6.获取程序变量列表 \r\n7.单码心跳 \r\n8.用户心跳 ',
  `code` int NOT NULL DEFAULT 200 COMMENT '返回校验码',
  `code_type` int NOT NULL DEFAULT 1 COMMENT 'code返回格式 \r\n1. int 类型\r\n2. string 类型',
  `safe_type` int NOT NULL DEFAULT 1 COMMENT '安全传输 \r\n1. 开启 \r\n2. 关闭',
  `return_time` int NOT NULL DEFAULT 1 COMMENT '返回时间戳 \r\n1. 返回 \r\n2. 不返回',
  PRIMARY KEY (`aid`, `link`) USING BTREE,
  INDEX `project_id_link`(`project_id` ASC) USING BTREE,
  CONSTRAINT `project_id_link` FOREIGN KEY (`project_id`) REFERENCES `easy_project` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 60 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for easy_permission
-- ----------------------------
DROP TABLE IF EXISTS `easy_permission`;
CREATE TABLE `easy_permission`  (
  `permission_id` int NOT NULL COMMENT '权限ID',
  `permission_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限名称',
  `permission_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限简绍',
  PRIMARY KEY (`permission_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for easy_project
-- ----------------------------
DROP TABLE IF EXISTS `easy_project`;
CREATE TABLE `easy_project`  (
  `project_id` int NOT NULL AUTO_INCREMENT COMMENT '程序主键',
  `project_user` int NOT NULL COMMENT '创建程序的用户',
  `project_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建程序的名称',
  `project_create_time` datetime NOT NULL COMMENT '程序创建的时间',
  `project_model` int NULL DEFAULT 1 COMMENT '程序的模式 \r\n1. 收费模式\r\n2. 免费模式\r\n3. 加时模式',
  `project_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '程序对接的密钥',
  `project_message` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '程序的一些简介',
  `project_notice` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '程序的公告',
  `return_update` int NOT NULL DEFAULT 1 COMMENT '验证程序更新为最新版本返回公告',
  `return_verify` int NOT NULL DEFAULT 1 COMMENT '用户登录或卡密登录成功返回变量',
  `project_encryption` int NOT NULL DEFAULT 1 COMMENT '程序加密方式 \r\n1. base64自定义编码 \r\n2. rsa非对称加密',
  `project_rsa_private` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'RAS私钥',
  `project_rsa_public` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'RAS公钥',
  `project_base64` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '程序的自定义BASE64编码',
  `project_status` int NOT NULL DEFAULT 0 COMMENT '程序的状态 \r\n0 正常\r\n1 关闭程序',
  `free_status` int NOT NULL DEFAULT 0 COMMENT '程序是否免费状态 任何登录请求都会通过',
  `deleted` int NOT NULL DEFAULT 0 COMMENT '逻辑删除的标识',
  PRIMARY KEY (`project_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10018 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for easy_project_update
-- ----------------------------
DROP TABLE IF EXISTS `easy_project_update`;
CREATE TABLE `easy_project_update`  (
  `update_id` int NOT NULL AUTO_INCREMENT COMMENT '更新ID',
  `project_id` int NOT NULL COMMENT '程序绑定ID',
  `update_version` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '1000' COMMENT '程序更新版本',
  `update_message` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '未设置公告,请前往控制台更改' COMMENT '更新公告',
  `update_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'https://example.com' COMMENT '更新链接',
  `must_update` int NOT NULL DEFAULT 1 COMMENT '是否强制更新',
  `deleted` int NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`update_id`) USING BTREE,
  INDEX `easy_project_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `easy_project_id` FOREIGN KEY (`project_id`) REFERENCES `easy_project` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for easy_role_permissions
-- ----------------------------
DROP TABLE IF EXISTS `easy_role_permissions`;
CREATE TABLE `easy_role_permissions`  (
  `role_permission_id` int NOT NULL COMMENT '用户权限ID',
  `role_id` int NULL DEFAULT NULL COMMENT '角色ID',
  `permission_id` int NULL DEFAULT NULL COMMENT '权限ID',
  PRIMARY KEY (`role_permission_id`) USING BTREE,
  INDEX `role_id_`(`role_id` ASC) USING BTREE,
  INDEX `permissiom_id`(`permission_id` ASC) USING BTREE,
  CONSTRAINT `permissiom_id` FOREIGN KEY (`permission_id`) REFERENCES `easy_permission` (`permission_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `role_id_` FOREIGN KEY (`role_id`) REFERENCES `easy_roles` (`role_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for easy_roles
-- ----------------------------
DROP TABLE IF EXISTS `easy_roles`;
CREATE TABLE `easy_roles`  (
  `role_id` int NOT NULL COMMENT '角色ID',
  `role_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `role_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色描述',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for easy_user
-- ----------------------------
DROP TABLE IF EXISTS `easy_user`;
CREATE TABLE `easy_user`  (
  `user_id` int NOT NULL AUTO_INCREMENT COMMENT '用户标识ID',
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户账号',
  `user_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户邮箱\r\n',
  `user_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户绑定的手机号',
  `user_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户密码',
  `user_avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户头像',
  `level` int NOT NULL DEFAULT 1 COMMENT '用户等级',
  `signature` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户签名',
  `register_time` datetime NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '用户创建时间',
  `deleted` int NOT NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for easy_user_roles
-- ----------------------------
DROP TABLE IF EXISTS `easy_user_roles`;
CREATE TABLE `easy_user_roles`  (
  `user_role_id` int NOT NULL COMMENT '用户角色ID',
  `user_id` int NULL DEFAULT NULL COMMENT '用户ID',
  `role_id` int NULL DEFAULT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_role_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `role_id`(`role_id` ASC) USING BTREE,
  CONSTRAINT `role_id` FOREIGN KEY (`role_id`) REFERENCES `easy_roles` (`role_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `user_id` FOREIGN KEY (`user_id`) REFERENCES `easy_user` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for easy_variable
-- ----------------------------
DROP TABLE IF EXISTS `easy_variable`;
CREATE TABLE `easy_variable`  (
  `vid` int NOT NULL AUTO_INCREMENT COMMENT '变量ID',
  `project_id` int NULL DEFAULT NULL COMMENT '程序ID',
  `variable_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '变量数据',
  PRIMARY KEY (`vid`) USING BTREE,
  INDEX `project_id_veriable`(`project_id` ASC) USING BTREE,
  CONSTRAINT `project_id_veriable` FOREIGN KEY (`project_id`) REFERENCES `easy_project` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for open_user
-- ----------------------------
DROP TABLE IF EXISTS `open_user`;
CREATE TABLE `open_user`  (
  `open_user_id` int NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `open_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户邮箱',
  `open_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户密码',
  `open_svip_time` datetime NULL DEFAULT NULL COMMENT '用户体验时长',
  `open_last_solo_time` datetime NULL DEFAULT NULL COMMENT '用户体验时间 每天一次',
  `open_vip` int NULL DEFAULT 1 COMMENT '用户VIP',
  `open_create_time` datetime NOT NULL COMMENT '用户绑定时间',
  `deleted` int NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`open_user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for open_user_project
-- ----------------------------
DROP TABLE IF EXISTS `open_user_project`;
CREATE TABLE `open_user_project`  (
  `open_user_project_id` int NOT NULL AUTO_INCREMENT COMMENT '用户程序ID',
  `open_user_id` int NOT NULL COMMENT '用户ID',
  `project_id` int NOT NULL COMMENT '程序ID',
  PRIMARY KEY (`open_user_project_id`) USING BTREE,
  INDEX `oepn_user_id`(`open_user_id` ASC) USING BTREE,
  INDEX `project_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `oepn_user_id` FOREIGN KEY (`open_user_id`) REFERENCES `open_user` (`open_user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `project_id` FOREIGN KEY (`project_id`) REFERENCES `easy_project` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
