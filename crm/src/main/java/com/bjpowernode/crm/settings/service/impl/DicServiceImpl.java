package com.bjpowernode.crm.settings.service.impl;

import com.bjpowernode.crm.settings.dao.DicTypeDao;
import com.bjpowernode.crm.settings.dao.DicValueDao;
import com.bjpowernode.crm.settings.domain.DicType;
import com.bjpowernode.crm.settings.domain.DicValue;
import com.bjpowernode.crm.settings.service.DicService;
import com.bjpowernode.crm.utils.SqlSessionUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DicServiceImpl implements DicService {

     private  DicTypeDao dicTypeDao= SqlSessionUtil.getSqlSession().getMapper(DicTypeDao.class);

     private DicValueDao dicValueDao= SqlSessionUtil.getSqlSession().getMapper(DicValueDao.class);

    public Map<String, List<DicValue>> getAll() {

        Map<String,List<DicValue>> map=new HashMap<String, List<DicValue>>();

        //获取所有的数据字典类型
        List<DicType> dtList = dicTypeDao.getTypeList();

        //循环List集合中的类型，每循环一次调用一次dicValueDao，取出对应该类型的value值
        for (DicType d:dtList){

            String typeCode = d.getCode();

            //根据外键typeCode，取出对应的值封装到List集合
            List<DicValue> dvList = dicValueDao.getListBytypeCode(typeCode);

            //以key等于typeCode，value等于List集合的形式循环存放到Map集合中
            map.put(typeCode+"List",dvList);

        }
        return  map;

    }
}
