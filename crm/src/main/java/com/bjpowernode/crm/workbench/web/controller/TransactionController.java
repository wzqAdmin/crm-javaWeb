package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.settings.service.impl.UserServiceImpl;
import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.PrintJson;
import com.bjpowernode.crm.utils.ServiceFactory;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.workbench.domain.Tran;
import com.bjpowernode.crm.workbench.domain.TranHistory;
import com.bjpowernode.crm.workbench.service.CustomerService;
import com.bjpowernode.crm.workbench.service.TransactionService;
import com.bjpowernode.crm.workbench.service.impl.CustomerServiceImpl;
import com.bjpowernode.crm.workbench.service.impl.TransactionServiceImpl;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TransactionController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入交易活动模块控制器");
        //获取用户的访问路径
        String path=request.getServletPath();
        //设计模板
        if("/workbench/transaction/getUserList.do".equals(path)){
            getUserList(request,response);
        }else if("/workbench/transaction/getCustomerName.do".equals(path)){
            getCustomerName(request,response);
        }else if("/workbench/transaction/save.do".equals(path)){
            save(request,response);
        }else if("/workbench/transaction/detail.do".equals(path)){
            detail(request,response);
        }else if("/workbench/transaction/getTranHistoryListByTranId.do".equals(path)){
            getTranHistoryListByTranId(request,response);
        }else if("/workbench/transaction/changeStage.do".equals(path)){
            changeStage(request,response);
        }
    }

    /**
     *  用户获取用户信息列表，铺创建交易活动中的所有者
     */
    private void getUserList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("用于获取用户信息列表操作");
        //创建Service层对象
        UserService us= (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> uList = us.getUserList();
        //将取出的数据 保存在request域对象中，因为不是ajax请求，所以无法printJson
        request.setAttribute("uList",uList);
        //请求转发到创建页
        request.getRequestDispatcher("/workbench/transaction/save.jsp").forward(request,response);
    }

    /**
     * 自动补全
     */
    private void getCustomerName(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("用户获取自动补全的操作");
        //获取用户传递过来的参数
        String name=request.getParameter("name");
        //调用Service层
        CustomerService cs= (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        List<String> cList = cs.getCustomerName(name);
        //返回数据
        PrintJson.printJsonObj(response,cList);
    }

    /**
     * 创建交易
     */
    private void save(HttpServletRequest request, HttpServletResponse response) throws IOException {
        System.out.println("进入创建交易的操作");
        //获取创建交易所必须的参数
        String id= UUIDUtil.getUUID();
        String owner=request.getParameter("owner");
        String money=request.getParameter("money");
        String name=request.getParameter("name");
        String expectedDate=request.getParameter("expectedDate");
        String customerName=request.getParameter("customerName");
        String stage=request.getParameter("stage");
        String type=request.getParameter("type");
        String source=request.getParameter("source");
        String activityId=request.getParameter("activityId");
        String contactsId=request.getParameter("contactsId");
        String createBy=((User)request.getSession().getAttribute("user")).getName();
        String createTime= DateTimeUtil.getSysTime();
        String description=request.getParameter("description");
        String contactSummary=request.getParameter("contactSummary");
        String nextContactTime=request.getParameter("nextContactTime");
      //将参数封装到对象中
        /*
          注意：有一个参数需要注意，那就是客户的id并没有通过前端提交过来，前端提交过来的是customerName，
          所以，在Service层，我们需要通过这个name调用dao层查询出来这个id，如果没有则创建一个这个客户
         */
        Tran t=new Tran();
        t.setId(id);
        t.setOwner(owner);
        t.setMoney(money);
        t.setName(name);
        t.setExpectedDate(expectedDate);
        t.setCreateBy(createBy);
        t.setStage(stage);
        t.setType(type);
        t.setSource(source);
        t.setActivityId(activityId);
        t.setContactsId(contactsId);
        t.setCreateTime(createTime);
        t.setDescription(description);
        t.setContactSummary(contactSummary);
        t.setNextContactTime(nextContactTime);

        //调用service层
        TransactionService ts= (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        boolean flag = ts.save(t,customerName);

        //使用重定向，将页面重定向到tran index,jsp
        if (flag){
            response.sendRedirect(request.getContextPath()+"/workbench/transaction/index.jsp");
        }


    }

    /**
     * 跳转到交易的详细信息页，展现交易的详细列表
     */
    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入跳转到交易的详细信息页，展现交易的详细列表的操作");
        //获取要展现哪条交易的详细信息
        String id=request.getParameter("id");
        //调用Service层
        TransactionService ts= (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        Tran t = ts.detail(id);
        //从服务器的缓存中去除可能性
        ServletContext application=request.getServletContext();  //获取全局作用域对象
        Map<String,String> pMap = (Map<String, String>) application.getAttribute("pMap");
        String possibility = pMap.get(t.getStage());
        t.setPossibility(possibility);

        request.setAttribute("t",t);
        //请求转发的形式将页面定位到详细信息页
        /*
           分析：为什么要使用请求转发，2个原因：
             1、我们要往request作用域对象存值，详细信息页面要用
             2、请求转发会将rul停留在detail.do这个地址，当我们刷新的时候，要重新执行这个方法，所以正好适合
           结论：
             当我们要request存值的时候就用请求转发，否则就用重定向
         */
        request.getRequestDispatcher("/workbench/transaction/detail.jsp").forward(request,response);
    }

    /**
     * 跳转到交易的详细信息页，获取交易历史列表
     */
    private void getTranHistoryListByTranId(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入跳转到交易的详细信息页，获取交易历史列表的操作");
       //获取交易的iD
        String tranId=request.getParameter("tranId");
        TransactionService ts= (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        List<TranHistory> tList = ts.getTranHistoryListByTranId(tranId);
        //获取上下文域对象
        ServletContext application = request.getServletContext();
        Map<String,String> pMap = (Map<String, String>) application.getAttribute("pMap");
        //循环List集合，往每一个TranHistory对象里面添加可能性
        for (TranHistory t:tList){
            //通过key，获取pMap中的value
           String possibility = pMap.get(t.getStage());
           //将possibility填入
            t.setPossibility(possibility);
        }
        PrintJson.printJsonObj(response,tList);
    }

    /**
     * 修改状态
     */
    private void changeStage(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入修改交易状态的操作");
        String id= request.getParameter("id");
        String stage= request.getParameter("stage");
        String money= request.getParameter("money");
        String expectedDate= request.getParameter("expectedDate");
        String editBy=((User)request.getSession().getAttribute("user")).getName();
        String editTime=DateTimeUtil.getSysTime();

        //创建对象，接受，方便传参
        Tran t=new Tran();
        t.setId(id);
        t.setStage(stage);
        t.setMoney(money);
        t.setExpectedDate(expectedDate);
        t.setEditBy(editBy);
        t.setEditTime(editTime);
        //处理可能性
        ServletContext application = request.getServletContext();
        Map<String,String> pMap = (Map<String, String>) application.getAttribute("pMap");
        t.setPossibility(pMap.get(t.getStage()));

        TransactionService ts= (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        boolean flag = ts.changeStage(t);


        //创建一个map，保存数据并返回给前端
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("success",flag);
        map.put("t",t);
        PrintJson.printJsonObj(response,map);


    }

}
