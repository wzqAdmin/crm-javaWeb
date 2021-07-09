package com.bjpowernode.crm.workbench.web.controller;


import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.settings.service.impl.UserServiceImpl;
import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.PrintJson;
import com.bjpowernode.crm.utils.ServiceFactory;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;
import com.bjpowernode.crm.workbench.service.ActivityService;
import com.bjpowernode.crm.workbench.service.impl.ActivityServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActivityController extends HttpServlet {
    /**
     * Servlet模板模式
     * @param request 请求对象
     * @param response 响应对象
     * @throws ServletException servlet异常
     * @throws IOException IO异常
     */
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("进入市场活动控制器");
        //获取用于访问的servlet路径，即web.xml中<url-pattern>的值,带'/'前缀
        String path = request.getServletPath();

        //判断用户访问的业务类型
        if("/workbench/activity/getUserList.do".equals(path)){
            getUserList(request,response);

        }else if( "/workbench/activity/add.do".equals(path) ){

            add(request,response);
        }else if( "/workbench/activity/pageList.do".equals(path) ){

            pageList(request,response);
        }else if( "/workbench/activity/delete.do".equals(path)){

            delete(request,response);
        }else if( "/workbench/activity/getUserListAndActivity.do".equals(path)){

            getUserListAndActivity(request,response);
        }else if( "/workbench/activity/update.do".equals(path)){
            update(request,response);
        }else if( "/workbench/activity/detail.do".equals(path)){

            detail(request,response);
        }else if( "/workbench/activity/showRemarkLsit.do".equals(path)){

            showRemarkLsit(request,response);
        }else if( "/workbench/activity/deleteRemark.do".equals(path)){

            deleteRemark(request,response);
        }else if( "/workbench/activity/saveRemark.do".equals(path)){

            saveRemark(request,response);
        }else if( "/workbench/activity/updateRemark.do".equals(path)){

            updateRemark(request,response);
        }

    }
    /**
     * 用于获取用户的信息列表，在打开创建市场活动的时候有一个所有者
     * 这个函数用于为所有者下拉框提供数据
     */
    private void getUserList(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("执行获取用户信息列表的操作");
      //因为我们呀调用Service，通过service调用数据库，那么我们应该使用ActivityService还是UserService呢
        /*
           UserService ，因为这次的业务是查询出tbl_user表中所有的记录封装成一个list<User>，并没有涉及到市场活动
           的需求，所有使用用户的即可
         */

        UserService us = (UserService) ServiceFactory.getService(new UserServiceImpl());

        //多态：实际是通过代理对象调用UserServiceImpl的getUserList方法
        List<User> uList =  us.getUserList();

        //调用工具类，将List集合转换成字符串并返回给调用者
        PrintJson.printJsonObj(response,uList);

    }


    /**
     * 添加市场活动的方法
     */
    private void add(HttpServletRequest request, HttpServletResponse response) {
       /*
           获取用户前端传递过来的数据,封装成一个Activity实体类，发送给Service层,
           由service层调用dao层，操作数据库
        */
        System.out.println("执行添加市场活动的操作");
        String id = UUIDUtil.getUUID();  //自动生成一个全球唯一的id，作为这条市场活动的主键
        String owner= request.getParameter("owner");
        String name= request.getParameter("name");
        String startDate= request.getParameter("startDate");
        String endDate= request.getParameter("endDate");
        String cost= request.getParameter("cost");
        String description= request.getParameter("description");
        String createTime= DateTimeUtil.getSysTime();  //获取当前的系统时间，作为创建活动的时间
        /*
           创建人为session域中的name
             1、首先获取session对象
             2、通过getAttribute("key")的方式获取存在session域中的user对象，并将其强转为user类型
             3、通过强转后的user类型的getName()方法获取创建人的名称
         */
        String createBy= ((User)request.getSession().getAttribute("user")).getName();

        //将获取的参数封装到一个Activity实体类中方便传参
        Activity activity = new Activity();
        activity.setId(id);
        activity.setOwner(owner);
        activity.setName(name);
        activity.setStartDate(startDate);
        activity.setEndDate(endDate);
        activity.setCost(cost);
        activity.setDescription(description);
        activity.setCreateTime(createTime);
        activity.setCreateBy(createBy);

        //创建一个Service层的对象，使用controller层调用service层
        /*
           由于我们这里的业务是市场活动的创建，是关于市场活动的，所以
           我们必须使用市场活动的代理类
         */
        ActivityService as = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        boolean flag = as.add(activity);

        PrintJson.printJsonFlag(response,flag);
    }

    /**
     * 用于展现详细的市场活动信息列表，在点击市场活动的时候
     */
    private void pageList(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入到查询市场活动信息列表的操作（结合条件查询+分页查询）");
       //获取用户传递来的数据
        String name= request.getParameter("name");
        String owner= request.getParameter("owner");
        String startDate= request.getParameter("startDate");
        String endDate= request.getParameter("endDate");
        String pageNoStr = request.getParameter("pageNo"); //第几页（唯一的作用就是计算pageStart）
        String pageSizeStr = request.getParameter("pageSize"); //每页显示几条记录

        //将pageNo转换为int类型 为了计算limit 条件的值
        int pageNo = Integer.valueOf(pageNoStr);
        int pageSize = Integer.valueOf(pageSizeStr);
        /*
           limit (pageNo-1)*pageSize,pageSize
                      pageStart
         */
        //计算略过的记录条数
        int skipCount = (pageNo-1)*pageSize;

        //将用户传过来的参数封装到map里传递给Service层，让service层调用dao层
        /*
          为什么要使用map？  因为没有一个适合这些格式的实体类来作为容器存放
         */
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("startDate",startDate);
        map.put("endDate",endDate);
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);

        //创建ActivityServie层对象，传入map参数
        ActivityService as = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        /*
           as.pageList(map);要返回什么类型呢？

            前端要： 市场活动信息列表
                    查询的总条数

                    业务层拿到了以上两项信息之后，如果做返回
                    map
                    map.put("dataList":dataList)
                    map.put("total":total)
                    PrintJSON map --> json
                    {"total":100,"dataList":[{市场活动1},{2},{3}]}


                    vo
                    PaginationVO<T>
                        private int total;
                        private List<T> dataList;

                    PaginationVO<Activity> vo = new PaginationVO<>;
                    vo.setTotal(total);
                    vo.setDataList(dataList);
                    PrintJSON vo --> json
                    {"total":100,"dataList":[{市场活动1},{2},{3}]}


            将来分页查询，每个模块都有，所以我们选择使用一个通用vo，操作起来比较方便
         */
        PaginationVO<Activity> vo = as.pageList(map);

        //将这个vo使用printJson工具类，返回给前端
        PrintJson.printJsonObj(response,vo);


    }

    /**
     * 用于删除市场活动，在点击删除市场活动的按钮时
     */
    private void delete(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入删除市场活动控制器");

        //接受用户传递过来的参数，即要删除的市场活动信息id，由于是一个key下有多个value
        /*
          接受形式为：
            request.getParameterValues()
         */
        String[] ids = request.getParameterValues("id");
        for (String id:ids) {
            System.out.println(id);
        }

        //创建业务层对象
        ActivityService as = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        
        //flag用于标识删除是否成功
        boolean flag = as.delete(ids);
        
        //返回给前端
        PrintJson.printJsonFlag(response,flag);

    }

    /**
     * 用于获得用户信息列表和要修改的市场活动的信息
     */
    private void getUserListAndActivity(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行获取用户信息列表(所有者)和通过id取得市场活动对象的操作");

        //1、获取前端传递过来的市场活动id值
        String id = request.getParameter("id");

        ActivityService as = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        /*
          为什么要使用map而不是vo？
            因为同时获取用户信息列表和单个市场活动信息的业务使用的较少
         */
        Map<String,Object> map = as.getUserListAndActivity(id);

        PrintJson.printJsonObj(response,map);


    }

    /**
     * 用于修改市场活动的信息
     */
    private void update(HttpServletRequest request, HttpServletResponse response) {
          /*
           获取用户前端传递过来的数据,封装成一个Activity实体类，发送给Service层,
           由service层调用dao层，操作数据库
        */
        System.out.println("执行修改市场活动的操作");
        String id = request.getParameter("id");  //获取前端传送过来的id
        String owner= request.getParameter("owner");
        String name= request.getParameter("name");
        String startDate= request.getParameter("startDate");
        String endDate= request.getParameter("endDate");
        String cost= request.getParameter("cost");
        String description= request.getParameter("description");
        String editTime= DateTimeUtil.getSysTime();  //获取当前的系统时间，作为修改活动的时间

        String eidtBy= ((User)request.getSession().getAttribute("user")).getName();

        //将获取的参数封装到一个Activity实体类中方便传参
        Activity activity = new Activity();
        activity.setId(id);
        activity.setOwner(owner);
        activity.setName(name);
        activity.setStartDate(startDate);
        activity.setEndDate(endDate);
        activity.setCost(cost);
        activity.setDescription(description);
        activity.setEditTime(editTime);
        activity.setEditBy(eidtBy);

        //创建一个Service层的对象，使用controller层调用service层
        /*
           由于我们这里的业务是市场活动的创建，是关于市场活动的，所以
           我们必须使用市场活动的代理类
         */
        ActivityService as = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        boolean flag = as.update(activity);

        PrintJson.printJsonFlag(response,flag);
    }

    /**
     * 点击市场活动的信息跳转到详细信息页的操作
     */
    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到跳转市场活动详细信息页的操作");

        //获取用户传递过来的要展开市场活动的id
        String aId = request.getParameter("id");

        //创建业务层代理类对象
        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        Activity a = as.detail(aId);

        //将返回的详细信息页保存到request域中
        request.setAttribute("a",a);

        //通过请求转发，定位到详细信息页的jsp文件，在jsp文件中使用el表达式输出
        request.getRequestDispatcher("/workbench/activity/detail.jsp").forward(request,response);

    }

    /**
     * 用于根据视窗活动的id，来查询出这个市场活动对应的备注信息
     */
    private void showRemarkLsit(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到查询市场活动备注信息的操作");

        //获取用户传递过来的市场活动id
        String activityId = request.getParameter("activityId");

        //创建Service的代理层对象，调用service层，让service层调用dao层来完成这个业务的操作
        ActivityService as = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        List<ActivityRemark> arLsit = as.showRemarkLsit(activityId);

        PrintJson.printJsonObj(response,arLsit);

    }

    /**
     * 通过备注的id用于删除备注信息
     */
    private void deleteRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到通过备注的id用于删除备注信息的操作");
      //1、获取前端发送来的备注信息
        String remarkId = request.getParameter("remarkId");
      //创建Service层代理对象
        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
      //调用service层的动态代理，通过动态代理执行service实现类的方法
        boolean flag = as.deleteRemark(remarkId);
      //将删除是否成功的标志返回
        PrintJson.printJsonFlag(response,flag);

    }

    /**
     * 用于添加一条备注
     */
    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入到添加一条备注信息的操作");
        //获取前端传递过来的参数，并生成新的参数
        String activityId = request.getParameter("activityId");
        String noteContent = request.getParameter("noteContent");

        String id = UUIDUtil.getUUID();                //为添加的这条备注信息生成新的id
        String createTime = DateTimeUtil.getSysTime(); //以当前的时间作为这条备注信息的创建时间
        /*
           当用户在登录成功后，会把这个用户的信息，保存在session作用域对象中，
           这个session作用域对象会随着请求协议包推送过来
         */
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        String editFlag="0";

        //将这些信息封装到一个备注实体类中，方便参数的传递
        ActivityRemark ar=new ActivityRemark();
        ar.setId(id);
        ar.setActivityId(activityId);
        ar.setCreateBy(createBy);
        ar.setCreateTime(createTime);
        ar.setEditFlag(editFlag);
        ar.setNoteContent(noteContent);

        //创建Service层代理对象，调用代理方法
        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        boolean flag = as.saveRemark(ar);

        //创建一个map对象，保存添加的数据和flag标志，通过调用printJson将其转化成json形式，传递给前端
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("success",flag);
        map.put("ar",ar);

        PrintJson.printJsonObj(response,map);


    }

    private void updateRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入修改备注信息的操作");
        //获取前端发过来的参数
        String remarkId = request.getParameter("remarkId");
        String noteContent = request.getParameter("noteContent");
        //生成修改人，修改时间
        String editBy=((User)request.getSession().getAttribute("user")).getName();
        String editTime = DateTimeUtil.getSysTime();
        String editFlag="1";

        //创建备注实体类，存放要修改和查询条件的备注信息
        ActivityRemark ar=new ActivityRemark();
        ar.setId(remarkId);
        ar.setNoteContent(noteContent);
        ar.setEditBy(editBy);
        ar.setEditTime(editTime);
        ar.setEditFlag(editFlag);

        //创建Service层的代理类对象
        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        boolean flag = as.updateRemark(ar);

        //将结果响应回前端
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("success",flag);
        map.put("ar",ar);
        PrintJson.printJsonObj(response,map);

    }

}
