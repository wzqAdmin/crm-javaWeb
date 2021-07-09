package com.bjpowernode.crm.settings.web.controller;

import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.settings.service.impl.UserServiceImpl;
import com.bjpowernode.crm.utils.MD5Util;
import com.bjpowernode.crm.utils.PrintJson;
import com.bjpowernode.crm.utils.ServiceFactory;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * 基于Servlet模板模式进行开发
 * 每一个模块对应着一个Servlet，不是像以前一样，每一个业务对应Servlet
 * 那样的话Servlet的规模会非常大
 */
public class UserController extends HttpServlet {

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入用户控制器");
        //获取用于访问的servlet路径，即web.xml中<url-pattern>的值,带'/'前缀
        String path = request.getServletPath();

        //如果用户访问的是登录业务
        if("/settings/user/login.do".equals(path)){

            login(request,response);

        }

    }

    private void login(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("执行用户登录操作");

        //获取前端的loginAct和loginPwd
        String loginAct = request.getParameter("loginAct");
        String loginPwd = request.getParameter("loginPwd");
        //将loginPwd解析为密文的形式，为的是与后台的数据库进行比对
        loginPwd = MD5Util.getMD5(loginPwd);

        //接收用户本机的IP地址
        String ip = request.getRemoteAddr();

        //创建接口的代理类对象进行处理业务
        /*
          这里明明是登录操作，为什么要使用代理对象呢，而不是直接使用Service层的实现类对象呢？
           难道还需要进行事物的处理吗？
              在这里，代理类的作用是处理ServiceImpl不方便处理的业务部分，比如回滚事物，提交事物等
              而这些操作并不是处理业务的大体步骤，如果写在了Service层就不符合了MVC开发原则，
              后期维护困难，所以要在Service层中加入一个代理，增强其功能，来实现这些操作。
              来保证Service层中只有调用dao层的代码。

              总：在后期进行扩展的时候，虽然只是登录业务，但是可能涉及数据库的日志修改操作，
                  这就涉及到事物(数据库中的记录)了，当发生异常时回滚事物，当执行顺利时提交事物，
                  ServiceImpl不能完成这个需求

              总结：记住：未来业务层开发，统一使用代理类形态的接口对象，方便扩展
         */

        //getService(实现类) ： 传递实现类，获取该实现类的代理
        UserService us = (UserService) ServiceFactory.getService(new UserServiceImpl());

        //进行登录验证
        /*
           这里为什么使用try...catch呢？
             因为要判断是否登录成功还是失败，如果失败，是以自定义异常的形式展现出来的，
             controller必须处理这个异常，把这个异常返回给前端
         */
        try{
            //如果这里出现了异常，则代表后台验证错误，即登录失败
            User user = us.login(loginAct,loginPwd,ip);

            //如果程序执行到这里，则代表上一句没有出现异常，将封装的结果返回给前端
            /*
              为什么要使用HttpSession对象保存呢？而不是使用HttpServletContext(application)保存呢？
                因为HttpServletContext对象的声明周期，与http服务器的关闭一样，声明周期太长，http服务器会
                一直运行的，而当用户关闭这个网站时，保存的数据就应该被清除，所以不方便保存为HttpServletContext

                为什么不用HttpServletRequest呢？
                 因为这个request(请求作用域对象)的生命周期在推送Http响应包的时候就结束了

               选择对象的原则：在合适的条件下，能用范围小的就用范围小的
                               request>session>context

               这里使用session域的原因是，当登录成功时，前台还需要拿到zs的具体信息进行展示
               而不仅仅是为了登录成功就完了，比如在右上角展现用户的真实姓名，这就需要从session中取得
             */
            request.getSession().setAttribute("user",user);

            //将登录成功的结果返回给前端 json形式：{“success”:true}
            /*
               返回这种形式的原因是前端的ajax请求决定的
             */
            PrintJson.printJsonFlag(response,true);


        }catch(Exception e){
            //表示登录失败
            e.printStackTrace();
            //一旦程序执行了catch块的信息，说明业务层为我们验证登录失败，为controller抛出了异常
            //获取抛出的异常信息
            String msg = e.getMessage();

            /*
              {"success":false,"msg":?}

             如何传递着两个信息呢？
               我们现在作为contoller，需要为ajax请求提供多项信息

                可以有两种手段来处理：
                    （1）将多项信息打包成为map，将map解析为json串
                    （2）创建一个Vo
                            private boolean success;
                            private String msg;


                    如果对于展现的信息将来还会大量的使用，我们创建一个vo类，使用方便
                    如果对于展现的信息只有在这个需求中能够使用，我们使用map就可以了
             */
            Map<String,Object>  map= new HashMap<String, Object>();
            map.put("success",false);
            map.put("msg",msg);

            //调用jason工具类，将json解析成Stirng，并返回给前端
            PrintJson.printJsonObj(response,map);

        }

    }
}
