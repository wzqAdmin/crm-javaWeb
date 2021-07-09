package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.ActivityRemark;

import java.util.List;

public interface ActivityRemarkDao {
    int getCountByAIds(String[] ids);

    int deleteByAIds(String[] ids);

    List<ActivityRemark> showRemarkLsit(String activityId);

    int deleteRemark(String remarkId);

    int saveRemark(ActivityRemark ar);

    int updateRemark(ActivityRemark ar);
}
