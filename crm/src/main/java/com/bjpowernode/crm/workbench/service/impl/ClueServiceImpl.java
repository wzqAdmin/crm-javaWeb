package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.workbench.dao.*;
import com.bjpowernode.crm.workbench.domain.*;
import com.bjpowernode.crm.workbench.service.ClueService;

import javax.servlet.http.HttpServletResponse;
import java.util.List;


public class ClueServiceImpl implements ClueService {

    //因为Service层要调用dao层，所以要引入dao层,由于dao层没有实现类，所以要使用mybatis的方法创建
    //线索相关的dao
    private ClueDao clueDao= SqlSessionUtil.getSqlSession().getMapper(ClueDao.class);
    private ClueActivityRelationDao clueActivityRelationDao =SqlSessionUtil.getSqlSession().getMapper(ClueActivityRelationDao.class);
    private ClueRemarkDao clueRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ClueRemarkDao.class);

    //客户相关表
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    private CustomerRemarkDao customerRemarkDao = SqlSessionUtil.getSqlSession().getMapper(CustomerRemarkDao.class);

    //联系人相关表
    private ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    private ContactsRemarkDao contactsRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ContactsRemarkDao.class);
    private ContactsActivityRelationDao contactsActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ContactsActivityRelationDao.class);

    //交易相关表
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);


    public boolean save(Clue clue) {
        boolean flag= true;
        //调用dao层，处理数据库添加
        int count = clueDao.save(clue);
        if(count!=1){
            flag=false;
        }
        return flag;
    }

    public Clue detail(String id) {

        //调用dao层，获取详细信息
        Clue c = clueDao.detail(id);
        return c;
    }

    public boolean unbund(String id) {
        boolean flag=true;
        int count = clueActivityRelationDao.unbund(id);
        if(count!=1){
            flag=false;
        }
        return flag;
    }

    public boolean bund(String cId, String[] aIds) {
        boolean flag = true;
        ClueActivityRelation clueActivityRelation=new ClueActivityRelation();
        clueActivityRelation.setClueId(cId);
        //循环要添加的市场活动id数组
        for (String aId:aIds){
            //生成随机的id，作为每条关联线索的主键
            String id=UUIDUtil.getUUID();
            clueActivityRelation.setActivityId(aId);
            clueActivityRelation.setId(id);
            int count = clueActivityRelationDao.bund(clueActivityRelation);
            if(count!=1){
                flag=false;
            }
        }
        return flag;
    }

    public boolean convert(String clueId, Tran t, String createBy) {
        boolean flag=true;
        String createTime= DateTimeUtil.getSysTime();

        //(1) 获取到线索id，通过线索id获取线索对象（线索对象当中封装了线索的信息）
        Clue c = clueDao.getClueById(clueId);

        //(2) 通过线索对象提取客户信息，当该客户不存在的时候，新建客户（根据公司的名称精确匹配，判断该客户是否存在！）
            /*
               为什么还有客户(客户以公司为单位)存在的情况？
                 在公司中，管理客户的人和宣传推广的人如果交流较少，则不知道这个客户(公司)，以前跟我们做过贸易，
                 可能认为该公司是条线索
             */
        String company=c.getCompany();
        //根据公司名字查询有没有记录条数
        /*
           为什么要返回customer对象，而不是返回一个count来判断有没有这个客户？
             因为在后续的操作中，我们还要用到这个客户的信息，所以返回一个对象更为方便
         */
        Customer cus=customerDao.getCustomerByName(company);
        //如果不表中，则新建客户，将线索表中关于客户的信息，填入，剩下的字段以后在详细信息页中维护
        if(cus==null){
            cus=new Customer();
            cus.setWebsite(c.getWebsite());
            cus.setPhone(c.getPhone());
            cus.setOwner(c.getOwner());
            cus.setNextContactTime(c.getNextContactTime());
            cus.setName(company);
            cus.setId(UUIDUtil.getUUID());
            cus.setDescription(c.getDescription());
            cus.setCreateTime(createTime);
            cus.setCreateBy(createBy);
            cus.setContactSummary(c.getContactSummary());
            cus.setAddress(c.getAddress());
            //添加客户
            int count2 = customerDao.save(cus);
            if (count2!=1){
                flag=false;
            }
        }
        //(3) 通过线索对象提取联系人信息，保存联系人
        Contacts con=new Contacts();
        con.setSource(c.getSource());
        con.setOwner(c.getOwner());
        con.setNextContactTime(c.getNextContactTime());
        con.setMphone(c.getMphone());
        con.setJob(c.getJob());
        con.setFullname(c.getFullname());
        con.setEmail(c.getEmail());
        con.setDescription(c.getDescription());
        con.setCustomerId(cus.getId());
        con.setCreateTime(createTime);
        con.setCreateBy(createBy);
        con.setContactSummary(c.getContactSummary());
        con.setAppellation(c.getAppellation());
        con.setAddress(c.getAddress());
        con.setId(UUIDUtil.getUUID());
        int count3=contactsDao.save(con);
        if(count3!=1){
            flag=false;
        }

        //(4) 线索备注转换到客户备注以及联系人备注
          //4.1 查询出要转换的线索对应的备注信息
        List<ClueRemark> clueRemarks = clueRemarkDao.getRemarkListByClueId(clueId);
          //4.2 循环备注集合，取出单条记录，动态inset记录中的信息到客户备注表和联系人备注表
        for(ClueRemark clueRemark:clueRemarks){
            //取出备注的信息noteContext
            String noteContext=clueRemark.getNoteContent();
            //创建客户备注对象并存入参数
            CustomerRemark customerRemark= new CustomerRemark();
            customerRemark.setNoteContent(noteContext);
            customerRemark.setId(UUIDUtil.getUUID());
            customerRemark.setEditFlag("0");
            /*
              这个客户的id使用的是我们第二步的客户id
             */
            customerRemark.setCustomerId(cus.getId());
            customerRemark.setCreateTime(createTime);
            customerRemark.setCreateBy(createBy);
            //调用客户备注对象的dao，将输入创建进去
            int count4 = customerRemarkDao.save(customerRemark);
            if(count4!=1){
                flag=false;
            }

            //创建联系人备注对象
            ContactsRemark contactsRemark=new ContactsRemark();
            contactsRemark.setNoteContent(noteContext);
            contactsRemark.setId(UUIDUtil.getUUID());
            contactsRemark.setEditFlag("0");
            /*
              这个联系人的id使用的是我们第三步的客户id
             */
            contactsRemark.setContactsId(con.getId());
            contactsRemark.setCreateTime(createTime);
            contactsRemark.setCreateBy(createBy);
            //调用客户备注对象的dao，将输入创建进去
            int count5 = contactsRemarkDao.save(contactsRemark);
            if(count5!=1){
                flag=false;
            }

        }
        //(5) “线索和市场活动”的关系转换到“联系人和市场活动”的关系
          //5.1 根据clueID取出市场活动的id,因为联系人和市场活动表中其中有个外键需要activityId
         List<ClueActivityRelation> clueActivityRelations = clueActivityRelationDao.getListByClueId(clueId);
          //5.2 循环clueActivityRelations，取出其中的activityId，并insert到联系人和市场活动的关系表中
        for(ClueActivityRelation clueActivityRelation:clueActivityRelations){
            String activityId=clueActivityRelation.getActivityId();
            //创建联系人和市场活动的关系表对象
            ContactsActivityRelation contactsActivityRelation=new ContactsActivityRelation();
            contactsActivityRelation.setActivityId(activityId);
             /*
              这个联系人的id使用的是我们第三步的客户id
             */
            contactsActivityRelation.setContactsId(con.getId());
            contactsActivityRelation.setId(UUIDUtil.getUUID());
            //调用创建联系人和市场活动的关系表dao，添加关系
            int count6 = contactsActivityRelationDao.save(contactsActivityRelation);
            if(count6!=1){
                flag=false;
            }
        }
        //(6) 如果有创建交易需求，创建一条交易
        /*
          怎样判断是否有交易需求？
            通过controller层传递过来的Tran t是否为null，进行判断

         t对象在controller里面已经封装好的信息如下：
                id,money,name,expectedDate,stage,activityId,createBy,createTime

            接下来可以通过第一步生成的c对象，取出一些信息，继续完善对t对象的封装
         */
        //创建交易
        if (t!=null){
            t.setSource(c.getSource());
            t.setOwner(c.getOwner());
            t.setNextContactTime(c.getNextContactTime());
            t.setDescription(c.getDescription());
            t.setCustomerId(cus.getId());
            t.setContactSummary(c.getContactSummary());
            t.setContactsId(con.getId());
            //创建Tran，dao层进行insert
            int count7 = tranDao.save(t);
            if(count7!=1){
                flag=false;
            }
            //(7) 如果创建了交易，则创建一条该交易下的交易历史
            /*
              注意：这一步必须放在创建交易里面，因为只有创建了交易才有这一步
             */
            TranHistory tranHistory=new TranHistory();
            tranHistory.setId(UUIDUtil.getUUID());
            tranHistory.setTranId(t.getId());
            tranHistory.setStage(t.getStage());
            tranHistory.setMoney(t.getMoney());
            tranHistory.setExpectedDate(t.getExpectedDate());
            tranHistory.setCreateTime(createTime);
            tranHistory.setCreateBy(createBy);
            //创建dao层
            int count8 = tranHistoryDao.save(tranHistory);
            if(count8!=1){
                flag=false;
            }
        }
        //(8) 删除线索备注,根据线索的id
        int count9 = clueRemarkDao.delete(clueId);

        //(9) 删除线索和市场活动的关系
        for(ClueActivityRelation clueActivityRelation:clueActivityRelations){
            int count10 = clueActivityRelationDao.delete(clueActivityRelation);
            if(count10!=1){
                flag=false;
            }
        }

        //(10) 删除线索
        int count11 = clueDao.delete(clueId);
        if(count11 != 1){
            flag=false;
        }

        return  flag;
    }


}
