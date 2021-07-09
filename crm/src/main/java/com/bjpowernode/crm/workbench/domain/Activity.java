package com.bjpowernode.crm.workbench.domain;

/**
 * 市场活动表：tbl_activity的实体类
 */
public class Activity {

    private String id;            //tbl_activity表的主键(唯一标识一个市场活动)
    private String owner;         //市场活动的所有者 外键 对应的是用户表(tbl_user)的id
    private String name;          //市场活动的名称 如：发传单
    private String startDate;     //开始时间
    private String endDate;       //结束时间
    private String cost;          //市场活动的成本
    private String description;   //市场活动的描述
    private String createTime;    //创建时间
    private String createBy;      //创建人
    private String editTime;      //修改时间
    private String editBy;        //修改人

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getOwner() {
        return owner;
    }

    public void setOwner(String owner) {
        this.owner = owner;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getStartDate() {
        return startDate;
    }

    public void setStartDate(String startDate) {
        this.startDate = startDate;
    }

    public String getEndDate() {
        return endDate;
    }

    public void setEndDate(String endDate) {
        this.endDate = endDate;
    }

    public String getCost() {
        return cost;
    }

    public void setCost(String cost) {
        this.cost = cost;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public String getCreateBy() {
        return createBy;
    }

    public void setCreateBy(String createBy) {
        this.createBy = createBy;
    }

    public String getEditTime() {
        return editTime;
    }

    public void setEditTime(String editTime) {
        this.editTime = editTime;
    }

    public String getEditBy() {
        return editBy;
    }

    public void setEditBy(String editBy) {
        this.editBy = editBy;
    }
}
