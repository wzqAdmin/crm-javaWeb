package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.Activity;

import java.util.List;
import java.util.Map;

public interface ActivityDao {
    int add(Activity activity);

    List<Activity> getActivityListByCondition(Map<String, Object> map);

    int getTotalByCondition(Map<String, Object> map);

    int delete(String[] ids);

    Activity getActivityById(String id);

    int update(Activity activity);

    Activity detail(String aId);

    List<Activity> getActivityByClueId(String clueId);

    List<Activity> getActivityListByActivityNameAndClueId(Map<String, String> map);

    List<Activity> getActivityListByActivityName(String aname);
}
