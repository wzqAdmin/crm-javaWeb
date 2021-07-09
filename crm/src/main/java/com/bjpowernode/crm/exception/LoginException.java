package com.bjpowernode.crm.exception;

/**
 *  用户的登录异常
 *    在软件的运行中，如果用户登录失败，需要往浏览器返回数据，
 *    这些数据是以自定义异常的形式返回的
 */
public class LoginException extends Exception{

    //自定义异常，通过传递message消息来返回这个消息
    public LoginException(String msg) {
       super(msg);
    }
}
