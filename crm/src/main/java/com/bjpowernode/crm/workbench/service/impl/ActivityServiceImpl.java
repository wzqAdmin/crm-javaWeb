package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.settings.dao.UserDao;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.dao.ActivityDao;
import com.bjpowernode.crm.workbench.dao.ActivityRemarkDao;
import com.bjpowernode.crm.workbench.dao.ClueActivityRelationDao;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;
import com.bjpowernode.crm.workbench.service.ActivityService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 市场活动模块的业务层实现类
 */
public class ActivityServiceImpl implements ActivityService {

    //由于service层的实现类要调用dao层操纵数据库，service层的每个方法可能都要使用,所以要创建一个成员变量
    /*
      记住：我们业务需求用到哪张表，就要使用哪张表的dao
      因为dao层没有实现类，所以我们要使用sqlSession对象的getMapper(Dao层接口)的形式获取这个实现类
     */
    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);

    private ActivityRemarkDao activityRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ActivityRemarkDao.class);

    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    public boolean add(Activity activity) {
        boolean flag = false;
        int count = activityDao.add(activity);
        if(count == 1){
            flag = true;
        }
        return flag;
    }

    public PaginationVO<Activity> pageList(Map<String, Object> map) {

        //1、调用dao层查询数据,取得记录的总条数
          int total = activityDao.getTotalByCondition(map);

        //2、调用dao层查询数据，取得市场活动信息列表
        List<Activity> dataList = activityDao.getActivityListByCondition(map);


        //将1和2封装成vo返回给调用者
        PaginationVO<Activity> vo=new PaginationVO<Activity>();
        vo.setTotal(total);
        vo.setDataList(dataList);

        return vo;
    }

    public boolean delete(String[] ids) {
        System.out.println("进行删除市场活动操作");

        /*
           对于删除市场活动，需要注意的点，一个市场活动可能有其关联的备注信息，这个备注信息是单独在
           一个备注表上的(tbl_activityremark)，两个表时通过外键，即activityId建立联系，在删除市场活动之前
           必须要先删除它的备注信息，否则备注表就失去了数据的正确性
         */

        boolean flag = true;

        //获取要删除的备注条数
        int count1 = activityRemarkDao.getCountByAIds(ids);

        //删除对应的市场活动备注
        int count2 = activityRemarkDao.deleteByAIds(ids);

        //进行比较，如果删除的备注个数与删除的备注条数一致，则继续删除市场活动
        if(count1!=count2){
            flag=false;
        }

        //删除市场活动
        //删除的记录条数与ids的length比较，因为前段传递的id就是市场活动表中的id
        int count3 = activityDao.delete(ids);
        if(count3 != ids.length){
            flag = false;
        }

        return flag;
    }

    public Map<String, Object> getUserListAndActivity(String id) {

        //1、获取信息列表(需要使用UserDao)
        List<User> uList = userDao.getUserList();

        //2、获取单个市场活动的信息
        Activity a = activityDao.getActivityById(id);

        //3、打包成map
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("uList",uList);
        map.put("a",a);

        //4、返回map
        return map;
    }

    public boolean update(Activity activity) {
        boolean flag = false;
        int count = activityDao.update(activity);
        if(count == 1){
            flag = true;
        }
        return flag;
    }

    public Activity detail(String aId) {
        //在业务层(service)调用dao层
        Activity a = activityDao.detail(aId);
        return  a;
    }

    public List<ActivityRemark> showRemarkLsit(String activityId) {
        List<ActivityRemark> arLsit = activityRemarkDao.showRemarkLsit(activityId);
        return arLsit;
    }

    public boolean deleteRemark(String remarkId) {
        boolean flag=false;
        int count =  activityRemarkDao.deleteRemark(remarkId);
        if (count ==1){
          flag=true;
        }
        return flag;
    }

    public boolean saveRemark(ActivityRemark ar) {
        boolean flag=false;
        int count = activityRemarkDao.saveRemark(ar);
        if(count==1){
            flag=true;
        }
        return flag;
    }

    public boolean updateRemark(ActivityRemark ar) {
        boolean flag=false;
        int count = activityRemarkDao.updateRemark(ar);
        if(count==1){
            flag=true;
        }
        return flag;
    }

    public List<Activity> getActivityByClueId(String clueId) {

        List<Activity> aList = activityDao.getActivityByClueId(clueId);

        return aList;

    }

    public List<Activity> getActivityListByActivityNameAndClueId(Map<String, String> map) {
        List<Activity> aList = activityDao.getActivityListByActivityNameAndClueId(map);
        return aList;
    }

    public List<Activity> getActivityListByActivityName(String aname) {
        List<Activity> aList=activityDao.getActivityListByActivityName(aname);
        return  aList;
    }
}
