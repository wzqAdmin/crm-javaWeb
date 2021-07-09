package com.bjpowernode.crm.settings.domain;

/**
 * 数据字典类型表(tbl_dic_type)的实体类
 */
public class DicType {

    private String code;        //主键 以英文单词命名，如source代表来源的意思
    private String name;        //类型名
    private String description; //类型的描述

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
