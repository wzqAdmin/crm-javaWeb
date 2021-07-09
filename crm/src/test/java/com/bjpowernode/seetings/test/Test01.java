package com.bjpowernode.seetings.test;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * 测试类
 */
public class Test01 {
    public static void main(String[] args) {
      /*  *//*如何验证用户的登录时间是否失效?*//*
         //1、用户的失效时间
        String expireTime = "2020-12-24 13:00:00";
         //2、获取用户登录的当前系统时间
          //2.1获取当前系统未经过格式化的事件
        Date date = new Date();
          //3、格式化当前系统时间，格式与数据库中表的字段格式一样
            //3.1设置时间的格式
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            //3.2通过format方法格式化时间
        String sdfDate = sdf.format(date);
          *//*
            4、使用String类的 对象1.compareto(对象2) 方法进行字符串的比较
               对象1>对象2  返回>0
               对象1=对象2  返回=0
               对象1<对象2  返回<0
           *//*
        int result = expireTime.compareTo(sdfDate);
        if(result > 0 || result == 0){
            System.out.println("登录时间合法！");
        }else{
            System.out.println("登录时间不合法");
        }*/

       /* *//*如何判断用户的账户是否锁定*//*
        String lockState = "0";
        if ("0".equals(lockState)){
            System.out.println("账号已锁定！");
        }*/

       /* *//*如何判断用户的登录IP是否合法*//*
        String userIP = "192.168.1.1";   //用户的登录ip
        String allowIps = "192.168.1.1,192.168.1.2"; //合法的ip
         //使用String类的 对象1.contains(对象2) 的方式，判断对象1是否包含对象2
        if(allowIps.contains(userIP)){
            System.out.println("用户的ip合法");
        }*/
    }
}
