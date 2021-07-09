package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.Tran;

import java.util.List;

public interface TranDao {

    int save(Tran t);

    List<String> getCustomerName(String name);

    Tran detail(String id);

    int changeStage(Tran t);
}
