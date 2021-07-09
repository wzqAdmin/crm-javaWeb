package com.bjpowernode.crm.vo;

import java.util.List;

/**
 * 市场活动的vo类，目的是往前端传输数据
 * @param <T>泛型，可以指定任意类型,当指定了这个泛型后，类中的<T>都会和类上的保持一致
 *           增加了这个VO类的可重用性
 */
public class PaginationVO<T> {

    private int total;
    private List<T> dataList;

    public int getTotal() {
        return total;
    }

    public void setTotal(int total) {
        this.total = total;
    }

    public List<T> getDataList() {
        return dataList;
    }

    public void setDataList(List<T> dataList) {
        this.dataList = dataList;
    }
}
