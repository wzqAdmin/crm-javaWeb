package com.bjpowernode.crm.settings.service.impl;

import com.bjpowernode.crm.exception.LoginException;
import com.bjpowernode.crm.settings.dao.UserDao;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.SqlSessionUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UserServiceImpl implements UserService {

    /*
       由于service的实现类需要调用数据库，这里需要创建一个成员变量，供所有的方法使用，由于dao层没有实现类，
      所以我们可以使用SqlSessionUtil.getSqlSession().getMapper(UserDao.class) 来通过dao层的接口创建一个
      类似于dao实现类的对象，从而操作数据库

      这里getMapper的作用是：通过代理：生成接口的实现类
    */
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    /**
     * 判断用户登录的方法
     * @param loginAct 用户名
     * @param loginPwd 密码
     * @param ip 用户的ip地址
     * @return 当用户登录成功后，返回用户的信息
     * @throws LoginException 自定义异常，用于响应用户登录失败的信息
     */
    public User login(String loginAct, String loginPwd, String ip) throws LoginException {

        //创建map集合，方便存储loginAct和loginPwd
        Map<String,String> map=new HashMap<String, String>();
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);

        //调用Dao层接口，通过接口找到mapper映射文件，从而执行sql语句
        User user = userDao.login(map);

        //判断登录是否成功，如果成功，user就不是null
        if (user == null){
            //自定义异常
            throw new LoginException("账号或密码错误");
        }

        //如果程序能执行到这，说明账号密码都正确
        String expireTime = user.getExpireTime();  //获取返回的失效时间
        String currentTime = DateTimeUtil.getSysTime();  //获取当前的系统时间

        //如果账户的失效时间小于当前的系统时间，则代表账户已经过期
        if(expireTime.compareTo(currentTime)<0){
            throw new LoginException("账号已失效");
        }

        /*判断账号的锁定状态*/
        String lockState = user.getLockState();
        if("0".equals(lockState)){
            throw new LoginException("账号已锁定");
        }

        /*判断用户的id地址是否合法*/
        String allowIps = user.getAllowIps();
        if( !allowIps.contains(ip) ){
            throw new LoginException("你的Ip地址没有访问权限");
        }

        //具体的业务层...
        return  user;
    }

    /**
     * 查询市场活动所有者的方法
     * @return 所有市场活动所有者对应的信息，由实体类保存
     */
    public List<User> getUserList() {
        List<User> uList = userDao.getUserList();
        return uList;
    }
}
