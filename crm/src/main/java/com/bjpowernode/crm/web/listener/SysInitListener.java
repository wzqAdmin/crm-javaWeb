package com.bjpowernode.crm.web.listener;

import com.bjpowernode.crm.settings.domain.DicValue;
import com.bjpowernode.crm.settings.service.DicService;
import com.bjpowernode.crm.settings.service.impl.DicServiceImpl;
import com.bjpowernode.crm.utils.ServiceFactory;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.*;

/**
 *  用于操作数据字典的监听器
 *    数据字典的作用：在整个网页中，用户选择的下拉列表、单选/复选按钮的数据来源都是来自于数据字典
 *    这样做的好处是：能够达到一改全改，即只需要修改数据库中的值，对应前端展现的效果会随之改变
 *
 *  数据字典的保存形式：
 *    按照数据字典的类型分类，将不同类型的数据字典封装到List集合中，最后将这些List封装到map中
 *    如：
 *      List<DicValue> dList1 = select * from tbl_dic_value where typeCode='appellation'
 *      List<DicValue> dList2 = select * from tbl_dic_value where typeCode='source'
 *      ...
 *      List<DicValue> dList7 = select * from tbl_dic_value where typeCode='xxx'
 *
 *      Map<String,List<DicValue>> map=new HashMap<>();
 *      map.put("appellationList",dList1);
 *      map.put("sourceList",dList2);
 *      .....
 *      map.put("xxxList",dList7);
 *
 *   然后再循环map，key作为application中的key，List作为value存入到上下文作用域对象中
 *
 *      application.setAttribute(appellationList,dList1);
 *      application.setAttribute(sourceList,dList2);
 *      .....
 *    前端如果想展示数据，则只需要
 *      1）先取得类型为key的List集合
 *      2）遍历这个List
 *
 *
 *  用于保存阶段的可能性
 *    当用户创建交易时，选择了不同的阶段，应该列出不同的可能性，一个阶段对应一个可能性，我们使用属性文件的形式保存
 *    在服务器启动的时候，将这些数据存放到服务器缓存中(application)中，以map的形式保存
 *    Map<String，String> pMap = new HashMap<>();
 *    map.put("01...",10);
 *    ......
 *    application.setAttribute("pMap",pMap);
 */
public class SysInitListener implements ServletContextListener {

    //在全局作用域对象被Http服务器初始化被调用
    public void contextInitialized(ServletContextEvent event) {

        System.out.println("监听器处理数据字典开始");
        //获取上下文作用域对象，用于保存
        ServletContext application = event.getServletContext();
       //创建业务层对象，控制器、监听器、拦截器是web中的三大组件，他们都有权利调用Service层
        DicService ds= (DicService) ServiceFactory.getService(new DicServiceImpl());
        //将分好类的数据字典值以map的形式存储，因为map中有key
        Map<String,List<DicValue>> map =ds.getAll();
        //遍历map，循环分好类的数据字典值set仅上下文作用域对象中，key为map中的key(即code)
        Set<String> code = map.keySet();
        for (String key:code){
            application.setAttribute(key,map.get(key));
        }
        System.out.println("监听器处理数据字典结束");
        /*-------------------------------------------*/
        System.out.println("保存阶段的可能性操作开始");
        /*
          使用java.util包下的ResourceBundle解析带中文的属性文件，会将里面的编码自动转化成中文
          而不使用java.util下的Properties的原因是，它无法处理中文
         */
        Map<String,String> pMap=new HashMap<String, String>();
        //注意getBundle这个方法不能加配置文件的扩展名
        ResourceBundle rs = ResourceBundle.getBundle("Stage2Possibility");
        //获取所有的key
        Enumeration<String> e=rs.getKeys();
        //遍历所有的key，通过key获取value
        while(e.hasMoreElements()){
            //获取key 01....
            String key = e.nextElement();
            //通过key获取value  10、20、25
            String value = rs.getString(key);
            //将key和value put到map中
            pMap.put(key,value);
        }
        //迭代完成后，将pMap保存到作用域对象中(服务器缓存)
        application.setAttribute("pMap",pMap);
        System.out.println("保存阶段的可能性操作结束");

    }
}
