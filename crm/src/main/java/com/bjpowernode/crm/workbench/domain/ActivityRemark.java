package com.bjpowernode.crm.workbench.domain;

/**
 * 市场活动备注表(tbl_activity_remark表)的实体类
 */
public class ActivityRemark {

    private String id;           //市场活动备注表的主键 唯一标识一个备注
    private String noteContent;  //备注信息
    private String createTime;   //备注的创建时间
    private String createBy;     //备注的创建人
    private String editTime;     //备注的修改时间
    private String editBy;       //备注的修改人
    private String editFlag;     //是否修改过的标记
    private String activityId;   //外键 对应市场活动表的主键，表示对哪个市场活动进行备注

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getNoteContent() {
        return noteContent;
    }

    public void setNoteContent(String noteContent) {
        this.noteContent = noteContent;
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

    public String getEditFlag() {
        return editFlag;
    }

    public void setEditFlag(String editFlag) {
        this.editFlag = editFlag;
    }

    public String getActivityId() {
        return activityId;
    }

    public void setActivityId(String activityId) {
        this.activityId = activityId;
    }
}
