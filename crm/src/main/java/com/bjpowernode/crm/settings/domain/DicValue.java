package com.bjpowernode.crm.settings.domain;

/**
 * 数据字典值(tbl_dic_value)的实体类，它与数据字典类型表时一对多的关系
 * 一个类型可以对应多个值，一个值只能从属于一个类型
 */
public class DicValue {

    private String id;       //主键 唯一标识一个值
    private String value;    //表单的value属性
    private String text;     //在前端展示的文本
    private String orderNo;  //展现顺序
    private String typeCode; //外键  关联类型表，表示这个值输入哪个类型

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getOrderNo() {
        return orderNo;
    }

    public void setOrderNo(String orderNo) {
        this.orderNo = orderNo;
    }

    public String getTypeCode() {
        return typeCode;
    }

    public void setTypeCode(String typeCode) {
        this.typeCode = typeCode;
    }
}
