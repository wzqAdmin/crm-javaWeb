package com.bjpowernode.crm.settings.dao;

import com.bjpowernode.crm.exception.LoginException;
import com.bjpowernode.crm.settings.domain.User;

import java.util.List;
import java.util.Map;

/**
 * User的mapper映射文件对应的接口类
 * 用于和mapper映射文件联系起来
 */
public interface UserDao {

    User login(Map<String, String> map) throws LoginException;

    List<User> getUserList();
}
