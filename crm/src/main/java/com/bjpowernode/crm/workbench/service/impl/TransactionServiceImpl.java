package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.workbench.dao.CustomerDao;
import com.bjpowernode.crm.workbench.dao.TranDao;
import com.bjpowernode.crm.workbench.dao.TranHistoryDao;
import com.bjpowernode.crm.workbench.domain.Customer;
import com.bjpowernode.crm.workbench.domain.Tran;
import com.bjpowernode.crm.workbench.domain.TranHistory;
import com.bjpowernode.crm.workbench.service.TransactionService;

import java.util.List;


public class TransactionServiceImpl implements TransactionService {
    private TranDao tranDao= SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao= SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);
    private CustomerDao customerDao=SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);

    public boolean save(Tran t, String customerName) {
        boolean flag=true;
        /*
           执行交易添加的大致流程：
             1、现将customerName处理成customerId，通过调用dao层，匹配名字的精确查询
                  如果有这个客户，则将这个客户的id取出
                  如果没有这个客户，则临时创建一个这个客户
               以上这样做的原因是，在tran表中有个外键是customerId，所以无论如何都必须取到这个id

             2、创建交易
             3、创建交易历史
                  交易历史中的信息，在交易信息中取出
         */
        Customer customer = customerDao.getCustomerByName(customerName);
        //如果这个对象为空，则代表数据库中没有这个客户，需要临时创建一个
        if(customer==null){
            customer=new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setName(customerName);
            customer.setCreateBy(t.getCreateBy());
            customer.setCreateTime(DateTimeUtil.getSysTime());
            customer.setNextContactTime(t.getNextContactTime());
            customer.setContactSummary(t.getContactSummary());
            //调用dao层执行添加操作
            int count = customerDao.save(customer);
            if(count!=1){
                flag=false;
            }
        }
        //创建交易，现将customerId set进t对象
        t.setCustomerId(customer.getId());
        int count2 = tranDao.save(t);
        if(count2!=1){
            flag=false;
        }
        //创建交易历史
        TranHistory tranHistory=new TranHistory();
        tranHistory.setCreateBy(t.getCreateBy());
        tranHistory.setCreateTime(DateTimeUtil.getSysTime());
        tranHistory.setExpectedDate(t.getExpectedDate());
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setMoney(t.getMoney());
        tranHistory.setStage(t.getStage());
        tranHistory.setTranId(t.getId());
        //调用dao层创建
        int count3=tranHistoryDao.save(tranHistory);
        if (count3!=1){
            flag=false;
        }
        return flag;
    }

    public Tran detail(String id) {
        Tran t = tranDao.detail(id);
        return t;
    }

    public List<TranHistory> getTranHistoryListByTranId(String tranId) {
        List<TranHistory> tList = tranHistoryDao.getTranHistoryListByTranId(tranId);
        return tList;
    }

    public boolean changeStage(Tran t) {
        boolean flag = true;
        int count = tranDao.changeStage(t);
        if (count != 1) {
            flag = false;
        }
        TranHistory tranHistory = new TranHistory();
        tranHistory.setCreateBy(t.getEditBy());
        tranHistory.setCreateTime(DateTimeUtil.getSysTime());
        tranHistory.setExpectedDate(t.getExpectedDate());
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setMoney(t.getMoney());
        tranHistory.setTranId(t.getId());
        tranHistory.setStage(t.getStage());
        tranHistory.setPossibility(t.getPossibility());
        int count2 = tranHistoryDao.save(tranHistory);
        if (count2 != 1) {
            flag = false;
        }
        return flag;
    }
}
