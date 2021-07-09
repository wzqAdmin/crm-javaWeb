package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.settings.service.impl.UserServiceImpl;
import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.PrintJson;
import com.bjpowernode.crm.utils.ServiceFactory;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.Clue;
import com.bjpowernode.crm.workbench.domain.Tran;
import com.bjpowernode.crm.workbench.service.ActivityService;
import com.bjpowernode.crm.workbench.service.ClueService;
import com.bjpowernode.crm.workbench.service.impl.ActivityServiceImpl;
import com.bjpowernode.crm.workbench.service.impl.ClueServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ClueController extends HttpServlet {

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("进入线索模块控制器");
        //获取用户的访问路径
        String path = request.getServletPath();

        if( "/workbench/clue/getUserList.do".equals(path)){
            getUserList(request,response);
        }else if( "/workbench/clue/save.do".equals(path)){
            save(request,response);
        }else if( "/workbench/clue/detail.do".equals(path)){
            detail(request,response);
        }else if( "/workbench/clue/getActivityByClueId.do".equals(path)){
            getActivityByClueId(request,response);
        }else if( "/workbench/clue/unbund.do".equals(path)){
            unbund(request,response);
        }else if( "/workbench/clue/getActivityListByActivityNameAndClueId.do".equals(path)){
            getActivityListByActivityNameAndClueId(request,response);
        }else if( "/workbench/clue/bund.do".equals(path)){
            bund(request,response);
        }else if( "/workbench/clue/getActivityListByActivityName.do".equals(path)){
            getActivityListByActivityName(request,response);
        }else if( "/workbench/clue/convert.do".equals(path)){
            convert(request,response);
        }
    }

    /**
     * 当打开添加线索的模态窗口时，获取所有者
     */
    private void getUserList(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入线索模块获取所有者的操作");

        //创建Service业务层
        UserService us= (UserService) ServiceFactory.getService(new UserServiceImpl());

        List<User> uList = us.getUserList();

        //将所有者返回
        PrintJson.printJsonObj(response,uList);
    }

    /**
     * 执行线索的添加操作
     */
    private void save(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入市场活动的添加操作");

        //获取前端传递过来的参数+在后台生成必要的参数
        String id = UUIDUtil.getUUID();
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String owner = request.getParameter("owner");
        String company = request.getParameter("company");
        String job = request.getParameter("job");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");
        String source = request.getParameter("source");
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        String createTime = DateTimeUtil.getSysTime();
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");

        //将这些参数封装到线索实体类中
        Clue clue=new Clue();
        clue.setAddress(address);
        clue.setWebsite(website);
        clue.setState(state);
        clue.setSource(source);
        clue.setPhone(phone);
        clue.setOwner(owner);
        clue.setNextContactTime(nextContactTime);
        clue.setMphone(mphone);
        clue.setJob(job);
        clue.setId(id);
        clue.setFullname(fullname);
        clue.setEmail(email);
        clue.setDescription(description);
        clue.setCreateTime(createTime);
        clue.setCreateBy(createBy);
        clue.setContactSummary(contactSummary);
        clue.setCompany(company);
        clue.setAppellation(appellation);

        //调用Service层处理添加业务
        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        boolean flag = cs.save(clue);

        //将结果添加到响应体
        PrintJson.printJsonFlag(response,flag);

    }

    /**
     * 当用户点击具体的线索的时候，会跳转到详细信息页，这个方法就是获取这个详细信息页的信息
     */
    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("进入到获取线索详细信息页的操作");

        //1、获取要跳转到哪条详细信息页 通过clue表的id
        String id=request.getParameter("id");

        //创建Service层对象，让service调用dao层
        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        //详细信息页中的数据实际上都是clue表中的信息
        Clue c = cs.detail(id);

        //将这个得到的Clue对象，添加到request域对象中
        request.setAttribute("c",c);

        //传统请求，使用请求转发的形式
        request.getRequestDispatcher("/workbench/clue/detail.jsp").forward(request,response);
    }

    /**
     * 获取与详细信息页线索关联的市场活动列表
     */
    private void getActivityByClueId(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入获取市场活动与线索关联关系的操作");
        //1、获取用户从前端传递过来的线索id
        String clueId = request.getParameter("clueId");

        //创建Service层对象
        /*
           这里的业务是获取市场活动的列表，是属于市场活动业务层的范畴，所以应该创建市场活动业务层对象
           在项目开发时：从哪个模块发出的请求，必须经过哪个模块的controller层，但是controller层可以调用
           任何一层的Service
           就像线索层的控制器，也可以调用市场活动的业务层，虽然这个业务是属于市场活动的，但是这个请求是由线索发出的
           所以必须由线索的controller调用市场活动的业务层，而不是去了市场活动的controller层
         */
        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        List<Activity> aList =as.getActivityByClueId(clueId);

        //将结果返回给前端
        PrintJson.printJsonObj(response,aList);

    }

    /**
     * 解除市场活动与线索的关联
     */
    private void unbund(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入解除线索与市场活动的关系操作");

        //获取用户传递过来的参数 即关联关系表的id
        String id=request.getParameter("id");

        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        boolean flag = cs.unbund(id);

        PrintJson.printJsonFlag(response,flag);
    }

    /**
     * 根据市场活动的名称模糊查询市场活动信息列表，为关联做准备
     */
    private void getActivityListByActivityNameAndClueId(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入根据市场活动的名称模糊查询市场活动信息列表的操作");
        String aName=request.getParameter("aname");
        String clueId=request.getParameter("clueId");
        //将两个参数封装成Map
        Map<String,String> map=new HashMap<String, String>();
        map.put("aName",aName);
        map.put("clueId",clueId);
        //创建Service层对象，由于是获取市场活动列表的操作，应该使用市场活动的service层
        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        List<Activity> aList = as.getActivityListByActivityNameAndClueId(map);
        //将结果响应给前端
        PrintJson.printJsonObj(response,aList);

    }

    /**
     * 进入到关联市场活动的操作
     */
    private void bund(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到关联市场活动的操作");
        String cId=request.getParameter("cId");
        String[] aIds=request.getParameterValues("aId");
        //创建Service层代理
        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        boolean flag = cs.bund(cId,aIds);
        //将结果返回给前端
        PrintJson.printJsonFlag(response,flag);

    }

    /**
     * 当用户执行线索转换并且要同时添加交易的时候，这个方法就是为其提供市场活动列表的
     */
    private void getActivityListByActivityName(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入绑定交易市场活动列表的功能");
        //获取用户传递过来的要查询的市场活动名称条件
        String aname=request.getParameter("aname");
        //创建Service层对象
        ActivityService as= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        List<Activity> aList = as.getActivityListByActivityName(aname);
        PrintJson.printJsonObj(response,aList);
    }

    /**
     * 执行线索转换的操作
     */
    private void convert(HttpServletRequest request, HttpServletResponse response) throws IOException {

        System.out.println("进入执行线索转换的操作");
        //获取前端传递过来的clueId
        String clueId=request.getParameter("clueId");
        //通过判断flag标志，来判断在转换的时候要不要创建交易
        String flag=request.getParameter("flag");
        //获取createBy，传递给后端使用
        String createBy=((User)request.getSession().getAttribute("user")).getName();
        Tran t=null;
        //如果需要创建交易
        if("a".equals(flag)){
            t=new Tran();
           //获取交易表单中填写的参数
            String money= request.getParameter("money");
            String name= request.getParameter("name");
            String expectedDate= request.getParameter("expectedDate");
            String stage= request.getParameter("stage");
            String activityId= request.getParameter("activityId");
            String id=UUIDUtil.getUUID();
            String createTime=DateTimeUtil.getSysTime();
           //将参数封装到domain中传递给后端
            t.setMoney(money);
            t.setName(name);
            t.setExpectedDate(expectedDate);
            t.setStage(stage);
            t.setActivityId(activityId);
            t.setId(id);
            t.setCreateTime(createTime);
            t.setCreateBy(createBy);
        }
        //参数获取完毕后，调用Service层，处理业务
        ClueService cs= (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        //返回的是一个布尔值，判断转换是否成功
        /*
           分析controller层调用Service层要传递什么参数？
             1、要转换的线索的id clueId
             2、Tran对象  如果T对象为null,则代表用户不创建交易
             3、createBy 因为在转换线索的过程中，需要大量的insert操作，其中大部分表中都需要createBy字段
         */
        boolean flag2 = cs.convert(clueId,t,createBy);
        if (flag2){
            //如果处理成功，则将页面重定向到线索的主页面
            /*
              为什么不用请求转发，而使用重定向呢？
               因为这里没有需要传递的参数
             */
            response.sendRedirect(request.getContextPath()+"/workbench/clue/index.jsp");
        }
    }
}
